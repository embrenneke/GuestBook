//
//  RootViewController.m
//  GuestBook
//
//  Created by Emily Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "GuestBookAppDelegate.h"
#import "Signature.h"

@implementation RootViewController

@synthesize eventsPopup, eventsView, addEntryPopup, addSigView, pendingDeletePath;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize fetchedResultsController=fetchedResultsController_;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Signature *sig = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [sig.name description];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:25.0];
    cell.detailTextLabel.text = [sig.message description];
    cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:16.0];
    cell.imageView.image = [UIImage imageWithData:[sig thumbnail]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set up the events and add signature buttons.
    UIBarButtonItem *events = [[UIBarButtonItem alloc] initWithTitle:@"Events" style:UIBarButtonItemStylePlain target:self action:@selector(chooseEvent:)];
    self.navigationItem.leftBarButtonItem = events;
    [events release];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewSignature:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];

    self.navigationItem.title = @"No Event Selected";

    eventsView = [[EventListController alloc] initWithNibName:@"EventListController" bundle:nil];
    eventsView.managedObjectContext = self.managedObjectContext;
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:eventsView];
    eventsPopup = [[UIPopoverController alloc] initWithContentViewController:navCon];
    eventsView.title = @"Event List";
    [navCon release];
    
    addSigView = [[AddSignatureViewController alloc] initWithNibName:@"AddSignatureViewController" bundle:nil];
    addSigView.managedObjectContext = self.managedObjectContext;
    UINavigationController *sigNavCon = [[UINavigationController alloc] initWithRootViewController:addSigView];
    addEntryPopup = [[UIPopoverController alloc] initWithContentViewController:sigNavCon];
    addSigView.title = @"Add Signature";
    [sigNavCon release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseEvent:) name:@"eventPopoverShouldDismiss" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertNewSignature:) name:@"signaturePopoverShouldDismiss" object:nil];
    
    NSString *openEvent = [[NSUserDefaults standardUserDefaults] stringForKey:@"OpenEvent"];
    if(openEvent)
    {
        // set current event
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"uuid == %@", openEvent];
        [fetchRequest setPredicate:aPredicate];
        [fetchRequest setFetchBatchSize:1];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        NSError *err = nil;
        NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&err];
        if((array != nil) && ([array count] > 0))
        {
            GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
            Event *event = [array objectAtIndex:0];
            [appDelegate setCurrentEvent:event];
        }
        [fetchRequest release];
        [sortDescriptor release];
        [sortDescriptors release];
    }
    else
    {
        // offer to create new event
        [self chooseEvent:self.navigationItem.leftBarButtonItem];
        [eventsView insertNewEvent];
        
        // disable add signature until event is created
        [addButton setEnabled:false];
    }
}

- (void)insertNewSignature:(id)sender
{
    if([eventsPopup isPopoverVisible])
    {
        [eventsPopup dismissPopoverAnimated:YES];
    }
    if(![addEntryPopup isPopoverVisible])
    {
        [addEntryPopup presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [addEntryPopup dismissPopoverAnimated:YES];
    }
}

- (void)chooseEvent:(id)sender
{
    if([addEntryPopup isPopoverVisible])
    {
        [addEntryPopup dismissPopoverAnimated:YES];
    }
    if(![eventsPopup isPopoverVisible])
    {
        [eventsPopup presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [eventsPopup dismissPopoverAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [NSFetchedResultsController deleteCacheWithName:nil];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return YES;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController_ != nil)
    {
        return fetchedResultsController_;
    }
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Signature" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"event == %@", [appDelegate currentEvent]];
    [fetchRequest setPredicate:aPredicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"SigsCache"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return fetchedResultsController_;
} 

- (void)updatePredicate
{
    [NSFetchedResultsController deleteCacheWithName:nil];
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"event == %@", [appDelegate currentEvent]];
    [[self.fetchedResultsController fetchRequest] setPredicate:aPredicate];
    NSError *error = nil;
    if(![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"%@, %@", error, [error userInfo]);
        abort();
    }
    
    self.navigationItem.title = [[appDelegate currentEvent] name];
    [self.navigationItem.rightBarButtonItem setEnabled:true];

    [self.tableView reloadData];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the Delete/Cancel buttons
    if (buttonIndex == 1)
    {
        // Delete the managed object for the given index path
        NSError *error = nil;
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        Signature *sig = [self.fetchedResultsController objectAtIndexPath:pendingDeletePath];
        [[NSFileManager defaultManager] removeItemAtPath:sig.mediaPath error:&error];
        
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:pendingDeletePath]];
        
        // Save the context.
        if (![context save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    pendingDeletePath = nil;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell....
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
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
    
    switch(type)
    {
            
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
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (editingStyle == UITableViewCellEditingStyleDelete) {
     
         // confirm delete
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this signature? This action cannot be undone." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
         pendingDeletePath = indexPath;
         [alert show];
         [alert release];
     }
     else if (editingStyle == UITableViewCellEditingStyleInsert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
}
 

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detailView = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    [detailView setSignature:[self.fetchedResultsController objectAtIndexPath:indexPath]];

    [self.navigationController pushViewController:detailView animated:YES];
    [detailView release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
    [NSFetchedResultsController deleteCacheWithName:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [fetchedResultsController_ release];
    [super dealloc];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

@end
