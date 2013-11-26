//
//  OnlinerMotoAppDelegateProtocol.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 25.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VehicleItemFilter;
@protocol VehicleItemsRepositoryProtocol;
@protocol VehicleItemsProviderProtocol;

@protocol OnlinerMotoAppDelegateProtocol

@required

@property (readonly, strong, nonatomic) id<VehicleItemsRepositoryProtocol> vehicleItemsRepository;
@property (readonly, strong, nonatomic) id<VehicleItemsProviderProtocol> vehicleItemsProvider;
@property (readonly, strong, nonatomic) VehicleItemFilter *vehicleItemFilter;

@property (nonatomic) BOOL isFilterAlreadyApplied;

@end
