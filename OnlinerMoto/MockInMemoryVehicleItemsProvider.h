//
//  MockInMemoryVehicleItemsProvider.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 3.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VehicleItemsProviderProtocol.h"

@interface MockInMemoryVehicleItemsProvider : NSObject <VehicleItemsProviderProtocol>

@property (nonatomic, assign) NSUInteger pageSize;
@property (nonatomic, assign) NSUInteger totalItemsCount;

- (id)init;

- (void)applyFilter:(VehicleItemFilter *)filter;
- (NSArray *)getPageWithIndex:(NSUInteger)index;
- (VehicleItemDetails *)getItemDetailsForItem:(VehicleItem *)item;

@end
