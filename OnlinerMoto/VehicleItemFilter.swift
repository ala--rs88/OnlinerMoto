//
//  VehicleItemFilter.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 13.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

class VehicleItemFilter : NSObject
{
    var minPrice: UInt = 0
    var maxPrice: UInt = 0
    
    var minYear: UInt = 0
    var maxYear: UInt = 0
    
    var minEngineVolume: UInt = 0
    var maxEngineVolume: UInt = 0
}