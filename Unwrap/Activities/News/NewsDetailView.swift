//
//  NewsDetailView.swift
//  Unwrap
//

import SwiftUI

struct NewsDetailView: View {
    let route: NewsRoute?

    var body: some View {
        if let route {
            BrowserView(url: route.url)
                .id(route)
        } else {
            PleaseSelectView(prompt: "Please select an article to read")
        }
    }
}
