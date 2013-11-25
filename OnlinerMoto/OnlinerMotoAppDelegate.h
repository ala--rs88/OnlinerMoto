//
//  OnlinerMotoAppDelegate.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OnlinerMotoAppDelegateProtocol.h"
@class VehicleItemFilter;

@interface OnlinerMotoAppDelegate : UIResponder <UIApplicationDelegate, OnlinerMotoAppDelegateProtocol>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, nonatomic, strong) VehicleItemFilter *vehicleItemFilter;

@property (nonatomic) BOOL isFilterAlreadyApplied;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
