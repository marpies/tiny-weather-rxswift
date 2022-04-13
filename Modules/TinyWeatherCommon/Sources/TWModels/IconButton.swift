//
//  IconButton.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation

public enum IconButton {
    
    public struct ViewModel {
        public let icon: FontIcon
        public let title: String

        public init(icon: FontIcon, title: String) {
            self.icon = icon
            self.title = title
        }
    }
    
}
