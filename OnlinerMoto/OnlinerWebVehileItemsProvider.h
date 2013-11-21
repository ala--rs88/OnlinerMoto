//
//  OnlinerWebVehileItemsProvider.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 4.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VehicleItemsProviderProtocol.h"
@class VehicleItem;
@class VehicleItemDetails;
@class VehicleItemFilter;

@interface OnlinerWebVehileItemsProvider : NSObject <VehicleItemsProviderProtocol>

@property (readonly, nonatomic, assign) NSUInteger totalItemsCount;

- (id)init;

- (void)applyFilter:(VehicleItemFilter *)filter;
- (NSArray *)getItemsFromIndex:(NSUInteger)startIndex count:(NSUInteger)itemsCount;
- (VehicleItemDetails *)getItemDetailsForItem:(VehicleItem *)item;

@end
