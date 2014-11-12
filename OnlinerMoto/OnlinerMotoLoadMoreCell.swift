//
//  OnlinerMotoLoadMoreCell.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 13.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

class OnlinerMotoLoadMoreCell : UITableViewCell
{
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setInitialState()
    {
        self.activityIndicator.stopAnimating()
        self.label.text = "Load more"
    }
    
    func setLoadingState()
    {
        self.label.text = "Loading ..."
        self.activityIndicator.startAnimating()
    }
}