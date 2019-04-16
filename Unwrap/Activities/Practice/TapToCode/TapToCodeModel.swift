//
//  TapToCodeModel.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// This is a private struct used by TapToCodeDataSource to handle the actual underlying data. The data source is there to manipulate this model with actual collection views.
struct TapToCodeModel {
    /// The current question they are solving, along with hints and solutions.
    var practiceData: TapToCodePractice

    /// The code order that is correct.
    var correctWords = [String]()

    /// The code order that the user has currently arranged.
    var usedWords = [String]()

    /// The code order that is currently unused.
    var allWords = [String]()

    /// Returns true when the user has arranged all their words correctly.
    var isUserCorrect: Bool {
        return usedWords == correctWords
    }

    init(practiceData: TapToCodePractice, names: [String], namesNatural: [String], values: [String], operators: [String]) {
        self.practiceData = practiceData

        // Resolve any placeholders in our code components.
        for component in practiceData.components {
            let resolved = component.resolvingPlaceholders(names: names, namesNatural: namesNatural, values: values, operators: operators)
            correctWords.append(resolved.output)
        }

        // Keep shuffling the words until allWords is different from correctWords.
        repeat {
            allWords = correctWords.shuffled()
        } while allWords == correctWords
    }

    /// Return the correct count for each collection view.
    func count(for collectionView: UICollectionView) -> Int {
        if collectionView is AllWordsCollectionView {
            return allWords.count
        } else {
            return usedWords.count
        }
    }

    /// Return the correct word for a given collection view.
    func word(for collectionView: UICollectionView, at indexPath: IndexPath) -> String {
        if collectionView is AllWordsCollectionView {
            return allWords[indexPath.item]
        } else {
            return usedWords[indexPath.item]
        }
    }

    /// Called when we move a word from one part of used words to another part of used words.
    mutating func rearrange(_ sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let word = usedWords[sourceIndexPath.item]
        usedWords.remove(at: sourceIndexPath.item)
        usedWords.insert(word, at: destinationIndexPath.item)
    }

    /// Called when we move a word from the all words array to the used words array.
    mutating func moveToUsed(_ sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let word = allWords[sourceIndexPath.item]
        allWords.remove(at: sourceIndexPath.item)
        usedWords.insert(word, at: destinationIndexPath.item)
    }

    /// Called when we move a word from the used words array to the all words array.
    mutating func moveToAll(_ sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let word = usedWords[sourceIndexPath.item]
        usedWords.remove(at: sourceIndexPath.item)
        allWords.insert(word, at: destinationIndexPath.item)
    }

    /// Calculate the size for each collection view cell by hand, adding a little space around the size of each word.
    func sizeForWord(in collectionView: UICollectionView, at indexPath: IndexPath) -> CGSize {
        let currentWord = word(for: collectionView, at: indexPath)
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        let attrib = NSAttributedString(string: currentWord, attributes: attrs)
        let size = attrib.size()
        return CGSize(width: size.width + 40, height: size.height + 30)
    }
}
