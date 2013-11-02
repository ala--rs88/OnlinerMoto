//
//  VehicleItem.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VehicleItem : NSManagedObject

@property (nonatomic, retain) NSNumber *vehicleId;
@property (nonatomic, retain) NSString *briefDescription;
@property (nonatomic, retain) NSNumber *mileage;
@property (nonatomic, retain) NSDate *year;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *price;
@property (nonatomic, retain) NSString *detailsUrl;
@property (nonatomic, retain) NSData *mainPhoto;

@end
