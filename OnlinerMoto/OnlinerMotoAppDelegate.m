//
//  OnlinerMotoAppDelegate.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "OnlinerMotoAppDelegate.h"
#import "VehicleItemsRepositoryProtocol.h"
#import "VehicleItemsProviderProtocol.h"
#import "VehicleItemFilter.h"

#import "OnlinerMotoVehicleItemsRepository.h"
#import "OnlinerWebVehileItemsProvider.h"

@interface OnlinerMotoAppDelegate ()
{
    NSObject *_repositoryLockObject;
    NSObject *_providerLockObject;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

@implementation OnlinerMotoAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize vehicleItemsRepository = _vehicleItemsRepository;
@synthesize vehicleItemsProvider = _vehicleItemsProvider;
@synthesize vehicleItemFilter = _vehicleItemFilter;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _repositoryLockObject = [[NSObject alloc] init];
    _providerLockObject = [[NSObject alloc] init];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (VehicleItemFilter *)vehicleItemFilter
{
    if (_vehicleItemFilter)
    {
        return _vehicleItemFilter;
    }
    
    _vehicleItemFilter = [[VehicleItemFilter alloc] init];
    
    return _vehicleItemFilter;
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"OnlinerMoto" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"OnlinerMoto.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark -- Vehicle Items Repository

- (id<VehicleItemsRepositoryProtocol>)vehicleItemsRepository
{
    @synchronized(_repositoryLockObject)
    {
        if (_vehicleItemsRepository != nil)
        {
            return _vehicleItemsRepository;
        }
    
        _vehicleItemsRepository = [[OnlinerMotoVehicleItemsRepository alloc] initWithObjectContext:self.managedObjectContext];
    
        return _vehicleItemsRepository;
    }
}

#pragma mark - Data providers

- (id<VehicleItemsProviderProtocol>)vehicleItemsProvider
{
    @synchronized(_providerLockObject)
    {
        if (_vehicleItemsProvider != nil)
        {
            return _vehicleItemsProvider;
        }
    
        _vehicleItemsProvider = [[OnlinerWebVehileItemsProvider alloc] init];
    
        return _vehicleItemsProvider;
    }
}



@end
