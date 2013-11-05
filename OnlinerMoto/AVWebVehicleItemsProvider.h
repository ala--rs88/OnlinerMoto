//
//  AVWebVehicleItemsProvider.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 3.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VehicleItemsProviderProtocol.h"

@interface AVWebVehicleItemsProvider : NSObject <VehicleItemsProviderProtocol, NSURLConnectionDelegate>

@property (readonly, nonatomic, assign) NSUInteger totalItemsCount;

- (id)init;

- (void)applyFilter:(VehicleItemFilter *)filter;
- (NSArray *)getItemsFromIndex:(NSUInteger)startIndex count:(NSUInteger)itemsCount;
- (VehicleItemDetails *)getItemDetailsForItem:(VehicleItem *)item;

@end
