//
//  KaffeModel.h
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 22/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoffeModel : NSObject<NSURLConnectionDelegate>

@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) NSArray *coffeeStatus;
@property (strong, nonatomic) NSString *coffeeStatusString;

- (id)init;
- (void)setCoffeeStatus;
- (void)refreshCoffeeStatus;
- (NSString *)getCoffeeStatus;


@end
