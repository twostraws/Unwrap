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
    // custom connections for the image view, title, and subtitle
    @IBOutlet var customImageView: UIImageView!
    @IBOutlet var customTextLabel: UILabel!
    @IBOutlet var customDetailTextLabel: UILabel!

    /// The dot beside the image indicating if the article has been read or not.
    @IBOutlet weak var readNotification: UILabel!

    // send back our custom image view in place of the default image view
    override var imageView: UIImageView? {
        return customImageView
    }

    // send back our custom text label in place of the default text label
    override var textLabel: UILabel? {
        return customTextLabel
    }

    // send back our custom detail text label in place of the default detail text label
    override var detailTextLabel: UILabel? {
        return customDetailTextLabel
    }
}
