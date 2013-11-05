//
//  OnlinerWebVehileItemsProvider.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 4.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "OnlinerWebVehileItemsProvider.h"
#import "HTMLParser.h"

@interface OnlinerWebVehileItemsProvider()
{
    NSMutableData *_responseData;
    bool _isResponseRecieved;
}
@end

@implementation OnlinerWebVehileItemsProvider

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _isResponseRecieved = false;
        
        // Create the request.
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://mb.onliner.by/search"]];
        
        NSURL * url = [NSURL URLWithString:@"http://mb.onliner.by/search"];
        NSError * error;
        NSStringEncoding *encoding;
        NSString * htmlContent = [NSString stringWithContentsOfURL:url usedEncoding:encoding error:&error];
        
        // Specify that it will be a POST request
        request.HTTPMethod = @"POST";
        
        // This is how we set header fields
       // [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        // Convert your data and set your request's HTTPBody property
        NSString *stringData = @"max-price=150";
        NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = requestBodyData;
        
        // Create url connection and fire request
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return self;
}

- (void)applyFilter:(VehicleItemFilter *)filter
{
    NSException *exception = [NSException exceptionWithName:@"NotImplementedException"
                                                     reason:@"This method is not yet implemented."
                                                   userInfo:nil];
    [exception raise];
}

- (NSUInteger)totalItemsCount
{
    return 17;
}

- (NSArray *)getItemsFromIndex:(NSUInteger)startIndex count:(NSUInteger)itemsCount;
{
    NSException *exception = [NSException exceptionWithName:@"NotImplementedException"
                                                     reason:@"This method is not yet implemented."
                                                   userInfo:nil];
    [exception raise];
    return nil;
}

- (VehicleItemDetails *)getItemDetailsForItem:(VehicleItem *)item
{
    NSException *exception = [NSException exceptionWithName:@"NotImplementedException"
                                                     reason:@"This method is not yet implemented."
                                                   userInfo:nil];
    [exception raise];
    return nil;
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    _isResponseRecieved = true;
    NSString *responseBody = [[NSString alloc] initWithData:_responseData encoding:NSASCIIStringEncoding];
    NSError *error;
    NSDictionary *responseJson = [NSJSONSerialization JSONObjectWithData:_responseData
                                                                 options:kNilOptions
                                                                   error:&error];
    if (error)
    {
        NSLog(@"Error: %@", error);
        return;
    }
    
  //  NSDictionary *results = responseJson[@"result"];
    NSString *html = responseJson[@"result"][@"content"];
    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    
    if (error)
    {
        NSLog(@"Error: %@", error);
        return;
    }
    
    HTMLNode *bodyNode = [parser body];
    
    NSArray *trNodes = [bodyNode findChildTags:@"tr"];
    
    for (HTMLNode *trNode in trNodes)
    {
            NSLog(@"%@", [trNode getAttributeNamed:@"id"]);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    _isResponseRecieved = true;
}

@end
