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
        
    }
    return self;
}

/*
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
 */

- (void)refreshCoffeeStatus
{
    [self setReturnString:nil];
    [NSThread detachNewThreadSelector:@selector(downloadURL) toTarget:self withObject:nil];
}

- (void)downloadURL
{
    NSString *data = [[NSString alloc] initWithContentsOfURL:coffeeUrl encoding:NSUTF8StringEncoding error:NULL];
    [self saveContentsOfUrlWith:data];
}

- (void)saveContentsOfUrlWith:(NSString *)data
{
    [self setCoffeeStatusWith:[data componentsSeparatedByString:@"\n"]];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self didFinishDownload];
    }];
}

- (void)didFinishDownload
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"coffeeUpdated" object:self];
}

- (void)setCoffeeStatusWith:(NSArray *)coffeeArray
{
    if ([coffeeArray count] == 0) {
        NSLog(@"Coffee response nil");
        [self setReturnString:@"Kunne ikke hente informasjon\ngrunnet nettverksfeil!"];
        return;
    } else {
        NSLog(@"Coffee response not nil");
    }
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd. LLLL yyyy HH:mm:ss"];
    NSDate *lastCoffeeMade = [format dateFromString:[coffeeArray objectAtIndex:1]];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *today = [[NSDate alloc] init];
    
    if ([[format stringFromDate:lastCoffeeMade] isEqualToString:[format stringFromDate:today]]) {
        [format setDateFormat:@"HH:mm:ss"];
        NSString *lastCoffee = [format stringFromDate:lastCoffeeMade];
        [self setReturnString:[NSString stringWithFormat:@"Antall kanner idag: %@\nSiste klokka: %@", [coffeeArray objectAtIndex:0], lastCoffee]];
        return;
    } else {
        [self setReturnString:@"Ingen kaffe laget i dag!\n\nHar kontorvakta gjort\njobben sin?"];
        return;
    }
}

@end
