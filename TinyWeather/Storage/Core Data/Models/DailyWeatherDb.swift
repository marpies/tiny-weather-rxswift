//
//  DailyWeatherDb.swift
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

class DailyWeatherDb: NSManagedObject {
    
    enum Attributes {
        static let entityName: String = "DailyWeatherDb"
    }
    
    struct Model {
        let date: Date
        let condition: Int
        let windSpeed: Float
        let rainAmount: Float
        let minTemperature: Float
        let maxTemperature: Float
    }
    
    @NSManaged var date: Date
    @NSManaged var condition: Int
    @NSManaged var windSpeed: Float
    @NSManaged var rainAmount: Float
    @NSManaged var minTemperature: Float
    @NSManaged var maxTemperature: Float
    
    var model: DailyWeatherDb.Model {
        return DailyWeatherDb.Model(date: self.date, condition: self.condition, windSpeed: self.windSpeed, rainAmount: self.rainAmount, minTemperature: self.minTemperature, maxTemperature: self.maxTemperature)
    }
    
}

