//
//  OnlinerMotoTaggedViewController.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "OnlinerMotoTaggedVehiclesViewController.h"
#import "OnlinerMotoVehicleItemsRepository.h"
#import "OnlinerWebVehileItemsProvider.h"
#import "OnlinerMotoVehicleDetailsViewController.h"
#import "OnlinerMotoVehicleItemCell.h"
#import "OnlinerMotoAppDelegate.h"

#import "OnlinerMoto-Swift.h"

@interface OnlinerMotoTaggedVehiclesViewController ()
{
    NSArray *_vehicleItemsToBeDisplayed;
}
@end

@implementation OnlinerMotoTaggedVehiclesViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to refresh"];
    [refreshControl addTarget:self
                       action:@selector(refreshTable:)
      forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:refreshControl];
}

- (void)refreshTable:(UIRefreshControl *)refreshControl
{
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating..."];
    
    [self.tableView reloadData];
    
    [refreshControl endRefreshing];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    _vehicleItemsToBeDisplayed = [[self getGlobalVehicleItemsRepository] getAllVehicleItems];
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
    cell.priceLabel.text = [NSString stringWithFormat:@"$%u", item.price];
    cell.yearLabel.text = [NSString stringWithFormat:@"%u", item.year];
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[self getGlobalVehicleItemsRepository] removeVehicleItemByDetailsUrl:((VehicleItem *)_vehicleItemsToBeDisplayed[indexPath.row]).detailsUrl];
        [self.tableView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"VehicleItemDetailsFromTaggedSegue"])
    {
        OnlinerMotoVehicleDetailsViewController *detailsViewController = [segue destinationViewController];
        
        detailsViewController.isTaggingAvailable = NO;
        detailsViewController.VehicleItem = _vehicleItemsToBeDisplayed[[self.tableView indexPathForSelectedRow].row];
    }
}

#pragma mark - AppDelegate accessors

- (id<VehicleItemsRepositoryProtocol>)getGlobalVehicleItemsRepository
{
    id<OnlinerMotoAppDelegateProtocol> theDelegate = (id<OnlinerMotoAppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    
    return theDelegate.vehicleItemsRepository;
}

@end
