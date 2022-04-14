//
//  Alert.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation

public enum Alert {
    
    public struct ViewModel {
        public let title: String
        public let message: String
        public let button: String

        public init(title: String, message: String, button: String) {
            self.title = title
            self.message = message
            self.button = button
        }
    }
    
}
