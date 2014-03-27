//
//  OfficeOpenModel.h
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 23/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import <Foundation/Foundation.h>

#define lightUrl [NSURL URLWithString:@"http://draug.online.ntnu.no/lys.txt"]
#define servantUrl [NSURL URLWithString:@"https://online.ntnu.no/notifier/online/servant"]
#define meetingUrl [NSURL URLWithString:@"https://online.ntnu.no/notifier/online/meetings"]
#define officeUrl [NSURL URLWithString:@"https://online.ntnu.no/notifier/online/office"]
#define urlArray [[NSArray alloc] initWithObjects:lightUrl, servantUrl, meetingUrl, officeUrl, nil]

@interface OfficeOpenModel : NSObject

@property (atomic) NSString *servantStatus;
@property (atomic) NSString *officeStatus;
@property (atomic) NSMutableArray *agendaList;

- (id)init;
- (void)refreshOfficeData;

@end
