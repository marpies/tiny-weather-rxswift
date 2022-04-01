//
//  WeatherAttributeView.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import UIKit

class WeatherAttributeView: UIStackView {
    
    private let theme: Theme
    private let titleLabel: UILabel = UILabel()
    private let iconView: DuotoneLabel

    init(theme: Theme) {
        self.theme = theme
        self.iconView = DuotoneLabel(theme: theme)
        
        super.init(frame: .zero)
        
        self.setupView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // MARK: - Public
    //
    
    func update(viewModel: Weather.Attribute.ViewModel) {
        self.iconView.updateIcon(viewModel: viewModel.icon)
        self.titleLabel.text = viewModel.title
    }
    
    //
    // MARK: - Private
    //
    
    private func setupView() {
        self.axis = .vertical
        self.spacing = 4
        self.alignment = .center
        
        self.iconView.setStyle(.title1)
        self.iconView.backgroundColor = self.theme.colors.background
        self.addArrangedSubview(self.iconView)
        
        self.titleLabel.font = self.theme.fonts.primary(style: .body)
        self.titleLabel.textColor = self.theme.colors.label
        self.titleLabel.backgroundColor = self.theme.colors.background
        self.addArrangedSubview(self.titleLabel)
    }

}
