//
//  FavoritesTableDataSource.swift
//  TinyWeather
//
//  Created by Marcel Piešťanský.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import UIKit
import TWThemes

class FavoritesTableDataSource {

    private let tableView: UITableView

    private var viewModel: [Search.Location.ViewModel] = []

    let dataSource: UITableViewDiffableDataSource<Int, Search.Location.ViewModel>

    init(tableView: UITableView, theme: Theme) {
        let cellProvider: FavoritesTableCellProvider = FavoritesTableCellProvider(tableView: tableView, theme: theme)

        self.tableView = tableView
        self.dataSource = UITableViewDiffableDataSource<Int, Search.Location.ViewModel>(tableView: tableView, cellProvider: cellProvider.cellFactory)
        self.dataSource.defaultRowAnimation = .fade

        tableView.dataSource = self.dataSource
    }

    func update(viewModel: [Search.Location.ViewModel]) {
        self.viewModel = viewModel

        var snapshot = self.dataSource.snapshot()
        if snapshot.numberOfSections > 0 {
            snapshot.deleteSections([0])
        }
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel, toSection: 0)
        self.dataSource.apply(snapshot, animatingDifferences: true, completion: nil)
    }

}
