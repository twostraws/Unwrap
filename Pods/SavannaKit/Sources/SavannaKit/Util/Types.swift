//
//  Types.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 24/06/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

#if os(macOS)
	
	import AppKit
	
	public typealias View			= NSView
	public typealias ViewController = NSViewController
	public typealias Window			= NSWindow
	public typealias Control		= NSControl
	public typealias TextView		= NSTextView
	public typealias TextField		= NSTextField
	public typealias Button			= NSButton
	public typealias Font			= NSFont
	public typealias Color			= NSColor
	public typealias StackView		= NSStackView
	public typealias Image			= NSImage
	public typealias BezierPath		= NSBezierPath
	public typealias ScrollView		= NSScrollView
	public typealias Screen			= NSScreen
	
#else
	
	import UIKit
	
	public typealias View			= UIView
	public typealias ViewController = UIViewController
	public typealias Window			= UIWindow
	public typealias Control		= UIControl
	public typealias TextView		= UITextView
	public typealias TextField		= UITextField
	public typealias Button			= UIButton
	public typealias Font			= UIFont
	public typealias Color			= UIColor
	public typealias StackView		= UIStackView
	public typealias Image			= UIImage
	public typealias BezierPath		= UIBezierPath
	public typealias ScrollView		= UIScrollView
	public typealias Screen			= UIScreen

#endif

