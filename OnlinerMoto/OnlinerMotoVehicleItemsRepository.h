//
//  OnlinerMotoVehicleItemsRepository.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 21.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnlinerMoto-Swift.h"

@class VehicleItem;

@interface OnlinerMotoVehicleItemsRepository : NSObject <VehicleItemsRepositoryProtocol>

- (id)initWithObjectContext:(NSManagedObjectContext *)objectContext;

- (void)addVehicleItem:(VehicleItem *)vehicleItem;
- (void)removeVehicleItemByDetailsUrl:(NSString *)detailsUrlOfItemToDelete;
- (BOOL)isItemAlreadyPresentByDetailsUrl:(NSString *)detailsUrl;
- (NSArray *)getAllVehicleItems;

@end
