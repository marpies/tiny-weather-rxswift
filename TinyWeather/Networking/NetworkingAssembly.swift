//
//  NetworkingAssembly.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský on 22.02.2022.
//  Copyright (c) 2022 Marcel Piestansky. All rights reserved.
//

import Foundation
import Swinject

struct NetworkingAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(RequestExecuting.self) { r in
            return DefaultRequestExecutor()
        }
    }
    
}
