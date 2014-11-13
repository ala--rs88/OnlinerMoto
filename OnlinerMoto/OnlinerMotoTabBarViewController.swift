//
//  OnlinerMotoTabBarViewController.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 13.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

class OnlinerMotoTabBarViewController : UITabBarController, UITabBarControllerDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    func tabBarController(
        tabBarController: UITabBarController,
        didSelectViewController viewController: UIViewController)
    {
        if let vehiclesViewController = viewController as? OnlinerMotoVehiclesViewController
        {
            vehiclesViewController.checkForFilterChanges()
        }
    }
}