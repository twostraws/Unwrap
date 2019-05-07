//
//  CreditsViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit
import WebKit

class CreditsViewController: UIViewController {
	private lazy var webView: WKWebView = {
		let preferences = WKPreferences()
		preferences.javaScriptEnabled = false
		let configuration = WKWebViewConfiguration()
		configuration.preferences = preferences
		let webview = WKWebView(frame: .zero, configuration: configuration)
		return webview
	}()

	override func loadView() {
		view = webView
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if let url = Bundle.main.url(forResource: "Credits", withExtension: "html") { webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
		}

		NotificationCenter.default.addObserver(self, selector: #selector(contentSizeDidChange(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
	}

	@objc private func contentSizeDidChange(_ notification: Notification) {
		webView.reload()
	}
}
