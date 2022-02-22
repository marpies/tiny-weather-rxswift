//
//  APIResource.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

enum APIResource {
    case geo(location: String)
    case weather(lat: Double, lon: Double)
}

extension APIResource: RequestProviding {
    
    var request: URLRequest? {
        switch self {
        case .geo, .weather:
            if var comps = URLComponents(string: self.url.absoluteString) {
                comps.queryItems = self.queryItems
                
                if let url = comps.url {
                    var request: URLRequest = URLRequest(url: url)
                    request.httpMethod = "GET"
                    return request
                }
            }
            return nil
        }
    }
    
    //
    // MARK: - Private
    //
    
    private var baseUrl: URL {
        return URL(string: "https://api.openweathermap.org/")!
    }
    
    private var url: URL {
        return self.baseUrl
            .appendingPathComponent(self.resourcePath)
            .appendingPathComponent(self.endpointPath)
    }
    
    private var resourcePath: String {
        switch self {
        case .geo:
            return "geo/1.0"
            
        case .weather:
            return "data/2.5"
        }
    }
    
    private var endpointPath: String {
        switch self {
        case .geo:
            return "direct"
            
        case .weather:
            return "weather"
        }
    }
    
    private var parameters: [String: String] {
        var params: [String: String]
        
        switch self {
        case .geo(let location):
            params = ["q": location, "limit": "5"]
        case .weather(let lat, let lon):
            let lat: String = String(format: "%.4f", lat)
            let lon: String = String(format: "%.4f", lon)
            params = ["lat": lat, "lon": lon]
        }
        
        params["appid"] = APISecrets.apiKey
        
        return params
    }
    
    private var queryItems: [URLQueryItem] {
        return self.parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    
}
