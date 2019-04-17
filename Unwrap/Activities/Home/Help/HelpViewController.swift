//
//  HelpViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

class HelpViewController: UITableViewController, Storyboarded, TappableTextViewDelegate {
    var coordinator: HomeCoordinator?
    var dataSource = HelpDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")

        title = "Help"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: coordinator, action: #selector(HomeCoordinator.showCredits))

        tableView.dataSource = dataSource
        dataSource.delegate = self
    }

    func linkTapped(_ url: URL) {
        coordinator?.open(url)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = dataSource.item(at: indexPath.section)

        switch item.action {
        case "showTour":
            coordinator?.showTour()

        default:
            break
        }
    }
}
