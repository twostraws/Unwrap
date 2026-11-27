# Contributing to Unwrap

There are lots of ways you can help build this app, and everyone is welcome regardless of skill level and experience.

The README includes suggestions for new contributors. This guide explains the current app structure and the checks every contribution should pass.


## Before you begin…

Please read [LICENSE.md](LICENSE.md) and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). The source code is available under the MIT license, but the bundled lesson media and artwork are not redistributable.

If you have questions about the code, commits, or opening a pull request, that’s OK – contact [@twostraws](https://twitter.com/twostraws) and I’ll try to help.


## Tools and platforms

Unwrap is a native SwiftUI app built with Swift 6.4 or later in Xcode 27 or later. The app supports iPhone and iPad running iOS 27.0 or later.

The project has no third-party runtime dependencies. Please discuss any proposed dependency before adding it.

`UnwrapTests` uses Swift Testing for product logic and content validation.

Unwrap uses SwiftLint as build tooling. Run the same strict check used by the project before submitting a change:

```sh
swiftlint lint --strict --quiet --config .swiftlint.yml --no-cache Unwrap UnwrapTests
```

The app ships a large amount of JSON lesson and practice content. Validate edited JSON carefully; JSON strings encode line breaks as `\n` and cannot contain comments.


## Project structure

The app has five tabs: Home, Learn, Practice, Challenges, and News. The most important source groups are:

- **Activities** contains one folder per product feature: Home, Learn, Practice, Challenges, News, Awards, Web, and Welcome.
- **Content** contains the lesson, practice, badge, help, tour, image, video, and color resources shipped with the app.
- **Extensions** contains small app-wide extensions.
- **Reusables** contains shared SwiftUI views and code-highlighting or resource-loading helpers.
- **User** contains the user model, progress calculations, serialization, and local/iCloud persistence.
- The files directly inside **Unwrap** contain the app entry point, root tabs, lifecycle handling, and quick-action routing.

The target uses main-actor isolation by default, and shared observable state must remain main-actor isolated. Strict Swift concurrency is enabled.


## Navigation and presentation

Each tab owns its navigation and uses typed routes with `navigationDestination(for:)`. Home uses a `NavigationStack`; the content-heavy tabs use `NavigationSplitView` so the same code adapts naturally between iPhone and iPad.

The Home-screen quick actions open Challenges and News through the app delegate and scene delegate. They are not public URL routes.


## User data and persistence

The app owns one `User` instance. Progress is saved locally and synchronized through `NSUbiquitousKeyValueStore` using the app’s existing ubiquity KVS identifier.

Persistence changes are high risk. They must preserve legacy decoding, local/cloud conflict resolution, reset behavior, and offline launch. Never change the ubiquity KVS identifier merely to work around a local signing profile.


## Home

Home summarizes rank progress, points, streaks, challenge history, and unlocked badges in one adaptive view.

Sharing uses SwiftUI `ImageRenderer`. The tab bar, practice icons, and badges are drawn with SF Symbols; each badge names its symbol in `Badges.json`.


## Learn

Learn loads the bundled chapter manifest, lesson JSON, glossary, images, and videos when they are needed.

Each lesson is a JSON file containing its text and code blocks, its review, and an optional postscript, all drawn with native SwiftUI views. Bundled videos use AVKit, and external web links open in the app’s browser.

Review, glossary, Help, and Credits rich text uses native `AttributedString` Markdown. Keep inline code and links as Markdown rather than adding HTML snippets or a custom parser.

The study flow is an explicit state machine: lesson, optional postscript, review, and completion. Single- and multiple-select review sessions own answer validation, retry, progression, and award eligibility.


## Practice

Practice supports seven activity kinds: Free Coding, Predict the Output, Rearrange the Lines, Review, Spot the Error, Tap to Code, and Type Checker.

Most activities load shipped JSON; generated questions must remain deterministic when supplied a seeded random source. The shared session controls sequencing, answers, hints, skips, and awards, while activity-specific state stays beside its feature.

Adding high-quality, unambiguous questions is a useful contribution.


### Draft an optional-value practice question

On a Mac with Xcode 27 and Apple Intelligence enabled, run the following command to print one candidate for Predict the Output.

    swift Tools/DraftOptionalQuestion.swift

The on-device model suggests inputs. The tool calculates the expected output in Swift and writes the draft to standard output. Check the wording, run the printed Swift in a playground, and compare its output with the answer before adding a question. The brackets make an empty string visible. Include coverage for the new code pattern in the practice answer oracle when contributing it.


## Challenges

Users can begin one daily challenge per day. A challenge contains ten weighted practice questions, allows up to three skips, and awards points only on successful completion.

Keep challenge rules together and preserve weighted question selection, skip accounting, quit behavior, result sharing, and history deletion behavior.


## News

News downloads the current feed using `URLSession`, with loading, loaded, empty, and failure states represented explicitly. It persists read/seen state in the user model.

Do not add a networking or image-loading package for this feature. Keep offline and recovery behavior straightforward and testable.


## Assets and bundled content

Unwrap ships Markdown, JSON, MP4 video, preview images, rank artwork, tour artwork, and app icons.

- Preserve the original supplied artwork where it is part of Unwrap’s established design. Use SF Symbols for new interface iconography when an appropriate symbol exists.
- Use named SwiftUI colors so light mode, dark mode, increased contrast, and accessibility remain consistent.
- Preserve lesson content and media unless a content change specifically requires editing them.
- Add bitmap artwork only when vector or code-native rendering is unsuitable.
- Keep the iPhone and iPad app-icon entries complete when changing the app icon.


## Code style

Follow the patterns in nearby modern SwiftUI code. In particular:

1. Use SwiftUI and `@Observable` state; do not introduce UIKit or AppKit application UI.
2. Use modern Swift concurrency and preserve strict actor isolation.
3. Keep product logic in testable models rather than embedding it in view bodies.
4. Prefer direct, feature-local code. Add an abstraction only when it has more than one real production use or protects required lifecycle/concurrency behavior.
5. Use Dynamic Type, accessibility labels and values, keyboard access, and non-color cues.
6. Prefer native Swift and Foundation APIs, and avoid force unwraps or forced error handling.
7. Keep iPhone and iPad behavior in sync while allowing layouts to adapt naturally to the available space.


## Before you commit code…

At a minimum:

1. Run SwiftLint in strict, no-cache mode.
2. Run the full Swift Testing suite on an iPhone simulator and an iPad simulator.
3. Build a warning-free Release configuration for iOS.
4. Test the changed flow with keyboard and accessibility settings where relevant.
5. Add or update unit tests for product logic, persistence, content validation, and regressions.
6. Update documentation when architecture, supported platforms, or contributor instructions change.

Use Instruments when a change affects performance or resource lifetime. If you cannot complete a useful follow-up, explain it clearly in the pull request rather than hiding it behind an unexplained workaround.
