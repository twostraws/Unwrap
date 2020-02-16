//
//  TourPageViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

class TourPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    weak var pageChangeDelegate: TourHostViewController?
    var allViewControllers = [UIViewController]()

    /// Loads all our tour items into the page view controller and tells the delegate how many we have.
    override func viewDidLoad() {
        super.viewDidLoad()

        let items = Bundle.main.decode([TourItem].self, from: "Tour.json")

        for item in items {
            let viewController = TourItemViewController.instantiate()
            viewController.item = item
            allViewControllers.append(viewController)
        }

        setViewControllers([allViewControllers[0]], direction: .forward, animated: false)
        dataSource = self
        delegate = self

        pageChangeDelegate?.setPageCount(to: allViewControllers.count)
    }

    /// Returns the previous tour item if there is one.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = allViewControllers.firstIndex(of: viewController) else { return nil }

        if currentIndex > 0 {
            return allViewControllers[currentIndex - 1]
        } else {
            return nil
        }
    }

    /// Returns the next tour item if there is one.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = allViewControllers.firstIndex(of: viewController) else { return nil }

        if currentIndex < allViewControllers.count - 1 {
            return allViewControllers[currentIndex + 1]
        } else {
            return nil
        }
    }

    /// Called when the user scrolls between pages; tells the delegate so it can update the rest of the UI.
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }

        guard let activeViewController = viewControllers?.last else { return }
        guard let page = allViewControllers.firstIndex(of: activeViewController) else { return }

        pageChangeDelegate?.pageChanged(to: page)
    }
}
