
<p align="center">
    <img src="https://www.hackingwithswift.com/files/unwrap/logo.png" alt="Unwrap logo" width="614" maxHeight="171" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/iOS-12.0+-blue.svg" />
    <img src="https://img.shields.io/badge/Swift-5.0-brightgreen.svg" />
    <a href="https://twitter.com/twostraws">
        <img src="https://img.shields.io/badge/Contact-@twostraws-lightgrey.svg?style=flat" alt="Twitter: @twostraws" />
    </a>
</p>

Unwrap is an app that helps you learn Swift faster and more effectively.

At its core are almost 100 video lessons that teach all the fundamentals of the Swift programming language, with each lesson backed up by an interactive review.

Once you’ve made some progress learning, you can dive into a selection of practice activities that make you write code by tapping, dragging, or typing, find errors, predict program output, and more. There are also daily challenges that test your overall language knowledge once per day, helping your new skills really sink in.

At some point hopefully soon Unwrap will be available to download for free on the App Store. Until then, I’ve made the code available so that anyone who wants to can see how I structure my code and perhaps learn from it. If you’d like to help you’re most welcome to and there are many opportunities, but make sure you read the contribution guidelines first.


## Trying it yourself

Unwrap is written using Xcode 10.2 and Swift 5.0. All the CocoaPods are checked in to this repository, so you should be able to clone this and build it immediately by opening `Unwrap.xcworkspace`.

As far as I know the app is feature complete, but there are likely to be errors all over the place at least to begin with – if you hit problems, either building or running the app, please let me know.


## Contribution guide

Any help you can offer with this project is most welcome, and trust me: there are opportunities big and small, so that someone with only a few weeks of Swift experience can help.

**However, before you start please read the LICENSE.md and CONTRIBUTING.md files inside this repository.** Although I want to make Unwrap available under an open-source license as soon as I can, right now it’s released under a really restrictive license to avoid clones, scams, and confused users. So, please read the LICENSE.md file before you contribute anything.

If you’d like to help, here are some suggestions ordered from most easy to most difficult. I’ve added documentation to most if not all of the code, but there’s also a separate document in this repository called CONTRIBUTING.md that documents how the code is structured and how it works.


### Easy

1. Just try running the app and let me know if you hit any problems.
2. I’ve written a huge amount of all-new content for this app, so if (and when!) you see any typos please correct them and open a PR.
3. If you spot any redundant code, or code that repeats itself that can sensible be refactored not to repeat, you’re welcome to clean it up. Any unused code should be deleted rather than just commented out.
4. If you can write (sensible!) solutions for Free Coding problems that aren’t currently accepted, please add them.
5. If you see any Sixty Seconds chapters that don’t have a postscript (alert message shown between the chapter text and review), and you think there’s something important to add there, add it.
5. Write new tests. It doesn’t matter how small they might seem, tests are always appreciated and won’t require you to modify any of the core code.

### Intermediate

1. If you find any bugs and can fix them, by all means do.
2. If you spot any performance hotspots that can be resolved smoothly, go for it.
3. All the practice activities have their data stored as JSON. I’ve tried to create samples of each of them, but it would be awesome to add more.
4. Right now the app is available only in English. We could look at localizing all the text, but I have concerns partly because Swift continues to change and partly because the videos will get in the way. If you have suggestions, let me know!
5. Did I already mention adding tests?


### Advanced

1. Although I’m pretty happy with the app’s architecture, it could always be improved – if you have suggestions, let me know!
2. I’ve added the basics of theme support, but it’s not implemented or tested yet. This could be expanded to work everywhere, and new themes could be added.
3. The storyboard started off small and grew far too big for its boots. This is particularly annoying because many screens are similar. To resolve this we could switch to building the UI in code, starting with a direct copy of the storyboard, then try to refactor it so that similar view controllers are created using shared code. 

Again, please make sure you read the LICENSE.md and CONTRIBUTING.md files before you start just to avoid problems.


## Credits

Unwrap was designed and built by Paul Hudson. Hacking with Swift, Swift in Sixty Seconds, Unwrap, and the Unwrap logo are all copyright © Paul Hudson 2019.

Unwrap is built using some third-party frameworks and fonts: [DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet), [Font Awesome](https://fontawesome.com/), [MKRingProgressView](https://github.com/maxkonovalov/MKRingProgressView), [QuickLayout](https://github.com/huri000/QuickLayout), [SavannaKit](https://github.com/louisdh/savannakit), [SDWebImage](https://github.com/SDWebImage/SDWebImage), [SourceEditor](https://github.com/louisdh/source-editor), and [SwiftEntryKit](https://github.com/huri000/SwiftEntryKit). Their licenses are stored inside their respective Pods directories, and are repeated inside the app’s credits screen.

Swift, the Swift logo, Xcode, Instruments, Cocoa Touch, Touch ID, AirDrop, iBeacon, iPhone, iPad, Safari, App Store, watchOS, tvOS, Mac and macOS are trademarks of Apple Inc., registered in the U.S. and other countries. 

If you liked Unwrap and want more like it, I have [a whole website full of free Swift tutorials](https://www.hackingwithswift.com).
