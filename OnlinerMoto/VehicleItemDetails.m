//
//  VehicleItemDetails.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "VehicleItemDetails.h"

@implementation VehicleItemDetails

- (id)initWithVehicleItem:(VehicleItem *)vehicleItem
{
    self = [super init];
    
    if (self)
    {
        self.vehicleItem = vehicleItem;
    }
    
    return self;
}

@end
