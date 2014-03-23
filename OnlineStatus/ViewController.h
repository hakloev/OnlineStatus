//
//  ViewController.h
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 22/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoffeModel.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) CoffeModel *coffeeModel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *coffeLabel;

@end
