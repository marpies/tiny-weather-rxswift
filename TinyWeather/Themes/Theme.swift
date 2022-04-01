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
    
    var weather: WeatherColors { get }
}

protocol WeatherColors {
    var rain: UIColor { get }
    var sun: UIColor { get }
    var wind: UIColor { get }
    var moon: UIColor { get }
    var stars: UIColor { get }
    var cloud: UIColor { get }
    var bolt: UIColor { get }
    var fog: UIColor { get }
    var snow: UIColor { get }
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
