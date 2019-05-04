//
//  SplitViewControllerDelegate.swift
//  Unwrap
//
//  Created by Paul Hudson on 02/05/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class SplitViewControllerDelegate: UISplitViewControllerDelegate {
    static let shared = SplitViewControllerDelegate()

    private init() { }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

/// A UISplitViewController that refuses to work in landscape on iPhone. If we used a regular UISplitViewController, then: select a topic from the Learn tab, play the movie, rotate to landscape, then close the movie – you'll find yourself back on the Learn tab rather than in the topic you were reading. This is because as the movie rotates to landscape so does the split view controller behind it, and when the movie exits and we return to portrait mode the split view controller delegate tries to collapse the secondary onto the primary. We ask to keep the primary, because without that the first screen the user sees is wrong, but that causes the behavior where we lose the study screen.
class PortraitSplitViewController: UISplitViewController {
    override var traitCollection: UITraitCollection {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return super.traitCollection
        } else {
            let horizontal = UITraitCollection(horizontalSizeClass: .compact)
            return UITraitCollection.init(traitsFrom: [super.traitCollection, horizontal])
        }
    }
}
