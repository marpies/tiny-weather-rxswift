//
//  AppCoordinator.swift
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
import Swinject

class AppCoordinator: Coordinator {
    
    private let resolver: Resolver
    private let navigationController: UINavigationController

    init(assembler: Assembler) {
        self.resolver = assembler.resolver
        self.navigationController = UINavigationController()
        self.setupAssembler(assembler)
    }
    
    @discardableResult func start() -> UIViewController {
        let vm: SetupViewModelProtocol = self.resolver.resolve(SetupViewModelProtocol.self)!
        let vc: SetupViewController = self.resolver.resolve(SetupViewController.self, argument: vm)!
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.navigationController.setViewControllers([vc], animated: false)
        
        return self.navigationController
    }
    
    //
    // MARK: - Private
    //
    
    private func setupAssembler(_ assembler: Assembler) {
        assembler.apply(assemblies: [
            SetupAssembly()
        ])
    }
    
}
