//
//  OnlinerMotoVehicleItemCell.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 3.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnlinerMotoVehicleItemCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UITextView *briefDescriptionTextView;
@property (nonatomic, weak) IBOutlet UIImageView *mainImageView;

@end
