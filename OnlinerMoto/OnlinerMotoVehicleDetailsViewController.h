//
//  OnlinerMotoVehicleDetailsViewController.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 17.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VehicleItem;
@protocol VehicleItemsRepositoryProtocol;
@protocol VehicleItemsProviderProtocol;

@interface OnlinerMotoVehicleDetailsViewController : UITableViewController <UICollectionViewDataSource>

@property (strong, nonatomic) id<VehicleItemsRepositoryProtocol> vehicleItemsRepository;
@property (strong, nonatomic) id<VehicleItemsProviderProtocol> vehicleItemsProvider;

@property (strong, nonatomic) VehicleItem *vehicleItem;
@property (nonatomic) BOOL isTaggingAvailable;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *mileageLabel;
@property (weak, nonatomic) IBOutlet UILabel *briefDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;


@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *additionalDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addVehicleItemToTaggedButton;

- (IBAction)addVehicleItemToTagged:(id)sender;
- (IBAction)hideDetailsView:(id)sender;

@end
