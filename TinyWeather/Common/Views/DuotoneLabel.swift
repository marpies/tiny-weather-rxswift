//
//  DuotoneLabel.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import UIKit

class DuotoneLabel: UIView {
    
    private let theme: Theme
    private let primaryLabel = UILabel()
    private let secondaryLabel = UILabel()
    
    init(theme: Theme) {
        self.theme = theme
        
        super.init(frame: .zero)
        
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // MARK: - Public
    //
    
    func setIconCode(_ value: UInt32) {
        let primary: UnicodeScalar = UnicodeScalar(value)!
        let secondary: UnicodeScalar = UnicodeScalar(0x100000 | value)!
        self.primaryLabel.text = primary.escaped(asASCII: false)
        self.secondaryLabel.text = secondary.escaped(asASCII: false)
    }
    
    func setColors(primary: UIColor, secondary: UIColor) {
        self.primaryLabel.textColor = primary
        self.secondaryLabel.textColor = secondary
    }
    
    func setColor(_ color: UIColor) {
        self.primaryLabel.textColor = color
        self.secondaryLabel.textColor = color.withAlphaComponent(0.5)
    }
    
    func setStyle(_ style: UIFont.TextStyle) {
        self.primaryLabel.font = self.theme.fonts.iconDuotone(style: style)
        self.secondaryLabel.font = self.theme.fonts.iconDuotone(style: style)
    }
    
    func setSize(_ size: CGFloat) {
        self.primaryLabel.font = self.theme.fonts.iconDuotone(size: size)
        self.secondaryLabel.font = self.theme.fonts.iconDuotone(size: size)
    }
    
    func setTextAlignment(_ alignment: NSTextAlignment) {
        self.primaryLabel.textAlignment = alignment
        self.secondaryLabel.textAlignment = alignment
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            // Primary label cannot have background color
            self.secondaryLabel.backgroundColor = self.backgroundColor
        }
    }
    
    //
    // MARK: - Private
    //
    
    private func setupView() {
        self.addSubview(self.secondaryLabel)
        self.secondaryLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(self.primaryLabel)
        self.primaryLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}
