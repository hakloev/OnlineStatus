//
//  OfficeOpenModel.m
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 23/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import "OfficeOpenModel.h"

@interface OfficeOpenModel ()

@property (strong, nonatomic) NSMutableDictionary *responseData;
@property (strong, nonatomic) NSMutableArray *requestArray;
@property (strong, nonatomic) NSString* lightValue;
@property (strong, nonatomic) NSOperationQueue *queue;

@end


@implementation OfficeOpenModel

- (id)init
{
    self = [super init];
    if (self) {
        NSURL *lightUrl = [NSURL URLWithString:@"http://draug.online.ntnu.no/lys.txt"];
        NSURL *servantUrl = [NSURL URLWithString:@"https://online.ntnu.no/notifier/online/servant"];
        NSURL *meetingUrl = [NSURL URLWithString:@"https://online.ntnu.no/notifier/online/meetings"];
        NSURL *officeUrl = [NSURL URLWithString:@"https://online.ntnu.no/notifier/online/office"];
        
        NSURLRequest *lightReq = [[NSURLRequest alloc] initWithURL:lightUrl];
        NSURLRequest *servantReq = [[NSURLRequest alloc] initWithURL:servantUrl];
        NSURLRequest *meetingReq = [[NSURLRequest alloc] initWithURL:meetingUrl];
        NSURLRequest *officeReq = [[NSURLRequest alloc] initWithURL:officeUrl];
        
        self.requestArray = [[NSMutableArray alloc] initWithObjects:officeReq, servantReq, meetingReq, lightReq, nil];
        self.queue = [[NSOperationQueue alloc] init];
        [self refreshOfficeData];
    }
    return self;
}

- (void)refreshOfficeData
{
    self.responseData = [[NSMutableDictionary alloc] init];
    
    __block NSInteger outstandingRequests = [[self requestArray] count];
    for (NSURLRequest *request in [self requestArray]) {
        [NSURLConnection sendAsynchronousRequest:request queue:self.queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if ([data length] > 0 && connectionError == nil) {
                                       [[self responseData] setObject:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forKey:request];
                                   } else {
                                       self.responseData = nil;
                                       NSLog(@"En eller flere pakker feila!");
                                   }
                                   outstandingRequests--;
                                   if (outstandingRequests == 0) {
                                       [self setOfficeStatus];
                                       NSLog(@"Done with refresh office data");
                                       dispatch_async(dispatch_get_main_queue(),^{
                                           [[NSNotificationCenter defaultCenter] postNotificationName:@"officeUpdated" object:self];
                                       });
                                   }
                               }];
    }
}

- (void)setOfficeStatus
{
    NSLog(@"createStatusArray");
    self.statusArray = [[NSMutableArray alloc] init];
    
    if ([self responseData] != nil) {
        NSString *officeeStatus = [[self responseData] objectForKey:[[self requestArray] objectAtIndex:0]];
        //NSString *officeeStatus = @"free";
        
        NSArray *servants = [[[self responseData] objectForKey:[[self requestArray] objectAtIndex:1]] componentsSeparatedByString:@"\n"];
        //NSArray *servants = [[NSArray alloc] initWithObjects:@"21:00-22:00 Håkon Løvdal", @"22:00-23:00 Truls Pettersen", @"23:00-23:59 Fredrik Berg", nil];
        
        NSArray *meetings = [[[self responseData] objectForKey:[[self requestArray] objectAtIndex:2]] componentsSeparatedByString:@"\n"];
        //NSArray *meetings = [[NSArray alloc] initWithObjects:@"10.00-11.00 fagKom", @"11.00-12.00 bedKom", @"12.00-13.00 triKom", @"13.00-14.00 arrKom", @"15.00-16.00 appKom", @"17.00-18.00 proKom", @"19.00-20.00 velKom", @"20.00-21.00 hovedStyret", @"10.00-18.00 kradalbyKom", nil];
        
        int lightValue = [[[self responseData] objectForKey:[[self requestArray] objectAtIndex:3]] intValue];
        
        // MUST ONLY PRINT THE SERVANT AT HIS/HER GIVEN TIME
        NSString *searchString = [servants objectAtIndex:0];
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d+:\\d+-\\d+:\\d+) ([a-zA-æøåÆØÅ ]+)" options:0 error:&error];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:searchString options:0 range:NSMakeRange(0, [searchString length])];
        // Hvvis det er en kontorvakt i lista:
        if (numberOfMatches >= 1) {
            NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
            [dateFormater setDateFormat:@"HH"];
            NSDate *servantStart = [dateFormater dateFromString:[searchString substringToIndex:2]];
            NSDate *servantEnd = [dateFormater dateFromString:[searchString substringWithRange:NSMakeRange(6, 2)]];
            NSDate *now = [[NSDate alloc] init];
            //BOOL bol = [[dateFormater stringFromDate:servantStart] intValue] <= [[dateFormater stringFromDate:now] intValue] && [[dateFormater stringFromDate:now] intValue] < [[dateFormater stringFromDate:servantEnd] intValue];
            //NSLog(@"boolean %d", bol);
            //NSLog(@"start: %@, end: %@, now: %@", [dateFormater stringFromDate:servantStart], [dateFormater stringFromDate:servantEnd], [dateFormater stringFromDate:now]);
            // Hvis kontorvakta har vakt nå
            if ([[dateFormater stringFromDate:servantStart] intValue] <= [[dateFormater stringFromDate:now] intValue] && [[dateFormater stringFromDate:now] intValue] < [[dateFormater stringFromDate:servantEnd] intValue]) {
                [[self statusArray] addObject:searchString];
            // Hvis kontorvakta ikke har vakt nå
            } else {
                [[self statusArray] addObject:@"Ingen kontorvakt nå!"];
            }
        // Ingen flere vakter i dag
        } else {
            [[self statusArray] addObject:[servants objectAtIndex:0]];
        }
        
        if ([officeeStatus isEqualToString:@"free"]) {
            NSString *statusString;
            NSLog(@"KONTORET ER LEDIG");
            if (lightValue < 860) {
                NSLog(@"KONTORET ER ÅPENT");
                statusString = @"ÅPENT";
            } else {
                NSLog(@"KONTORET ER STENGT");
                statusString = @"STENGT";
            }
            [[self statusArray] addObject:statusString];
        } else if ([officeeStatus hasPrefix:@"meeting"]) {
            //NSLog(@"DET ER MØTE: %@", meetingStatus);
            NSString *currentMeeting = [[officeeStatus componentsSeparatedByString:@"\n"] objectAtIndex:1];
            if ([[meetings objectAtIndex:0] hasSuffix:currentMeeting]) {
                [[self statusArray] addObject:[meetings objectAtIndex:0]];
                NSLog(@"Det er møte: %@", [meetings objectAtIndex:0]);
                //[[self statusArray] addObject:currentMeeting];
            } else {
                [[self statusArray] addObject:@"Ukjent møte"];
            }
        }
        
        NSLog(@"meetings count: %lu", (unsigned long)[meetings count]);
        if ([meetings count] == 2) {
            [[self statusArray] addObject:@"Det er ikke noe mer på agendaen!"];
        } else {
            for (int i = 1; i < [meetings count]; i++) {
                NSLog(@"Current index in meetings: %@", [meetings objectAtIndex:i]);
                [[self statusArray] addObject:[meetings objectAtIndex:i]];
            }
        }
    } else {
        [[self statusArray] addObject:@"Kunne ikke hente informasjon\ngrunnet nettverksfeil!"];
    }
    

}

@end
