//
//  OnlinerMotoTaggedViewController.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VehicleItemsRepositoryProtocol.h"
#import "VehicleItemsProviderProtocol.h"

@interface OnlinerMotoTaggedVehiclesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (readonly, strong, nonatomic) id<VehicleItemsRepositoryProtocol> vehicleItemsRepository;

@property (readonly, strong, nonatomic) id<VehicleItemsProviderProtocol> vehicleItemsProvider;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
