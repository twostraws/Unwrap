//
//  ShareScore.swift
//  Unwrap
//
//  Created by Mohammed mohsen on 2/25/21.
//  Copyright © 2021 Hacking with Swift. All rights reserved.
//

import Foundation
import UIKit

struct ShareScore: Shareable {
    var navigationController: UINavigationController?
    let sourceRect: CGRect
    var textToShare: Reader
    // the same thing here could be! which's make every share has its own text!
    // dependency injection
//    let shareReader: ShareScoreRead
    
    // share the score of the user!
    init(sourceRect: CGRect, shareWhat: Reader) {
        self.sourceRect = sourceRect
        self.textToShare = shareWhat
    }
    func share() {
        let image = User.current.rankImage.imageForSharing
        
        // now what's wrong with that?
        

        // even this alert creation should be independently clear!
        let alert = UIActivityViewController.buildAlert(text: textToShare, image: image)
        
        alert.completionWithItemsHandler = handleScoreSharingResult
        
        // if we're on iPad there is nowhere sensible to anchor this from, so just center it
        if let popOver = alert.popoverPresentationController {
            popOver.sourceView = navigationController?.topViewController?.view
            popOver.sourceRect = sourceRect
        }
        navigationController?.present(alert, animated: true)
    }
    func handleScoreSharingResult(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) {
        guard completed == true else { return }
        
        if activityType == .postToFacebook || activityType == .postToTwitter {
            User.current.sharedScore()
        }
    }
    
}
