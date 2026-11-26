//
//  ShareArtwork.swift
//  Unwrap
//

import CoreTransferable
import ImageIO
import SwiftUI
import UniformTypeIdentifiers

struct ShareArtwork: View {
    private static let canvasSize = CGSize(width: 512, height: 512)

    let item: HomeShareItem

    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    .linearGradient(
                        colors: [
                            Color("UnwrapGradientTop"),
                            Color("UnwrapGradientBottom")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Group {
                switch item.artwork {
                case .image(let name):
                    Image(name)
                        .resizable()
                        .scaledToFit()
                case .badge(let symbolName):
                    BadgeGlyph(symbolName: symbolName)
                }
            }
            .foregroundStyle(.white)
            .frame(width: 256, height: 256)
            .position(x: 256, y: 180)

            UnwrapLogoShape()
                .stroke(.white, lineWidth: 2)
                .frame(width: 128, height: 128)
                .position(x: 256, y: 416)
        }
    }

    static func pngData(for item: HomeShareItem) -> Data? {
        let artwork = ShareArtwork(item: item)
            .frame(width: canvasSize.width, height: canvasSize.height)
            .environment(\.colorScheme, .light)

        let renderer = ImageRenderer(content: artwork)
        renderer.scale = 2

        guard let image = renderer.cgImage else { return nil }

        let data = NSMutableData()

        guard let destination = CGImageDestinationCreateWithData(
            data,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            return nil
        }

        CGImageDestinationAddImage(destination, image, nil)
        return CGImageDestinationFinalize(destination) ? data as Data : nil
    }
}

nonisolated extension HomeShareItem: Transferable {
    /// Shares the item as a PNG, which is only drawn once the user has chosen where to send it.
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            guard let data = await ShareArtwork.pngData(for: item) else {
                throw CocoaError(.fileWriteUnknown)
            }

            return data
        }
    }
}
