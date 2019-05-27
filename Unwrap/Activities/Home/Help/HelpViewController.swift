//
//  HelpViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

class HelpViewController: UITableViewController, TappableTextViewDelegate {
    var coordinator: HomeCoordinator?
    var dataSource = HelpDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")

        title = "Help"
        navigationItem.largeTitleDisplayMode = .never

        if UIDevice.current.userInterfaceIdiom == .pad {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))

        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        dataSource.coordinator = coordinator
        dataSource.delegate = self

        tableView.separatorStyle = .none
        tableView.register(HelpTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(DynamicHeightHeaderView.self, forHeaderFooterViewReuseIdentifier: "SectionHeader")
    }

    func linkTapped(_ url: URL) {
        coordinator?.open(url)

        if UIDevice.current.userInterfaceIdiom == .pad {
            // if we're on iPad we should dismiss the modal view controller immediately so the user can browse the link they chose.
            dismiss(animated: true)
        }
    }

    @objc func doneTapped() {
        dismiss(animated: true)
    }

    /// Show the app credits. This cannot be done using the coordinator, because on iPhone we use the coordinator's navigation controller, but on iPad we run in a modal window with our own navigation controller.
    @objc func showCredits() {
        let credits = CreditsViewController()
        credits.coordinator = coordinator
        navigationController?.pushViewController(credits, animated: true)
    }
}
