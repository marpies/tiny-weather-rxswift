//
//  SetupViewController.swift
//  TinyWeather
//
//  Created Marcel Piešťanský on 17.02.2022.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//

import UIKit
import RxSwift

class SetupViewController: UIViewController {
    
    let viewModel: SetupViewModelProtocol

    init(viewModel: SetupViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemBackground
        
        self.bindViewModel()
    }

    //
    // MARK: - View model bindable
    //

    private func bindViewModel() {
        //
    }
    
}
