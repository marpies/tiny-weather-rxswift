//
//  DynamicColor.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import UIKit.UIColor

/// Wrapper around `UIColor` providing support for dynamic color that allows transition between another color.
/// When we calculate a transition between `UIColor` objects directly, we loose the user interface style adaptivity.
class DynamicColor {
    let lightColor: UIColor
    let darkColor: UIColor
    let color: UIColor
    
    init(lightColor: UIColor, darkColor: UIColor) {
        self.lightColor = lightColor
        self.darkColor = darkColor
        self.color = UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return darkColor
            }
            return lightColor
        }
    }
    
    func toColor(_ color: DynamicColor, percentage: CGFloat) -> UIColor {
        let lightColor: UIColor = self.lightColor.toColor(color.lightColor, percentage: percentage)
        let darkColor: UIColor = self.darkColor.toColor(color.darkColor, percentage: percentage)
        return UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return darkColor
            }
            return lightColor
        }
    }
    
}
