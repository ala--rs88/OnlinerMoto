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

@interface OnlinerMotoVehiclesViewController ()

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
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
    // todo: IK What if real page size is less than property value?
    [[OnlinerWebVehileItemsProvider alloc] init];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // todo: IK consider hardcoding
    static NSString *CellIdentifier = @"OnlinerMotoVehicleItemCell";
    
    OnlinerMotoVehicleItemCell *cell = (OnlinerMotoVehicleItemCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSArray *page = [self.vehicleItemsProvider getItemsFromIndex:0 count:10];
    
    VehicleItem *item = page[indexPath.row];
    
    cell.nameLabel.text = item.name;
    cell.briefDescriptionLabel.text = item.briefDescription;
    
    return cell;
}

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
    
    // todo: IK provide all hardcoding in one location
    //_vehicleItemsProvider = [[MockInMemoryVehicleItemsProvider alloc] init];
    _vehicleItemsProvider = [[AVWebVehicleItemsProvider alloc] init];
    
    return _vehicleItemsProvider;
}

@end
