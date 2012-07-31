//
//  UISignaturePageViewController.m
//  GuestBook
//
//  Created by Emily Brenneke on 3/9/12.
//  Copyright (c) 2012 UnspunProductions. All rights reserved.
//

#import "SignaturePageViewController.h"
#import "GuestBookAppDelegate.h"
#import "Signature.h"
#import "DetailViewController.h"

@interface SignaturePageViewController ()

-(NSIndexPath*)adjustedIndexPath:(NSIndexPath*)indexPath;
-(BOOL)isPortrait;

@end

@implementation SignaturePageViewController

@synthesize tableView = _tableView;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize firstElement = _firstElement;
@synthesize renderPrint = _renderPrint;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Signature *sig = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [sig.name description];
    cell.textLabel.font = [UIFont fontWithName:@"SnellRoundhand-Bold" size:25.0];
    cell.detailTextLabel.text = [sig.message description];
    cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:16.0];
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.detailTextLabel.numberOfLines = 3;
    cell.imageView.image = [UIImage imageWithData:[sig thumbnail]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.renderPrint = NO;
        self.firstElement = 0;
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }

    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Signature" inManagedObjectContext:appDelegate.managedObjectContext];
    [fetchRequest setEntity:entity];
    
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
    [NSFetchedResultsController deleteCacheWithName:@"SigsCache"];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:@"SigsCache"];
    aFetchedResultsController.delegate = self;
    _fetchedResultsController = aFetchedResultsController;
    
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

- (NSIndexPath*)adjustedIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    row += self.firstElement;
    NSIndexPath* newIndexPath = [indexPath indexPathByRemovingLastIndex];
    newIndexPath = [newIndexPath indexPathByAddingIndex:row];
    return newIndexPath;
}

- (BOOL)isPortrait
{
    // get current orientation
    bool isDevicePortrait = YES;
    if(!self.renderPrint)
    {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        isDevicePortrait = UIInterfaceOrientationIsPortrait(orientation);
    }
    return isDevicePortrait;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 155;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger maxRows = 4;
    if([self isPortrait])
    {
        maxRows = 6;
    }

    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSInteger rowsLeft = [sectionInfo numberOfObjects] - self.firstElement;
    return MIN(maxRows, rowsLeft);
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SignatureTableCell";
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell....
    [self configureCell:cell atIndexPath:[self adjustedIndexPath:indexPath]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailViewController *detailView = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:[NSBundle mainBundle]];
    [detailView setSignature:[self.fetchedResultsController objectAtIndexPath:[self adjustedIndexPath:indexPath]]];
    
    [self.navigationController pushViewController:detailView animated:YES];
    detailView = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
