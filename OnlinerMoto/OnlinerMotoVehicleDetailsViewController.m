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
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // todo: is this section synchronized???
        
        _vehicleItemDetails = [self.vehicleItemsProvider getItemDetailsForItem:self.vehicleItem];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showVehicleItemDetails:_vehicleItemDetails];
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark -- Private Mehtods

- (void)showVehicleItemDetails:(VehicleItemDetails *)itemDetails
{
    self.locationLabel.text = itemDetails.location;
    [self.locationLabel sizeToFit];
    self.additionalDescriptionLabel.text = itemDetails.additionalDescription;
    self.additionalDescriptionLabel.numberOfLines = 0;
    [self.additionalDescriptionLabel sizeToFit];
    
    
    
    [self.photosCollectionView reloadData];
  //  self.photosCollectionView.dataSource = itemDetails.allPhotos;
}

@end
