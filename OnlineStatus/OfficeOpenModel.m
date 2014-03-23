//
//  OfficeOpenModel.m
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 23/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import "OfficeOpenModel.h"

@implementation OfficeOpenModel

- (id)init
{
    self = [super init];
    if (self) {
        [self refreshLightValue];
    }
    return self;
}

- (void)refreshLightValue
{
    self.lightValue = nil;
    NSURL *coffeeUrl = [NSURL URLWithString:@"http://draug.online.ntnu.no/lys.txt"];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:coffeeUrl];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
}

- (NSString *)getLightStatus
{
    if (self.lightValue != nil) {
        int value = [[self lightValue] intValue];
        // Light limit, 0-860 is ON, 860-1023 is OFF
        NSLog([NSString stringWithFormat:@"The value is %i", value]);
        if (value <= 860) {
            return @"Kontoret er åpent!";
        } else {
            return @"Kontoret er stengt!";
        }
    }
    return @"Kunne ikke hente informasjon\ngrunnet nettverksfeil!";
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"OfficeOpenModel: didReciveResponse");
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"OfficeOpenModel: didReciveData");
    [[self responseData] appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSLog(@"OfficeOpenModel: didReciveNothing");
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"OfficeOpenModel: finishedLoading");
    self.lightValue = [[NSString alloc] initWithData:[self responseData] encoding:NSUTF8StringEncoding];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lightUpdated" object:self];

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"OfficeOpenModel: didFail");
    self.lightValue = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"lightUpdated" object:self];

}


@end
