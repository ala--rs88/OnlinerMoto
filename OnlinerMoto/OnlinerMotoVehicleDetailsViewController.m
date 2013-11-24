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

@interface OnlinerMotoVehicleDetailsViewController()
{
    VehicleItemDetails *_vehicleItemDetails;
}
@end

@implementation OnlinerMotoVehicleDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.nameLabel.text = self.vehicleItem.name;
    self.priceLabel.text = [NSString stringWithFormat:@"$%u", self.vehicleItem.price];
    self.yearLabel.text =[NSString stringWithFormat:@"%u", self.vehicleItem.year];
    self.mileageLabel.text =[NSString stringWithFormat:@"%u km", self.vehicleItem.mileage];
    self.briefDescriptionLabel.text = self.vehicleItem.briefDescription;
    self.urlLabel.text = self.vehicleItem.detailsUrl;
    
    [self.photosCollectionView setBackgroundColor:[UIColor whiteColor]];
    
    [self.addVehicleItemToTaggedButton setEnabled:self.isTaggingAvailable];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // todo: is this section synchronized???
        
        _vehicleItemDetails = [self.vehicleItemsProvider getItemDetailsForItem:self.vehicleItem];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
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

#pragma mark -- UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- Private Mehtods

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
    [self.locationLabel sizeToFit];
    self.additionalDescriptionLabel.text = itemDetails.additionalDescription;
    self.additionalDescriptionLabel.numberOfLines = 0;
    [self.additionalDescriptionLabel sizeToFit];
       
    
    [self.photosCollectionView reloadData];
  //  self.photosCollectionView.dataSource = itemDetails.allPhotos;
}

@end
