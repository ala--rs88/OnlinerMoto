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

- (NSUInteger)totalVehicleItemsCount
{
    return [items count];
}

- (NSArray *)getItemsFromIndex:(NSUInteger)startIndex count:(NSUInteger)itemsCount;
{
    if (startIndex + itemsCount > self.totalItemsCount)
    {
        NSException *exception = [NSException exceptionWithName:@"ArgumentOutOfRange"
                                                         reason:@"Total items count is not sufficient."
                                                       userInfo:nil];
        [exception raise];
    }
    
    NSRange pageRange;   
    pageRange.location = startIndex;
    pageRange.length = itemsCount;
    
    return [items subarrayWithRange:pageRange];
}

- (VehicleItemDetails *)getItemDetailsForItem:(VehicleItem *)item
{
    return [[VehicleItemDetails alloc] initWithVehicleItem:item];
}


@end
