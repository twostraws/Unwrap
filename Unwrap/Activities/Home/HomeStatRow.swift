//
//  HomeStatRow.swift
//  Unwrap
//

import SwiftUI

struct HomeStatRow: View {
    let title: String
    let value: String
    let accessibilityLabel: String

    var body: some View {
        LabeledContent(title, value: value)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
    }
}
