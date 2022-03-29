//
//  SearchModels.swift
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
import RxCocoa

enum Search {
    
    struct Model {
        let hintCities: BehaviorRelay<[Search.City.Response]?> = BehaviorRelay(value: nil)
        
        func getCity(at index: Int) -> Search.City.Response? {
            if index >= 0, let cities = self.hintCities.value, index < cities.count {
                return cities[index]
            }
            return nil
        }
    }
    
    enum AnimationState {
        /// Animation is in the hidden state.
        case hidden
        
        /// Animation is in the visible state.
        case visible
        
        /// Returns the opposite state.
        var opposite: Search.AnimationState {
            switch self {
            case .hidden:
                return .visible
            case .visible:
                return .hidden
            }
        }
    }
    
    enum City {
        struct Response: Codable {
            let name: String
            let state: String?
            let country: String
            let lon: Double
            let lat: Double
        }
        
        struct ViewModel {
            let flag: UIImage?
            let title: String
            let subtitle: String
        }
    }
    
    enum SearchHints {
        case loading
        case empty(message: String)
        case results(cities: [Search.City.ViewModel])
        case error(message: String)
    }
    
}
