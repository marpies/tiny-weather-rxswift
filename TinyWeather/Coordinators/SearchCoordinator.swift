//
//  SearchCoordinator.swift
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
import Swinject
import RxSwift
import RxCocoa

class SearchCoordinator: Coordinator {
    
    private let resolver: Resolver
    private var viewController: SearchViewController?
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    // Outputs
    private let _sceneDidHide: PublishRelay<Void> = PublishRelay()
    var sceneDidHide: Observable<Void> {
        return _sceneDidHide.asObservable()
    }
    
    weak var parent: Coordinator?
    var children: [Coordinator] = []
    let navigationController: UINavigationController

    init(navigationController: UINavigationController, resolver: Resolver) {
        self.navigationController = navigationController
        self.resolver = resolver
    }
    
    @discardableResult func start() -> UIViewController {
        let vm: SearchViewModelProtocol = self.resolver.resolve(SearchViewModelProtocol.self)!
        self.viewController = self.resolver.resolve(SearchViewController.self, argument: vm)
        
        vm.outputs.sceneDidHide
            .subscribe(onNext: { [weak self] in
                self?._sceneDidHide.accept(())
            })
            .disposed(by: self.disposeBag)
        
        if let root = self.navigationController.topViewController, let vc = self.viewController {
            root.addChild(vc)
            vc.view.frame = root.view.frame
            root.view.addSubview(vc.view)
            vc.didMove(toParent: root)
        }
        
        return self.viewController!
    }
    
    func animateIn() {
        self.viewController?.animateIn()
    }
    
    func dispose() {
        if self.viewController?.parent != nil {
            self.viewController?.willMove(toParent: nil)
            self.viewController?.view.removeFromSuperview()
            self.viewController?.removeFromParent()
        }
    }
    
    func animate(_ animation: RoutePanAnimation) {
        switch animation {
        case .began:
            self.viewController?.startScrubbingAnimation()
            
        case .changed(let translation):
            self.viewController?.updateAnimationProgress(translation: translation)
            break
            
        case .ended(let velocity):
            self.viewController?.finishAnimation(velocity: velocity)
            break
        }
    }
    
}