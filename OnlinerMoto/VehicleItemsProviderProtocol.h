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

@property (readonly, nonatomic, assign) NSUInteger pageSize;
@property (readonly, nonatomic, assign) NSUInteger totalItemsCount;

- (void)applyFilter:(VehicleItemFilter *)filter;
- (NSArray *)getPageWithIndex:(NSUInteger)index;
- (VehicleItemDetails *)getItemDetailsForItem:(VehicleItem *)item;


/*
 
 plements smth like following:
 
 _currentPage
 
 LoadNextPage()
 LoadPreviousPage()
 
 etc.
 
 reason: each page item is accessed separately to render each table row, so loaded page should be stored in some temp variable
 
 */

@end
