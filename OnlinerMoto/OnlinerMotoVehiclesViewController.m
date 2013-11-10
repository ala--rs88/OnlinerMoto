//
//  OnlinerMotoVehiclesViewController.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "OnlinerMotoVehiclesViewController.h"
//#import "MockInMemoryVehicleItemsProvider.h"
#import "AVWebVehicleItemsProvider.h"
#import "OnlinerMotoVehicleItemCell.h"
#import "OnlinerWebVehileItemsProvider.h"
#import "VehicleItem.h"
#import "VehicleItemFilter.h"

@interface OnlinerMotoVehiclesViewController ()
{
    NSArray *_vehicleItemsToBeDisplayed;
}
@end

@implementation OnlinerMotoVehiclesViewController

@synthesize vehicleItemsProvider = _vehicleItemsProvider;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        _vehicleItemsToBeDisplayed = [[NSArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // todo: IS View loaded multiple times?
    
    [self.vehicleItemsProvider applyFilter:[[VehicleItemFilter alloc] init]];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // todo: is this section synchronized???
        
        _vehicleItemsToBeDisplayed = [self.vehicleItemsProvider getItemsFromIndex:0 count:30];
        
        // todo: disable paging functionality for the request time
        // todo: consider case: request is sent, then filter is updated;
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // todo: consider multiple firing
    NSLog(@"numberOfRowsInSection");
    return [_vehicleItemsToBeDisplayed count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // todo: IK consider hardcoding
    static NSString *CellIdentifier = @"OnlinerMotoVehicleItemCell";
    
    OnlinerMotoVehicleItemCell *cell = (OnlinerMotoVehicleItemCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    VehicleItem *item = _vehicleItemsToBeDisplayed[indexPath.row];
    
    cell.nameLabel.text = item.name;
    cell.briefDescriptionLabel.text = item.briefDescription;
    cell.mainImageView.image = [UIImage imageWithData:item.mainPhoto];
    
    return cell;
}

// todo: Is this method mandatory?
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - Data providers

- (id<VehicleItemsProviderProtocol>)vehicleItemsProvider
{
    if (_vehicleItemsProvider != nil) {
        return _vehicleItemsProvider;
    }
    
    // todo: IK place all hardcoding in one location
    _vehicleItemsProvider = [[OnlinerWebVehileItemsProvider alloc] init];
    
    return _vehicleItemsProvider;
}

@end
