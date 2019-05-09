
<p align="center">
    <img src="https://www.hackingwithswift.com/files/sourceful/logo.png" alt="Sourceful logo" width="550" maxHeight=“118" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/iOS-12.0+-blue.svg" />
    <img src="https://img.shields.io/badge/Swift-5.0-brightgreen.svg" />
    <a href="https://twitter.com/twostraws">
        <img src="https://img.shields.io/badge/Contact-@twostraws-lightgrey.svg?style=flat" alt="Twitter: @twostraws" />
    </a>
</p>

Sourceful is a syntax text editor for iOS and macOS, providing subclasses of `UITextView` and `NSTextView` that offer live syntax highlighting as you type. Right now it includes syntax highlighting support for Swift and Python, but it's easy to add your own.

This project is a combination of two projects from Louis D’hauwe: [SavannaKit](https://github.com/louisdh/savannakit) and [Source Editor](https://github.com/louisdh/source-editor).

Both of those projects were archived when Louis joined Apple, which meant they haven’t been updated since Swift 4.1. This causes a variety of pain points with Cocoapods, so Sourceful is designed to avoid them entirely: it combines both those projects into one repository, and is fully updated for modern versions of Swift.


## Credits

SavannaKit and SourceEditor were designed by Louis D’hauwe. Sourceful was built by combining those two and updating them to modern Swift, and is maintained by Paul Hudson.

Sourceful is licensed under the MIT license; see LICENSE for more information.

Swift, the Swift logo, Xcode, Instruments, Cocoa Touch, Touch ID, AirDrop, iBeacon, iPhone, iPad, Safari, App Store, watchOS, tvOS, Mac and macOS are trademarks of Apple Inc., registered in the U.S. and other countries. 
