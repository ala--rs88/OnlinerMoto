//
//  OnlinerMotoCollectionViewLayout.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 01.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

#import "OnlinerMotoCollectionViewLayout.h"

@interface OnlinerMotoCollectionViewFlowLayout ()

@property (nonatomic, assign) CGFloat previousOffset;
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation OnlinerMotoCollectionViewFlowLayout

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    NSInteger itemsCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    
    // Imitating paging behaviour
    // Check previous offset and scroll direction
    if ((self.previousOffset > self.collectionView.contentOffset.x) && (velocity.x < 0.0f))
    {
        self.currentPage = MAX(self.currentPage - 1, 0);
    }
    else if ((self.previousOffset < self.collectionView.contentOffset.x) && (velocity.x > 0.0f))
    {
        self.currentPage = MIN(self.currentPage + 1, itemsCount - 1);
    }
    
    // Update offset by using item size + spacing
    CGFloat updatedOffset = (self.itemSize.width + self.minimumInteritemSpacing) * self.currentPage;
    self.previousOffset = updatedOffset;
    
    return CGPointMake(updatedOffset, proposedContentOffset.y);
}

@end
