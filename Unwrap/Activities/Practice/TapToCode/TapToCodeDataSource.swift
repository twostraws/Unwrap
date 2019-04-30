//
//  TapToCodeDataSource.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Manages all the rows in the Tap to Code table view. A huge chunk of this is just handling the UIKit collection view drag and drop work.
class TapToCodeDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDragDelegate, UICollectionViewDropDelegate, UICollectionViewDelegateFlowLayout {
    weak var delegate: TapToCodeViewController?

    /// The collection view that stores the code components they have used.
    var usedWordsCollectionView: UICollectionView!

    /// The collection view that stores the code components they have not yet used.
    var allWordsCollectionView: UICollectionView!

    /// An internal data model to help us manage the actual storage of code blocks separately from all the drag and drop mess.
    private var model: TapToCodeModel!

    /// The user-facing question explaining what is needed.
    var question = ""

    /// Any code we should show before the user-replaceable code.
    var existingCode = ""

    /// Stores whether we are currently showing the question or the showing the answers.
    var isShowingAnswers = false

    /// Stores whether the user is able to check their answer – becomes true when all code components have been used.
    var readyToCheck: Bool {
        return model.allWords.isEmpty
    }

    /// Returns whether the user has used all the code correctly or not.
    var isUserCorrect: Bool {
        return model.isUserCorrect
    }

    init(practiceData: TapToCodePractice, usedWordsCollectionView: UICollectionView, allWordsCollectionView: UICollectionView) {
        self.usedWordsCollectionView = usedWordsCollectionView
        self.allWordsCollectionView = allWordsCollectionView

        // Resolve any placeholders, ensuring that the code we show users looks a little different each time.
        let resolvedQuestion = practiceData.question.resolvingPlaceholders()
        question = resolvedQuestion.output

        // Resolve placeholders in our existing code, using whatever we resolved above.
        let resolvedCode = practiceData.existingCode.resolvingPlaceholders(names: resolvedQuestion.names, namesNatural: resolvedQuestion.namesNatural, values: resolvedQuestion.values, operators: resolvedQuestion.operators)
        existingCode = resolvedCode.output

        // Send all that over to our model so that it can track the data for us.
        model = TapToCodeModel(practiceData: practiceData, names: resolvedCode.names, namesNatural: resolvedCode.namesNatural, values: resolvedCode.values, operators: resolvedCode.operators)
    }

    // Calculate every word size by hand, because autosizing cells + drag and drop doesn't work well.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return model.sizeForWord(in: collectionView, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.count(for: collectionView)
    }

    // Style each cell normally, as a correct answer, or as a wrong answer.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? WordCollectionViewCell else {
            fatalError("Failed to dequeue a WordCollectionViewCell.")
        }

        cell.textLabel.text = model.word(for: collectionView, at: indexPath)

        if isShowingAnswers {
            if isUserCorrect {
                cell.correctAnswer()
            } else {
                cell.wrongAnswer()
            }
        }

        return cell
    }

    // When we start dragging (from either collection view), store the index path we're coming from.
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let word = model.word(for: collectionView, at: indexPath)
        let itemProvider = NSItemProvider(object: word as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = indexPath
        return [dragItem]
    }

    /// When we drop a word (only happens on the top collection view), then we're either moving it around or dragging it from bottom to top.
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        // Make sure we have an item in the drop coordinator.
        guard let item = coordinator.items.first else { return }

        // …and make sure we can read the original index path it came from.
        guard let originalIndexPath = item.dragItem.localObject as? IndexPath else { return }

        // Now update the collection views.
        collectionView.performBatchUpdates({
            let destinationIndexPath: IndexPath

            if let sourceIndexPath = item.sourceIndexPath {
                // we moved used words around
                // Use the destination index path if we have one, or insert the word at the end of our used words collection view.
                destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: model.count(for: usedWordsCollectionView) - 1, section: 0)
                model.rearrange(sourceIndexPath, to: destinationIndexPath)
                collectionView.deleteItems(at: [sourceIndexPath])
            } else {
                // we dragged a word from all to used
                // Use the destination index path if we have one, or insert the word at the end of our used words collection view.
                destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: model.count(for: usedWordsCollectionView), section: 0)
                model.moveToUsed(originalIndexPath, to: destinationIndexPath)
                allWordsCollectionView?.deleteItems(at: [originalIndexPath])
            }

            collectionView.insertItems(at: [destinationIndexPath])

            // animate the drop completion…
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        })

        // …and notify the delegate so it can update the UI.
        delegate?.usedWordsChanged(to: model.count(for: usedWordsCollectionView))
    }

    // Our drop sessions are always insertions so that other items move to make space.
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    // Tapping words either moves from them fro used to all, or from all to used.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == usedWordsCollectionView {
            // We're moving a word from used to all.
            let destinationIndexPath = IndexPath(item: model.count(for: allWordsCollectionView), section: 0)
            model.moveToAll(indexPath, to: destinationIndexPath)
            usedWordsCollectionView?.deleteItems(at: [indexPath])
            allWordsCollectionView?.insertItems(at: [destinationIndexPath])
        } else {
            // We're moving a word from all to used.
            let destinationIndexPath = IndexPath(item: model.count(for: usedWordsCollectionView), section: 0)
            model.moveToUsed(indexPath, to: destinationIndexPath)
            allWordsCollectionView?.deleteItems(at: [indexPath])
            usedWordsCollectionView?.insertItems(at: [destinationIndexPath])
        }

        // Notify the delegate so it can update the UI.
        delegate?.usedWordsChanged(to: model.count(for: usedWordsCollectionView))
    }
}
