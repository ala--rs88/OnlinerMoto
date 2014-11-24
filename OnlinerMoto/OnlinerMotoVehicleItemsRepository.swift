//
//  OnlinerMotoVehicleItemsRepository.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 25.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

class OnlinerMotoVehicleItemsRepository : NSObject, VehicleItemsRepositoryProtocol
{
    private var managedObjectContext: NSManagedObjectContext!
    
    init(objectContext: NSManagedObjectContext)
    {
        self.managedObjectContext = objectContext
        
        super.init()
    }
    
    // MARK: - VehicleItemsRepositoryProtocol Implementation
    
    func addVehicleItem(vehicleItem: VehicleItem)
    {
        var newEntry = NSEntityDescription.insertNewObjectForEntityForName(
            "VehicleItem",
            inManagedObjectContext: self.managedObjectContext) as VehicleItemData
        
        newEntry.detailsUrl = vehicleItem.detailsUrl
        newEntry.name = vehicleItem.name
        newEntry.price = NSNumber(integer: vehicleItem.price)
        newEntry.mainPhoto = vehicleItem.mainPhoto
        newEntry.briefDescription = vehicleItem.briefDescription
        newEntry.mileage = NSNumber(integer: vehicleItem.mileage)
        newEntry.year = NSNumber(integer: vehicleItem.year)
        
        var error: NSError?
        if (!self.managedObjectContext.save(&error))
        {
            println("Saving VehicleItemData failed: \(error)")
        }
    }
    
    func removeVehicleItemByDetailsUrl(detailsUrlOfItemToDelete: String)
    {
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(
            "VehicleItem",
            inManagedObjectContext: self.managedObjectContext)
        fetchRequest.predicate = NSPredicate(format: "detailsUrl == %@", detailsUrlOfItemToDelete)
        
        var error: NSError?
        var fetchedRecords = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        
        if (error != nil
            || fetchedRecords == nil)
        {
            println("Fetching VehicleItemData failed: \(error)")
            return
        }
        
        if (fetchedRecords!.count != 1)
        {
            println("detailsUrl is not unique in storage.")
            return
        }
        
        self.managedObjectContext.deleteObject(fetchedRecords![0] as NSManagedObject)
        if (!self.managedObjectContext.save(&error))
        {
            println("Deleting VehicleItemData failed: \(error)")
        }
    }
    
    func isItemAlreadyPresentByDetailsUrl(detailsUrl: String) -> Bool
    {
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(
            "VehicleItem",
            inManagedObjectContext: self.managedObjectContext)
        fetchRequest.predicate = NSPredicate(format: "detailsUrl == %@", detailsUrl)
        fetchRequest.includesSubentities = false
        
        var error: NSError?
        var count = self.managedObjectContext.countForFetchRequest(fetchRequest, error: &error)
        
        return count == 0 ? false : true
    }
    
    func getAllVehicleItems() -> [VehicleItem]?
    {
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(
            "VehicleItem",
            inManagedObjectContext: self.managedObjectContext)
        
        var error: NSError?
        var fetchedRecords = [VehicleItemData]?()
        fetchedRecords = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as [VehicleItemData]?
        
        if (error != nil
            || fetchedRecords == nil)
        {
            println("Fetching VehicleItemData failed: \(error)")
            return nil
        }
        
        var vehicleItems = [VehicleItem]()
        for vehicleItemData in fetchedRecords!
        {
            var vehicleItem = VehicleItem()
            
            vehicleItem.detailsUrl = vehicleItemData.detailsUrl;
            vehicleItem.name = vehicleItemData.name;
            vehicleItem.price = vehicleItemData.price.integerValue;
            vehicleItem.mainPhoto = vehicleItemData.mainPhoto;
            vehicleItem.mileage = vehicleItemData.mileage.integerValue;
            vehicleItem.year = vehicleItemData.year.integerValue;
            vehicleItem.briefDescription = vehicleItemData.briefDescription;
            
            vehicleItems.append(vehicleItem)
        }
        
        return vehicleItems
    }
    
    // MARK: -
}