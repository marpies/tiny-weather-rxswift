//
//  DuotoneIconButton.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation
import UIKit.UIFont

public enum IconButton {
    
    public struct ViewModel {
        public let icon: FontIcon
        public let title: String
        public let font: UIFont

        public init(icon: FontIcon, title: String, font: UIFont) {
            self.icon = icon
            self.title = title
            self.font = font
        }
    }
    
}
