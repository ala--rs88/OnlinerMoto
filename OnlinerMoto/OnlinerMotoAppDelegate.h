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

@property (readonly, strong, nonatomic) id<VehicleItemsRepositoryProtocol> vehicleItemsRepository;
@property (readonly, strong, nonatomic) id<VehicleItemsProviderProtocol> vehicleItemsProvider;
@property (readonly, nonatomic, strong) VehicleItemFilter *vehicleItemFilter;

@property (nonatomic) BOOL isFilterAlreadyApplied;

@end
