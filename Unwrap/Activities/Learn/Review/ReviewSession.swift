//
//  ReviewSession.swift
//  Unwrap
//

import Foundation

struct ReviewSession: Equatable {
    static let singleQuestionCount = 8

    let content: ReviewContent
    private(set) var candidates: [ReviewCandidate]
    private(set) var currentIndex = 0
    private(set) var selectedTruth: Bool?
    private(set) var selectedCandidateIDs = Set<String>()
    private(set) var isShowingAnswer = false

    var currentCandidate: ReviewCandidate? {
        guard candidates.indices.contains(currentIndex) else { return nil }
        return candidates[currentIndex]
    }

    var questionNumber: Int {
        guard content.kind == .singleSelection, candidates.isEmpty == false else { return 0 }
        return currentIndex + 1
    }

    var canSkip: Bool {
        isShowingAnswer == false
    }

    var submittedAnswerWasCorrect: Bool? {
        guard isShowingAnswer else { return nil }

        switch content.kind {
        case .singleSelection:
            guard let selectedTruth, let currentCandidate else { return nil }
            return selectedTruth == currentCandidate.isCorrect
        case .multipleSelection:
            let correctIDs = Set(candidates.filter(\.isCorrect).map(\.id))
            return selectedCandidateIDs == correctIDs
        }
    }

    init(content: ReviewContent, random: any RandomProviding) {
        self.content = content

        let correct = content.correct.map { ReviewCandidate(answer: $0, isCorrect: true) }
        let wrong = content.wrong.map { ReviewCandidate(answer: $0, isCorrect: false) }
        let shuffledCandidates = random.shuffled(correct + wrong)

        if content.kind == .singleSelection {
            candidates = Array(shuffledCandidates.prefix(Self.singleQuestionCount))
        } else {
            candidates = shuffledCandidates
        }
    }

    mutating func answerCurrent(_ selectedTrue: Bool) {
        guard content.kind == .singleSelection,
              isShowingAnswer == false,
              currentCandidate != nil else {
            return
        }

        selectedTruth = selectedTrue
        isShowingAnswer = true
    }

    mutating func toggleSelection(for id: String) {
        guard content.kind == .multipleSelection,
              isShowingAnswer == false,
              candidates.contains(where: { $0.id == id }) else {
            return
        }

        if selectedCandidateIDs.contains(id) {
            selectedCandidateIDs.remove(id)
        } else {
            selectedCandidateIDs.insert(id)
        }
    }

    mutating func submitMultipleSelection() {
        guard content.kind == .multipleSelection, isShowingAnswer == false else { return }
        isShowingAnswer = true
    }

    /// Advances a single-selection review, returning true when all questions are complete.
    mutating func advance() -> Bool {
        guard content.kind == .singleSelection, isShowingAnswer else { return false }

        if currentIndex + 1 < candidates.count {
            currentIndex += 1
            selectedTruth = nil
            isShowingAnswer = false
            return false
        }

        return true
    }

    func isSelected(_ candidate: ReviewCandidate) -> Bool {
        selectedCandidateIDs.contains(candidate.id)
    }
}
