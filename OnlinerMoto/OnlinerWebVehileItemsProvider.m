//
//  OnlinerWebVehileItemsProvider.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 4.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "OnlinerWebVehileItemsProvider.h"
#import "HTMLParser.h"
#import "VehicleItem.h"

@interface OnlinerWebVehileItemsProvider()
{
    NSArray *_loadedVehicleItems;
    NSMutableData *_responseData;
    NSInteger _totalVehicleItemsCount;
    NSInteger _currentLoadedPageIndex;
    
    // todo: make it Const
    NSUInteger _onlinerPageSize;
    
    NSString *_initialHttpBodyForFilter;
}
@end


// todo: Consider multithreading !!!

@implementation OnlinerWebVehileItemsProvider

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _onlinerPageSize = 30;
        
        [self applyFilter:nil];
    }
    
    return self;
}




#pragma mark VehicleItemsProviderProtocol members

// todo: consider megring with init or smth like that
- (void)applyFilter:(VehicleItemFilter *)filter
{
    [self resetProviderState];
    
    if (filter)
    {
        // todo: implement filter processing
        _initialHttpBodyForFilter = @"max-price=150&min-price=150";
    }
}

- (NSUInteger)totalVehicleItemsCount
{
    return (_totalVehicleItemsCount) < 0 ? 0 : _totalVehicleItemsCount;
}

- (NSArray *)getItemsFromIndex:(NSUInteger)startIndex count:(NSUInteger)itemsCount
{
    if ((startIndex % _onlinerPageSize) + itemsCount > _onlinerPageSize)
    {
        // requested items range is not inside single page
        // todo: handle it appropriately
        
        NSException *exception = [NSException exceptionWithName:@"NotImplementedException"
                                                         reason:@"NotImplementedException: requested items range is not inside single page."
                                                       userInfo:nil];
        [exception raise];
    }
    
    NSUInteger onlinerPageIndexToRetrieveFrom = startIndex / _onlinerPageSize;
    
    if (onlinerPageIndexToRetrieveFrom != _currentLoadedPageIndex)
    {
        _loadedVehicleItems = [self loadOnlinerPageWithIndex:onlinerPageIndexToRetrieveFrom];
        _currentLoadedPageIndex = onlinerPageIndexToRetrieveFrom;
    }
    
    NSRange range;
    range.location = startIndex;
    range.length = startIndex + itemsCount <= [_loadedVehicleItems count] ? itemsCount : [_loadedVehicleItems count] - startIndex;
        
    return [_loadedVehicleItems subarrayWithRange:range];

}

- (VehicleItemDetails *)getItemDetailsForItem:(VehicleItem *)item
{
    NSException *exception = [NSException exceptionWithName:@"NotImplementedException"
                                                     reason:@"This method is not yet implemented."
                                                   userInfo:nil];
    [exception raise];
    return nil;
}



/*
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
   _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{    
    NSError *error;
    NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:_responseData
                                                                 options:kNilOptions
                                                                   error:&error];
    if (error)
    {
        // todo: handle error
        NSLog(@"Error: %@", error);
        return;
    }
    
    // todo: check json for Success==true
    
    _loadedVehicleItems = [OnlinerWebVehileItemsProvider parseJsonObjectForVehicleItems:responseJson];
    // todo: Handle possible changes of TotalCount
    _totalVehicleItemsCount = [OnlinerWebVehileItemsProvider parseJsonObjectForTotalVehicleItemsCount:responseJson];
    
    _isLoadingInProgress = false;
    
    [self processWaitingProviderDelegate];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self resetProviderState];
    
    // todo: handle error
    NSLog(@"Error: %@", error);
}
*/

#pragma mark Private methods

- (void)resetProviderState
{
    _initialHttpBodyForFilter = nil;
    _loadedVehicleItems = nil;    
    _totalVehicleItemsCount = -1;
    _currentLoadedPageIndex = -1;
}

- (NSArray *)loadOnlinerPageWithIndex:(NSUInteger)pageIndex
{
    NSMutableString *completeHttpBody = [[NSMutableString alloc] init];
    
    if (_initialHttpBodyForFilter && ![_initialHttpBodyForFilter isEqualToString:@""])
    {
        [completeHttpBody appendFormat:@"%@&", _initialHttpBodyForFilter];
    }
    
    if (pageIndex > 0)
    {
        [completeHttpBody appendFormat:@"page=%u", pageIndex + 1];
    }  
    
    return [OnlinerWebVehileItemsProvider syncLoadVehicleItemsWithHttpBodyData:[completeHttpBody dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSArray *)syncLoadVehicleItemsWithHttpBodyData:(NSData *)httpBodyData
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://mb.onliner.by/search"]];
    request.HTTPMethod = @"POST";
    
    if (httpBodyData)
    {
        request.HTTPBody = httpBodyData;
    }
    
    NSURLResponse* response = nil;
    NSError *error;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
    if (error)
    {
        // todo: handle error
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    // todo: IK handle total Count
    return [OnlinerWebVehileItemsProvider parseJsonObjectForVehicleItems:responseJson];
}


+ (NSUInteger)parseJsonObjectForTotalVehicleItemsCount:(NSDictionary *)jsonObject
{
    return [jsonObject[@"result"][@"counters"][@"total"] integerValue];
}

+ (NSArray *)parseJsonObjectForVehicleItems:(NSDictionary *)jsonObject
{
    NSString *html = jsonObject[@"result"][@"content"];
    
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    
    if (error)
    {
        // todo: handle error
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    NSArray *motoRows = [[parser body] findChildrenWithAttribute:@"class" matchingName:@"motoRow" allowPartial:YES];
    
    NSMutableArray *vehicleItems = [[NSMutableArray alloc] init];
    for (HTMLNode *motoRow in motoRows)
    {
        [vehicleItems addObject:[OnlinerWebVehileItemsProvider parseMotoRowNode:motoRow]];
    }
    
    return [vehicleItems copy];
}

+ (VehicleItem *)parseMotoRowNode:(HTMLNode *)motoRowNode
{
    VehicleItem *vehicleItem = [[VehicleItem alloc] init];
    
    HTMLNode *tdTxt = [motoRowNode findChildOfClass:@"txt"];
    HTMLNode *tdPhoto = [motoRowNode findChildOfClass:@"ph"];
    HTMLNode *tdCost = [motoRowNode findChildOfClass:@"cost lst"];
    
    
    // todo: handle EXTENDED rows
    // todo: parse name postfix
    
    HTMLNode *detailsUrlWithName = [[[tdTxt findChildTag:@"h2"] findChildTag:@"span"] findChildTag:@"a"];
    vehicleItem.detailsUrl = [detailsUrlWithName getAttributeNamed:@"href"];
    vehicleItem.name = [[detailsUrlWithName findChildTag:@"strong"] contents];
    
    vehicleItem.briefDescription = [[tdTxt findChildTag:@"p"] contents];
    
    vehicleItem.year = [[[tdTxt findChildOfClass:@"year"] contents] integerValue];
    
    vehicleItem.mileage = [[[[tdTxt findChildOfClass:@"dist"] findChildTag:@"strong"] contents] integerValue];
    
    vehicleItem.price = [[[[[tdCost findChildOfClass:@"big"] findChildTag:@"a"] findChildTag:@"strong"] contents] integerValue];
    
    NSString *mainPhotoUrl = [[[tdPhoto findChildTag:@"a"] findChildTag:@"img"] getAttributeNamed:@"src"];
    vehicleItem.mainPhoto = [NSData dataWithContentsOfURL: [NSURL URLWithString:mainPhotoUrl]];
    
    return vehicleItem;
}

@end
