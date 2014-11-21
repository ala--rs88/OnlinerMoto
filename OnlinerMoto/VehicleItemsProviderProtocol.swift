//
//  VehicleItemsProviderProtocol.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 15.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

@objc protocol VehicleItemsProviderProtocol
{
    var totalItemsCount: Int { get }
    
    func applyFilter(filter: VehicleItemFilter?)
    
    func getItems(startIndex: Int, itemsCount:Int) -> [VehicleItem]?
    func getItemDetailsForItem(item: VehicleItem) -> VehicleItemDetails?
}