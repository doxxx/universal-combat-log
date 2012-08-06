//
//  UCLActorViewController.m
//  UniversalCombatLog
//
//  Created by Gordon Tyler on 12-08-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UCLActorViewController.h"

#import "UCLLogEvent.h"

@interface UCLActorViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;

@end

@implementation UCLActorViewController

@synthesize actor = _actor;
@synthesize fight = _fight;

@synthesize nameLabel = _nameLabel;
@synthesize lineChartView = _lineChartView;
@synthesize masterPopoverController = _masterPopoverController;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.lineChartView.data = [NSArray arrayWithObjects:[NSNumber numberWithInt:10], 
                               [NSNumber numberWithInt:30],
                               [NSNumber numberWithInt:20],
                               [NSNumber numberWithInt:50],
                               [NSNumber numberWithInt:15], nil];
}

- (void)viewDidUnload
{
    [self setNameLabel:nil];
    [self setLineChartView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)setActor:(UCLEntity *)actor fight:(UCLFight *)fight
{
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    
    _actor = actor;
    _fight = fight;
    
    [self configureView];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Fights", @"Fights");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)configureView
{
    self.nameLabel.text = self.actor.name;
    
    NSArray* events = [self.fight allEventsForEntity:self.actor];
    NSUInteger duration = ceil(self.fight.duration);
    NSDate* start = self.fight.startTime;
    double* data = malloc(sizeof(double)*duration);
    
    for (NSUInteger i = 0; i < duration; i++) {
        data[i] = 0;
    }
    
    for (UCLLogEvent* event in events) {
        if ([event isDamage] && [event.actor isEqualToEntity:self.actor]) {
            uint32_t index = floor([event.time timeIntervalSinceDate:start]);
            data[index] = data[index] + [event.amount doubleValue];
        }
    }
    
    NSMutableArray* numbers = [NSMutableArray arrayWithCapacity:duration];
    for (NSUInteger i = 0; i < duration; i++) {
        [numbers addObject:[NSNumber numberWithDouble:data[i]]];
    }
    
    self.lineChartView.data = numbers;
    
    free(data);
}

@end
