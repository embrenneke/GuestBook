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
    self.datePicker.date = [NSDate date];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
}

#pragma mark - Actions

- (IBAction)createEvent:(UIButton*)sender
{
    // Create a new instance of the entity managed by the fetched results controller.
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    Event* event = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    [event setName:[self.name text]];
    [event setTime:[self.datePicker date]];
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    [event setUuid:[appDelegate generateUuidString]];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    [[self navigationController] popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
