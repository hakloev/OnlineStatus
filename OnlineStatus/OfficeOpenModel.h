//
//  OfficeOpenModel.h
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 23/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OfficeOpenModel : NSObject

@property (strong, nonatomic) NSMutableArray *statusArray;

- (id)init;
- (void)refreshOfficeData;
//- (NSString *)getLightStatus;

@end
