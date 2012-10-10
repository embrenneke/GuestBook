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
#import "SignaturePageRootViewController.h"
#import "AddEventViewController.h"

@interface EventListGridViewController ()
- (void)configureCell:(GMGridViewCell *)cell atIndex:(NSUInteger) index;
@end

@implementation EventListGridViewController

@synthesize gridView=_gridView;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize fetchedResultsController=_fetchedResultsController;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Events";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editEventList:)];
    
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.gridView.autoresizesSubviews = YES;
    self.gridView.backgroundColor = [UIColor darkGrayColor];
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
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editEventList:)];
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
}

#pragma mark -
#pragma mark Grid View Data Source

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
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:position inSection:0];
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setCurrentEvent:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    
    SignaturePageRootViewController*  sigView = [[SignaturePageRootViewController alloc] initWithNibName:@"SignaturePageRootViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:sigView animated:YES];
}

- (void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index
{

}

@end
