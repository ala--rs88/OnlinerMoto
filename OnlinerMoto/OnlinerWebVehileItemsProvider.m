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

- (NSUInteger)totalItemsCount
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
    
    
    NSUInteger rangeStartIndex = startIndex % _onlinerPageSize;
    NSUInteger rangeLength = itemsCount;
    
    if (rangeStartIndex >= [_loadedVehicleItems count])
    {
        return nil;
    }
    
    if (rangeStartIndex + rangeLength > [_loadedVehicleItems count]
        && [_loadedVehicleItems count] > 0)
    {
        rangeLength = [_loadedVehicleItems count] - rangeStartIndex;
    }
    
    NSRange range;
    range.location = rangeStartIndex;
    range.length = rangeLength;
        
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
    
    return [self syncLoadVehicleItemsWithHttpBodyData:[completeHttpBody dataUsingEncoding:NSUTF8StringEncoding]];
}

// todo: try to get rid of side effect
- (NSArray *)syncLoadVehicleItemsWithHttpBodyData:(NSData *)httpBodyData
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://mb.onliner.by/search"]];
    request.HTTPMethod = @"POST";
    
    if (httpBodyData)
    {
        request.HTTPBody = httpBodyData;
    }
    
    NSURLResponse* response = nil;
    NSError *error;
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
    if (error)
    {
        // todo: handle error
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    bool isLoadingSuccessful = [OnlinerWebVehileItemsProvider parseJsonObjectForSuccess:responseJson];
    
    _totalVehicleItemsCount = isLoadingSuccessful ? [OnlinerWebVehileItemsProvider parseJsonObjectForTotalVehicleItemsCount:responseJson] : -1;
    
    return isLoadingSuccessful ? [OnlinerWebVehileItemsProvider parseJsonObjectForVehicleItems:responseJson] : nil;
}


+ (bool)parseJsonObjectForSuccess:(NSDictionary *)jsonObject
{
    return [jsonObject[@"success"] boolValue];
}

+ (NSUInteger)parseJsonObjectForTotalVehicleItemsCount:(NSDictionary *)jsonObject
{
    return [jsonObject[@"result"][@"counters"][@"realCount"] integerValue];
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
    
    vehicleItem.price = [[[[[[tdCost findChildOfClass:@"big"] findChildTag:@"a"] findChildTag:@"strong"] contents] stringByReplacingOccurrencesOfString:@" " withString:@"" ] integerValue];
    
    NSString *mainPhotoUrl = [[[tdPhoto findChildTag:@"a"] findChildTag:@"img"] getAttributeNamed:@"src"];
    vehicleItem.mainPhoto = [NSData dataWithContentsOfURL: [NSURL URLWithString:mainPhotoUrl]];
    
    return vehicleItem;
}

@end
