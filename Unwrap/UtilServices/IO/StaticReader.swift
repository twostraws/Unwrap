//
//  StaticReader.swift
//  Unwrap
//
//  Created by Mohammed mohsen on 2/25/21.
//  Copyright © 2021 Hacking with Swift. All rights reserved.
//

import Foundation

struct StaticReader: Reader {
    private var staticText: String
    public var text: String {
        set {
            // put any condition here bro !!!
            staticText = newValue
        }
        get { return staticText }
    }
    
    init(text: String)  {
        staticText = text;
    }
    func reader() -> String {
        return staticText
    }
}
