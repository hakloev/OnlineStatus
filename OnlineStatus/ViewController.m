//
//  ViewController.m
//  OnlineStatus
//
//  Created by Håkon Ødegård Løvdal on 22/03/14 .
//  Copyright (c) 2014 Håkon Ødegård Løvdal. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) CoffeModel *coffeeModel;
@property (strong, nonatomic) OfficeOpenModel *officeOpenModel;

@property (strong, nonatomic) IBOutlet UILabel *coffeLabel;
@property (strong, nonatomic) IBOutlet UILabel *servantLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UITextView *meetingView;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *officeActivity;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *coffeActivity;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(officeOpenModelUpdated) name:@"officeUpdated" object:nil];
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
        [[self meetingView] setText:@"Henter informasjon..."];
        [[self officeActivity] startAnimating];
        [[self officeOpenModel] refreshOfficeData];
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
    
    if ([[[self officeOpenModel] statusArray] count] == 1) {
        [[self meetingView] setText:[[[self officeOpenModel] statusArray] objectAtIndex:0]];
    } else {
        // First we print the servant label
        [[self servantLabel] setText:[[[self officeOpenModel] statusArray] objectAtIndex:0]];
        // Then we print the status
        [[self statusLabel] setText:[[[self officeOpenModel] statusArray] objectAtIndex:1]];
        // Then we print the agenda
        NSMutableString *stringForLabel = [[NSMutableString alloc] init];
        for (int i = 2; i < [[[self officeOpenModel] statusArray] count]; i++) {
            NSString *currentString = [[[self officeOpenModel] statusArray] objectAtIndex:i];
            [stringForLabel appendString:currentString];
            [stringForLabel appendString:@"\n"];
        }
        [[self meetingView] setText:stringForLabel];
        //self.meetingView.textColor = [UIColor whiteColor];
    }
}

@end
