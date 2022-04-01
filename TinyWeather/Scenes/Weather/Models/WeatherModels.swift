//
//  WeatherModels.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský on 30.03.2022.
//  Copyright (c) 2022 Marcel Piestansky. All rights reserved.
//

import UIKit

enum Weather {
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    enum State {
        case loading, loaded, error
    }
	
    enum Location {
        struct ViewModel {
            let title: String
            let subtitle: String
            let flag: UIImage?
            let favoriteIcon: String
        }
    }
    
    enum Attribute {
        case rain(Float), wind(Float), sunrise(Date), sunset(Date)
        
        struct ViewModel {
            let title: String
            let icon: DuotoneIcon.ViewModel
        }
    }
    
    enum Condition {
        /// Code group 2xx
        case thunderstorm
        
        /// Code group 3xx
        case drizzle
        
        /// Code group 500 - 504
        case rain
        
        /// Code group 520 - 522 + 531
        case showerRain
        
        /// Code 511
        case freezingRain
        
        /// Codes 602, 621, 622
        case snow
        
        /// Codes 600, 601, 611, 612, 613, 615, 616, 620
        case lightSnow
        
        /// Code group 7xx
        case atmosphere
        
        /// Code 800
        case clear
        
        /// Code 801
        case fewClouds
        
        /// Code 802
        case scatteredClouds
        
        /// Code group 803 - 804
        case clouds
    }
    
    enum Info {
        struct Response: Codable {
            let id: Int
            let description: String
            let icon: String
            
            var condition: Weather.Condition {
                switch self.id {
                case 200...299:
                    return .thunderstorm
                    
                case 300...399:
                    return .drizzle
                    
                case 500...504:
                    return .rain
                    
                case 531, 520...522:
                    return .showerRain
                    
                case 511:
                    return .freezingRain
                    
                case 600, 601, 611, 612, 613, 615, 616, 620:
                    return .lightSnow
                    
                case 602, 621, 622:
                    return .snow
                    
                case 700...799:
                    return .atmosphere
                    
                case 801:
                    return .fewClouds
                    
                case 802:
                    return .scatteredClouds
                
                case 803, 804:
                    return .clouds
                    
                default:
                    assert(self.id == 800)
                    return .clear
                }
            }
            
            var isNight: Bool {
                return self.icon.contains("n.")
            }
        }
    }
    
    enum Current {
        struct Response: Codable {
            let weather: Weather.Info.Response
            let lastUpdate: Date
            let sunrise: Date
            let sunset: Date
            let temperature: Float
            let wind: Float
            let rain: Float
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: RootKeys.self)
                let sys = try container.nestedContainer(keyedBy: SysKeys.self, forKey: .sys)
                let main = try container.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
                let wind = try container.nestedContainer(keyedBy: WindKeys.self, forKey: .wind)
                let lastUpdateRaw = try container.decode(TimeInterval.self, forKey: .dt)
                let sunriseRaw = try sys.decode(TimeInterval.self, forKey: .sunrise)
                let sunsetRaw = try sys.decode(TimeInterval.self, forKey: .sunset)
                let weathers = try container.decode([Weather.Info.Response].self, forKey: .weather)
                
                guard let weather = weathers.first else {
                    throw Weather.Error.invalidData
                }
                
                self.weather = weather
                self.lastUpdate = Date(timeIntervalSince1970: lastUpdateRaw)
                self.sunrise = Date(timeIntervalSince1970: sunriseRaw)
                self.sunset = Date(timeIntervalSince1970: sunsetRaw)
                self.temperature = try main.decode(Float.self, forKey: .temp)
                self.wind = (try wind.decode(Float.self, forKey: .speed)) * 3.6 // km/h
                
                if container.contains(.rain) {
                    let rain = try container.nestedContainer(keyedBy: RainKeys.self, forKey: .rain)
                    self.rain = (try rain.decode(Float?.self, forKey: .oneHour)) ?? 0
                } else {
                    self.rain = 0
                }
            }
            
            enum RootKeys: String, CodingKey {
                case main, weather, dt, sys, wind, rain, timezone
            }
            
            enum SysKeys: String, CodingKey {
                case sunrise, sunset
            }
            
            enum MainKeys: String, CodingKey {
                case temp
            }
            
            enum WindKeys: String, CodingKey {
                case speed
            }
            
            enum RainKeys: String, CodingKey {
                case oneHour = "1h"
            }
        }
        
        struct ViewModel {
            let conditionIcon: DuotoneIcon.ViewModel
            let lastUpdate: String
            let lastUpdateIcon: DuotoneIcon.ViewModel
            let temperature: String
            let description: String
            let attributes: [Weather.Attribute.ViewModel]
        }
    }
    
}
