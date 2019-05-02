//
//  UISplitViewController-NavigationController.swift
//  Unwrap
//
//  Created by Paul Hudson on 02/05/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

extension UISplitViewController {
    func popToRootViewController(animated: Bool) {
        if let masterViewController = viewControllers.first as? UINavigationController {
            masterViewController.popViewController(animated: animated)
        }
    }
}
