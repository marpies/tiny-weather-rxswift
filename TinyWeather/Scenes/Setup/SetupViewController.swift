//
//  SetupViewController.swift
//  TinyWeather
//
//  Created Marcel Piešťanský on 17.02.2022.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//

import UIKit
import SnapKit

class SetupViewController: UIViewController {
    
    private let viewModel: SetupViewModelProtocol

    init(viewModel: SetupViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = self.viewModel.theme.colors.background
        
        self.bindViewModel()
    }

    //
    // MARK: - View model bindable
    //

    private func bindViewModel() {
        let inputs: SetupViewModelInputs = self.viewModel.inputs
        
        inputs.viewDidLoad.accept(())
    }
    
}
