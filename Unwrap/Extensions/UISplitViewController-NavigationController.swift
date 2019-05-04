//
//  UISplitViewController-NavigationController.swift
//  Unwrap
//
//  Created by Paul Hudson on 02/05/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

extension UISplitViewController {
    func popToRootViewController() {
        if let masterViewController = self.viewControllers.first as? UINavigationController {
            // This next line is what we want to do, but it does *not* work – UIKit gets confused because our adaptive layout pushes navigation controllers around a lot, and we end up with layout trouble when looking at True/False review tests e.g. multi-line strings.
            // masterViewController.popToRootViewController(animated: false)

            // This next line is effectively the same thing, but it actually works
            if let first = masterViewController.viewControllers.first {
                masterViewController.viewControllers = [first]
            }
        }
    }
}
