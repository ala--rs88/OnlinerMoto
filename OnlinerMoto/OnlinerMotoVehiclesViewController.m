//
//  OnlinerMotoVehiclesViewController.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "OnlinerMotoVehiclesViewController.h"
#import "OnlinerMotoVehicleItemCell.h"
#import "OnlinerMotoLoadMoreCell.h"
#import "OnlinerMotoVehicleItemsRepository.h"
#import "OnlinerWebVehileItemsProvider.h"
#import "VehicleItem.h"
#import "VehicleItemFilter.h"
#import "OnlinerMotoVehicleDetailsViewController.h"
#import "OnlinerMotoAppDelegate.h"

@interface OnlinerMotoVehiclesViewController ()
{
    NSUInteger _pageSize;
    NSMutableArray *_vehicleItemsToBeDisplayed;
    
    NSInteger _currentLoadedPageIndex;
    
   // BOOL _isPreviousPageButtonEnabledOldValue;
   // BOOL _isNextPageButtonEnabledOldValue;
    BOOL _isLoadedPageLast;
}

@property (nonatomic) NSUInteger indexForLoadMoreRow;

@end

@implementation OnlinerMotoVehiclesViewController

@synthesize vehicleItemsRepository = _vehicleItemsRepository;
@synthesize vehicleItemsProvider = _vehicleItemsProvider;
@synthesize indexForLoadMoreRow;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _vehicleItemsToBeDisplayed = [[NSMutableArray alloc] init];
        
        // todo: use const here
        _pageSize = 30;
        _currentLoadedPageIndex = -1;
        _isLoadedPageLast = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // todo: consider multiple firing
    NSLog(@"numberOfRowsInSection fired");
    
    NSUInteger rowsCount = _isLoadedPageLast ? [_vehicleItemsToBeDisplayed count] : [_vehicleItemsToBeDisplayed count] + 1;
    
    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.indexForLoadMoreRow)
    {      
        OnlinerMotoLoadMoreCell *cell = (OnlinerMotoLoadMoreCell *)[tableView dequeueReusableCellWithIdentifier:@"OnlinerMotoLoadMoreCell"];
        
        if (_currentLoadedPageIndex == -1)
        {
            [cell setLoadingState];
            [self beginLoadNextPage];
        }
        else
        {
            [cell setInitialState];
        }
        
        return cell;
    }
    else
    {
        OnlinerMotoVehicleItemCell *cell = (OnlinerMotoVehicleItemCell *)[tableView dequeueReusableCellWithIdentifier:@"OnlinerMotoVehicleItemCell"];
    
        VehicleItem *item = _vehicleItemsToBeDisplayed[indexPath.row];
    
        cell.nameLabel.text = item.name;
        cell.briefDescriptionLabel.text = item.briefDescription;
        cell.mainImageView.image = [UIImage imageWithData:item.mainPhoto];
        cell.priceLabel.text = [NSString stringWithFormat:@"$%u", item.price];
        cell.yearLabel.text = [NSString stringWithFormat:@"%u", item.year];
    
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.indexForLoadMoreRow)
    {
        OnlinerMotoLoadMoreCell *cell = (OnlinerMotoLoadMoreCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        [cell setLoadingState];
        [self beginLoadNextPage];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"VehicleItemDetailsFromVehiclesSegue"])
    {
        OnlinerMotoVehicleDetailsViewController *detailsViewController = [segue destinationViewController];
        
        VehicleItem *vehicleItemToPresent = _vehicleItemsToBeDisplayed[[self.tableView indexPathForSelectedRow].row];
        
        detailsViewController.isTaggingAvailable = [self checkIsTaggingAvailableForVehicleItem:vehicleItemToPresent];
        detailsViewController.vehicleItemsRepository = self.vehicleItemsRepository;
        detailsViewController.vehicleItemsProvider = self.vehicleItemsProvider;
        detailsViewController.VehicleItem = vehicleItemToPresent;
    }
}

#pragma mark -- Vehicle Items Repository

- (id<VehicleItemsRepositoryProtocol>)vehicleItemsRepository
{
    if (_vehicleItemsRepository != nil)
    {
        return _vehicleItemsRepository;
    }
    
    _vehicleItemsRepository = [[OnlinerMotoVehicleItemsRepository alloc]
                               initWithObjectContext:[(OnlinerMotoAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]];
    
    return _vehicleItemsRepository;
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

#pragma mark - Private methods

- (NSUInteger)indexForLoadMoreRow
{
    return _pageSize * (_currentLoadedPageIndex + 1);
}

- (BOOL)checkIsTaggingAvailableForVehicleItem:(VehicleItem *)vehicleItem
{
    return ![self.vehicleItemsRepository isItemAlreadyPresentByDetailsUrl:vehicleItem.detailsUrl];
}

- (void)beginLoadNextPage
{
    NSUInteger pageToLoadIndex = _currentLoadedPageIndex + 1;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // todo: is this section synchronized???
        
        NSArray *loadedVehicleItems = [self.vehicleItemsProvider getItemsFromIndex:(pageToLoadIndex * _pageSize)
                                                                             count:_pageSize];
        

        // todo: consider case: request is sent, then filter is updated;
        
        // todo: consider totalCount changing
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self endLoadPageWithIndex:pageToLoadIndex
                    loadedVehicleItems:loadedVehicleItems
                totalVehicleItemsCount:self.vehicleItemsProvider.totalItemsCount];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
}

- (void)endLoadPageWithIndex:(NSUInteger)pageIndex
          loadedVehicleItems:(NSArray *)loadedVehicleItems
      totalVehicleItemsCount:(NSUInteger)totalVehicleItemsCount
{    
    if (loadedVehicleItems)
    {
        [_vehicleItemsToBeDisplayed addObjectsFromArray:loadedVehicleItems];
        
        _currentLoadedPageIndex = pageIndex;
    }
    
    if (!loadedVehicleItems
        || [loadedVehicleItems count] == 0
        || totalVehicleItemsCount <= [_vehicleItemsToBeDisplayed count])
    {
        _isLoadedPageLast = YES;
    }
    
    [self.tableView reloadData];
}

@end
