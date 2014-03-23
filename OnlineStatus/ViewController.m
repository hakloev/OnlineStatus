//
//  ViewController.m
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 22/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Do any additional setup after loading the view, typically from a nib.
    self.coffeeModel = [[CoffeModel alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coffeeModelUpdated) name:@"statusUpdated" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshButton:(id)sender
{
    if (self.coffeeModel != nil) {
        [[self coffeLabel] setText:@"Henter informasjon..."];
        [[self coffeeModel] refreshCoffeeStatus];
    }

}

- (void)coffeeModelUpdated
{
    NSLog(@"coffeeModelUpdated");
    [[self coffeLabel] setText:[[self coffeeModel] getCoffeeStatus]];
}

@end
