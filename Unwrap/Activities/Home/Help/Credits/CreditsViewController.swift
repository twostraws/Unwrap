//
//  CreditsViewController.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import UIKit

class CreditsViewController: UIViewController {
    let textView = UITextView()

    override func loadView() {
        view = UIView()

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.dataDetectorTypes = .link
        textView.isEditable = false
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Credits"

        let contents = String(bundleName: "Credits.md")
        textView.attributedText = contents.fromSimpleMarkdown()
    }

    override func viewDidLayoutSubviews() {
        // Set content offset to zero to make sure the textview starts from the top
        // when the view is laid out.
        textView.setContentOffset(.zero, animated: false)
    }
}
