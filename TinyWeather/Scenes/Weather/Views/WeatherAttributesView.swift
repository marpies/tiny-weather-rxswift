//
//  WeatherAttributesView.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import UIKit

class WeatherAttributesView: UIStackView {
    
    private let theme: Theme

    init(theme: Theme) {
        self.theme = theme
        
        super.init(frame: .zero)
        
        self.setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // MARK: - Public
    //
    
    func update(viewModel: [Weather.Attribute.ViewModel]) {
        for vm in viewModel {
            let view: WeatherAttributeView = WeatherAttributeView(theme: self.theme)
            view.update(viewModel: vm)
            self.addArrangedSubview(view)
        }
    }
    
    //
    // MARK: - Private
    //
    
    private func setupView() {
        self.axis = .horizontal
        self.spacing = 24
    }

}
