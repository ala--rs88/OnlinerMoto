//
//  VehicleItemsRepositoryProtocol.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 15.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

@objc protocol VehicleItemsRepositoryProtocol
{
    func addVehicleItem(vehicleItem: VehicleItem)
    func removeVehicleItemByDetailsUrl(detailsUrlOfItemToDelete: String)
    
    func isItemAlreadyPresentByDetailsUrl(detailsUrl: String) -> Bool
    func getAllVehicleItems() -> [VehicleItem]?
}