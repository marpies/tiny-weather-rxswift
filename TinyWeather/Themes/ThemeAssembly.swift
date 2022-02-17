//
//  ThemeAssembly.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský on 17.02.2022.
//  Copyright (c) 2022 Marcel Piestansky. All rights reserved.
//

import Foundation
import Swinject

struct ThemeAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(Theme.self) { r in
            return AppTheme()
        }
    }
    
}
