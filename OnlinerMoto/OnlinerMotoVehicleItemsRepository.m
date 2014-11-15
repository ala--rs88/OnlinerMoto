//
//  OnlinerMotoVehicleItemsRepository.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 21.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "OnlinerMotoVehicleItemsRepository.h"
#import "OnlinerMoto-Swift.h"

@interface OnlinerMotoVehicleItemsRepository ()

@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;

@end

@implementation OnlinerMotoVehicleItemsRepository

- (id)initWithObjectContext:(NSManagedObjectContext *)objectContext
{
    self = [super init];
    
    if (self)
    {     
        _managedObjectContext = objectContext;
    }
    
    return self;
}

#pragma mark -- VehicleItemsRepositoryProtocol Members

- (void)addVehicleItem:(VehicleItem *)vehicleItem
{
    VehicleItemData *newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"VehicleItem" inManagedObjectContext:self.managedObjectContext];
    
    // todo: IK consider aoutomapping
    newEntry.detailsUrl = vehicleItem.detailsUrl;
    newEntry.name = vehicleItem.name;
    
    newEntry.price = [NSNumber numberWithUnsignedInteger:vehicleItem.price];
    
    newEntry.mainPhoto = vehicleItem.mainPhoto;
    newEntry.briefDescription = vehicleItem.briefDescription;

    newEntry.mileage = [NSNumber numberWithUnsignedInteger:vehicleItem.mileage];
    newEntry.year = [NSNumber numberWithUnsignedInteger:vehicleItem.year];
    

    NSError *error;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Saving VehicleItemData failed: %@", [error localizedDescription]);
        abort();
    }
}

- (void)removeVehicleItemByDetailsUrl:(NSString *)detailsUrlOfItemToDelete
{
    // todo: IK reuse duplicating code
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"VehicleItem"
                                        inManagedObjectContext:self.managedObjectContext]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"detailsUrl == %@", detailsUrlOfItemToDelete]];
    
    NSError* error;
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error)
    {
        NSLog(@"Fetching VehicleItemData failed: %@", [error localizedDescription]);
        abort();
    }
    
    if ([fetchedRecords count] != 1)
    {
        NSLog(@"detailsUrl is not unique in storage.");
 //       abort();
    }
    
    [self.managedObjectContext deleteObject:fetchedRecords[0]];
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Deleting VehicleItemData failed: %@", [error localizedDescription]);
      //  abort();
    }
}

- (BOOL)isItemAlreadyPresentByDetailsUrl:(NSString *)detailsUrl
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"VehicleItem"
                                   inManagedObjectContext:self.managedObjectContext]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"detailsUrl == %@", detailsUrl]];
    
    [fetchRequest setIncludesSubentities:NO];
    
    NSError *error;
    NSUInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    if(count == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (NSArray *)getAllVehicleItems
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"VehicleItem"
                                        inManagedObjectContext:self.managedObjectContext]];
    
    NSError* error;
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error)
    {
        NSLog(@"Fetching VehicleItemData failed: %@", [error localizedDescription]);
        abort();
    }
    
    NSMutableArray* vehicleItems = [[NSMutableArray alloc] init];
    for (VehicleItemData *vehicleItemData in fetchedRecords)
    {
        VehicleItem *vehicleItem = [[VehicleItem alloc] init];
        
        // todo: consider automapping
        vehicleItem.detailsUrl = vehicleItemData.detailsUrl;
        vehicleItem.name = vehicleItemData.name;
        vehicleItem.price = vehicleItemData.price.integerValue;
        vehicleItem.mainPhoto = vehicleItemData.mainPhoto;
        vehicleItem.mileage = vehicleItemData.mileage.integerValue;
        vehicleItem.year = vehicleItemData.year.integerValue;
        vehicleItem.briefDescription = vehicleItemData.briefDescription;
        
        [vehicleItems insertObject:vehicleItem atIndex:0];
    }
    
    return vehicleItems;
}

@end
