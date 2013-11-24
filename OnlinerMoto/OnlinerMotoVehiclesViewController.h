//
//  OnlinerMotoVehiclesViewController.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VehicleItemsRepositoryProtocol.h"
#import "VehicleItemsProviderProtocol.h"

@interface OnlinerMotoVehiclesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (readonly, strong, nonatomic) id<VehicleItemsRepositoryProtocol> vehicleItemsRepository;
@property (readonly, strong, nonatomic) id<VehicleItemsProviderProtocol> vehicleItemsProvider;

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousPageButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextPageButton;

@end
