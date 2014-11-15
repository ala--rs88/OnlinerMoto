//
//  OnlinerMotoVehiclesViewController.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 13.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

class OnlinerMotoVehiclesViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var previousPageButton: UIBarButtonItem!
    @IBOutlet weak private var nextPageButton: UIBarButtonItem!
    
    private let DEFAULT_PAGE_SIZE: Int = 30
    private let LOCK_QUEUE = dispatch_queue_create("com.OnlinerMoto.LockQueue", DISPATCH_QUEUE_SERIAL)
    
    private var pageSize: Int
    private var vehicleItemsToBeDisplayed: Array<VehicleItem>
    private var currentLoadedPageIndex: Int
    private var isLoadedPageLast: Bool
    private var currentRequestId: String?
    private var indexForLoadMoreRow: Int {
        get
        {
            return self.pageSize * (self.currentLoadedPageIndex + 1)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        self.pageSize = DEFAULT_PAGE_SIZE
        self.vehicleItemsToBeDisplayed = Array<VehicleItem>()
        self.currentLoadedPageIndex = -1
        self.isLoadedPageLast = false

        super.init(coder: aDecoder)
        
        resetData()
    }
    
    func checkForFilterChanges()
    {
        if (!isFilterAlreadyApplied())
        {
            applyGlobalFilter()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var rowsCount = self.isLoadedPageLast
            ? self.vehicleItemsToBeDisplayed.count
            : (self.vehicleItemsToBeDisplayed.count + 1)
        return rowsCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if (indexPath.row == self.indexForLoadMoreRow)
        {
            var cell = tableView.dequeueReusableCellWithIdentifier("OnlinerMotoLoadMoreCell") as OnlinerMotoLoadMoreCell
            
            if (self.currentLoadedPageIndex == -1)
            {
                cell.setLoadingState()
                self.beginLoadNextPage(true)
            }
            else
            {
                cell.setInitialState()
            }
            
            return cell
        }
        else
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
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if (indexPath.row == self.indexForLoadMoreRow)
        {
            var cell = tableView.cellForRowAtIndexPath(indexPath) as OnlinerMotoLoadMoreCell
            
            cell.setLoadingState()
            beginLoadNextPage(false)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier == "VehicleItemDetailsFromVehiclesSegue")
        {
            var detailsViewController = segue.destinationViewController as OnlinerMotoVehicleDetailsViewController
            
            var vehicleItemToPresent = self.vehicleItemsToBeDisplayed[self.tableView.indexPathForSelectedRow()!.row]
            
            detailsViewController.isTaggingAvailable = isTaggingAvailableForVehicleItem(vehicleItemToPresent)
            detailsViewController.vehicleItem = vehicleItemToPresent
        }
    }
    
    private func resetData()
    {
        self.vehicleItemsToBeDisplayed = Array<VehicleItem>()
        self.currentLoadedPageIndex = -1
        self.isLoadedPageLast = false
        markFilterAsAlreadyApplied()
        self.tableView?.reloadData()
    }
    
    private func isFilterAlreadyApplied() -> Bool
    {
        var appDelegate = UIApplication.sharedApplication().delegate as OnlinerMotoAppDelegateProtocol
        var isApplied = appDelegate.isFilterAlreadyApplied
        return isApplied
    }
    
    private func markFilterAsAlreadyApplied()
    {
        var appDelegate = UIApplication.sharedApplication().delegate as OnlinerMotoAppDelegateProtocol
        appDelegate.isFilterAlreadyApplied = true
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
    
    private func getGlobalFilter() -> VehicleItemFilter
    {
        var appDelegate = UIApplication.sharedApplication().delegate as OnlinerMotoAppDelegateProtocol
        return appDelegate.vehicleItemFilter
    }
    
    private func applyGlobalFilter()
    {
        var globalFilter = getGlobalFilter()
        getGlobalVehicleItemsProvider().applyFilter(globalFilter)
        resetData()
    }
    
    private func showLoadingIndicators(fullyAnimated: Bool)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        if (fullyAnimated)
        {
            self.tableView.scrollEnabled = false
            self.view.addSubview(LoadingIndicatorView(frame: self.view.bounds))
        }
    }
    
    private func hideLoadingIndicators(fullyAnimated: Bool)
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        if (fullyAnimated)
        {
            for subview in self.view.subviews
            {
                if (subview is LoadingIndicatorView)
                {
                    subview.removeFromSuperview()
                }
            }
            self.tableView.scrollEnabled = true
        }
    }
    
    private func isTaggingAvailableForVehicleItem(vehicleItem: VehicleItem) -> Bool
    {
        var isAvailable = !(getGlobalVehicleItemsRepository().isItemAlreadyPresentByDetailsUrl(vehicleItem.detailsUrl!))
        return isAvailable
    }
    
    private func createUniqueId() -> String
    {
        var newId = NSUUID().UUIDString
        return newId
    }
    
    private func beginLoadNextPage(fullyAnimated: Bool)
    {
        var pageToLoadIndex = self.currentLoadedPageIndex + 1
        
        showLoadingIndicators(fullyAnimated)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var tempCurrentRequestId: String?
            dispatch_sync(self.LOCK_QUEUE) {
                self.currentRequestId = self.createUniqueId()
                tempCurrentRequestId = self.currentRequestId
            }
            
            var loadedVehicleItems = self.getGlobalVehicleItemsProvider().getItems(
                pageToLoadIndex * self.pageSize,
                itemsCount: self.pageSize) ?? [VehicleItem]()
            
            dispatch_async(dispatch_get_main_queue()) {
                if (tempCurrentRequestId == self.currentRequestId)
                {
                    self.hideLoadingIndicators(fullyAnimated)
                    self.endLoadPage(
                        pageToLoadIndex,
                        loadedVehicleItems: loadedVehicleItems,
                        totalVehicleItemsCount: Int(self.getGlobalVehicleItemsProvider().totalItemsCount))
                }
            }
        }
    }
    
    private func endLoadPage(pageIndex: Int, loadedVehicleItems: [VehicleItem], totalVehicleItemsCount: Int)
    {
        if (!loadedVehicleItems.isEmpty)
        {
            self.vehicleItemsToBeDisplayed += loadedVehicleItems
            self.currentLoadedPageIndex = pageIndex
        }
        
        if (loadedVehicleItems.isEmpty
            || totalVehicleItemsCount <= self.vehicleItemsToBeDisplayed.count)
        {
            self.isLoadedPageLast = true
        }
        
        if (loadedVehicleItems.isEmpty
            && self.currentLoadedPageIndex <= 0)
        {
            UIAlertView(
                title: "",
                message: "Sorry, no matching items found or connection failed.",
                delegate: nil,
                cancelButtonTitle: "OK").show()
        }
        
        self.tableView.reloadData()
    }
}