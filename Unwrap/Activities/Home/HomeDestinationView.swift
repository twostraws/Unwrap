//
//  HomeDestinationView.swift
//  Unwrap
//

import SwiftUI

struct HomeDestinationView: View {
    let route: HomeRoute
    let content: HomeContent
    let show: (HomeRoute) -> Void
    let showTour: () -> Void

    var body: some View {
        switch route {
        case .help:
            HelpView(
                items: content.helpItems,
                showTour: showTour,
                openWebURL: { show(.web($0)) }
            )
        case .credits:
            CreditsView(markdown: content.creditsMarkdown) { url in
                show(.web(url))
            }
        case .web(let url):
            BrowserView(url: url)
        }
    }
}
