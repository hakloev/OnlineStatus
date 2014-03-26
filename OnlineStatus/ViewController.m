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

@property (strong, nonatomic) IBOutlet UILabel *servantLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UITextView *meetingView;
@property (strong, nonatomic) IBOutlet UITextView *coffeeView;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *officeActivity;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *coffeActivity;

@property BOOL threadIsFinished;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Do any additional setup after loading the view, typically from a nib.
    [[self officeActivity] startAnimating];
    [[self coffeActivity] startAnimating];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coffeeModelUpdated) name:@"coffeeUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(officeOpenModelUpdated) name:@"officeUpdated" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateModels) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.threadIsFinished = NO;
    [NSThread detachNewThreadSelector:@selector(updateModels) toTarget:self withObject:nil];
}

- (void)updateModels
{
    NSLog(@"Update Models");
    if (self.coffeeModel == nil) {
        self.coffeeModel = [[CoffeModel alloc] init];
    } else {
        [[self coffeeModel] refreshCoffeeStatus];
    }
    if (self.officeOpenModel == nil) {
        self.officeOpenModel = [[OfficeOpenModel alloc] init];
    } else {
        [[self officeOpenModel] refreshOfficeData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshButton:(id)sender
{
    if (self.threadIsFinished) {
        NSLog(@"Refreshing, Thread FREE");
        [[self servantLabel] setText:@" "];
        [[self statusLabel] setText:@" "];
        
        if (self.coffeeModel != nil) {
            [[self coffeeView] setText:@"Henter informasjon..."];
            [[self coffeActivity] startAnimating];
        }
        
        if (self.officeOpenModel != nil) {
            [[self meetingView] setText:@"Henter informasjon..."];
            [[self officeActivity] startAnimating];
        }
        
        self.threadIsFinished = NO;
        [NSThread detachNewThreadSelector:@selector(updateModels) toTarget:self withObject:nil];
    } else {
        NSLog(@"Not refreshing, Thread BUSY");
    }
    
}

- (IBAction)infoPushed:(id)sender {
    UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"Informasjon" message: @"https://github.com/hakloev/OnlineStatus" delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
    [someError show];
}

- (void)coffeeModelUpdated
{
    NSLog(@"Coffe Model Updated");
    [[self coffeActivity] stopAnimating];
    [[self coffeeView] setText:[[self coffeeModel] returnString]];
}

- (void)officeOpenModelUpdated
{
    NSLog(@"Office Model Updated");
    
    [[self officeActivity] stopAnimating];
       
    [[self servantLabel] setText:[[self officeOpenModel] servantStatus]];
    [[self statusLabel] setText:[[self officeOpenModel] officeStatus]];
    
    NSMutableString *stringForView = [[NSMutableString alloc] init];
    for (int i = 0; i < [[[self officeOpenModel] agendaList] count]; i++) {
        NSString *currentString = [[[self officeOpenModel] agendaList] objectAtIndex:i];
        [stringForView appendString:currentString];
        [stringForView appendString:@"\n"];
    }
    [[self meetingView] setText:stringForView];
    
    self.threadIsFinished = YES;
}

@end
