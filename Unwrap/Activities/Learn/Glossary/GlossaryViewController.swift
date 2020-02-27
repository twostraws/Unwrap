//
//  GlossaryViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/01/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class GlossaryViewController: UITableViewController {
    let dataSource = GlossaryDataSource()

    let noResultsLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Glossary"
        extendedLayoutIncludesOpaqueBars = true
        navigationItem.largeTitleDisplayMode = .never

        dataSource.delegate = self
        tableView.dataSource = dataSource
        tableView.register(GlossaryTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView() // Remove separator lines when search has no results

        setupNoResultsLabel()
        setupSearchController()
    }

    func setupNoResultsLabel() {
        noResultsLabel.text = "No Results"
        noResultsLabel.font = Unwrap.scaledBoldFont
        noResultsLabel.isHidden = true

        view.addSubview(noResultsLabel)
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        noResultsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = dataSource
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    func searchPerformed(noResults: Bool) {
        tableView.reloadData()
        noResultsLabel.isHidden = !noResults
    }

}
