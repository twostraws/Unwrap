//
//  BadgeIconView.swift
//  Unwrap
//

import SwiftUI

struct BadgeIconView: View {
    let badge: Badge
    let isEarned: Bool

    var body: some View {
        BadgeGlyph(symbolName: badge.symbolName)
            .foregroundStyle(isEarned ? Color(badge.color) : Color("Locked"))
    }
}

/// A badge's artwork: a symbol inside a ring, drawn in the current foreground style at whatever size it is given.
struct BadgeGlyph: View {
    let symbolName: String

    var body: some View {
        GeometryReader { proxy in
            let diameter = min(proxy.size.width, proxy.size.height)

            ZStack {
                Circle()
                    .strokeBorder(lineWidth: diameter * 0.08)

                Image(systemName: symbolName)
                    .resizable()
                    .scaledToFit()
                    .fontWeight(.semibold)
                    .frame(width: diameter * 0.5, height: diameter * 0.5)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
