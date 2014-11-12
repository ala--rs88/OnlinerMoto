//
//  VehicleItemDetails.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 12.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

class VehicleItemDetails : NSObject
{
    var vehicleItem: VehicleItem?
    var additionalDescription: String?
    var location: String?
    var allPhotos: Array<NSData>?

    override init() {}
    
    init(vehicleItem: VehicleItem)
    {
        self.vehicleItem = vehicleItem
    }
}
