//
//  NewsTableViewCell.swift
//  Unwrap
//
//  Created by Michael Charland on 2019-04-02.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

/// Represents a row in the News table view that contains an article to read.
class NewsTableViewCell: UITableViewCell {

    /// The little splat beside the image indicating if the article has been read or not.
    @IBOutlet weak var readNotification: UILabel!
}
