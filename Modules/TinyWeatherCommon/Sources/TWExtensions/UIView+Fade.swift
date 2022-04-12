//
//  UIView+Fade.swift
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

public extension UIView {
    
    func fadeIn() {
        self.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
    func fadeOut() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 0
        }, completion: nil)
    }
    
}
