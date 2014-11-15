//
//  OnlinerMotoVehicleDetailsViewController.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 15.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

class OnlinerMotoVehicleDetailsViewController : UITableViewController, UICollectionViewDataSource
{
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var priceLabel: UILabel!
    @IBOutlet weak private var yearLabel: UILabel!
    @IBOutlet weak private var mileageLabel: UILabel!
    @IBOutlet weak private var briefDescriptionLabel: UILabel!
    @IBOutlet weak private var locationLabel: UILabel!
    @IBOutlet weak private var urlLabel: UILabel!
    @IBOutlet weak private var additionalDescriptionLabel: UILabel!
    
    @IBOutlet weak private var photosCollectionView: UICollectionView!
    @IBOutlet weak private var addVehicleItemToTaggedButton: UIBarButtonItem!
    
    var vehicleItem: VehicleItem!
    var isTaggingAvailable: Bool = false
    private var vehicleItemDetails: VehicleItemDetails?
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.nameLabel.text = self.vehicleItem.name
        self.priceLabel.text = "$\(self.vehicleItem.price)"
        self.yearLabel.text = String(self.vehicleItem.year)
        self.mileageLabel.text = "\(self.vehicleItem.mileage) km"
        self.briefDescriptionLabel.text = self.vehicleItem.briefDescription
        self.urlLabel.text = self.vehicleItem.detailsUrl
        
        self.photosCollectionView.backgroundColor = UIColor.whiteColor()
        self.addVehicleItemToTaggedButton.enabled = self.isTaggingAvailable
        
        showLoadingIndicators()

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0))
        {
            var itemDetails = self.getGlobalVehicleItemsProvider().getItemDetailsForItem(self.vehicleItem)
            
            dispatch_async(dispatch_get_main_queue())
            {
                self.hideLoadingIndicators()
                self.vehicleItemDetails = itemDetails
                if (self.vehicleItemDetails != nil)
                {
                    self.showVehicleItemDetails(self.vehicleItemDetails!)
                }
            }
        }
    }
    
    @IBAction private func addVehicleItemToTagged(sender: AnyObject)
    {
        self.getGlobalVehicleItemsRepository().addVehicleItem(self.vehicleItem)
        self.addVehicleItemToTaggedButton.enabled = false
        
        OnlinerMotoVehicleDetailsViewController.showMessage("Item marked as tagged")
    }
    
    private class func showMessage(message: String)
    {
        UIAlertView(
                title: "",
                message: message,
                delegate: nil,
                cancelButtonTitle: "OK").show()
    }
    
    @IBAction private func hideDetailsView(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        var number = 0
        
        if let photos = self.vehicleItemDetails?.allPhotos
        {
            number = photos.count
        }
        
        return number
    }
    
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            "OnlinerMotoPhotoCell",
            forIndexPath: indexPath) as OnlinerMotoPhotoCell
        
        if let photos = self.vehicleItemDetails?.allPhotos
        {
            cell.photoImage.image = UIImage(data: photos[indexPath.row])
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        var height: CGFloat = 44
        if (indexPath.section == 0 && indexPath.row == 1)
        {
            if let text: String = self.vehicleItemDetails?.vehicleItem?.briefDescription
            {
                var foundationText = text as NSString
                var constraint = CGSizeMake(320 - (20 * 2), 20000)
                var pstyle = NSMutableParagraphStyle()
                pstyle.lineBreakMode = .ByWordWrapping
                
                var attributes = [NSFontAttributeName: UIFont.systemFontOfSize(17.0), NSParagraphStyleAttributeName: pstyle]
                
                var rect = foundationText.boundingRectWithSize(
                    constraint,
                    options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                    attributes: attributes,
                    context: nil)
                
                height = 10 + max(rect.height, 44.0)
            }
            else
            {
                height = 10
            }
        }
        else if (indexPath.section == 1)
        {
            height = 320
        }
        else if (indexPath.section == 2)
        {
            if let text: String = self.vehicleItemDetails?.additionalDescription
            {
                var foundationText = text as NSString
                var constraint = CGSizeMake(320 - (20 * 2), 20000)
                var pstyle = NSMutableParagraphStyle()
                pstyle.lineBreakMode = .ByWordWrapping
                
                var attributes = [NSFontAttributeName: UIFont.systemFontOfSize(17.0), NSParagraphStyleAttributeName: pstyle]
                
                var rect = foundationText.boundingRectWithSize(
                    constraint,
                    options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                    attributes: attributes,
                    context: nil)
                
                height = 10 + max(rect.height, 44.0)
            }
            else
            {
                height = 10
            }
        }
        
        return height
    }
    
    private func showVehicleItemDetails(itemDetails: VehicleItemDetails)
    {
        self.locationLabel.text = itemDetails.location
        self.additionalDescriptionLabel.text = itemDetails.additionalDescription
        self.additionalDescriptionLabel.numberOfLines = 0
        self.additionalDescriptionLabel.sizeToFit()
        self.briefDescriptionLabel.sizeToFit()

        self.photosCollectionView.reloadData()
        self.tableView.reloadData()
    }
    
    private func showLoadingIndicators()
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.tableView.scrollEnabled = false
        self.view.addSubview(LoadingIndicatorView(frame: self.view.bounds))
    }
    
    private func hideLoadingIndicators()
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        for subview in self.view.subviews
        {
            if (subview is LoadingIndicatorView)
            {
                subview.removeFromSuperview()
            }
        }
        self.tableView.scrollEnabled = true
    }
    
    private func getGlobalVehicleItemsRepository() -> VehicleItemsRepositoryProtocol
    {
        var appDelegate = UIApplication.sharedApplication().delegate as OnlinerMotoAppDelegateProtocol
        return appDelegate.vehicleItemsRepository
    }
    
    private func getGlobalVehicleItemsProvider() -> VehicleItemsProviderProtocol
    {
        var appDelegate = UIApplication.sharedApplication().delegate as OnlinerMotoAppDelegateProtocol
        return appDelegate.vehicleItemsProvider
    }
}