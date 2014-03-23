//
//  OfficeOpenModel.h
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 23/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OfficeOpenModel : NSObject<NSURLConnectionDelegate>

@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSString* lightValue;

- (id)init;
- (void)refreshLightValue;
- (NSString *)getLightStatus;

@end
