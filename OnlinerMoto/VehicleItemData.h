//
//  VehicleItemData.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 23.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VehicleItemData : NSManagedObject

@property (nonatomic, retain) NSString * briefDescription;
@property (nonatomic, retain) NSString * detailsUrl;
@property (nonatomic, retain) NSData * mainPhoto;
@property (nonatomic, retain) NSNumber * mileage;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * vehicleId;
@property (nonatomic, retain) NSNumber * year;

@end
