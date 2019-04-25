# Zephyr 🌬️

### Effortlessly sync UserDefaults over iCloud

![Swift Support](https://img.shields.io/badge/Swift-4.2%2C%204.1%2C%203.2%2C%203.1-orange.svg) [![Platform](https://img.shields.io/badge/Platforms-iOS%20%7c%20tvOS-lightgray.svg?style=flat)](http://cocoadocs.org/docsets/Zephyr) ![Documentation](https://github.com/ArtSabintsev/Zephyr/blob/master/docs/badge.svg)

[![CocoaPods](https://img.shields.io/cocoapods/v/Zephyr.svg)]()  [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)]() [![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-brightgreen.svg)](https://swift.org/package-manager/)

---
### About

Zephyr synchronizes specific keys and/or all of your [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults) over iCloud using [NSUbiquitousKeyValueStore](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSUbiquitousKeyValueStore_class/).

Zephyr has built in monitoring, allowing it to sync specific keys in the background as they change.

For the latest updates, refer to the [Releases](https://github.com/ArtSabintsev/Zephyr/releases) tab.

### Features
- [x] CocoaPods, Carthage, and SwiftPM Support
- [x] Syncs specific `UserDefaults` keys or all of your `UserDefaults`.
- [x] Background monitoring and synchronization between `UserDefaults` and `NSUbiquitousKeyValueStore`
- [x] Detailed Logging
- [x] Documentation at http://sabintsev.com/Zephyr/

### Installation Instructions

| Swift Version |  Branch Name  | Will Continue to Receive Updates?
| ------------- | ------------- |  -------------
| 5.0 | master | **Yes**
| 4.2 | swift4.2 | No
| 4.1 | swift4.1 | No
| 3.2 | swift3.2 | No
| 3.1 | swift3.1 | No

#### CocoaPods
```ruby
pod 'Zephyr' # Swift 5.0
pod 'Zephyr', :git => 'https://github.com/ArtSabintsev/Zephyr.git', :branch => 'swift4.2' # Swift 4.2
pod 'Zephyr', :git => 'https://github.com/ArtSabintsev/Zephyr.git', :branch => 'swift4.1' # Swift 4.1
pod 'Zephyr', :git => 'https://github.com/ArtSabintsev/Zephyr.git', :branch => 'swift3.2' # Swift 3.2
pod 'Zephyr', :git => 'https://github.com/ArtSabintsev/Zephyr.git', :branch => 'swift3.1' # Swift 3.1
```

### Carthage
``` swift
github "ArtSabintsev/Zephyr" // Swift 5.0
github "ArtSabintsev/Zephyr" "swift4.2" // Swift 4.2
github "ArtSabintsev/Zephyr" "swift4.1" // Swift 4.1
github "ArtSabintsev/Zephyr" "swift3.2" // Swift 3.2
github "ArtSabintsev/Zephyr" "swift3.1" // Swift 3.1
```

### Swift Package Manager
``` swift
.Package(url: "https://github.com/ArtSabintsev/Zephyr.git", majorVersion: 3)
```

#### Manual

1. [Download Zephyr](http://github.com/ArtSabintsev/Zephyr/archive/master.zip)
2. Copy `Zephyr.swift` into your project.

### Setup

#### Turn on iCloud Sync in Xcode
In Xcode, open your app's project/workspace file:
- Click on your Project
- Click on one of your Targets
- Click on Capabilities
- Turn on iCloud syncing
- Under Services, make sure to check `Key-value storage`
- Repeat for all Targets (if necessary)

![How to turn on iCloud Key Value Store Syncing](https://github.com/ArtSabintsev/Zephyr/blob/master/Assets/XcodeSettings.png?raw=true "How to turn on iCloud Key Value Store Syncing")

#### Integrate Zephyr into your App

Before performing each sync, Zephyr automatically checks to see if the data in UserDefaults or NSUbiquitousKeyValueStore is newer. To make sure there's no overwriting going on in a fresh installation of your app on a new device that's connected to the same iCloud account, make sure that your UserDefaults are registered ***BEFORE*** calling any of the Zephyr methods. One way to easily achieve this is by using the [UserDefaults Register API](https://developer.apple.com/documentation/foundation/userdefaults/1417065-register).

**Sync all UserDefaults**
```Swift
Zephyr.sync()
```

**Sync a specific key or keys (Variadic Option)**
```Swift
Zephyr.sync(keys: "MyFirstKey", "MySecondKey", ...)
```

**Sync a specific key or keys (Array Option)**
```Swift
Zephyr.sync(keys: ["MyFirstKey", "MySecondKey"])
```

**Add/Remove Keys for Background Monitoring (Variadic Option)**

```Swift
Zephyr.addKeysToBeMonitored(keys: "MyFirstKey", "MySecondKey", ...)
Zephyr.removeKeysFromBeingMonitored(keys: "MyFirstKey", "MySecondKey", ...)
```

**Add/Remove Keys for Background Monitoring (Array Option)**
```Swift
Zephyr.addKeysToBeMonitored(keys: ["MyFirstKey", "MySecondKey"])
Zephyr.removeKeysFromBeingMonitored(keys: ["MyFirstKey", "MySecondKey"])
```
**Toggle Automatic Calling of NSUbiquitousKeyValueStore's Synchronization method**
```
Zephyr.syncUbiquitousKeyValueStoreOnChange = true // Default
Zephyr.syncUbiquitousKeyValueStoreOnChange = false // Turns off instantaneous synchronization
```

**Debug Logging**
```Swift
Zephyr.debugEnabled = true // Must be called before sync(_:)
Zephyr.sync()
```

### Sample App

Please ignore the Sample App as I did not add any demo code in the Sample App. It's only in this repo to add support for Carthage.

### Created and maintained by
[Arthur Ariel Sabintsev](http://www.sabintsev.com/)
