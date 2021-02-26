//
//  ShareBadge.swift
//  Unwrap
//
//  Created by Mohammed mohsen on 01/07/1442 AH.
//  Copyright © 1442 Hacking with Swift. All rights reserved.
//

import Foundation
import UIKit


struct ShareBadge : Shareable {
    var navigationController: UINavigationController?
    let badge: Badge
    var textToShare: Reader
    
    init(badge: Badge, textToShare: Reader) {
        self.badge = badge
        self.textToShare = textToShare
    }
    
    
    /// Share a specific badge the user earned.
    func share() {
        // so its factory or 'Builder'!
        let image = badge.image.imageForSharing
   
        let alert = UIActivityViewController.buildAlert(text: textToShare, image: image)
        // if we're on iPad there is nowhere sensible to anchor this from, so just center it
        if let popOver = alert.popoverPresentationController {
            popOver.sourceView = navigationController?.view
            let midX = navigationController?.view.frame.midX
            let midY = navigationController?.view.frame.midY
            let width: CGFloat = 0
            let height: CGFloat = 0
            popOver.sourceRect = CGRect(x: midX!, y: midY!, width: width, height: height)
        }
        navigationController?.present(alert, animated: true)
    }
}


extension ShareBadge {
    
    
    init(nav: UINavigationController, badge: Badge, text: Reader) {
        self.init(badge: badge, textToShare: text)
        navigationController = nav
    }
}

extension UIActivityViewController {// here another problem!
    static func buildAlert(text readI: Reader, image: UIImage) -> UIActivityViewController {
        let alert = UIActivityViewController(activityItems: [readI.reader(), image], applicationActivities: nil)
        return alert
    }
}
//
//  ShareBadge.swift
//  Unwrap
//
//  Created by Mohammed mohsen on 2/25/21.
//  Copyright © 2021 Hacking with Swift. All rights reserved.
//

import Foundation
