//
//  CoordinatedNavigationController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A navigation controller that is aware of its coordinator. This is used extremely rarely through UIResponder-Coordinated.swift, for when we need to find the coordinator responsible for a specific view.
class CoordinatedNavigationController: UINavigationController {
    weak var coordinator: Coordinator?

    override init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        extendedLayoutIncludesOpaqueBars = true
        navigationBar.isTranslucent = false
    }

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        extendedLayoutIncludesOpaqueBars = true
        navigationBar.isTranslucent = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        extendedLayoutIncludesOpaqueBars = true
        navigationBar.isTranslucent = false
    }
}
