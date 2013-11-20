//
//  AddEventViewController.m
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2013 Matt Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import "AddEventViewController.h"
#import "GuestBookAppDelegate.h"
#import "Event.h"

@interface AddEventViewController ()

@property (nonatomic, weak, readwrite) IBOutlet UITextField* name;
@property (nonatomic, weak, readwrite) IBOutlet UIDatePicker* datePicker;

@end

@implementation AddEventViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Create a New Event";
    self.datePicker.datePickerMode = UIDatePickerModeDate;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.name.text = @"";
    self.datePicker.date = [NSDate date];
}

#pragma mark - Actions

- (IBAction)createEvent:(UIButton*)sender
{
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    Event* event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];
    
    [event setName:[self.name text]];
    [event setTime:[self.datePicker date]];
    [event setUuid:[appDelegate generateUuidString]];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelEvent:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
