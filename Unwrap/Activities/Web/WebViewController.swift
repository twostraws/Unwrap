//
//  WebViewController.swift
//  Unwrap
//
//  Created by Julian Schiavo on 2/5/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit
import WebKit

/// A simple wrapper for WKWebView, because SFSafariViewController looks awful in an iPad split view controller.
class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    var internalWebView: WebView!
    var url: URL

    var refreshButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)

        navigationItem.largeTitleDisplayMode = .never
        extendedLayoutIncludesOpaqueBars = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        internalWebView = WebView()
        internalWebView.delegate = self
        view = internalWebView

        internalWebView.load(url)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: internalWebView, action: #selector(internalWebView.reload))
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareArticle))
        navigationItem.setRightBarButtonItems([shareButton, refreshButton], animated: true)
    }

    @objc private func shareArticle() {
        let shareItems = internalWebView.getShareItems()
        guard shareItems.isEmpty == false else { return }

        let alert = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        alert.popoverPresentationController?.barButtonItem = shareButton
        present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        internalWebView.loadingDidStart()
        refreshButton?.isEnabled = false
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        title = "Failed to load"
        internalWebView.loadingDidFinish()
        refreshButton?.isEnabled = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
        internalWebView.loadingDidFinish()
        refreshButton?.isEnabled = true
    }

    /// Disallow new windows from being created.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }
}
