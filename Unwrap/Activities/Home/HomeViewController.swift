//
//  HomeViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import StoreKit
import UIKit

/// The main view controller you see in  the Home tab in the app.
class HomeViewController: UICollectionViewController, Storyboarded, UserTracking {
    // MARK: - Properties

    var coordinator: HomeCoordinator?
    var dataSource = HomeDataSource()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(coordinator != nil, "You must set a coordinator before presenting this view controller.")

        title = "Home"
        registerForUserChanges()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = makeLayout()

        let helpButton = UIBarButtonItem(title: "Help", style: .plain, target: coordinator, action: #selector(HomeCoordinator.showHelp))
        navigationItem.rightBarButtonItem = helpButton
    }

    /// When running on a real device for a user that has been using the app for a while, this prompts for a review.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        #if DEBUG
            // showing the review request thing while debugging is annoying, so we'll just do nothing instead
        #else
            // once the user has had some time with the app, ask them what they think
            if reviewRequested == false && User.current.totalPoints > 2000 {
                SKStoreReviewController.requestReview()
                reviewRequested = true
            }
        #endif

        // Attempt to alleviate the performance freeze when loading our collection view.
        preheatBadges()
    }

    // MARK: - Methods

    /// This briefly touches the images for our badges, which helps scrolling performance when users see the collection view for the first time. Even though this won't cause the images to be fully loaded, it still about halves the overall rendering time.
    func preheatBadges() {
        let badges = Bundle.main.decode([Badge].self, from: "Badges.json")

        for badge in badges {
            _ = badge.image
        }
    }

    /// Refreshes everything when the user changes.
    func userDataChanged() {
        dataSource.updateSections()
        collectionView.reloadData()
    }

    // MARK: - Layout

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (section, env) -> NSCollectionLayoutSection? in
            switch self.dataSource.sections[section].type {
            case .status:
                return self.statusSection()
            case .score:
                return self.buildSection(for: .score)
            case .stats:
                return self.buildSection(for: .stats)
            case .streak:
                return self.buildSection(for: .streak)
            case .badges:
                return self.badgesSection()
            }
        }

        layout.register(BackgroundSupplementaryView.self, forDecorationViewOfKind: "background")
        return layout
    }

    private func header() -> NSCollectionLayoutBoundarySupplementaryItem {
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(56)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
    
    private func buildSection(for type: HomeSectionType) -> NSCollectionLayoutSection {
        let itemHeight: CGFloat = 44
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(itemHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let itemsCount = dataSource.sections.first(where: { $0.type == type })?.items.count ?? 0
        
        let groupHeight = itemHeight * CGFloat(itemsCount)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(groupHeight))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: itemsCount)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header()]
        
        return section
    }

    private func statusSection() -> NSCollectionLayoutSection {
        let statusSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(400))
        let status = NSCollectionLayoutItem(layoutSize: statusSize)

        let pointsSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90))
        let points = NSCollectionLayoutItem(layoutSize: pointsSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(490))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [status, points])

        return NSCollectionLayoutSection(group: group)
    }

    private func badgesSection() -> NSCollectionLayoutSection {
        let size: CGFloat = 60
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(size), heightDimension: .absolute(size))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(size))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 5)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 24, trailing: 0)
        section.interGroupSpacing = 16
        section.boundarySupplementaryItems = [header()]

        let background = NSCollectionLayoutDecorationItem.background(elementKind: "background")
        section.decorationItems = [background]

        return section
    }

    // MARK: - UICollectionViewDelegate

    /// When the Share Score cell is tapped start the share score process, otherwise do nothing.
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = dataSource.sections[indexPath.section]
        let item = section.items[indexPath.item]

        switch (section.type, item.type) {
        case (.score, .share):
            guard let attributes = collectionView.layoutAttributesForItem(at: indexPath) else {
                return
            }

            coordinator?.shareScore(from: attributes.frame)
        case (.badges, .badge):
            let badge = dataSource.badges[indexPath.item]

            /// Do not show badge details when voice over is running. For for earned badges we share directly and for not earned the accessibilityValue already tells the current progress.
            if UIAccessibility.isVoiceOverRunning {
                if User.current.isBadgeEarned(badge) {
                    coordinator?.shareBadge(badge)
                }
            } else {
                coordinator?.showBadgeDetails(badge)
            }
        default:
            return
        }

        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
