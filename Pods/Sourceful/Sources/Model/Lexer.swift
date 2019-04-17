//
//  Lexer.swift
//  SavannaKit iOS
//
//  Created by Louis D'hauwe on 04/02/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public protocol Lexer {
	
	func getSavannaTokens(input: String) -> [Token]
	
}
