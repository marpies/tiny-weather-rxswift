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

public protocol Theme {
    var colors: ThemeColors { get }
    var fonts: ThemeFonts { get }
}

public protocol ThemeColors {
    var background: UIColor { get }
    var secondaryBackground: UIColor { get }
    
    var label: UIColor { get }
    var secondaryLabel: UIColor { get }
    
    var separator: UIColor { get }
    
    var shadow: UIColor { get }
    
    var weather: WeatherColors { get }
    var temperatures: TemperatureColors { get }
}

public protocol WeatherColors {
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

public protocol TemperatureColors {
    /// 36°C and above
    var superHot: DynamicColor { get }
    
    /// 30°C and above
    var hot: DynamicColor { get }
    
    /// 20°C and above
    var warm: DynamicColor { get }
    
    /// 10°C and above
    var neutral: DynamicColor { get }
    
    /// 0°C and above
    var zero: DynamicColor { get }
    
    /// -10°C and above
    var cold: DynamicColor { get }
    
    /// Below -25°C
    var superCold: DynamicColor { get }
}

public protocol ThemeFonts {
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

public protocol ThemeProviding {
    var theme: Theme { get }
}
