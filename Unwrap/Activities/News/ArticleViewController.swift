//
//  ArticleViewController.swift
//  Unwrap
//
//  Created by Julian Schiavo on 2/5/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit
import WebKit

class ArticleViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var article: NewsArticle

    let webView = WKWebView()
    let progressView = UIProgressView(progressViewStyle: .bar)
    var refreshButton: UIBarButtonItem?
    var shareButton: UIBarButtonItem?

    private var estimatedProgressObserver: NSKeyValueObservation?

    init(article: NewsArticle) {
        self.article = article
        super.init(nibName: nil, bundle: nil)

        extendedLayoutIncludesOpaqueBars = true

        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        load(article: article)

        setupEstimatedProgressObserver()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()

        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        progressView.isHidden = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            progressView.heightAnchor.constraint(equalToConstant: 2.0),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(WKWebView.reload))
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareArticle))
        navigationItem.setRightBarButtonItems([shareButton!, refreshButton!], animated: true)
    }

    private func setupEstimatedProgressObserver() {
        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            guard let self = self else { return }
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }

    @objc private func shareArticle() {
        let alert = UIActivityViewController(activityItems: [article.title, article.url], applicationActivities: nil)
        alert.popoverPresentationController?.barButtonItem = shareButton
        present(alert, animated: true)
    }

    /// Loads a new article
    func load(article: NewsArticle) {
        self.article = article

        let request = URLRequest(url: article.url)
        webView.load(request)
    }

    // MARK: WKNavigationDelegate

    /// Allow all navigation but open third party urls
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        UIApplication.shared.open(url, options: [.universalLinksOnly: true]) { (successful) in
            if successful {
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        title = article.title

        progressView.progress = 0
        progressView.isHidden = false

        refreshButton?.isEnabled = false
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        title = "Failed to load"
        refreshButton?.isEnabled = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
        progressView.isHidden = true
        refreshButton?.isEnabled = true
    }

    // MARK: WKUIDelegate

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }
}
