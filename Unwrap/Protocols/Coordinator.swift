//
//  Coordinator.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// Used to dictate the basics of all coordinators in the app.
protocol Coordinator: AnyObject {
//    var navigationController: CoordinatedNavigationController { get set }
    var splitViewController: UISplitViewController { get set }
}
