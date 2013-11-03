//
//  AVWebVehicleItemsProvider.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 3.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "AVWebVehicleItemsProvider.h"

@implementation AVWebVehicleItemsProvider

- (void)applyFilter:(VehicleItemFilter *)filter
{
    NSException *exception = [NSException exceptionWithName:@"NotImplementedException"
                                                     reason:@"This method is not yet implemented."
                                                   userInfo:nil];
    [exception raise];
}

- (NSUInteger)totalItemsCount
{
    return 17;
}

- (NSArray *)getPageWithIndex:(NSUInteger)index
{
    NSException *exception = [NSException exceptionWithName:@"NotImplementedException"
                                                     reason:@"This method is not yet implemented."
                                                   userInfo:nil];
    [exception raise];
    return nil;
}

- (VehicleItemDetails *)getItemDetailsForItem:(VehicleItem *)item
{
    NSException *exception = [NSException exceptionWithName:@"NotImplementedException"
                                                     reason:@"This method is not yet implemented."
                                                   userInfo:nil];
    [exception raise];
    return nil;
}

@end
