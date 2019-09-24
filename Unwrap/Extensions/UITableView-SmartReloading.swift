//
//  UITableView-SmartReloading.swift
//  Unwrap
//
//  Created by Paul Hudson on 24/09/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

extension UITableView {
    /// Reloads a table view without losing track of what was selected.
    func reloadDataSavingSelections() {
        let selectedRows = indexPathsForSelectedRows

        reloadData()

        if let selectedRow = selectedRows {
            for indexPath in selectedRow {
                selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
}
