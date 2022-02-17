//
//  AppDelegate.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import UIKit
import Swinject

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var coordinator: Coordinator?
    private var assembler: Assembler?

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.assembler = Assembler()
        self.coordinator = AppCoordinator(assembler: self.assembler!)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .black
        self.window?.rootViewController = self.coordinator?.start()
        self.window?.makeKeyAndVisible()
        
        return true
    }


}

