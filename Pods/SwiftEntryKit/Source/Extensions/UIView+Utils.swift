//
//  UILabel+Message.swift
//  SwiftEntryKit
//
//  Created by Daniel Huri on 04/14/2018.
//  Copyright (c) 2018 huri000@gmail.com. All rights reserved.
//

import UIKit
import QuickLayout

extension UILabel {
    var style: EKProperty.LabelStyle {
        set {
            font = newValue.font
            textColor = newValue.color
            textAlignment = newValue.alignment
            numberOfLines = newValue.numberOfLines
        }
        get {
            return EKProperty.LabelStyle(font: font, color: textColor, alignment: textAlignment, numberOfLines: numberOfLines)
        }
    }
    
    var content: EKProperty.LabelContent {
        set {
            text = newValue.text
            style = newValue.style
        }
        get {
            return EKProperty.LabelContent(text: text ?? "", style: style)
        }
    }
}

extension UIButton {
    var buttonContent: EKProperty.ButtonContent {
        set {
            setTitle(newValue.label.text, for: .normal)
            setTitleColor(newValue.label.style.color, for: .normal)
            titleLabel?.font = newValue.label.style.font
            backgroundColor = newValue.backgroundColor
        }
        get {
            fatalError("buttonContent doesn't have a getter")
        }
    }
}

extension UIImageView {
    var imageContent: EKProperty.ImageContent {
        set {
            stopAnimating()
            animationImages = newValue.images
            animationDuration = newValue.imageSequenceAnimationDuration
            contentMode = newValue.contentMode
            
            if let size = newValue.size {
                set(.width, of: size.width)
                set(.height, of: size.height)
            } else {
                forceContentWrap()
            }
            
            if newValue.makesRound {
                clipsToBounds = true
                if let size = newValue.size {
                    layer.cornerRadius = min(size.width, size.height) * 0.5
                } else {
                    layoutIfNeeded()
                    layer.cornerRadius = min(bounds.width, bounds.height) * 0.5
                }
            }
            
            startAnimating()
            
            if case .animate(duration: let duration, options: let options, transform: let transform) = newValue.animation {
                let options: UIView.AnimationOptions = [.repeat, .autoreverse, options]
                // A hack that forces the animation to run on the main thread on one of the next run loops
                DispatchQueue.main.async {
                    UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                        self.transform = transform
                    }, completion: nil)
                }
            }
        }
        get {
            fatalError("imageContent doesn't have a getter")
        }
    }
}

extension UITextField {
    var textFieldContent: EKProperty.TextFieldContent {
        set {
            attributedPlaceholder = NSAttributedString(string: newValue.placeholder.text, attributes: [.font: newValue.placeholder.style.font, .foregroundColor: newValue.placeholder.style.color])
            keyboardType = newValue.keyboardType
            textColor = newValue.textStyle.color
            font = newValue.textStyle.font
            textAlignment = newValue.textStyle.alignment
            isSecureTextEntry = newValue.isSecure
            text = newValue.textContent
            tintColor = newValue.tintColor
        }
        get {
            fatalError("textFieldContent doesn't have a getter")
        }
    }
}
