//
//  KaffeModel.h
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 22/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoffeModel : NSObject

- (id)init;
- (void)refreshCoffeeStatus;
- (NSString *)getCoffeeStatus;


@end
