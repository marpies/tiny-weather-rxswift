//
//  WeatherModels.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
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
        case rain(Float), snow(Float), wind(Float), sunrise(TimeInterval), sunset(TimeInterval)
        
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
        
        /// Code 500
        case lightRain
        
        /// Code group 501 - 504
        case rain
        
        /// Code group 520 - 522 + 531
        case showerRain
        
        /// Codes 302, 312, 314, 502 - 504, 522
        case heavyRain
        
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
    
    enum Temperature {
        struct ViewModel {
            let title: String
            let color: UIColor
        }
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
                    
                case 302, 312, 314, 502...504, 522:
                    return .heavyRain
                    
                case 300...399:
                    return .drizzle
                    
                case 500:
                    return .lightRain
                    
                case 501:
                    return .rain
                    
                case 520, 521, 531:
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
                return self.icon.contains("n")
            }
        }
    }
    
    enum Current {
        struct Response: Codable {
            let weather: Weather.Info.Response
            let lastUpdate: TimeInterval
            let sunrise: TimeInterval
            let sunset: TimeInterval
            let temperature: Float
            let windSpeed: Float
            let rain: Float
            let snow: Float
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: RootKeys.self)
                let weathers = try container.decode([Weather.Info.Response].self, forKey: .weather)
                
                guard let weather = weathers.first else {
                    throw Weather.Error.invalidData
                }
                
                self.weather = weather
                self.lastUpdate = try container.decode(TimeInterval.self, forKey: .time)
                self.sunrise = try container.decode(TimeInterval.self, forKey: .sunrise)
                self.sunset = try container.decode(TimeInterval.self, forKey: .sunset)
                self.temperature = try container.decode(Float.self, forKey: .temp)
                self.windSpeed = (try container.decode(Float.self, forKey: .windSpeed)) * 3.6 // km/h
                
                if container.contains(.rain) {
                    let rain = try container.nestedContainer(keyedBy: RainKeys.self, forKey: .rain)
                    if rain.contains(.oneHour) {
                        self.rain = try rain.decode(Float.self, forKey: .oneHour).rounded()
                    } else if rain.contains(.threeHour) {
                        self.rain = try rain.decode(Float.self, forKey: .threeHour).rounded()
                    } else {
                        self.rain = 0
                    }
                } else {
                    self.rain = 0
                }
                
                if container.contains(.snow) {
                    let snow = try container.nestedContainer(keyedBy: SnowKeys.self, forKey: .snow)
                    if snow.contains(.oneHour) {
                        self.snow = try snow.decode(Float.self, forKey: .oneHour).rounded()
                    } else if snow.contains(.threeHour) {
                        self.snow = try snow.decode(Float.self, forKey: .threeHour).rounded()
                    } else {
                        self.snow = 0
                    }
                } else {
                    self.snow = 0
                }
            }
            
            enum RootKeys: String, CodingKey {
                case weather, rain, snow, timezone, temp, sunrise, sunset
                case windSpeed = "wind_speed"
                case time = "dt"
            }
            
            enum RainKeys: String, CodingKey {
                case oneHour = "1h"
                case threeHour = "3h"
            }
            
            enum SnowKeys: String, CodingKey {
                case oneHour = "1h"
                case threeHour = "3h"
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
    
    enum Day {
        struct Response: Codable {
            let date: TimeInterval
            let weather: Weather.Info.Response
            let tempMin: Float
            let tempMax: Float
            let rain: Float
            let snow: Float
            let windSpeed: Float
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: RootKeys.self)
                
                let weathers = try container.decode([Weather.Info.Response].self, forKey: .weather)
                
                guard let weather = weathers.first else {
                    throw Weather.Error.invalidData
                }
                
                self.weather = weather
                self.date = try container.decode(TimeInterval.self, forKey: .date)
                
                let temps = try container.nestedContainer(keyedBy: TempKeys.self, forKey: .temp)
                self.tempMin = try temps.decode(Float.self, forKey: .min)
                self.tempMax = try temps.decode(Float.self, forKey: .max)
                
                self.windSpeed = try container.decode(Float.self, forKey: .windSpeed)
                
                if container.contains(.rain) {
                    self.rain = try container.decode(Float.self, forKey: .rain).rounded()
                } else {
                    self.rain = 0
                }
                
                if container.contains(.snow) {
                    self.snow = try container.decode(Float.self, forKey: .snow).rounded()
                } else {
                    self.snow = 0
                }
            }
            
            enum RootKeys: String, CodingKey {
                case weather, rain, snow, timezone, temp
                case windSpeed = "wind_speed"
                case date = "dt"
            }
            
            enum TempKeys: String, CodingKey {
                case min, max
            }
        }
        
        struct ViewModel: Hashable {
            let id: UUID
            let dayOfWeek: String
            let date: String
            let conditionIcon: DuotoneIcon.ViewModel
            let tempMin: Weather.Temperature.ViewModel
            let tempMax: Weather.Temperature.ViewModel
            let attributes: [Weather.Attribute.ViewModel]
            
            static func == (lhs: Weather.Day.ViewModel, rhs: Weather.Day.ViewModel) -> Bool {
                return lhs.id == rhs.id
            }
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
            }
        }
    }
    
    enum Overview {
        struct Response: Codable {
            let timezoneOffset: TimeInterval
            let current: Weather.Current.Response
            let daily: [Weather.Day.Response]
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: RootKeys.self)
                
                self.timezoneOffset = try container.decode(TimeInterval.self, forKey: .timezoneOffset)
                self.current = try container.decode(Weather.Current.Response.self, forKey: .current)
                self.daily = try container.decode([Weather.Day.Response].self, forKey: .daily)
            }
            
            enum RootKeys: String, CodingKey {
                case current, daily, timezoneOffset = "timezone_offset"
            }
        }
        
        struct ViewModel {
            let current: Weather.Current.ViewModel
            let daily: [Weather.Day.ViewModel]
        }
    }
    
}
