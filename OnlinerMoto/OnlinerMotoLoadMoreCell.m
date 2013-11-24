//
//  OnlinerMotoLoadMoreCell.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 24.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "OnlinerMotoLoadMoreCell.h"

@implementation OnlinerMotoLoadMoreCell

- (void)setInitialState
{
    [self.activityIndicator stopAnimating];
    self.label.text = @"Load more";
}

- (void)setLoadingState
{
    self.label.text = @"Loading...";
    [self.activityIndicator startAnimating];
}

@end
