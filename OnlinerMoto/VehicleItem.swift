//
//  VehicleItem.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 11.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

class VehicleItem : NSObject
{
    var vehicleId: NSNumber = 0
    var briefDescription: String?
    var mileage: Int = 0
    var year: Int = 0
    var name: String?
    var price: Int = 0
    var detailsUrl: String?
    var mainPhoto: NSData?
}