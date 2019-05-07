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
    private lazy var webview: WKWebView = {
    let preferences = WKPreferences()
    preferences.javaScriptEnabled = false
    let configuration = WKWebViewConfiguration()
    configuration.preferences = preferences
    let webview = WKWebView(frame: .zero, configuration: configuration)
    webview.translatesAutoresizingMaskIntoConstraints = false
    return webview
  }()

    override func loadView() {
        self.view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    loadHTML("Credits.html")
    
    NotificationCenter.default.addObserver(self, 
  selector: #selector(contentSizeDidChange(_:)),
  name: NSNotification.Name.UIContentSizeCategoryDidChange,
  object: nil)
    }
    
    private func setupViews() {
    view.addSubview(webview)
    NSLayoutConstraint.activate([
        webview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        webview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        webview.topAnchor.constraint(equalTo: view.topAnchor),
        webview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
  }
  
  private func loadHTML(_ file: String) {
    if let baseURL = Bundle.main.resourceURL {
      let fileURL = baseURL.appendingPathComponent(file)
      webview.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
    }
  }
  
  @objc private func contentSizeDidChange(_ notification: Notification) {
    webview.reload()
}
}
