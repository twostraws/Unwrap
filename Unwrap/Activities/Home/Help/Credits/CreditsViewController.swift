//
//  CreditsViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit
import WebKit

class CreditsViewController: UIViewController, TappableTextViewDelegate {
    var coordinator: HomeCoordinator?
    var textView: TappableTextView?

	override func loadView() {
		textView = TappableTextView()
        textView?.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        textView?.isEditable = false
        textView?.linkDelegate = self
        view = textView
	}

	override func viewDidLoad() {
		super.viewDidLoad()

        title = "Credits"
        let credits = String(bundleName: "Credits.html")
        let contents = String.wrapperHTML(allowTheming: true, width: 320, slimLayout: true).replacingOccurrences(of: "[BODY]", with: credits)

        let data = Data(contents.utf8)
        let str = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        textView?.attributedText = str
	}

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView?.flashScrollIndicators()
    }

    func linkTapped(_ url: URL) {
        coordinator?.open(url)

        if UIDevice.current.userInterfaceIdiom == .pad {
            // if we're on iPad we should dismiss the modal view controller immediately so the user can browse the link they chose.
            dismiss(animated: true)
        }
    }
}
