//
//  LoadingIndicatorView.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 13.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

class LoadingIndicatorView : UIView
{
    let labelWidth: CGFloat = 150
    let labelHeight: CGFloat = 20
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor();
        var label = UILabel(frame: CGRectMake(
            (self.bounds.size.width - labelWidth) / 2 + 20,
            (self.bounds.size.height - labelHeight) / 2,
            labelWidth,
            labelHeight))
        
        label.text = "Loading ..."
        label.center = self.center
        
        var spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner.frame = CGRectMake(
            label.frame.origin.x - labelHeight - 5,
            label.frame.origin.y,
            labelHeight,
            labelHeight)
        
        spinner.startAnimating()
        
        self.addSubview(spinner)
        self.addSubview(label)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}