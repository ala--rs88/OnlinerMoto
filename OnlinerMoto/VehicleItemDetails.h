//
//  VehicleItemDetails.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VehicleItem;

@interface VehicleItemDetails : NSObject

@property (nonatomic, strong) VehicleItem *vehicleItem;
@property (nonatomic, strong) NSString *additionalDescription;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSArray *allPhotos;

@end
