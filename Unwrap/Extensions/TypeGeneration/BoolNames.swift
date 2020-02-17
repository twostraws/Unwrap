//
//  BoolNames.swift
//  Unwrap
//
//  Created by Paul Hudson on 09/08/2018.
//  Copyright © 2019 Hacking with Swift.
//

import Foundation

extension Bool: TypeGenerating {
    static func randomName() -> String {
        let names = ["isAnimated", "isAuthenticated", "isActive", "isDeleted", "isEdited", "isEditing", "isEnabled", "isEncrypted", "isFirstResponder", "isFocused", "isHidden", "isLandscape", "isLoaded", "isLoggedIn", "isModal", "isOpaque", "isPortrait", "isPresented", "isRecognized", "isRead", "isReady", "isSaved", "isSelected", "isSorted", "isStatic", "isUnlocked", "isVisible", "isZoomed"]
        return names.randomElement()!
    }

    static func makeInstance() -> String {
        let storage = letOrVar()
        let name = randomName()
        let type: String

        if includeType() {
            type = ": Bool"
        } else {
            type = ""
        }

        let selectedValue = String(describing: Bool.random())
        let value = "\(selectedValue)"

        return "\(storage) \(name)\(type) = \(value)"
    }
}
