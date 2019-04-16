# MKRingProgressView

[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat)](https://developer.apple.com/swift)
[![Platform](https://img.shields.io/cocoapods/p/MKRingProgressView.svg?style=flat)](http://cocoapods.org/pods/MKRingProgressView)
[![License](https://img.shields.io/cocoapods/l/MKRingProgressView.svg?style=flat)](http://cocoapods.org/pods/MKRingProgressView)
[![Version](https://img.shields.io/cocoapods/v/MKRingProgressView.svg?style=flat)](http://cocoapods.org/pods/MKRingProgressView)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


Ring progress view similar to Activity app on Apple Watch

<img src="MKRingProgressView.png" alt="MKRingProgressView" width=375>

## Features

- Progress animation
- Customizable start/end and backdrop ring colors
- Customizable ring width
- Customizable progress line end style
- Customizable shadow under progress line end
- Progress values above 100% (or 360°) can also be displayed

## Installation

### CocoaPods

To install `MKRingProgressView` via [CocoaPods](http://cocoapods.org), add the following line to your Podfile:

```
pod 'MKRingProgressView'
```

### Carthage

To install `MKRingProgressView` via [Carthage](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos), add the following line to your Cartfile:

```
github "maxkonovalov/MKRingProgressView"
```

## Usage

See the example Xcode project. It contains 2 targets:
- **ProgressRingExample** - a simple example containing a single progress ring with adjustable parameters.
- **ActivityRingsExample** - an advanced usage example replicating Activity app by Apple. It also contains additional classes for convenient grouping of 3 ring progress views together.

### Interface Builder

`MKRingProgressView` can be set up in Interface Builder. To use it, set the custom view class to `MKRingProgressView`. Most of the control's parameters can be customized in Interface Builder.

### Code

```swift
let ringProgressView = RingProgressView(frame: CGRect(x: 0, y: 100, width: 100, height: 100))
ringProgressView.startColor = .red
ringProgressView.endColor = .magenta
ringProgressView.ringWidth = 25
ringProgressView.progress = 0.0
view.addSubview(ringProgressView)
```

The `progress` value can be animated the same way you would normally animate any property using `UIView`'s block-based animations: 

```swift
UIView.animate(withDuration: 0.5) {
    ringProgressView.progress = 1.0
}
```

## Performance

To achieve better performance the following options are possible:

- Set `gradientImageScale` to lower values like `0.5` (defaults to `1.0`)
- Set `startColor` and `endColor` to the same value
- Set `shadowOpacity` to `0.0`
- Set `allowsAntialiasing` to `false`

## Requirements

- iOS 8.2
- tvOS 9.0
- Xcode 10, Swift 4+

## License

`MKRingProgressView` is available under the MIT license. See the LICENSE file for more info.
