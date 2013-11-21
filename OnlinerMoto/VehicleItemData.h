//
//  VehicleItem.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VehicleItemData : NSManagedObject

// todo: IK remove vehicleId
@property (nonatomic, retain) NSNumber *vehicleId;

@property (nonatomic, retain) NSString *detailsUrl;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) NSUInteger price;
@property (nonatomic, retain) NSString *briefDescription;
@property (nonatomic, retain) NSData *mainPhoto;

@property (nonatomic, assign) NSUInteger mileage;
@property (nonatomic, assign) NSUInteger year;

@end
