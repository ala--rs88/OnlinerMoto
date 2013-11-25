//
//  VehicleItemFilter.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 3.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VehicleItemFilter : NSObject

@property (nonatomic, assign) NSUInteger minPrice;
@property (nonatomic, assign) NSUInteger maxPrice;

@property (nonatomic, assign) NSUInteger minYear;
@property (nonatomic, assign) NSUInteger maxYear;

@property (nonatomic, assign) NSUInteger minEngineVolume;
@property (nonatomic, assign) NSUInteger maxEngineVolume;

@end
