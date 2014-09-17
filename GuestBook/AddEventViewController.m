//
//  AddEventViewController.m
//  GuestBook
//
//  Created by Emily Brenneke on 8/23/11.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import "AddEventViewController.h"
#import "GuestBookAppDelegate.h"

@interface AddEventViewController ()

@property (nonatomic, weak, readwrite) IBOutlet UITextField *name;
@property (nonatomic, weak, readwrite) IBOutlet UIDatePicker *datePicker;

@end

@implementation AddEventViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Create a New Event";
    self.datePicker.datePickerMode = UIDatePickerModeDate;

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.name.text = @"";
    self.datePicker.date = [NSDate date];
}

#pragma mark - Actions

- (IBAction)createEvent:(UIButton *)sender
{
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    Event *event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];

    [event setName:[self.name text]];
    [event setTime:[self.datePicker date]];
    [event setUuid:[[NSUUID UUID] UUIDString]];

    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    [appDelegate setCurrentEvent:event];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelEvent:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
