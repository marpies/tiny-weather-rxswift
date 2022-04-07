//
//  LocationWeatherDb.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import CoreData

class LocationWeatherDb: NSManagedObject {
    
    enum Attributes {
        static let entityName: String = "LocationWeatherDb"
    }
    
    struct Model {
        let date: Date
        let condition: Int
        let conditionDescription: String
        let lastUpdate: Date
        let sunrise: Date
        let sunset: Date
        let windSpeed: Float
        let rainAmount: Float
        let temperature: Float
        let name: String
        let country: String
        let state: String?
        let lon: Double
        let lat: Double
    }
    
    @NSManaged var date: Date
    @NSManaged var condition: Int
    @NSManaged var conditionDescription: String
    @NSManaged var lastUpdate: Date
    @NSManaged var sunrise: Date
    @NSManaged var sunset: Date
    @NSManaged var windSpeed: Float
    @NSManaged var rainAmount: Float
    @NSManaged var temperature: Float
    @NSManaged var name: String
    @NSManaged var country: String
    @NSManaged var state: String?
    @NSManaged var lon: Double
    @NSManaged var lat: Double
    
    var model: LocationWeatherDb.Model {
        return LocationWeatherDb.Model(date: date, condition: condition, conditionDescription: conditionDescription, lastUpdate: lastUpdate, sunrise: sunrise, sunset: sunset, windSpeed: windSpeed, rainAmount: rainAmount, temperature: temperature, name: name, country: country, state: state, lon: lon, lat: lat)
    }
    
}
