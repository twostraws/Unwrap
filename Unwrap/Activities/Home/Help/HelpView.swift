//
//  HelpView.swift
//  Unwrap
//

import SwiftUI

struct HelpView: View {
    @Environment(User.self) private var user
    @State private var isResetConfirmationPresented = false

    let items: [HelpItem]
    let showTour: () -> Void
    let openWebURL: (URL) -> Void

    var body: some View {
        List {
            ForEach(items.enumerated(), id: \.offset) { _, item in
                Section(item.title) {
                    if item.action.isEmpty {
                        MarkdownText(markdown: item.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Button {
                            perform(item.action)
                        } label: {
                            MarkdownText(markdown: item.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(Color("BrandPrimary"))
                    }
                }
            }
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink("Credits", value: HomeRoute.credits)
            }
        }
        .environment(\.openURL, OpenURLAction { url in
            if url.scheme == "http" || url.scheme == "https" {
                openWebURL(url)
                return .handled
            }

            return .systemAction
        })
        .alert("Reset data", isPresented: $isResetConfirmationPresented) {
            Button("Reset", role: .destructive) {
                user.resetProgress()
            }
            Button("Cancel", role: .cancel) {
            }
        }
    }

    private func perform(_ action: String) {
        switch action {
        case "showTour":
            showTour()
        case "resetProgress":
            isResetConfirmationPresented = true
        default:
            break
        }
    }
}
