//
//  KaffeModel.m
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 22/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import "CoffeModel.h"

@interface CoffeModel ()

@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSArray *coffeeStatus;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) NSURL *coffeeUrl;
@property (strong, nonatomic) NSURLRequest *req;

@end

@implementation CoffeModel

-(id)init
{
    self = [super init];
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
        self.coffeeUrl = [NSURL URLWithString:@"http://draug.online.ntnu.no/coffee.txt"];
        self.req = [[NSURLRequest alloc] initWithURL:self.coffeeUrl];

        [self refreshCoffeeStatus];
    }
    return self;
}

- (void)refreshCoffeeStatus
{
    self.responseData = [[NSMutableData alloc] init];
    
    __block NSUInteger outstandingRequests = 1;
    [NSURLConnection sendAsynchronousRequest:self.req queue:self.queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if ([data length] > 0 && connectionError == nil) {
                                   [[self responseData] appendData:data];
                                   NSLog(@"Done with coffe request");
                               } else {
                                   self.responseData = nil;
                                   NSLog(@"Coffee package failed");
                               }
                               outstandingRequests--;
                               if (outstandingRequests == 0) {
                                   [self setCoffeeStatus];
                                   dispatch_async(dispatch_get_main_queue(),^{
                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"coffeeUpdated" object:self];
                                   });
                                }
                            }];
}

- (void)setCoffeeStatus
{
    if (self.responseData == nil) {
        NSLog(@"getCoffeStatus response nil");
        self.returnString = @"Kunne ikke hente informasjon\ngrunnet nettverksfeil!";
    } else {
        NSLog(@"getCoffeStatus response not nil");
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
    } else {
        self.returnString = @"Ingen kaffe laget i dag!\n\nHar kontorvakta gjort\njobben sin?";
    }
}

@end
