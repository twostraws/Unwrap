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

    /// A tap recognizer that helps us detect link taps quickly.
    var tapRecognizer: UITapGestureRecognizer!

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
        // Force the content to go edge to edge.
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0

        // We want to handle text view events so that we can catch interaction events in plain text.
        delegate = self
    }

    /// Sets up this text view to look for link taps in the attributed string. You must call this yourself if you want this behavior.
    func lookForAttributedTaps() {
        // Don't configure this view more than once.
        guard tapRecognizer == nil else { return }

        // Make sure we recognize link taps immediately.
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(textViewTapped))
        addGestureRecognizer(tapRecognizer)
    }

    /// Called when a link is tapped; we pass it on to our link delegate.
    @objc func textViewTapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        guard let textPosition = closestPosition(to: location) else { return }
        guard let attributes = textStyling(at: textPosition, in: .backward) else { return }

        if let url = attributes[NSAttributedString.Key.link] as? URL {
            linkDelegate?.linkTapped(url)
        }
    }

    /// Handle non-attributed link taps either by handling them directly (we don't care about mailto: etc), or by passing them on to our delegate.
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        // don't let delegates handle email addresses, because the system does this best
        if URL.scheme?.hasPrefix("mailto") == true {
            return true
        }

        linkDelegate?.linkTapped(URL)
        return false
    }
}
