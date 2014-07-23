//
//  EventListController.m
//  GuestBook
//
//  Created by Emily Brenneke on 8/23/11.
//  Copyright 2014 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import "EventListController.h"
#import "AddEventViewController.h"
#import "GuestBookAppDelegate.h"
#import "Signature.h"
#import "UGBZipHTMLExport.h"
#import <MessageUI/MessageUI.h>

@interface EventListController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSIndexPath *pendingDeletePath;

@end

@implementation EventListController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
    [NSFetchedResultsController deleteCacheWithName:nil];
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.contentSizeForViewInPopover = CGSizeMake(300.0, 300.0);

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;

    // display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // display a Cancel button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissSelf:)];

    if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)]) {
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Action Handlers

- (IBAction)dismissSelf:(id)sender
{
    // dismiss popup, change to selected event
    [[NSNotificationCenter defaultCenter] postNotificationName:@"eventPopoverShouldDismiss" object:nil];
}

#pragma mark - UIAlertViewDelegate Protocol

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // the user clicked one of the Delete/Cancel buttons
    if (buttonIndex == 1) {
        // delete all associated signatures first
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        Event *event = [self.fetchedResultsController objectAtIndexPath:self.pendingDeletePath];
        NSEnumerator *e = [event.signatures objectEnumerator];
        id collectionMemberObject;

        while ((collectionMemberObject = [e nextObject])) {
            // delete the signature
            NSError *error = nil;
            Signature *sig = collectionMemberObject;
            [[NSFileManager defaultManager] removeItemAtPath:sig.mediaPath error:&error];
            [context deleteObject:collectionMemberObject];
        }

        // if deleting currentEvent, set current event to nil
        GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
        if ([appDelegate currentEvent] == event) {
            [appDelegate setCurrentEvent:nil];
        }

        // Delete the managed object for the given index path
        [context deleteObject:event];

        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    self.pendingDeletePath = nil;
}

#pragma mark - UITableViewDataSource Protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventListTableViewCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)insertNewEvent
{
    // create just one add event view controller and keep it around
    AddEventViewController *aevController = [[AddEventViewController alloc] init];
    [[self navigationController] pushViewController:aevController animated:YES];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;

    switch (type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    NSInteger numberOfObjects = [sectionInfo numberOfObjects];
    if (indexPath.row < numberOfObjects) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // confirm delete
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this event? This action cannot be undone." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
        self.pendingDeletePath = [indexPath copy];
        [alert show];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }

    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    if (indexPath.row < [sectionInfo numberOfObjects]) {
        Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = [[event name] description];
        cell.detailTextLabel.text = [dateFormatter stringFromDate:[event time]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = [self shareButtonForTag:indexPath.row];
    } else {
        cell.textLabel.text = @"Add a New Event...";
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
    }
    cell.backgroundColor = [UIColor clearColor];
}

- (UIView *)shareButtonForTag:(NSInteger)tag
{
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0., 0., 60., 30.)];
    shareButton.layer.cornerRadius = 5.f;
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    shareButton.tag = tag;

    if ([MFMailComposeViewController canSendMail]) {
        shareButton.backgroundColor = [UIColor colorWithRed:0. green:0.35 blue:0. alpha:1.0];
        [shareButton addTarget:self action:@selector(shareEvent:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        shareButton.backgroundColor = [UIColor lightGrayColor];
        [shareButton addTarget:self action:@selector(unableToShareEvent:) forControlEvents:UIControlEventTouchUpInside];
    }

    return shareButton;
}

- (IBAction)shareEvent:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:tag inSection:0];
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];

    NSString *zipDataPath = [UGBZipHTMLExport zipDataForEvent:event];
    if (!zipDataPath) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Unable to export guestbook. Device full?" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alert show];
    } else {
        NSString *fileName = [[zipDataPath lastPathComponent] stringByDeletingPathExtension];
        NSData *fileData = [NSData dataWithContentsOfFile:fileName];
        MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
        [vc setSubject:[NSString stringWithFormat:@"Guestbook for %@", [event name]]];
        [vc setMessageBody:@"Guestbook is attached!\n\n" isHTML:NO];
        [vc addAttachmentData:fileData mimeType:@"application/zip" fileName:fileName];
        [vc setModalPresentationStyle:UIModalPresentationCurrentContext];
        [vc setMailComposeDelegate:self];
        [self presentModalViewController:vc animated:YES];

        [[NSFileManager defaultManager] removeItemAtPath:zipDataPath error:NULL];
    }
}

- (IBAction)unableToShareEvent:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to share" message:@"Please make sure this device is configured to send email." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UITableViewDelegate Protocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
    if (indexPath.row < [sectionInfo numberOfObjects]) {
        // dismiss popup, change to selected event
        [[NSNotificationCenter defaultCenter] postNotificationName:@"eventPopoverShouldDismiss" object:nil];

        // save current selection
        GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setCurrentEvent:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    } else {
        [self insertNewEvent];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate Protocol

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
