//
//  VehicleItemData.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 15.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

class VehicleItemData : NSManagedObject
{
    @NSManaged var briefDescription: String?
    @NSManaged var detailsUrl: String?
    @NSManaged var mainPhoto: NSData?
    @NSManaged var mileage: NSNumber
    @NSManaged var name: String?
    @NSManaged var price: NSNumber
    @NSManaged var vehicleId: NSNumber
    @NSManaged var year: NSNumber
}