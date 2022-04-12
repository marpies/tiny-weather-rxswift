//
//  UIColor+ColorTransition.swift
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

public extension UIColor {
    
    func toColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage: CGFloat = max(min(percentage, 1), 0)
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }
            
            return UIColor(red: (r1 + (r2 - r1) * percentage),
                           green: (g1 + (g2 - g1) * percentage),
                           blue: (b1 + (b2 - b1) * percentage),
                           alpha: (a1 + (a2 - a1) * percentage))
        }
    }
    
}
