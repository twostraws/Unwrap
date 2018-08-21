//
//  UIScrollView-ProgrammaticScrolling.swift
//  Unwrap
//
//  Created by Ian Manor on 21/08/18.
//  Copyright © 2018 Hacking with Swift. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    var scrolledToTop: Bool {
        let topEdge = 0 - contentInset.top
        return contentOffset.y <= topEdge
    }
    
    /// Animates scrolling to top of scrollview
    func scrollToTop(maxNavBarHeight: CGFloat) {
        self.setContentOffset(CGPoint(x: 0.0, y: -self.adjustedContentInset.top - maxNavBarHeight), animated: true)
    }
}
