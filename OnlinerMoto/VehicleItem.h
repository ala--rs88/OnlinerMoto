//
//  VehicleItem.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 3.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VehicleItem : NSObject

@property (nonatomic, strong) NSNumber *vehicleId;
@property (nonatomic, strong) NSString *briefDescription;
@property (nonatomic, assign) NSUInteger mileage;
@property (nonatomic, assign) NSUInteger year;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSUInteger price;
@property (nonatomic, strong) NSString *detailsUrl;
@property (nonatomic, strong) NSData *mainPhoto;


@end
