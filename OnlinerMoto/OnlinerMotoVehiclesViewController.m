//
//  OnlinerMotoVehiclesViewController.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 2.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "OnlinerMotoVehiclesViewController.h"
#import "OnlinerMotoVehicleItemCell.h"
#import "OnlinerMotoVehicleItemsRepository.h"
#import "OnlinerWebVehileItemsProvider.h"
#import "VehicleItem.h"
#import "VehicleItemFilter.h"
#import "OnlinerMotoVehicleDetailsViewController.h"
#import "OnlinerMotoAppDelegate.h"

@interface OnlinerMotoVehiclesViewController ()
{
    NSUInteger _pageSize;
    NSArray *_vehicleItemsToBeDisplayed;
    
    NSInteger _currentLoadedPageIndex;
    
    BOOL _isPreviousPageButtonEnabledOldValue;
    BOOL _isNextPageButtonEnabledOldValue;
}
@end

@implementation OnlinerMotoVehiclesViewController

@synthesize vehicleItemsRepository = _vehicleItemsRepository;
@synthesize vehicleItemsProvider = _vehicleItemsProvider;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {   
    }
    return self;
}*/

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _vehicleItemsToBeDisplayed = [[NSArray alloc] init];
        
        // todo: use const here
        _pageSize = 30;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // todo: IS View loaded multiple times?
    _currentLoadedPageIndex = -1;
    [self beginLoadPageWithIndex:0];
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


#pragma mark - Navigation bar

- (IBAction)previousPageButtonAction:(id)sender
{
    // todo: add validation
    [self beginLoadPageWithIndex:(_currentLoadedPageIndex - 1)];
}

- (IBAction)nextPageButtonAction:(id)sender
{
    // todo: add validation
    [self beginLoadPageWithIndex:(_currentLoadedPageIndex + 1)];
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

- (BOOL)checkIsTaggingAvailableForVehicleItem:(VehicleItem *)vehicleItem
{
    return ![self.vehicleItemsRepository isItemAlreadyPresentByDetailsUrl:vehicleItem.detailsUrl];
}

- (void)setPreviousPageButtonEnabled:(bool)previousButtonEnabled
            andNextPageButtonEnabled:(bool)nextButtonEnabled
{
    _isPreviousPageButtonEnabledOldValue = self.previousPageButton.isEnabled;
    _isNextPageButtonEnabledOldValue = self.nextPageButton.isEnabled;
    
    // todo: try to hide instead of disable
    [self.previousPageButton setEnabled:previousButtonEnabled];
    [self.nextPageButton setEnabled:nextButtonEnabled];
}

- (void)undoNavigationButtonsAvailabilityChenges
{
    [self.previousPageButton setEnabled:_isPreviousPageButtonEnabledOldValue];
    [self.nextPageButton setEnabled:_isNextPageButtonEnabledOldValue];
}

- (void)beginLoadPageWithIndex:(NSUInteger)pageIndex
{
    [self setPreviousPageButtonEnabled:NO
              andNextPageButtonEnabled:NO];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // todo: is this section synchronized???
        
        NSArray *loadedVehicleItems = [self.vehicleItemsProvider getItemsFromIndex:(pageIndex * _pageSize)
                                                                             count:_pageSize];
        

        // todo: consider case: request is sent, then filter is updated;
        
        // todo: consider totalCount changing
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self endLoadPageWithIndex:pageIndex
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
        _vehicleItemsToBeDisplayed = loadedVehicleItems;
        
        [self.tableView reloadData];
        
        _currentLoadedPageIndex = pageIndex;
    }
    
    // todo: Review condition
    if (loadedVehicleItems && ([loadedVehicleItems count] != 0 || pageIndex == 0))
    {
        [self.navigationItem setTitle:[NSString stringWithFormat:@"Page %d of %d", (pageIndex + 1), (totalVehicleItemsCount / _pageSize + 1)]];
        
        [self setPreviousPageButtonEnabled:(pageIndex > 0)
                  andNextPageButtonEnabled:((pageIndex + 1) * _pageSize < totalVehicleItemsCount)];
    }
    else     
    {
        [self undoNavigationButtonsAvailabilityChenges];
        [self.navigationItem setTitle:[NSString stringWithFormat:@"Page %d of %d", _currentLoadedPageIndex, _currentLoadedPageIndex]];
        [self setPreviousPageButtonEnabled:self.previousPageButton.isEnabled
                  andNextPageButtonEnabled:NO];
    }
}

@end
