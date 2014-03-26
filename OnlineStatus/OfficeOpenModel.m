//
//  OfficeOpenModel.m
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 23/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import "OfficeOpenModel.h"

@interface OfficeOpenModel ()

@property (strong, atomic) NSMutableDictionary *responseData;
@property (strong, atomic) NSMutableArray *requestArray;
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
        
        NSURLRequest *lightReq = [NSURLRequest requestWithURL:lightUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        NSURLRequest *servantReq = [NSURLRequest requestWithURL:servantUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        NSURLRequest *meetingReq = [NSURLRequest requestWithURL:meetingUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        NSURLRequest *officeReq = [NSURLRequest requestWithURL:officeUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
        
        self.requestArray = [[NSMutableArray alloc] initWithObjects:officeReq, servantReq, meetingReq, lightReq, nil];
        self.queue = [[NSOperationQueue alloc] init];
        self.responseData = [[NSMutableDictionary alloc] init];
        [self refreshOfficeData];
    }
    return self;
}

- (void)refreshOfficeData
{
    [[self responseData] removeAllObjects];
    
    __block NSInteger outstandingRequests = [[self requestArray] count];
    for (NSURLRequest *request in [self requestArray]) {
        [NSURLConnection sendAsynchronousRequest:request queue:self.queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if ([data length] > 0 && connectionError == nil) {
                                       [[self responseData] setObject:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forKey:request];
                                   } else {
                                       [[self responseData] removeAllObjects];
                                       NSLog(@"Office data: one package failed!");
                                   }
                                   outstandingRequests--;
                                   if (outstandingRequests == 0) {
                                       [self setOfficeStatus];
                                       NSLog(@"Office data: done with refresh office data");
                                       [self performSelectorOnMainThread:@selector(tellMainThreadReady) withObject:nil waitUntilDone:NO];
                                   }
                               }];
    }
}

- (void)setOfficeStatus
{
    
    if ([[self responseData] count] != 0) {
        NSString *officeeStatus = [[self responseData] objectForKey:[[self requestArray] objectAtIndex:0]];
        NSArray *servants = [[[self responseData] objectForKey:[[self requestArray] objectAtIndex:1]] componentsSeparatedByString:@"\n"];
        NSMutableArray *meetings = [[NSMutableArray alloc] initWithArray:[[[self responseData] objectForKey:[[self requestArray] objectAtIndex:2]] componentsSeparatedByString:@"\n"]];
        int lightValue = [[[self responseData] objectForKey:[[self requestArray] objectAtIndex:3]] intValue];
        
        [self setMeetingStatusWith:officeeStatus andMeetingList:meetings andLightValue:lightValue];
        [self setServantStatusWith:servants];
        [self setAgendaListWith:meetings];
                
    } else {
        self.agendaList = [[NSMutableArray alloc] initWithObjects:@"Kunne ikke hente informasjon\ngrunnet nettverksfeil!", nil];
        self.servantStatus = nil;
        self.officeStatus = nil;
    }
}

- (void)setMeetingStatusWith:(NSString *)officeeStatus andMeetingList:(NSMutableArray *)meetingList andLightValue:(int)lightValue
{
    if ([officeeStatus isEqualToString:@"free\n"]) {
        NSString *statusString;
        if (lightValue > 0 && lightValue < 860) {
            statusString = @"ÅPENT";
        } else {
            statusString = @"STENGT";
        }
        self.officeStatus = statusString;
    } else if ([officeeStatus hasPrefix:@"meeting"]) {
        NSString *currentMeeting = [[officeeStatus componentsSeparatedByString:@"\n"] objectAtIndex:1];
        if ([[meetingList objectAtIndex:0] hasSuffix:currentMeeting]) {
            self.officeStatus = [meetingList objectAtIndex:0];
            [meetingList removeObjectAtIndex:0];
        } else {
            self.officeStatus = @"Ukjent møte!";
        }
    } else if ([officeeStatus hasPrefix:@"cake"]) {
        self.officeStatus = [[meetingList objectAtIndex:0] substringFromIndex:12];
        [meetingList removeObjectAtIndex:0];
        
    }
}

- (void)setServantStatusWith:(NSArray *)servantList
{
    // MUST ONLY PRINT THE SERVANT AT HIS/HER GIVEN TIME
    NSString *searchString = [servantList objectAtIndex:0];
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
        // Hvis kontorvakta har vakt nå
        if ([[dateFormater stringFromDate:servantStart] intValue] <= [[dateFormater stringFromDate:now] intValue] && [[dateFormater stringFromDate:now] intValue] < [[dateFormater stringFromDate:servantEnd] intValue]) {
            self.servantStatus = [searchString substringFromIndex:12];
            // Hvis kontorvakta ikke har vakt nå
        } else {
            self.servantStatus = @"Ingen kontorvakt nå";
        }
        // Ingen flere vakter i dag
    } else {
        self.servantStatus = [servantList objectAtIndex:0];
    }
}

- (void)setAgendaListWith:(NSMutableArray *)meetingList
{
    if ([meetingList count] == 1) {
        self.agendaList = [[NSMutableArray alloc] initWithObjects:@"Det er ikke noe mer på agendaen!", nil];
    } else {
        self.agendaList = [[NSMutableArray alloc] init];
        for (int i = 0; i < [meetingList count]; i++) {
            [[self agendaList] addObject:[meetingList objectAtIndex:i]];
        }
    }

}

- (void)tellMainThreadReady
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"officeUpdated" object:self];
}

@end
