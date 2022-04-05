//
//  DailyWeatherTableCellProvider.swift
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

struct DailyWeatherTableCellProvider {
    
    private let cellId: String = "weather"
    private let theme: Theme
    
    init(tableView: UITableView, theme: Theme) {
        self.theme = theme
        
        tableView.register(WeatherDayTableViewCell.self, forCellReuseIdentifier: self.cellId)
    }
    
    func cellFactory(tableView: UITableView, indexPath: IndexPath, viewModel: Weather.Day.ViewModel) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellId, for: indexPath) as! WeatherDayTableViewCell
        
        cell.theme = self.theme
        cell.update(viewModel: viewModel)
        
        return cell
    }
    
}
