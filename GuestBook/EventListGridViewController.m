//
//  EventListGridViewController.m
//  GuestBook
//
//  Created by Emily Brenneke on 3/8/12.
//  Copyright (c) 2012 UnspunProductions. All rights reserved.
//

#import "EventListGridViewController.h"
#import "GuestBookAppDelegate.h"
#import "Event.h"
#import "Signature.h"
#import "SignaturePageRootViewController.h"
#import "AddEventViewController.h"

@interface EventListGridViewController ()
- (void)configureCell:(GMGridViewCell *)cell atIndex:(NSUInteger) index;
@property (nonatomic, weak) GMGridViewCell* selectedCell;
@property (nonatomic, strong) UIActionSheet* deleteActionSheet;
@property (nonatomic, strong) UIActionSheet* shareActionSheet;
@end

@implementation EventListGridViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)setSelectedCell:(GMGridViewCell *)selectedCell
{
    _selectedCell = selectedCell;
    for(UIBarButtonItem* bbItem in self.navigationItem.leftBarButtonItems) {
        bbItem.enabled = (_selectedCell?true:false);
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Events";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editEventList:)];
    
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.gridView.autoresizesSubviews = YES;
    self.gridView.centerGrid = NO;
    self.gridView.minEdgeInsets = UIEdgeInsetsMake(10, 10, 5, 5);
    //self.gridView.backgroundColor = [UIColor darkGrayColor];
    self.gridView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"spine"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.gridView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    // re-fetch data in case event was added
    [self.fetchedResultsController performFetch:nil];
    [self.gridView reloadData];
}

- (void)addEvent:(id)sender
{
    // create just one add event view controller and keep it around
    AddEventViewController* aevController = [[AddEventViewController alloc] init];
    [aevController setFetchedResultsController:self.fetchedResultsController];
    [[self navigationController] pushViewController:aevController animated:YES];
}

- (void)editEventList:(id)sender
{
    self.gridView.editing = !self.gridView.editing;
    if(self.gridView.editing)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editEventList:)];
        UIBarButtonItem* shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareEvent:)];
        UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteEvent:)];
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:shareButton, deleteButton, nil];
        self.selectedCell = nil;
    }
    else
    {
        if(self.selectedCell)
        {
            [self.selectedCell setBackgroundColor:[UIColor clearColor]];
            self.selectedCell.highlighted = NO;
            self.selectedCell = nil;
        }
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editEventList:)];
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent:)];
    }
}

- (Event*)getEventForPosition:(NSUInteger)position
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:position inSection:0];
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)shareEvent:(id)sender
{
    if(self.selectedCell && !self.shareActionSheet)
    {
        Event* event = [self getEventForPosition:self.selectedCell.position];
        NSString* title = [NSString stringWithFormat:@"Share %@ how?", [event name]];
        self.shareActionSheet = [[UIActionSheet alloc]
                                 initWithTitle:title
                                 delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:@"E-Mail", @"iTunes", @"Cancel", nil];
        [self.shareActionSheet showFromBarButtonItem:sender animated:YES];
    }
    else if (self.shareActionSheet)
    {
        [self.shareActionSheet dismissWithClickedButtonIndex:2 animated:YES];
        self.shareActionSheet = nil;
    }
}
- (void)deleteEvent:(id)sender
{
    if(self.selectedCell && !self.deleteActionSheet)
    {
        Event* event = [self getEventForPosition:self.selectedCell.position];
        NSString* title = [NSString stringWithFormat:@"Delete \"%@\"?", [event name]];
        self.deleteActionSheet = [[UIActionSheet alloc]
                                    initWithTitle:title
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:@"Delete"
                                    otherButtonTitles:@"Cancel",nil];

        [self.deleteActionSheet showFromBarButtonItem:sender animated:YES];
    }
    else if (self.deleteActionSheet)
    {
        [self.deleteActionSheet dismissWithClickedButtonIndex:1 animated:YES];
        self.deleteActionSheet = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext)
    {
        GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
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
    
    return _fetchedResultsController;
} 

#pragma mark -
#pragma mark actionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet == self.deleteActionSheet)
    {
        self.deleteActionSheet = nil;
        // if delete was clicked, remove entity

        if (buttonIndex == 0)
        {
            // delete all associated signatures first
            NSUInteger position = self.selectedCell.position;
            Event* event = [self getEventForPosition:self.selectedCell.position];
            NSEnumerator *e = [event.signatures objectEnumerator];
            id collectionMemberObject;

            while ( (collectionMemberObject = [e nextObject]) )
            {
                // delete the signature
                NSError *error = nil;
                Signature *sig = collectionMemberObject;
                [[NSFileManager defaultManager] removeItemAtPath:sig.mediaPath error:&error];
                [self.managedObjectContext deleteObject:collectionMemberObject];
            }

            // if deleting currentEvent, set current event to nil
            GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
            if ([appDelegate currentEvent] == event)
            {
                [appDelegate setCurrentEvent:nil];
            }

            // Delete the managed object for the given index path
            [self.managedObjectContext deleteObject:event];

            // Save the context.
            NSError *error = nil;
            if (![self.managedObjectContext save:&error])
            {
                /*
                 Replace this implementation with code to handle the error appropriately.

                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
                 */
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            self.selectedCell = nil;
            [self editEventList:self];
            [self.gridView removeObjectAtIndex:position animated:YES];
        }
    }
    else if(actionSheet == self.shareActionSheet)
    {
        self.shareActionSheet = nil;
        // TODO: show pdf/xml/archive form
        NSLog(@"TODO: share event dismiss with button %d", buttonIndex);
    }
}

#pragma mark -
#pragma mark Grid View Data Source

- (void)configureCell:(GMGridViewCell *)cell atIndex:(NSUInteger) index
{
    Event* event = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 50)];
    name.text = [[event name] description];
    [cell addSubview:name];
    UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 180, 50)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    date.text = [formatter stringFromDate:[event time]];
    [cell addSubview:date];
    cell.position = index;
    cell.deleteButtonIcon = [UIImage imageNamed:@"blank"];
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView;
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    static NSString *CellIdentifier = @"EventCell";
    GMGridViewCell *cell = [gridView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[GMGridViewCell alloc] initWithFrame:CGRectMake(0, 0, 224.0, 168.0)];
    }
    [self configureCell:cell atIndex:index];
    return cell;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return ( CGSizeMake(224.0, 168.0) );
}

- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES;
}

-(void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    // save current selection
    if(self.gridView.editing)
    {
        [self GMGridView:self.gridView processDeleteActionForItemAtIndex:position];
    }
    else
    {
        GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setCurrentEvent:[self getEventForPosition:position]];
    
        SignaturePageRootViewController*  sigView = [[SignaturePageRootViewController alloc] initWithNibName:@"SignaturePageRootViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:sigView animated:YES];
    }
}

- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{
    if(self.selectedCell)
    {
        [self.selectedCell setBackgroundColor:[UIColor clearColor]];
        self.selectedCell.highlighted = NO;
    }
    GMGridViewCell* cell = [self.gridView cellForItemAtIndex:index];
    self.selectedCell = cell;
    cell.highlighted = YES;
    [cell setBackgroundColor:[UIColor blueColor]];
}

@end
