//
//  Theme.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import UIKit

protocol Theme {
    var colors: ThemeColors { get }
    var fonts: ThemeFonts { get }
}

protocol ThemeColors {
    var background: UIColor { get }
    var secondaryBackground: UIColor { get }
    
    var label: UIColor { get }
    var secondaryLabel: UIColor { get }
    
    var separator: UIColor { get }
    
    var shadow: UIColor { get }
}

protocol ThemeFonts {
    func primary(style: UIFont.TextStyle) -> UIFont
    func primaryBold(style: UIFont.TextStyle) -> UIFont
    func primary(size: CGFloat) -> UIFont
    func primaryBold(size: CGFloat) -> UIFont
    func iconLight(style: UIFont.TextStyle) -> UIFont
    func iconSolid(style: UIFont.TextStyle) -> UIFont
    func iconDuotone(style: UIFont.TextStyle) -> UIFont
    func iconLight(size: CGFloat) -> UIFont
    func iconSolid(size: CGFloat) -> UIFont
    func iconDuotone(size: CGFloat) -> UIFont
}

protocol ThemeProviding {
    var theme: Theme { get }
}
