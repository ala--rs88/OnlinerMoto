//
//  OnlinerMotoTaggedVehiclesViewController.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 14.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

class OnlinerMotoTaggedVehiclesViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak private var tableView: UITableView!
    
    private var vehicleItemsToBeDisplayed = [VehicleItem]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        var refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refreshTable:", forControlEvents: .ValueChanged)
        
        self.tableView.addSubview(refreshControl)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        self.vehicleItemsToBeDisplayed = getGlobalVehicleItemsRepository().getAllVehicleItems() as [VehicleItem]
        var count = self.vehicleItemsToBeDisplayed.count
        
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("OnlinerMotoVehicleItemCell") as OnlinerMotoVehicleItemCell
        
        var item = self.vehicleItemsToBeDisplayed[indexPath.row]
        
        cell.nameLabel.text = item.name
        cell.briefDescriptionLabel.text = item.briefDescription
        if let mainPhotoData = item.mainPhoto?
        {
            cell.mainImageView.image = UIImage(data: mainPhotoData)
        }
        cell.priceLabel.text = String(item.price)
        cell.yearLabel.text = String(item.year)

        return cell
    }
    
    func tableView(
        tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.Delete)
        {
            var repository = getGlobalVehicleItemsRepository()
            var item = self.vehicleItemsToBeDisplayed[indexPath.row] as VehicleItem
            
            repository.removeVehicleItemByDetailsUrl(item.detailsUrl)
            self.tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "VehicleItemDetailsFromTaggedSegue")
        {
            var detailsViewController = segue.destinationViewController as OnlinerMotoVehicleDetailsViewController
            
            detailsViewController.isTaggingAvailable = false
            detailsViewController.vehicleItem = self.vehicleItemsToBeDisplayed[self.tableView.indexPathForSelectedRow()!.row]
        }
    }
    
    func refreshTable(refreshControl: UIRefreshControl)
    {
        refreshControl.attributedTitle = NSAttributedString(string: "Undating ...")
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - AppDelegate accessors
    
    private func getGlobalVehicleItemsRepository() -> VehicleItemsRepositoryProtocol
    {
        var appDelegate = UIApplication.sharedApplication().delegate as OnlinerMotoAppDelegateProtocol
        return appDelegate.vehicleItemsRepository
    }
}
