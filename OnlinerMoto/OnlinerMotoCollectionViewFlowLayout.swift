//
//  OnlinerMotoCollectionViewFlowLayout.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 13.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

class OnlinerMotoCollectionViewFlowLayout : UICollectionViewFlowLayout
{
    private var previousOffset: CGFloat = 0
    private var currentPage = 0
    
    
    override func targetContentOffsetForProposedContentOffset(
        proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint) -> CGPoint
    {
        if (self.collectionView?.dataSource == nil)
        {
            return super.targetContentOffsetForProposedContentOffset(
                proposedContentOffset,
                withScrollingVelocity: velocity)
        }
        
        var itemsCount = self.collectionView!.dataSource!.collectionView(
            self.collectionView!,
            numberOfItemsInSection: 0)
        
        // Imitating paging behaviour
        // Check previous offset and scroll direction
        if ((self.previousOffset > self.collectionView!.contentOffset.x)
            && (velocity.x < 0.0))
        {
            self.currentPage = max(self.currentPage - 1, 0)
        }
        else if ((self.previousOffset < self.collectionView!.contentOffset.x)
                && (velocity.x > 0.0))
        {
            self.currentPage = min(self.currentPage + 1, itemsCount - 1)
        }
        
        // Update offset by using item size + spacing
        var updatedOffset = (self.itemSize.width + self.minimumInteritemSpacing) * CGFloat(self.currentPage)
        self.previousOffset = updatedOffset;
        
        return CGPointMake(updatedOffset, proposedContentOffset.y);
    }
}