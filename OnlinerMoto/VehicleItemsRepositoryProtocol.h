//
//  VehicleItemsRepositoryProtocol.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 21.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VehicleItem;

@protocol VehicleItemsRepositoryProtocol <NSObject>

@required

- (void)addVehicleItem:(VehicleItem *)vehicleItem;
- (void)removeVehicleItemByDetailsUrl:(NSString *)detailsUrlOfItemToDelete;
- (BOOL)isItemAlreadyPresentByDetailsUrl:(NSString *)detailsUrl;

// todo: IK implement fetching by portions
- (NSArray *)getAllVehicleItems;


@end
