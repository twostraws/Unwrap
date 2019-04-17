//
//  EKProperty.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 4/19/18.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import UIKit

public struct EKProperty {
    
    /** Button content descriptor */
    public struct ButtonContent {
        
        public typealias Action = () -> ()
        
        /** Button title label content descriptor */
        public var label: LabelContent
        
        /** Button background color */
        public var backgroundColor: UIColor
        public var highlightedBackgroundColor: UIColor

        /** Content edge inset */
        public var contentEdgeInset: CGFloat
        
        /** Action */
        public var action: Action?
        
        public init(label: LabelContent, backgroundColor: UIColor, highlightedBackgroundColor: UIColor, contentEdgeInset: CGFloat = 5, action: @escaping Action = {}) {
            self.label = label
            self.backgroundColor = backgroundColor
            self.highlightedBackgroundColor = highlightedBackgroundColor
            self.contentEdgeInset = contentEdgeInset
            self.action = action
        }
    }
    
    /** Label content descriptor */
    public struct LabelContent {
        
        /** The text */
        public var text: String
        
        /** The label's style */
        public var style: LabelStyle
        
        public init(text: String, style: LabelStyle) {
            self.text = text
            self.style = style
        }
    }
    
    /** Label style descriptor */
    public struct LabelStyle {
        
        /** Font of the text */
        public var font: UIFont
        
        /** Color of the text */
        public var color: UIColor
        
        /** Text Alignment */
        public var alignment: NSTextAlignment
        
        /** Number of lines */
        public var numberOfLines: Int
        
        public init(font: UIFont, color: UIColor, alignment: NSTextAlignment = .left, numberOfLines: Int = 0) {
            self.font = font
            self.color = color
            self.alignment = alignment
            self.numberOfLines = numberOfLines
        }
    }
    
    /** Image View style descriptor */
    public struct ImageContent {
        
        /** Repeated-reversed animation throughout the presentation of an image */
        public enum TransformAnimation {
            case animate(duration: TimeInterval, options: UIView.AnimationOptions, transform: CGAffineTransform)
            case none
        }
        
        /** The images */
        public var images: [UIImage]
        
        /** Image sequence duration, if any */
        public var imageSequenceAnimationDuration: TimeInterval
        
        /** Image View size - can be forced. If nil, then the image view hugs content and resists compression */
        public var size: CGSize?
    
        /** Content mode */
        public var contentMode: UIView.ContentMode
        
        /** Should the image be rounded */
        public var makesRound: Bool
        
        /** Repeated-Reversed animation */
        public var animation: TransformAnimation
        
        public init(imageName: String, animation: TransformAnimation = .none, size: CGSize? = nil, contentMode: UIView.ContentMode = .scaleToFill, makesRound: Bool = false) {
            let image = UIImage(named: imageName)!
            self.init(image: image, size: size, contentMode: contentMode, makesRound: makesRound)
        }
        
        public init(image: UIImage, animation: TransformAnimation = .none, size: CGSize? = nil, contentMode: UIView.ContentMode = .scaleToFill, makesRound: Bool = false) {
            self.images = [image]
            self.size = size
            self.contentMode = contentMode
            self.makesRound = makesRound
            self.animation = animation
            self.imageSequenceAnimationDuration = 0
        }
        
        public init(images: [UIImage], imageSequenceAnimationDuration: TimeInterval = 1, animation: TransformAnimation = .none, size: CGSize? = nil, contentMode: UIView.ContentMode = .scaleToFill, makesRound: Bool = false) {
            self.images = images
            self.size = size
            self.contentMode = contentMode
            self.makesRound = makesRound
            self.animation = animation
            self.imageSequenceAnimationDuration = imageSequenceAnimationDuration
        }
        
        public init(imagesNames: [String], imageSequenceAnimationDuration: TimeInterval = 1, animation: TransformAnimation = .none, size: CGSize? = nil, contentMode: UIView.ContentMode = .scaleToFill, makesRound: Bool = false) {
            let images = imagesNames.map { UIImage(named: $0)! }
            self.init(images: images, imageSequenceAnimationDuration: imageSequenceAnimationDuration, animation: animation, size: size, contentMode: contentMode, makesRound: makesRound)
        }
        
        /** Quick thumbail property generator */
        public static func thumb(with image: UIImage, edgeSize: CGFloat) -> ImageContent {
            return ImageContent(images: [image], size: CGSize(width: edgeSize, height: edgeSize), contentMode: .scaleAspectFill, makesRound: true)
        }
        
        /** Quick thumbail property generator */
        public static func thumb(with imageName: String, edgeSize: CGFloat) -> ImageContent {
            return ImageContent(imagesNames: [imageName], size: CGSize(width: edgeSize, height: edgeSize), contentMode: .scaleAspectFill, makesRound: true)
        }
    }
    
    /** Text field content **/
    public struct TextFieldContent {
        
        // NOTE: Intentionally a reference type
        class ContentWrapper {
            var text = ""
        }
        
        public var keyboardType: UIKeyboardType
        public var isSecure: Bool
        public var leadingImage: UIImage!
        public var placeholder: LabelContent
        public var textStyle: LabelStyle
        public var tintColor: UIColor!
        public var bottomBorderColor: UIColor
        let contentWrapper = ContentWrapper()
        public var textContent: String {
            set {
                contentWrapper.text = newValue
            }
            get {
                return contentWrapper.text
            }
        }
        
        public init(keyboardType: UIKeyboardType = .default, placeholder: LabelContent, tintColor: UIColor? = nil, textStyle: LabelStyle, isSecure: Bool = false, leadingImage: UIImage? = nil, bottomBorderColor: UIColor = .clear) {
            self.keyboardType = keyboardType
            self.placeholder = placeholder
            self.textStyle = textStyle
            self.tintColor = tintColor
            self.isSecure = isSecure
            self.leadingImage = leadingImage
            self.bottomBorderColor = bottomBorderColor
        }
    }
    
    /** Button bar content */
    public struct ButtonBarContent {
        
        /** Button content array */
        public var content: [ButtonContent] = []
        
        /** The color of the separator */
        public var separatorColor: UIColor
        
        /** Upper threshold for the number of buttons (*ButtonContent*) for horizontal distribution. Must be a positive value */
        public var horizontalDistributionThreshold: Int
        
        /** Determines whether the buttons expands animately */
        public var expandAnimatedly: Bool
        
        /** The height of each button. All are equally distributed in their axis */
        public var buttonHeight: CGFloat
        
        public init(with buttonContents: ButtonContent..., separatorColor: UIColor, horizontalDistributionThreshold: Int = 2, buttonHeight: CGFloat = 50, expandAnimatedly: Bool) {
            guard horizontalDistributionThreshold > 0 else {
                fatalError("horizontalDistributionThreshold Must have a positive value!")
            }
            self.separatorColor = separatorColor
            self.horizontalDistributionThreshold = horizontalDistributionThreshold
            self.expandAnimatedly = expandAnimatedly
            self.buttonHeight = buttonHeight
            content.append(contentsOf: buttonContents)
        }
    }
    
    /** Rating item content */
    public struct EKRatingItemContent {
        public var title: EKProperty.LabelContent
        public var description: EKProperty.LabelContent
        public var unselectedImage: EKProperty.ImageContent
        public var selectedImage: EKProperty.ImageContent
        
        public init(title: EKProperty.LabelContent, description: EKProperty.LabelContent, unselectedImage: EKProperty.ImageContent, selectedImage: EKProperty.ImageContent) {
            self.title = title
            self.description = description
            self.unselectedImage = unselectedImage
            self.selectedImage = selectedImage
        }
    }
}
