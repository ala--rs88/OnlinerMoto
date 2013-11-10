//
//  AVWebVehicleItemsProvider.m
//  OnlinerMoto
//
//  Created by Igor Karpov on 3.11.2013.
//  Copyright (c) 2013 KarpovIV. All rights reserved.
//

#import "AVWebVehicleItemsProvider.h"

@interface AVWebVehicleItemsProvider()
{
    NSMutableData *_responseData;
    bool _isResponseRecieved;
}
@end

@implementation AVWebVehicleItemsProvider

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _isResponseRecieved = false;
        
        // Create the request.
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.av.by/public/index.php?event=3&category_id=1382&show_new=0"]];
        
        // Create url connection and fire request
        //NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
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

- (NSUInteger)totalVehicleItemsCount
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
    NSLog(@"%@", responseBody);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    _isResponseRecieved = true;
}

@end