//
//  SignatureTableViewController.m
//  GuestBook
//
//  Created by Emily Brenneke on 8/23/11.
//  Copyright 2014 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import "SignatureTableViewController.h"
#import "AddSignatureViewController.h"
#import "DetailViewController.h"
#import "EventListController.h"
#import "GuestBookAppDelegate.h"
#import "Signature.h"
#import "UIImage+Resize.h"

@interface SignatureTableViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSIndexPath *pendingDeletePath;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation SignatureTableViewController

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Signature *sig = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [sig.name description];
    cell.textLabel.font = [UIFont fontWithName:@"SnellRoundhand-Bold" size:25.0];
    cell.detailTextLabel.text = [sig.message description];
    cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:16.0];
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.detailTextLabel.numberOfLines = 0;
    CGRect accessoryFrame = CGRectMake(0., 0., 140., 140.);
    if (sig.thumbnail) {
        UIImage *image = [[UIImage imageWithData:[sig thumbnail]] resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:accessoryFrame.size interpolationQuality:kCGInterpolationDefault];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.frame = accessoryFrame;
        cell.accessoryView = imageView;
    } else {
        cell.accessoryView = [[UIView alloc] initWithFrame:accessoryFrame];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)]) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }

    // Set up the add signature buttons.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewSignature:)];
    self.navigationItem.rightBarButtonItem = addButton;
    UIBarButtonItem *events = [[UIBarButtonItem alloc] initWithTitle:@"Events" style:UIBarButtonItemStylePlain target:self action:@selector(chooseEvent:)];
    self.navigationItem.leftBarButtonItem = events;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventChosen:) name:@"eventPopoverShouldDismiss" object:nil];

    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    Event *event = [appDelegate currentEvent];
    self.navigationItem.title = event ? event.name : @"No Event Selected";
    [self.tableView reloadData];

    [self.tableView setSeparatorColor:[UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [NSFetchedResultsController deleteCacheWithName:nil];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate currentEvent] == nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self chooseEvent:nil];
        });
    }
}

- (void)insertNewSignature:(id)sender
{
    AddSignatureViewController *addVC = [[AddSignatureViewController alloc] initWithNibName:@"AddSignatureViewController" bundle:nil];
    addVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:addVC animated:YES];
}

- (void)chooseEvent:(id)sender
{
    EventListController *eventController = [[EventListController alloc] initWithNibName:@"EventListController" bundle:nil];
    eventController.managedObjectContext = self.managedObjectContext;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:eventController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:navController animated:YES];
}

- (void)eventChosen:(NSNotification *)notif
{
    [self dismissModalViewControllerAnimated:YES];
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    Event *event = [appDelegate currentEvent];
    self.navigationItem.title = event ? event.name : @"No Event Selected";
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return YES;
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
    _fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    return _fetchedResultsController;
}

- (void)updatePredicate
{
    [NSFetchedResultsController deleteCacheWithName:nil];
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"event == %@", [appDelegate currentEvent]];
    [[self.fetchedResultsController fetchRequest] setPredicate:aPredicate];
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"%@, %@", error, [error userInfo]);
    }

    Event *event = [appDelegate currentEvent];
    self.navigationItem.title = event ? event.name : @"No Event Selected";
    [self.navigationItem.rightBarButtonItem setEnabled:(event != nil)];

    [self.tableView reloadData];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // the user clicked one of the Delete/Cancel buttons
    if (buttonIndex == 1) {
        // Delete the managed object for the given index path
        NSError *error = nil;
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        Signature *sig = [self.fetchedResultsController objectAtIndexPath:self.pendingDeletePath];
        [[NSFileManager defaultManager] removeItemAtPath:sig.mediaPath error:&error];

        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:self.pendingDeletePath]];

        // Save the context.
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    self.pendingDeletePath = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OldTableCell";

    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    // Configure the cell....
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
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

        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *theTableView = self.tableView;

    switch (type) {

        case NSFetchedResultsChangeInsert:
            [theTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[theTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;

        case NSFetchedResultsChangeMove:
            [theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [theTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
        self.pendingDeletePath = [indexPath copy];
        [alert show];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detailView = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:[NSBundle mainBundle]];
    [detailView setSignature:[self.fetchedResultsController objectAtIndexPath:indexPath]];

    [self.navigationController pushViewController:detailView animated:YES];
    detailView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    [NSFetchedResultsController deleteCacheWithName:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"eventPopoverShouldDismiss" object:nil];
}

@end
