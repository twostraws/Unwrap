//
//  TappableTextView.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

/// A UITextView subclass that detects taps in attributed strings better than the default behavior.
class TappableTextView: UITextView, UITextViewDelegate {
    /// Where we should report link taps.
    weak var linkDelegate: TappableTextViewDelegate?
    var lastURLInteraction = CFAbsoluteTimeGetCurrent()

    // Stop the user from selecting pieces of text.
    override public var selectedTextRange: UITextRange? {
        get {
            return nil
        }
        set { }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        addCustomizations()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addCustomizations()
    }

    /// Tappable text views have no margin and handle taps by hand to avoid delays.s
    func addCustomizations() {
        // Stop the user from accidentally dragging our top image
        textDragInteraction?.isEnabled = false

        // Force the content to go edge to edge.
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0

        // We want to handle text view events so that we can catch interaction events in plain text.
        delegate = self
    }

    /// Handle non-attributed link taps either by handling them directly (we don't care about mailto: etc), or by passing them on to our delegate.
    func textView(_ textView: UITextView, primaryActionFor textItem: UITextItem, defaultAction: UIAction) -> UIAction? {
        guard case let .link(url) = textItem.content else {
            return defaultAction
        }

        // Don't let delegates handle email addresses, because the system does this best.
        if url.scheme?.hasPrefix("mailto") == true {
            return defaultAction
        }

        return UIAction { [weak self] _ in
            guard let self else { return }

            // Rate limit how often we trigger link taps to avoid double taps causing a problem.
            if self.lastURLInteraction + 0.2 < CFAbsoluteTimeGetCurrent() {
                self.lastURLInteraction = CFAbsoluteTimeGetCurrent()
                self.linkDelegate?.linkTapped(url)
            }
        }
    }
}
