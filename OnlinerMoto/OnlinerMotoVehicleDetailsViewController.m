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
    self.priceLabel.text = [NSString stringWithFormat:@"%u$", self.vehicleItem.price];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // todo: is this section synchronized???
        
        _vehicleItemDetails = [self.vehicleItemsProvider getItemDetailsForItem:self.vehicleItem];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showVehicleItemDetails:_vehicleItemDetails];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

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
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
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
