//
//  OnlinerMotoAppDelegateProtocol.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 15.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

@objc protocol OnlinerMotoAppDelegateProtocol
{
    var vehicleItemsRepository: VehicleItemsRepositoryProtocol { get }
    var vehicleItemsProvider: VehicleItemsProviderProtocol { get }
    
    var vehicleItemFilter: VehicleItemFilter { get }
    var isFilterAlreadyApplied: Bool { get set }
}