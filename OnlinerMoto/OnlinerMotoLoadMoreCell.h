//
//  OnlinerMotoLoadMoreCell.h
//  OnlinerMoto
//
//  Created by Igor Karpov on 24.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnlinerMotoLoadMoreCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)setInitialState;
- (void)setLoadingState;

@end
