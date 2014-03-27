//
//  OfficeOpenModel.m
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 23/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import "OfficeOpenModel.h"

@interface OfficeOpenModel ()

// Private
@property NSArray *officeData;
@property int lightData;
@property (nonatomic) int urlCounter;

@end


@implementation OfficeOpenModel

- (id)init
{
    self = [super init];
    if (self) {
        self.urlCounter = 4;
    }
    return self;
}

- (void)refreshOfficeData
{
    [self setOfficeData:nil];
    [self setLightData:0];
    [self setUrlCounter:4];
    [NSThread detachNewThreadSelector:@selector(downloadURL) toTarget:self withObject:nil];
}

- (void)downloadURL
{
    for (int i = 0; i < [urlArray count]; i++) {
        NSLog(@"%@", [urlArray objectAtIndex:i]);
        NSString *string = [[NSString alloc] initWithContentsOfURL:[urlArray objectAtIndex:i] encoding:NSUTF8StringEncoding error:NULL];
        [self saveContentsOfUrlWith:string and:[urlArray objectAtIndex:i]];
        self.urlCounter--;
    }
    if (self.urlCounter == 0) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self didFinishDownload];
        }];
    }
}

- (void)saveContentsOfUrlWith:(NSString *)data and:(NSURL *)url
{
    if ([url isEqual:lightUrl]) {
        [self setLightData:[data intValue]];
    } else if ([url isEqual:servantUrl]) {
        [self setServantStatusWith:[data componentsSeparatedByString:@"\n"]];
    } else if ([url isEqual:meetingUrl]) {
        [self setAgendaListWith:[data componentsSeparatedByString:@"\n"]];
    } else if ([url isEqual:officeUrl]) {
        [self setOfficeData:[data componentsSeparatedByString:@"\n"]];
    }
    
    if ([self officeData] != nil && [self lightData] > 0) {
        [self setMeetingStatusWith:[self officeData] andLightValue:[self lightData]];
    }
}

- (void)didFinishDownload
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"officeUpdated" object:self];
}

- (void)setMeetingStatusWith:(NSArray *)officeeStatusArray andLightValue:(int)lightValue
{
    if ([[officeeStatusArray objectAtIndex:0] isEqualToString:@"free"]) {
        if (lightValue > 0 && lightValue < 860) {
            [self setOfficeStatus:@"ÅPENT"];
        } else {
            [self setOfficeStatus:@"STENGT"];
        }
    } else if ([[officeeStatusArray objectAtIndex:0] hasPrefix:@"meeting"]) {
        [self setOfficeStatus:[officeeStatusArray objectAtIndex:1]];
        /*
        if ([[meetingList objectAtIndex:0] hasSuffix:currentMeeting]) {
            self.officeStatus = [meetingList objectAtIndex:0];
            [meetingList removeObjectAtIndex:0];
        } else {
            self.officeStatus = @"Ukjent møte!";
        }
         */
    } else if ([[officeeStatusArray objectAtIndex:0] hasPrefix:@"cake"]) {
        [self setOfficeStatus:[officeeStatusArray objectAtIndex:1]];
        /*
        self.officeStatus = [[meetingList objectAtIndex:0] substringFromIndex:12];
        [meetingList removeObjectAtIndex:0];
         */
    }
}

- (void)setServantStatusWith:(NSArray *)servantList
{
    // MUST ONLY PRINT THE SERVANT AT HIS/HER GIVEN TIME
    NSString *searchString = [servantList objectAtIndex:0];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\d+:\\d+-\\d+:\\d+) ([a-zA-æøåÆØÅ ]+)" options:0 error:&error];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:searchString options:0 range:NSMakeRange(0, [searchString length])];
    // If there is a servant in the list
    if (numberOfMatches >= 1) {
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        [dateFormater setDateFormat:@"HH"];
        NSDate *servantStart = [dateFormater dateFromString:[searchString substringToIndex:2]];
        NSDate *servantEnd = [dateFormater dateFromString:[searchString substringWithRange:NSMakeRange(6, 2)]];
        NSDate *now = [[NSDate alloc] init];
        // If the servant is the current servant
        if ([[dateFormater stringFromDate:servantStart] intValue] <= [[dateFormater stringFromDate:now] intValue] && [[dateFormater stringFromDate:now] intValue] < [[dateFormater stringFromDate:servantEnd] intValue]) {
            self.servantStatus = [searchString substringFromIndex:12];
            // If the servant is not the current servant
        } else {
            self.servantStatus = @"Ingen kontorvakt nå";
        }
    // No more servants this day
    } else {
        self.servantStatus = [servantList objectAtIndex:0];
    }
}

- (void)setAgendaListWith:(NSArray *)meetingList
{
    /*
    if ([meetingList count] == 1) {
        self.agendaList = [[NSMutableArray alloc] initWithObjects:@"Det er ikke noe mer på agendaen!", nil];
    } else {
        self.agendaList = [[NSMutableArray alloc] init];
        for (int i = 0; i < [meetingList count]; i++) {
            [[self agendaList] addObject:[meetingList objectAtIndex:i]];
        }
    }
    */
    self.agendaList = [[NSMutableArray alloc] init];
    for (int i = 0; i < [meetingList count]; i++) {
        [[self agendaList] addObject:[meetingList objectAtIndex:i]];
    }

    
    

}

#pragma mark OLD CODE

/*
- (void)tellMainThreadReady
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"officeUpdated" object:self];
}
*/

/*
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
 */

/*
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
 */

@end
