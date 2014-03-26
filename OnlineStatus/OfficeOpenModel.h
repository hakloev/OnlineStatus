//
//  OfficeOpenModel.h
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 23/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OfficeOpenModel : NSObject

@property (strong, nonatomic) NSString *servantStatus;
@property (strong, nonatomic) NSString *officeStatus;
@property (strong, nonatomic) NSMutableArray *agendaList;

- (id)init;
- (void)refreshOfficeData;

@end
