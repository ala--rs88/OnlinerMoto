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
#import "LoadingIndicatorView.h"

#define DEFAULT_PAGE_SIZE 30

@interface OnlinerMotoVehiclesViewController ()
{
    NSUInteger _pageSize;
    NSMutableArray *_vehicleItemsToBeDisplayed;
    
    NSInteger _currentLoadedPageIndex;

    BOOL _isLoadedPageLast;
    
    NSString *_currentRequestId;
}

@property (nonatomic) NSUInteger indexForLoadMoreRow;

@end

@implementation OnlinerMotoVehiclesViewController

@synthesize indexForLoadMoreRow;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        _pageSize = DEFAULT_PAGE_SIZE;
        
        [self resetData];
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

- (void)checkForFilterChanges
{
    if (![self isFilterAlreadyApplied])
    {
        [self applyGlobalFilter];
    }
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{   
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
            [self beginLoadNextPageAndWithFullAnimation:YES];
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
        [self beginLoadNextPageAndWithFullAnimation:NO];
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
        detailsViewController.VehicleItem = vehicleItemToPresent;
    }
}

#pragma mark - AppDelegate accessors

- (id<VehicleItemsRepositoryProtocol>)getGlobalVehicleItemsRepository
{
    id<OnlinerMotoAppDelegateProtocol> theDelegate = (id<OnlinerMotoAppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    
    return theDelegate.vehicleItemsRepository;
}

- (id<VehicleItemsProviderProtocol>)getGlobalVehicleItemsProvider
{
    id<OnlinerMotoAppDelegateProtocol> theDelegate = (id<OnlinerMotoAppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    
    return theDelegate.vehicleItemsProvider;
}

- (VehicleItemFilter *)getGlobalFilter
{
    id<OnlinerMotoAppDelegateProtocol> theDelegate = (id<OnlinerMotoAppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    
	return (VehicleItemFilter *) theDelegate.vehicleItemFilter;
}

#pragma mark - Private methods

- (void)applyGlobalFilter
{
    [self.getGlobalVehicleItemsProvider applyFilter:[self getGlobalFilter]];
    [self resetData];
}

- (void)resetData
{
    _vehicleItemsToBeDisplayed = [[NSMutableArray alloc] init];
    _currentLoadedPageIndex = -1;
    _isLoadedPageLast = NO;
    [self markFilterAsAlreadyApplied];
    [self.tableView reloadData];
}

- (BOOL)isFilterAlreadyApplied
{
    id<OnlinerMotoAppDelegateProtocol> theDelegate = (id<OnlinerMotoAppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    return theDelegate.isFilterAlreadyApplied;
}

- (void)markFilterAsAlreadyApplied
{
    id<OnlinerMotoAppDelegateProtocol> theDelegate = (id<OnlinerMotoAppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    theDelegate.isFilterAlreadyApplied = YES;
}

- (void)showLoadingIndicatorsAndWithFullAnimation:(BOOL)fullyAnimated
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if (fullyAnimated)
    {
        [self.tableView setScrollEnabled:NO];
        [self.view addSubview:[[LoadingIndicatorView alloc] initWithFrame:self.view.bounds]];
    }
}

- (void)hideLoadingIndicatorsAndWithFullAnimation:(BOOL)fullyAnimated
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (fullyAnimated)
    {
        for (UIView *subView in self.view.subviews)
        {
            if ([subView isKindOfClass:[LoadingIndicatorView class]])
            {
                [subView removeFromSuperview];
            }
        }
        [self.tableView setScrollEnabled:YES];
    }
}

- (NSUInteger)indexForLoadMoreRow
{
    return _pageSize * (_currentLoadedPageIndex + 1);
}

- (BOOL)checkIsTaggingAvailableForVehicleItem:(VehicleItem *)vehicleItem
{
    return ![[self getGlobalVehicleItemsRepository] isItemAlreadyPresentByDetailsUrl:vehicleItem.detailsUrl];
}

- (NSString *)createUniqueId
{   
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *newId = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    return newId;
}

- (void)beginLoadNextPageAndWithFullAnimation:(BOOL)fullyAnimated
{
    NSUInteger pageToLoadIndex = _currentLoadedPageIndex + 1;
    
    [self showLoadingIndicatorsAndWithFullAnimation:fullyAnimated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *tempCurrentRequestId;
        @synchronized(self)
        {
            _currentRequestId = [self createUniqueId];
            tempCurrentRequestId = _currentRequestId;
        }

        NSArray *loadedVehicleItems = [[self getGlobalVehicleItemsProvider] getItemsFromIndex:(pageToLoadIndex * _pageSize)
                                                                                        count:_pageSize];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([tempCurrentRequestId isEqualToString:_currentRequestId])
            {
                [self hideLoadingIndicatorsAndWithFullAnimation:fullyAnimated];
                
                [self endLoadPageWithIndex:pageToLoadIndex
                        loadedVehicleItems:loadedVehicleItems
                    totalVehicleItemsCount:[self getGlobalVehicleItemsProvider].totalItemsCount];
            }
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
    
    if ((!loadedVehicleItems || [loadedVehicleItems count] == 0) && _currentLoadedPageIndex <= 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"Sorry, no matching items found or connection failed."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
    [self.tableView reloadData];
}

@end
