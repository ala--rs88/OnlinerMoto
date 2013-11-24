//
//  OnlinerMotoVehicleDetailsViewController.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 17.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "OnlinerMotoVehicleDetailsViewController.h"
#import "VehicleItem.h"
#import "VehicleItemDetails.h"
#import "VehicleItemsRepositoryProtocol.h"
#import "VehicleItemsProviderProtocol.h"
#import "OnlinerMotoPhotoCell.h"
#import "LoadingIndicatorView.h"

@interface OnlinerMotoVehicleDetailsViewController()
{
    VehicleItemDetails *_vehicleItemDetails;
}
@end

@implementation OnlinerMotoVehicleDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nameLabel.text = self.vehicleItem.name;
    self.priceLabel.text = [NSString stringWithFormat:@"$%u", self.vehicleItem.price];
    self.yearLabel.text =[NSString stringWithFormat:@"%u", self.vehicleItem.year];
    self.mileageLabel.text =[NSString stringWithFormat:@"%u km", self.vehicleItem.mileage];
    self.briefDescriptionLabel.text = self.vehicleItem.briefDescription;
    self.urlLabel.text = self.vehicleItem.detailsUrl;
    
    [self.photosCollectionView setBackgroundColor:[UIColor whiteColor]];
    
    [self.addVehicleItemToTaggedButton setEnabled:self.isTaggingAvailable];
    
    [self showLoadingIndicators];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _vehicleItemDetails = [self.vehicleItemsProvider getItemDetailsForItem:self.vehicleItem];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoadingIndicators];
            
            [self showVehicleItemDetails:_vehicleItemDetails];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addVehicleItemToTagged:(id)sender
{
    [self.vehicleItemsRepository addVehicleItem:self.vehicleItem];
    [self.addVehicleItemToTaggedButton setEnabled:NO];
    
    [OnlinerMotoVehicleDetailsViewController showMessage:@"Item marked as tagged"];
}

+ (void)showMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:nil
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (IBAction)hideDetailsView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
   if (_vehicleItemDetails == nil
        || _vehicleItemDetails.allPhotos == nil)
    {
        return 0;
    }
    
    return [_vehicleItemDetails.allPhotos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OnlinerMotoPhotoCell *cell = (OnlinerMotoPhotoCell *)[cv dequeueReusableCellWithReuseIdentifier:@"OnlinerMotoPhotoCell" forIndexPath:indexPath];
    
    cell.photoImage.image = [UIImage imageWithData:_vehicleItemDetails.allPhotos[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        NSString *text = _vehicleItemDetails.vehicleItem.briefDescription;
        CGSize constraint = CGSizeMake(320.0f - (20.0f * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = MAX(size.height, 44.0f);
        
        return height + 10.0f;
    }
    else if (indexPath.section == 1)
    {
        return 320.0f;
    }
    else if (indexPath.section == 2)
    {
        NSString *text = _vehicleItemDetails.additionalDescription;
        CGSize constraint = CGSizeMake(320.0f - (20.0f * 2), 20000.0f);
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:17.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = MAX(size.height, 44.0f);
        
        return height + 10.0f;
    }
    else
    {
        return 44.0f;
    }
}

#pragma mark -- UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- Private Mehtods

- (void)showLoadingIndicators
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.tableView setScrollEnabled:NO];
    [self.view addSubview:[[LoadingIndicatorView alloc] initWithFrame:self.view.bounds]];
}

- (void)hideLoadingIndicators
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    for (UIView *subView in self.view.subviews)
    {
        if ([subView isKindOfClass:[LoadingIndicatorView class]])
        {
            [subView removeFromSuperview];
        }
    }
    [self.tableView setScrollEnabled:YES];
}

- (void)showVehicleItemDetails:(VehicleItemDetails *)itemDetails
{
    if (!itemDetails)
    {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"Sorry, this item doesn't exist anymore."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];        
        return;
    }
    
    self.locationLabel.text = itemDetails.location;
    self.additionalDescriptionLabel.text = itemDetails.additionalDescription;
    self.additionalDescriptionLabel.numberOfLines = 0;
    [self.additionalDescriptionLabel sizeToFit];
    [self.briefDescriptionLabel sizeToFit];
       
    [self.photosCollectionView reloadData];
    [self.tableView reloadData];
}

@end
