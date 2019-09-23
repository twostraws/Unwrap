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

    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!

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

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 50

        backButton = UIBarButtonItem(image: UIImage(bundleName: "Back"), style: .plain, target: internalWebView, action: #selector(internalWebView.goBack))
        forwardButton = UIBarButtonItem(image: UIImage(bundleName: "Forward"), style: .plain, target: internalWebView, action: #selector(internalWebView.goForward))
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareArticle))

        toolbarItems = [backButton, fixedSpace, forwardButton, flexibleSpace, shareButton]

        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: internalWebView, action: #selector(internalWebView.reload))
        navigationItem.setRightBarButton(refreshButton, animated: true)

        // All three of these become disabled immediately when page loading starts, so we need the below so they don't start active then immediately deactivate.
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        refreshButton.isEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // FIXME: This causes the back/forward toolbar to become huge in iOS 13,
        // for reasons known only to Apple.
        // navigationController?.setToolbarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }

    @objc private func shareArticle() {
        let shareItems = internalWebView.getShareItems()
        guard shareItems.isEmpty == false else { return }

        let alert = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        alert.popoverPresentationController?.barButtonItem = shareButton
        present(alert, animated: true)
    }

    private func updateBackForwardState() {
        backButton.isEnabled = internalWebView.canGoBack
        forwardButton.isEnabled = internalWebView.canGoForward
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        title = webView.url?.host ?? webView.title
        internalWebView.loadingDidStart()
        refreshButton?.isEnabled = false
        updateBackForwardState()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        title = "Failed to load"
        internalWebView.loadingDidFinish()
        refreshButton?.isEnabled = true
        updateBackForwardState()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.url?.host ?? webView.title
        internalWebView.loadingDidFinish()
        refreshButton?.isEnabled = true
        updateBackForwardState()
    }

    /// Disallow new windows from being created.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }
}
