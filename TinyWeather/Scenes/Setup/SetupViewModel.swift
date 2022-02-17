//
//  SetupViewModel.swift
//  TinyWeather
//
//  Created Marcel Piešťanský on 17.02.2022.
//  Copyright © 2022 Marcel Piestansky. All rights reserved.
//

import Foundation
import RxSwift

protocol SetupViewModelInputs {

}

protocol SetupViewModelOutputs {
    
}

protocol SetupViewModelProtocol {
    var inputs: SetupViewModelInputs { get }
    var outputs: SetupViewModelOutputs { get }
}

class SetupViewModel: SetupViewModelProtocol, SetupViewModelInputs, SetupViewModelOutputs {

    var inputs: SetupViewModelInputs { return self }
    var outputs: SetupViewModelOutputs { return self }

    // Inputs

    // Outputs

}