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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Glossary"
        extendedLayoutIncludesOpaqueBars = true
        navigationItem.largeTitleDisplayMode = .never

        tableView.dataSource = dataSource
        tableView.register(GlossaryTableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}
