//
//  OnlinerWebVehileItemsProvider.swift
//  OnlinerMoto
//
//  Created by Igor Karpov on 17.11.2014.
//  Copyright (c) 2014 KarpovIV. All rights reserved.
//

import Foundation

class OnlinerWebVehileItemsProvider : NSObject, VehicleItemsProviderProtocol
{
    private var loadedVehicleItems: [VehicleItem]?
    private var responseData: NSMutableData?
    private var totalVehiclesItemsCount: Int?
    private var currentLoadedPageIndex: Int?
    private var onlinerPageSize: Int
    private var initialHttpBodyForFilter: String?
    
    // MARK: - VehicleItemsProviderProtocol implementation
    
    var totalItemsCount: Int {
        var count = (self.totalVehiclesItemsCount == nil
            || self.totalVehiclesItemsCount < 0)
            ? 0
            : self.totalVehiclesItemsCount!
        
        return count
    }
    
    // MARK: - 
    
    override init()
    {
        self.onlinerPageSize = 30;
        
        super.init()
        
        applyFilter(nil)
    }
    
    // MARK: - VehicleItemsProviderProtocol implementation
    
    func getItems(startIndex: Int, itemsCount: Int) -> [VehicleItem]?
    {
        assert(!((startIndex % self.onlinerPageSize) + itemsCount > self.onlinerPageSize),
                "requested items range is not inside single page")
        
        var onlinerPageIndexToRetrieveFrom = startIndex / self.onlinerPageSize
        
        if (onlinerPageIndexToRetrieveFrom != self.currentLoadedPageIndex)
        {
            self.loadedVehicleItems = self.loadOnlinerPageWithIndex(onlinerPageIndexToRetrieveFrom)
            
            if (self.loadedVehicleItems != nil)
            {
                self.currentLoadedPageIndex = onlinerPageIndexToRetrieveFrom
            }
            else
            {
                self.resetProviderState()
                return [VehicleItem]()
            }
        }
        
        var rangeStartIndex = startIndex % self.onlinerPageSize
        var rangeLength = itemsCount
        
        if (self.loadedVehicleItems == nil
            || rangeStartIndex >= self.loadedVehicleItems!.count)
        {
            return nil
        }
        
        if (rangeStartIndex+rangeLength > self.loadedVehicleItems!.count
            && self.loadedVehicleItems!.count > 0)
        {
            rangeLength = self.loadedVehicleItems!.count - rangeStartIndex;
        }
        
        var itemsRange: [VehicleItem]?
        if let items: [VehicleItem] = self.loadedVehicleItems
        {
            itemsRange = Array(items[rangeStartIndex...rangeStartIndex+rangeLength-1])
        }
        else
        {
            itemsRange = nil
        }
        
        return itemsRange
    }
    
    func getItemDetailsForItem(item: VehicleItem) -> VehicleItemDetails?
    {
        var error: NSError?
        var parser = HTMLParser(contentsOfURL: NSURL(string: item.detailsUrl!)!, error: &error)
        
        if (error != nil)
        {
            return nil
        }
        
        var itemDetails = OnlinerWebVehileItemsProvider.parseVehicleItemDetailsBody(parser.body())
        
        if (itemDetails != nil)
        {
            itemDetails!.vehicleItem = item
        }
        
        return itemDetails
    }
    
    func applyFilter(optionalFilter: VehicleItemFilter?)
    {
        resetProviderState()
        
        if let filter = optionalFilter
        {
            var httpBody = ""
            
            var filterValuesGettersRepresentations: [(VehicleItemFilter -> Int, String)] = [
                ({ $0.minPrice }, "min-price"),
                ({ $0.maxPrice }, "max-price"),
                ({ $0.minYear }, "min-year"),
                ({ $0.maxYear }, "max-year"),
                ({ $0.minEngineVolume }, "min-capacity"),
                ({ $0.maxEngineVolume }, "max-capacity")
            ]
            
            for (valueGetterBlock, httpParameterFormat) in filterValuesGettersRepresentations
            {
                var filterParameterValue = valueGetterBlock(filter)
                if (filterParameterValue > 0)
                {
                    httpBody += "\(httpParameterFormat)=\(filterParameterValue)&"
                }
            }
            
            if (!httpBody.isEmpty)
            {
                self.initialHttpBodyForFilter = httpBody.substringToIndex(httpBody.endIndex.predecessor())
            }
            else
            {
                self.initialHttpBodyForFilter = nil
            }
        }
        else
        {
            self.initialHttpBodyForFilter = nil
        }
    }
    
    // MARK: -
    
    private func loadOnlinerPageWithIndex(pageIndex: Int) -> [VehicleItem]?
    {
        var completeHttpBody = ""
        
        println("self.initialHttpBodyForFilter: \(self.initialHttpBodyForFilter)")
        if let filter = self.initialHttpBodyForFilter
        {
            if (filter != "")
            {
                completeHttpBody += filter
            }
        }
        
        if (pageIndex > 0)
        {
            if (completeHttpBody != "")
            {
                completeHttpBody += "&"
            }
            
            completeHttpBody += "page=\(pageIndex + 1)"
        }
        
        println("http params: \(completeHttpBody)")
        
        var vehicleItems = self.syncLoadVehicleItemsWithHttpBodyData(completeHttpBody.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
        
        return vehicleItems
    }
    
    private func syncLoadVehicleItemsWithHttpBodyData(httpBodyData: NSData?) -> [VehicleItem]?
    {
        var request = NSMutableURLRequest(URL: NSURL(string: "http://mb.onliner.by/search")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = httpBodyData

        var error: NSError?
        var data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: &error)
        
        if (error != nil)
        {
            return nil
        }
        
        var responseJson = NSJSONSerialization.JSONObjectWithData(data!, options: .allZeros, error: &error) as NSDictionary
        
        if (error != nil)
        {
            return nil
        }
        
        self.totalVehiclesItemsCount = OnlinerWebVehileItemsProvider.parseJsonObjectForTotalVehicleItemsCount(responseJson)
        
        var vehicleItems = (self.totalVehiclesItemsCount != nil && self.totalVehiclesItemsCount! > 0)
            ? OnlinerWebVehileItemsProvider.parseJsonObjectForVehicleItems(responseJson)
            : [VehicleItem]()
        
        return vehicleItems
    }
    
    private class func parseVehicleItemDetailsBody(body: HTMLNode) -> VehicleItemDetails?
    {
        var photosAndDescriptionNode = body.findChildOfClass("autoba-msglongcont")
        
        if (photosAndDescriptionNode == nil)
        {
            return nil
        }
        
        var photosAndDescriptionNodeChildren = photosAndDescriptionNode.children()
        
        var description = ""
        
        for node in photosAndDescriptionNodeChildren
        {
            if (node.nodetype_Swift() == .HTMLPNode_Swift)
            {
                var secriptionLine = node.allContents().stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet());
                println(secriptionLine)
                description += "\(secriptionLine)\n"
            }
        }
        
        var photoLinkNodes = photosAndDescriptionNode.findChildrenWithAttribute("id", matchingName: "thumb_", allowPartial: true)
        var photosDatas = [NSData]()
        
        for photoNode in photoLinkNodes
        {
            var photoUrlString = photoNode.findChildTag("img").getAttributeNamed("src")
            photoUrlString = photoUrlString.stringByReplacingOccurrencesOfString("100x100", withString: "800x800")
            
            if let photoData = NSData(contentsOfURL: NSURL(string: photoUrlString)!)
            {
                photosDatas.append(photoData)
            }
        }
        
        var itemDetails = VehicleItemDetails()
        
        itemDetails.location = body.findChildOfClass("content").findChildTags("p")[2].contents as String?
        itemDetails.additionalDescription = description.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        itemDetails.allPhotos = photosDatas
        
        return itemDetails
    }
    
    private class func parseJsonObjectForTotalVehicleItemsCount(jsonObject: NSDictionary) -> Int
    {
        if (!OnlinerWebVehileItemsProvider.parseJsonObjectForSuccess(jsonObject))
        {
            return 0
        }
        
        var totalCount = 0
        
        if (jsonObject.valueForKey("result") is NSDictionary)
        {
            var result = jsonObject.valueForKey("result") as NSDictionary?
            var counters = result?.valueForKey("counters") as NSDictionary?
            var realCount = counters?.valueForKey("realCount") as Int?
            
            totalCount = realCount? ?? 0
        }
        
        return totalCount
    }
    
    private class func parseJsonObjectForVehicleItems(jsonObject: NSDictionary) -> [VehicleItem]?
    {
        if (!OnlinerWebVehileItemsProvider.parseJsonObjectForSuccess(jsonObject))
        {
            return nil
        }
        
        var html = (jsonObject.valueForKey("result") as NSDictionary?)?.valueForKey("content") as String?
        
        if (html == nil)
        {
            return nil
        }
        
        var error: NSError? = nil
        var parser = HTMLParser(string: html!, error: &error)
        
        if (error != nil)
        {
            println("Error: \(error)")
            return nil
        }
        
        var motoRows = parser.body().findChildrenWithAttribute("class", matchingName: "motoRow", allowPartial: true)
        
        var vehicleItems = [VehicleItem]()
        for motoRowNode in motoRows
        {
            var vehicleItem = OnlinerWebVehileItemsProvider.parseMotoRowNode(motoRowNode as HTMLNode)
            vehicleItems.append(vehicleItem)
        }
        
        return vehicleItems
    }
    
    private class func parseJsonObjectForSuccess(jsonObject: NSDictionary) -> Bool
    {
        var isSuccess = jsonObject["success"]?.boolValue ?? false
        return isSuccess
    }
    
    private class func parseMotoRowNode(motoRowNode: HTMLNode) -> VehicleItem
    {
        var vehicleItem = VehicleItem()
        
        var tdTxt = motoRowNode.findChildOfClass("txt")
        var tdCost = motoRowNode.findChildOfClass("cost lst")
        
        var detailsUrlWithName = tdTxt.findChildTag("h2").findChildTag("span").findChildTag("a")
        var href = detailsUrlWithName.getAttributeNamed("href")
        vehicleItem.detailsUrl = "http://mb.onliner.by\(href)"
        
        
        var name = detailsUrlWithName.allContents().stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        var error: NSError? = nil
        var regex = NSRegularExpression(pattern: "  +", options: .CaseInsensitive, error: &error)
        
        vehicleItem.name = regex?.stringByReplacingMatchesInString(name, options:NSMatchingOptions.allZeros, range: NSMakeRange(0, countElements(name)), withTemplate: "")
        
        vehicleItem.briefDescription = tdTxt.findChildTag("p").contents().stringByReplacingOccurrencesOfString("мотоцикл, ", withString: "")
        
        vehicleItem.year = tdTxt.findChildOfClass("year").contents().toInt() ?? 0
        
        vehicleItem.mileage = tdTxt.findChildOfClass("dist").findChildTag("strong").contents().stringByReplacingOccurrencesOfString(" ", withString: "").toInt() ?? 0
        
        vehicleItem.price = tdCost.findChildOfClass("big").findChildTag("a").findChildTag("strong").contents().stringByReplacingOccurrencesOfString(" ", withString: "").toInt() ?? 0
        
        var mainPhotoUrl: String
        if let tdPhoto = motoRowNode.findChildOfClass("ph")
        {
            mainPhotoUrl = tdPhoto.findChildTag("a").findChildTag("img").getAttributeNamed("src")
        }
        else
        {
            mainPhotoUrl = tdTxt.findChildWithAttribute("class", matchingName: "autoba-table-thumbs", allowPartial: true).findChildTag("a").findChildTag("img").getAttributeNamed("src")
        }
        
        if (mainPhotoUrl.isEmpty)
        {
            mainPhotoUrl = tdTxt.findChildWithAttribute("class", matchingName: "autoba-table-thumbs", allowPartial: true).findChildTag("a").findChildTag("img").getAttributeNamed("src")
        }
        
        if let url = NSURL(string: mainPhotoUrl)
        {
            vehicleItem.mainPhoto = NSData(contentsOfURL: url)
        }

        return vehicleItem
    }
    
    private func resetProviderState()
    {
        self.initialHttpBodyForFilter = nil
        self.loadedVehicleItems = nil
        self.totalVehiclesItemsCount = -1
        self.currentLoadedPageIndex = -1
    }
}