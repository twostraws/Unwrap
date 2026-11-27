//
//  PracticeView.swift
//  Unwrap
//

import SwiftUI

struct PracticeView: View {
    @Environment(User.self) private var user
    @State private var showsBlankPractice = false
    @State private var selectedKind: PracticeKind?
    @State private var session: PracticeSession?
    @State private var alertTitle = "Practice Unavailable"
    @State private var errorMessage: String?
    #if DEBUG
    @State private var debugUnlocksEnabled = false
    #endif

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedKind) {
                Button("Fill in the Blank", systemImage: "text.cursor") {
                    showsBlankPractice = true
                }
                ForEach(PracticeKind.allCases) { kind in
                    if isUnlocked(kind) {
                        NavigationLink(value: kind) {
                            PracticeCatalogRow(kind: kind, isUnlocked: true)
                        }
                    } else {
                        Button {
                            showLockedAlert(for: kind)
                        } label: {
                            PracticeCatalogRow(kind: kind, isUnlocked: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Practice")
            #if DEBUG
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(debugUnlocksEnabled ? "Debug: On" : "Debug: Off") {
                        finishSession()
                        debugUnlocksEnabled.toggle()
                    }
                    .accessibilityIdentifier("practice.debugUnlocks")
                    .accessibilityHint("Debug only. Unlocks every activity; unlocked practice does not save progress.")
                }
            }
            #endif
        } detail: {
            if let session {
                PracticeSessionView(
                    session: session,
                    exitAction: finishSession
                )
            } else {
                PleaseSelectView(prompt: "Please select a practice activity to begin")
            }
        }
        .sheet(isPresented: $showsBlankPractice) {
            NavigationStack { BlankPracticeView() }
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: selectedKind) { _, selectedKind in
            if let selectedKind {
                start(selectedKind)
            } else if session != nil {
                finishSession()
            }
        }
        .alert(
            alertTitle,
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { isPresented in
                    if isPresented == false {
                        errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "Practice could not be loaded.")
        }
    }

    private func start(_ kind: PracticeKind) {
        guard isUnlocked(kind) else {
            showLockedAlert(for: kind)
            return
        }

        do {
            alertTitle = "Practice Unavailable"
            errorMessage = nil
            #if DEBUG
            if debugUnlocksEnabled {
                session = try PracticeSession.unlockedForDebug(
                    kind: kind,
                    user: user,
                    randomSource: SystemRandomSource()
                )
                return
            }
            #endif
            session = try PracticeSession(
                kind: kind,
                user: user,
                randomSource: SystemRandomSource()
            )
        } catch {
            alertTitle = "Practice Unavailable"
            errorMessage = error.localizedDescription
            selectedKind = nil
            session = nil
        }
    }

    private func isUnlocked(_ kind: PracticeKind) -> Bool {
        #if DEBUG
        if debugUnlocksEnabled {
            return true
        }
        #endif
        return kind.isUnlocked(for: user)
    }

    private func showLockedAlert(for kind: PracticeKind) {
        alertTitle = "Activity Locked"
        errorMessage = kind.lockedMessage
        selectedKind = nil
        session = nil
    }

    private func finishSession() {
        selectedKind = nil
        session = nil
    }
}
