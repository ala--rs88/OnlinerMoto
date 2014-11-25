//
//  OnlinerMotoAppDelegate.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 25.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

@UIApplicationMain
class OnlinerMotoAppDelegate : UIResponder, UIApplicationDelegate, OnlinerMotoAppDelegateProtocol
{
    private let REPOSITORY_LOCK_QUEUE = dispatch_queue_create("com.OnlinerMoto.RepositoryLockQueue", DISPATCH_QUEUE_SERIAL)
    private let PROVIDER_LOCK_QUEUE = dispatch_queue_create("com.OnlinerMoto.ProviderLockQueue", DISPATCH_QUEUE_SERIAL)
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        var modelUrl = NSBundle.mainBundle().URLForResource("OnlinerMoto", withExtension: "momd")!
        var model = NSManagedObjectModel(contentsOfURL: modelUrl)
        return model!
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        [unowned self] in
        
        var storeURL = self.applicationDocumentsDirectory()?.URLByAppendingPathComponent("OnlinerMoto.sqlite")
        
        var error: NSError?
        var persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        if (persistentStoreCoordinator.addPersistentStoreWithType(
                NSSQLiteStoreType,
                configuration: nil,
                URL: storeURL!,
                options: nil,
                error: &error) == nil)
        {
            println("Unresolved error  \(error), \(error?.userInfo)")
        }
        
        return persistentStoreCoordinator
    }()
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        [unowned self] in
        
        var coordinator = self.persistentStoreCoordinator
        var context = NSManagedObjectContext()
        context.persistentStoreCoordinator = coordinator
        
        return context
    }()
    
    private(set) internal lazy var vehicleItemsRepository: VehicleItemsRepositoryProtocol = OnlinerMotoVehicleItemsRepository(objectContext: self.managedObjectContext)
    
    private(set) internal lazy var vehicleItemsProvider: VehicleItemsProviderProtocol = OnlinerWebVehileItemsProvider()
    private(set) internal lazy var vehicleItemFilter = VehicleItemFilter()

    var isFilterAlreadyApplied = false
    
    var window: UIWindow?
    
    func applicationWillTerminate(application: UIApplication) {
        self.saveContext()
    }
    
    private func applicationDocumentsDirectory() -> NSURL?
    {
        var url = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last
            as NSURL?
        
        return url
    }
    
    private func saveContext()
    {
        var error: NSError?
        var context = self.managedObjectContext
        if (context.hasChanges && !context.save(&error))
        {
            println("Unresolved error  \(error)")
        }
    }
}