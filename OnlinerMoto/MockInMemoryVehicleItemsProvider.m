//
//  MockInMemoryVehicleItemsProvider.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 3.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "MockInMemoryVehicleItemsProvider.h"
#import "VehicleItem.h"
#import "VehicleItemDetails.h"

@interface MockInMemoryVehicleItemsProvider()
{
    NSMutableArray *items;
}
@end

@implementation MockInMemoryVehicleItemsProvider

@synthesize totalItemsCount = _totalItemsCount;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.pageSize = 5;
        items = [[NSMutableArray alloc] init];
        for (int i = 0; i < 13; i++)
        {
            VehicleItem *newItem = [[VehicleItem alloc] init];                                    
            newItem.vehicleId = [NSNumber numberWithInt:i];
            newItem.briefDescription = [NSString stringWithFormat:@"descriptionFor:%d", i];
            newItem.mileage = i * 110;
            newItem.year = 2013;
            newItem.name = [NSString stringWithFormat:@"nameFor:%d", i];;
            newItem.price = i * 11;
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            newItem.detailsUrl = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
            CFRelease(uuid);
            newItem.mainPhoto = nil;
                                    
            [items addObject:newItem];
        }
    }
    
    return self;
}

- (void)applyFilter:(VehicleItemFilter *)filter
{
    NSException *exception = [NSException exceptionWithName:@"NotImplementedException"
                                                     reason:@"This method is not yet implemented."
                                                   userInfo:nil];
    [exception raise];
}

- (NSUInteger)totalItemsCount
{
    return [items count];
}

- (NSArray *)getPageWithIndex:(NSUInteger)index
{
    NSRange pageRange;
    
    NSUInteger pageSize = self.pageSize;
    NSUInteger totalCount = self.totalItemsCount;
    
    pageRange.location = index * pageSize;
    if ((index + 1) * pageSize <= totalCount)
    {
        pageRange.length = pageSize;
    }
    else if (index * pageSize <= totalCount)
    {
        pageRange.length = totalCount - (index * pageSize);
    }
    else
    {
        return nil;
    }
    
    return [items subarrayWithRange:pageRange];
}

- (VehicleItemDetails *)getItemDetailsForItem:(VehicleItem *)item
{
    return [[VehicleItemDetails alloc] initWithVehicleItem:item];
}


@end
