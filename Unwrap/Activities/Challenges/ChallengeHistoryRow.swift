//
//  ChallengeHistoryRow.swift
//  Unwrap
//

import SwiftUI

struct ChallengeHistoryRow: View {
    let result: ChallengeResult

    var body: some View {
        ShareLink(item: result.shareText) {
            HStack {
                VStack(alignment: .leading) {
                    Text(result.date.formatted)
                    Text("Score: \(result.score)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
