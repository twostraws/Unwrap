//
//  CoordinatorLocating.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

extension UIResponder {
    /// It's very, very rare, but sometimes some view deep down in our hierarchy needs to find whatever coordinator is ultimately responsible for the current display. This method navigates upwards from a view to whatever coordinator is ultimately responsible for it.
    func findCoordinator() -> Coordinator? {
        if let nextResponder = self.next as? CoordinatedNavigationController {
            return nextResponder.coordinator
        } else if let nextResponder = self.next as? UIViewController {
            return nextResponder.findCoordinator()
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findCoordinator()
        } else {
            return nil
        }
    }
}
