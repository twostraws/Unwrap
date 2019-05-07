//
//  NewsViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// The view controller you see in the News tab in the app.
class NewsViewController: UITableViewController, UIViewControllerPreviewingDelegate {
    var coordinator: NewsCoordinator?

    /// This handles all the rows in our table view, including downloading news.
    var dataSource = NewsDataSource()

    /// This handles showing something meaningful if news download failed.
    var emptyDataSource = NewsEmptyDataSource()

    /// The article that has selected by a 3D touch.
    var currentSelectedArticle: NewsArticle!

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")

        title = "News"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Buy Swift Books", style: .plain, target: coordinator, action: #selector(NewsCoordinator.buyBooks))

        dataSource.delegate = self
        tableView.dataSource = dataSource
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: "Cell")

        // Configure DZNEmptyDataSource to show a meaningful message when news loading fails. We need to create an empty table footer view to stop separators appearing everywhere.
        tableView.emptyDataSetSource = emptyDataSource
        tableView.emptyDataSetDelegate = emptyDataSource
        tableView.tableFooterView = UIView()
        emptyDataSource.delegate = self

        registerForPreviewing(with: self, sourceView: tableView)

        // Allow folks to pull to refresh stories. Honestly, this will never actually do anything because it's not like I publish *that* often, but it's a bit like close buttons on an elevator – people expect them to work.
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(fetchArticles), for: .valueChanged)

        // Start fetching news articles as soon as we're loaded.
        fetchArticles()
    }

    /// Clears our tab badge as soon as we're shown.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarItem.badgeValue = nil
        dataSource.containsNewArticles = false
    }

    /// Tell the delegate we need to fetch articles immediately.
    @objc func fetchArticles() {
        dataSource.fetchArticles()
    }

    /// Called as soon as our data source has finished its news download, so we can update the UI.
    func finishedLoadingArticles() {
        tableView.reloadData()
        refreshControl?.endRefreshing()

        // if we aren't currently visible, show a star
        if tabBarController?.selectedViewController != navigationController {
            if dataSource.containsNewArticles {
                tabBarItem.badgeValue = "★"
            }
        }
    }

    /// Called when the user selects a news story.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = dataSource.article(at: indexPath.row)
        coordinator?.read(article)
        tableView.reloadData()
    }

    /// Called when the user 3D touches on a news story.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            currentSelectedArticle = dataSource.article(at: indexPath.row)
            return coordinator?.articleViewController(for: currentSelectedArticle)
        }

        return nil
    }

    /// Called when the user 3D touches harder on a news story.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        coordinator?.startReading(using: viewControllerToCommit, withURL: currentSelectedArticle.url)
        tableView.reloadData()
    }
}
