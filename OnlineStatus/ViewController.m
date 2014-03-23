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
    [[self officeActivity] startAnimating];
    [[self coffeActivity] startAnimating];
    
    self.coffeeModel = [[CoffeModel alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coffeeModelUpdated) name:@"coffeeUpdated" object:nil];
    
    self.officeOpenModel = [[OfficeOpenModel alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(officeOpenModelUpdated) name:@"lightUpdated" object:nil];
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
        [[self coffeActivity] startAnimating];
        [[self coffeeModel] refreshCoffeeStatus];
    }
    if (self.officeOpenModel != nil) {
        [[self lightLabel] setText:@"Henter informasjon..."];
        [[self officeActivity] startAnimating];
        [[self officeOpenModel] refreshLightValue];
    }

}

- (void)coffeeModelUpdated
{
    NSLog(@"coffeeModelUpdated");
    [[self coffeActivity] stopAnimating];
    [[self coffeLabel] setText:[[self coffeeModel] getCoffeeStatus]];
}

- (void)officeOpenModelUpdated
{
    NSLog(@"officeOpenModelUpdated");
    [[self officeActivity] stopAnimating];
    [[self lightLabel] setText:[[self officeOpenModel] getLightStatus]];
}

@end
