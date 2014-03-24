//
//  ViewController.h
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 22/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoffeModel.h"
#import "OfficeOpenModel.h"

@interface ViewController : UIViewController

- (void)coffeeModelUpdated;
- (void)officeOpenModelUpdated;

@end
