//
//  WeakRouter.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

public struct WeakRouter<RouteType>: Router {
    
    private let route: (RouteType) -> Void
    
    public init<T: Router & AnyObject>(_ router: T) where T.RouteType == RouteType {
        self.route = { [weak router] (route) in
            router?.route(to: route)
        }
    }
    
    public func route(to route: RouteType) {
        self.route(route)
    }
    
}
