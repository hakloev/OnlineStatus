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

@property (strong, nonatomic) CoffeModel *coffeeModel;
@property (strong, nonatomic) OfficeOpenModel *officeOpenModel;

@property (strong, nonatomic) IBOutlet UILabel *coffeLabel;
@property (strong, nonatomic) IBOutlet UILabel *lightLabel;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *officeActivity;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *coffeActivity;

@end
