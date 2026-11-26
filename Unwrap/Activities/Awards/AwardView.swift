//
//  AwardView.swift
//  Unwrap
//

import SwiftUI

struct AwardView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var displayedEarnedPoints = 0
    @State private var displayedRankTotal: Int
    @State private var displayedTotal: Int
    @State private var levelUpFeedback = 0

    let model: AwardModel
    let continueAction: () -> Void

    init(model: AwardModel, continueAction: @escaping () -> Void) {
        self.model = model
        _displayedRankTotal = State(initialValue: model.startingTotal)
        _displayedTotal = State(initialValue: model.startingTotal)
        self.continueAction = continueAction
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("UnwrapGradientTop"), Color("UnwrapGradientBottom")],
                startPoint: .top,
                endPoint: .bottom
            )
            // Fill behind the bars, but stop at the sidebar rather than running underneath it.
            .ignoresSafeArea(edges: [.top, .bottom, .trailing])

            VStack(spacing: 0) {
                Text("Your Progress")
                    .font(.system(size: 42))
                    .bold()
                    .padding(.bottom, 20)

                RankProgressView(
                    totalPoints: displayedRankTotal,
                    style: .award
                )
                .frame(width: 250, height: 200)
                .padding(.bottom, 20)

                VStack(spacing: 0) {
                    Text("TOTAL")
                        .font(.body)

                    Text(displayedTotal, format: .number)
                        .font(.largeTitle)
                }

                VStack(spacing: 0) {
                    Text("EARNED")
                        .font(.body)

                    Text(displayedEarnedPoints, format: .number)
                        .font(.largeTitle)
                }
                .padding(.top, 30)

                if horizontalSizeClass != .regular {
                    Text("TAP TO CONTINUE")
                        .font(.headline)
                        .padding(.top, 35)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 30)
        }
        .foregroundStyle(.white)
        .overlay {
            Button(action: continueAction) {
                Color.clear
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Continue")
        }
        .task {
            await presentAward()
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: levelUpFeedback)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(horizontalSizeClass == .regular ? .automatic : .hidden, for: .tabBar)
    }

    private func presentAward() async {
        if reduceMotion {
            displayedRankTotal = model.endingTotal
            displayedTotal = model.endingTotal
            displayedEarnedPoints = model.earnedPoints

            if model.crossesLevelBoundary {
                levelUpFeedback += 1
            }

            return
        }

        do {
            try await Task.sleep(for: .milliseconds(500))
        } catch {
            return
        }

        displayedRankTotal = model.endingTotal

        let frameCount = 60

        for frame in 1...frameCount {
            guard Task.isCancelled == false else { return }

            do {
                try await Task.sleep(for: .seconds(1.0 / Double(frameCount)))
            } catch {
                return
            }

            let progress = Double(frame) / Double(frameCount)
            let earnedPoints = Int((Double(model.earnedPoints) * progress).rounded())
            displayedEarnedPoints = earnedPoints
            displayedTotal = model.startingTotal + earnedPoints
        }

        displayedTotal = model.endingTotal
        displayedEarnedPoints = model.earnedPoints

        if model.crossesLevelBoundary {
            do {
                try await Task.sleep(for: .milliseconds(500))
            } catch {
                return
            }

            levelUpFeedback += 1
        }
    }
}
