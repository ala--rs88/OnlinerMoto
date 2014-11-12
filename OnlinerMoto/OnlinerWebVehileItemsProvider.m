//
//  OnlinerWebVehileItemsProvider.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 4.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "OnlinerWebVehileItemsProvider.h"
#import "HTMLParser.h"

#import "OnlinerMoto-Swift.h"

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
        NSMutableString *httpBody = [[NSMutableString alloc] init];
        
        if (filter.minPrice)
        {
            [httpBody appendFormat:@"min-price=%u&", filter.minPrice];
        }
        
        if (filter.maxPrice)
        {
            [httpBody appendFormat:@"max-price=%u&", filter.maxPrice];
        }
        
        if (filter.minYear)
        {
            [httpBody appendFormat:@"min-year=%u&", filter.minYear];
        }
        
        if (filter.maxYear)
        {
            [httpBody appendFormat:@"max-year=%u&", filter.maxYear];
        }
        
        if (filter.minEngineVolume)
        {
            [httpBody appendFormat:@"min-capacity=%u&", filter.minEngineVolume];
        }
        
        if (filter.maxEngineVolume)
        {
            [httpBody appendFormat:@"max-capacity=%u&", filter.maxEngineVolume];
        }
        
        if (![httpBody isEqualToString:@""])
        {
            _initialHttpBodyForFilter = [httpBody substringToIndex:[httpBody length] - 1];
        }
        else
        {
            _initialHttpBodyForFilter = nil;
        }
    }
    else
    {
        _initialHttpBodyForFilter = nil;
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
        if (_loadedVehicleItems)
        {
            _currentLoadedPageIndex = onlinerPageIndexToRetrieveFrom;
        }
        else
        {
            [self resetProviderState];
            return [[NSArray alloc] init];
        }
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
    NSError *error;
    HTMLParser *parser = [[HTMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:item.detailsUrl] error:&error];
    
    if (error)
    {
        // todo: handle error
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    VehicleItemDetails *itemDetails = [OnlinerWebVehileItemsProvider parseVehicleItemDetailsBody:[parser body]];
    
    if (itemDetails)
    {
        itemDetails.vehicleItem = item;
    }
        
    return itemDetails;
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
        [completeHttpBody appendString:_initialHttpBodyForFilter];
    }
    
    if (pageIndex > 0)
    {
        if (![completeHttpBody isEqualToString:@""])
        {
            [completeHttpBody appendString:@"&"];
        }
        
        [completeHttpBody appendFormat:@"page=%u", pageIndex + 1];
    }  
    
    return [self syncLoadVehicleItemsWithHttpBodyData:[completeHttpBody dataUsingEncoding:NSUTF8StringEncoding]];
}

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
    
    if (error)
    {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
    if (error)
    {
        NSLog(@"Error: %@", error);
        return nil;
    }
    
    _totalVehicleItemsCount = [OnlinerWebVehileItemsProvider parseJsonObjectForTotalVehicleItemsCount:responseJson];
    
    return _totalVehicleItemsCount > 0 ? [OnlinerWebVehileItemsProvider parseJsonObjectForVehicleItems:responseJson] : [[NSArray alloc] init];
}


+ (bool)parseJsonObjectForSuccess:(NSDictionary *)jsonObject
{
    return [jsonObject[@"success"] boolValue];
}

+ (NSUInteger)parseJsonObjectForTotalVehicleItemsCount:(NSDictionary *)jsonObject
{
    if (![OnlinerWebVehileItemsProvider parseJsonObjectForSuccess:jsonObject])
    {
        return 0;
    }
    
    @try
    {
        return [jsonObject[@"result"][@"counters"][@"realCount"] integerValue]; 
    }
    @catch (NSException *exception)
    {
        return 0;
    }
}
    
+ (NSArray *)parseJsonObjectForVehicleItems:(NSDictionary *)jsonObject
{
    if (![OnlinerWebVehileItemsProvider parseJsonObjectForSuccess:jsonObject])
    {
        return nil;
    }
    
    NSString *html;
    
    @try
    {
       html = jsonObject[@"result"][@"content"];
    }
    @catch (NSException *exception)
    {
        return nil;
    }
    
    
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
    
    HTMLNode *detailsUrlWithName = [[[tdTxt findChildTag:@"h2"] findChildTag:@"span"] findChildTag:@"a"];
    vehicleItem.detailsUrl = [NSString stringWithFormat:@"http://mb.onliner.by%@", [detailsUrlWithName getAttributeNamed:@"href"]];
    
    
    NSString *name = [[detailsUrlWithName allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
    vehicleItem.name = [regex stringByReplacingMatchesInString:name options:0 range:NSMakeRange(0, [name length]) withTemplate:@""];
        
    vehicleItem.briefDescription = [[[tdTxt findChildTag:@"p"] contents] stringByReplacingOccurrencesOfString:@"мотоцикл, " withString:@""];
    
    vehicleItem.year = [[[tdTxt findChildOfClass:@"year"] contents] integerValue];
    
    vehicleItem.mileage = [[[[[tdTxt findChildOfClass:@"dist"] findChildTag:@"strong"] contents]
                            stringByReplacingOccurrencesOfString:@" " withString:@""]  integerValue];
    
    vehicleItem.price = [[[[[[tdCost findChildOfClass:@"big"] findChildTag:@"a"] findChildTag:@"strong"] contents]
                          stringByReplacingOccurrencesOfString:@" " withString:@""] integerValue];
    
    NSString *mainPhotoUrl = [[[tdPhoto findChildTag:@"a"] findChildTag:@"img"] getAttributeNamed:@"src"];
    
    if (!mainPhotoUrl)
    {
        mainPhotoUrl = [[[[tdTxt findChildWithAttribute:@"class" matchingName:@"autoba-table-thumbs" allowPartial:YES] findChildTag:@"a"] findChildTag:@"img"] getAttributeNamed:@"src"];
    }
    
    vehicleItem.mainPhoto = [NSData dataWithContentsOfURL: [NSURL URLWithString:mainPhotoUrl]];
    
    return vehicleItem;
}

+ (VehicleItemDetails *)parseVehicleItemDetailsBody:(HTMLNode *)body
{
    VehicleItemDetails *itemDetails = [[VehicleItemDetails alloc] init];
    
    HTMLNode *photosAndDescriptionNode = [body findChildOfClass:@"autoba-msglongcont"];
    
    if (!photosAndDescriptionNode)
    {
        return nil;
    }
    
    NSArray *photosAndDescriptionNodeChildren = [photosAndDescriptionNode children];
    
    NSMutableString *description = [[NSMutableString alloc] init];
    
    for (HTMLNode *node in photosAndDescriptionNodeChildren)
    {
        if ([node nodetype] == HTMLPNode)
        {
            [description appendFormat:@"%@\n", [[node allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
    }
    
    NSArray *photoLinkNodes = [photosAndDescriptionNode findChildrenWithAttribute:@"id" matchingName:@"thumb_" allowPartial:YES];
    NSMutableArray *photosDatas = [[NSMutableArray alloc] init];
    
    for (HTMLNode *photoNode in photoLinkNodes)
    {
        NSString *photoUrlString = [[photoNode findChildTag:@"img"] getAttributeNamed:@"src"];
        photoUrlString = [photoUrlString stringByReplacingOccurrencesOfString:@"100x100" withString:@"800x800"];
        
        NSData *photoData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:photoUrlString]];
        [photosDatas addObject:photoData];
    }
    
    itemDetails.location = [[[body findChildOfClass:@"content"] findChildTags:@"p"][2] contents];
    itemDetails.additionalDescription = [[description copy] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    itemDetails.allPhotos = [photosDatas copy];
    
    return itemDetails;
}

@end
