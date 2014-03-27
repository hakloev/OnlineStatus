//
//  KaffeModel.m
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 22/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import "CoffeModel.h"

@interface CoffeModel ()

//Private
@property NSMutableData *responseData; // (strong, atomic) by default
@property NSArray *coffeeStatus;
@property NSOperationQueue *queue;
@property NSURL *coffeeUrl;
@property NSURLRequest *req;

@end

@implementation CoffeModel

-(id)init
{
    self = [super init];
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
        self.coffeeUrl = [NSURL URLWithString:@"http://draug.online.ntnu.no/coffee.txt"];
        self.req = [NSURLRequest requestWithURL:self.coffeeUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        self.responseData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)refreshCoffeeStatus
{
    [[self responseData] setLength:0];
    
    __block NSUInteger outstandingRequests = 1;
    [NSURLConnection sendAsynchronousRequest:self.req queue:self.queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if ([data length] > 0 && connectionError == nil) {
                                   [[self responseData] appendData:data];
                                   NSLog(@"Done with coffee request");
                               } else {
                                   [[self responseData] setLength:0];
                                   NSLog(@"Coffee package failed");
                               }
                               outstandingRequests--;
                               if (outstandingRequests == 0) {
                                   [self setCoffeeStatus];
                                   [self performSelectorOnMainThread:@selector(tellMainThreadReady) withObject:nil waitUntilDone:NO];
                               }
                            }];
}

- (void)setCoffeeStatus
{
    if ([[self responseData] length] == 0) {
        NSLog(@"Coffee response nil");
        self.returnString = @"Kunne ikke hente informasjon\ngrunnet nettverksfeil!";
        return;
    } else {
        NSLog(@"Coffee response not nil");
        self.coffeeStatus = [[[NSString alloc] initWithData:[self responseData] encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"\n"];
    }
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd. LLLL yyyy HH:mm:ss"];
    NSDate *lastCoffeeMade = [format dateFromString:[[self coffeeStatus] objectAtIndex:1]];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *today = [[NSDate alloc] init];
    
    if ([[format stringFromDate:lastCoffeeMade] isEqualToString:[format stringFromDate:today]]) {
        [format setDateFormat:@"HH:mm:ss"];
        NSString *lastCoffee = [format stringFromDate:lastCoffeeMade];
        self.returnString = [NSString stringWithFormat:@"Antall kanner idag: %@\nSiste klokka: %@", [[self coffeeStatus] objectAtIndex:0], lastCoffee];
        return;
    } else {
        self.returnString = @"Ingen kaffe laget i dag!\n\nHar kontorvakta gjort\njobben sin?";
        return;
    }
}

- (void)tellMainThreadReady
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"coffeeUpdated" object:self];
}

@end
