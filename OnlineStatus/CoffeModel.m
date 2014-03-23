//
//  KaffeModel.m
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 22/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import "CoffeModel.h"

@implementation CoffeModel

-(id)init
{
    self = [super init];
    if (self) {
        [self refreshCoffeeStatus];
    }
    return self;
}

- (void)refreshCoffeeStatus
{
    self.coffeeStatus = nil;
    NSURL *coffeeUrl = [NSURL URLWithString:@"http://draug.online.ntnu.no/coffee.txt"];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:coffeeUrl];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
}

- (NSString *)getCoffeeStatus
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd. LLLL yyyy HH:mm:ss"];
    NSDate *lastCoffeeMade = [format dateFromString:[[self coffeeStatus] objectAtIndex:1]];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *today = [[NSDate alloc] init];
    
    if ([[format stringFromDate:lastCoffeeMade] isEqualToString:[format stringFromDate:today]]) {
        [format setDateFormat:@"HH:mm:ss"];
        NSString *lastCoffee = [format stringFromDate:lastCoffeeMade];
        return [NSString stringWithFormat:@"Antall kanner idag: %@\nSiste klokka: %@", [[self coffeeStatus] objectAtIndex:0], lastCoffee];
    } else {
        return @"Ingen kaffe laget i dag!\n\nHar kontorvakta gjort\njobben sin?";
    }
    
    /*if ([[self coffeeStatus] objectAtIndex:0] == nil) {
        return @"Kunne ikke hente informasjon\ngrunnet nettverksfeil!";
    }*/
    
    return @"Kunne ikke hente informasjon\ngrunnet nettverksfeil!";

}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"CoffeModel: didReciveResponse");
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"CoffeModel: didReciveData");
    [[self responseData] appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSLog(@"CoffeModel: didReciveNothing");
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"CoffeModel: finishedLoading");
    NSString *tempString = [[NSString alloc] initWithData:[self responseData] encoding:NSUTF8StringEncoding];
    self.coffeeStatus = [tempString componentsSeparatedByString:@"\n"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"coffeeUpdated" object:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"CoffeModel: didFail");
    self.coffeeStatus = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"coffeeUpdated" object:self];
}

@end
