//
//  ChallengesView.swift
//  Unwrap
//

import SwiftUI

struct ChallengesView: View {
    let model: ChallengesModel
    @State private var isChallengeSelected: Bool?

    var body: some View {
        NavigationSplitView {
            List(selection: $isChallengeSelected) {
                Section("Today's challenge") {
                    if model.hasCompletedToday, model.awardModel == nil {
                        VStack(alignment: .leading) {
                            Text("Come Back Tomorrow")
                                .font(.title)
                            Text("Each daily challenge may be attempted only once.")
                        }
                    } else {
                        NavigationLink(value: true) {
                            VStack(alignment: .leading) {
                                Text(model.todayTitle)
                                    .font(.title)
                                Text("Each daily challenge may be attempted only once.")
                            }
                        }
                    }
                }

                Section {
                    if model.history.isEmpty {
                        Text("No completed challenges yet")
                    } else {
                        ForEach(model.history) { result in
                            ChallengeHistoryRow(result: result)
                                .swipeActions {
                                    Button("Delete", role: .destructive) {
                                        model.delete(result)
                                    }
                                }
                        }
                    }
                } header: {
                    Text("Previous challenges")
                } footer: {
                    if model.history.isEmpty == false {
                        Text("Tap any date to share your score.")
                    }
                }
            }
            .navigationTitle("Challenges")
        } detail: {
            if let awardModel = model.awardModel {
                AwardView(model: awardModel) {
                    model.continueAfterAward()
                    isChallengeSelected = nil
                }
            } else if let session = model.session, let question = model.question {
                ChallengeSessionView(
                    model: model,
                    session: session,
                    question: question
                ) {
                    isChallengeSelected = nil
                }
            } else {
                PleaseSelectView(
                    prompt: model.hasCompletedToday
                        ? "Come back tomorrow"
                        : "Start today's challenge when you're ready"
                )
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: isChallengeSelected) { _, isSelected in
            if isSelected == true {
                if model.startChallenge() == false {
                    isChallengeSelected = nil
                }
            } else if model.awardModel == nil {
                model.abandonChallenge()
            }
        }
        .alert("Unable to Continue", isPresented: questionErrorPresentation) {
            Button("OK", role: .cancel) {
                model.clearQuestionError()
                isChallengeSelected = nil
            }
        } message: {
            Text(model.questionError ?? "The challenge question could not be loaded.")
        }
    }

    private var questionErrorPresentation: Binding<Bool> {
        Binding(
            get: { model.questionError != nil },
            set: { isPresented in
                if isPresented == false {
                    model.clearQuestionError()
                }
            }
        )
    }
}
