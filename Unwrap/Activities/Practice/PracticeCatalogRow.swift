//
//  PracticeCatalogRow.swift
//  Unwrap
//

import SwiftUI

struct PracticeCatalogRow: View {
    let kind: PracticeKind
    let isUnlocked: Bool

    var body: some View {
        HStack {
            if isUnlocked {
                Image(systemName: kind.symbolName)
                    .font(.title2)
                    .frame(width: 30)
                    .foregroundStyle(.tint)
                    .accessibilityHidden(true)
            } else {
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .frame(width: 30)
                    .foregroundStyle(Color("Locked"))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(kind.title)
                    .font(.title)

                if isUnlocked {
                    Text(kind.subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Complete \"\(kind.unlockSectionTitle)\" to unlock.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}
