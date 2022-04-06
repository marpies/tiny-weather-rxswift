//
//  DailyWeatherTableDataSource.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import UIKit

class DailyWeatherTableDataSource {
    
    private let tableView: UITableView
    
    private var viewModel: [Weather.Day.ViewModel] = []
    
    let dataSource: UITableViewDiffableDataSource<Int, Weather.Day.ViewModel>
    
    init(tableView: UITableView, theme: Theme) {        
        let cellProvider: DailyWeatherTableCellProvider = DailyWeatherTableCellProvider(tableView: tableView, theme: theme)
        
        self.tableView = tableView
        self.dataSource = UITableViewDiffableDataSource<Int, Weather.Day.ViewModel>(tableView: tableView, cellProvider: cellProvider.cellFactory)
        self.dataSource.defaultRowAnimation = .fade
        
        tableView.dataSource = self.dataSource
    }
    
    func update(viewModel: [Weather.Day.ViewModel]) {
        self.viewModel = viewModel
        
        var snapshot = self.dataSource.snapshot()
        if snapshot.numberOfSections > 0 {
            snapshot.deleteSections([0])
        }
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel, toSection: 0)
        self.dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
    }
    
    func add(viewModel: Weather.Day.ViewModel) {
        var snapshot = self.dataSource.snapshot()
        if snapshot.numberOfSections == 0 {
            snapshot.appendSections([0])
        }
        snapshot.appendItems([viewModel], toSection: 0)
        self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    func removeAll() {
        var snapshot = self.dataSource.snapshot()
        if snapshot.numberOfSections > 0 {
            snapshot.deleteAllItems()
            self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
        }
    }
    
}
