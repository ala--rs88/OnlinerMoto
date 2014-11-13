//
//  VehicleItemsProvider.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 3.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VehicleItem;
@class VehicleItemFilter;
@class VehicleItemDetails;

@protocol VehicleItemsProviderProtocol <NSObject>

@required

@property (readonly, nonatomic, assign) NSUInteger totalItemsCount;

- (void)applyFilter:(VehicleItemFilter *)filter;
// todo: consider renaming
- (NSArray *)getItemsFromIndex:(NSInteger)startIndex count:(NSInteger)itemsCount;
- (VehicleItemDetails *)getItemDetailsForItem:(VehicleItem *)item;

@end
