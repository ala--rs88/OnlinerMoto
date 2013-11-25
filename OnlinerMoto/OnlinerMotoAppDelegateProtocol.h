//
//  OnlinerMotoAppDelegateProtocol.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 25.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VehicleItemFilter;

@protocol OnlinerMotoAppDelegateProtocol

@required

@property (readonly, nonatomic, strong) VehicleItemFilter *vehicleItemFilter;

@property (nonatomic) BOOL isFilterAlreadyApplied;

// todo: IK move provider & repo here

@end
