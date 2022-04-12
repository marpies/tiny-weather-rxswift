//
//  WeatherLocation.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

public protocol WeatherLocation {
    var name: String { get }
    var state: String? { get }
    var country: String { get }
    var lon: Double { get }
    var lat: Double { get }
}
