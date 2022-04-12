//
//  DuotoneIcon.swift
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

public enum DuotoneIcon {
    
    public struct ViewModel {
        public let icon: FontIcon
        public let primaryColor: UIColor
        public let secondaryColor: UIColor
        
        public var isUnicolor: Bool {
            return self.primaryColor == self.secondaryColor
        }

        public init(icon: FontIcon, primaryColor: UIColor, secondaryColor: UIColor) {
            self.icon = icon
            self.primaryColor = primaryColor
            self.secondaryColor = secondaryColor
        }
        
        public init(icon: FontIcon, color: UIColor) {
            self.icon = icon
            self.primaryColor = color
            self.secondaryColor = color
        }
    }
}
