//
//  UISignaturePageViewController.m
//  GuestBook
//
//  Created by Emily Brenneke on 3/9/12.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import "SignaturePageViewController.h"
#import "GuestBookAppDelegate.h"
#import "Signature.h"
#import "DetailViewController.h"
#import "AddSignatureViewController.h"

@interface SignaturePageViewController ()<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong, readwrite) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readwrite) IBOutlet UIImageView *rightImageView;
@property (nonatomic, strong, readwrite) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign, readwrite) BOOL renderPrint;

@end

@implementation SignaturePageViewController

#pragma mark - Object Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.renderPrint = NO;
    }
    return self;
}

#pragma mark - Property Accessors

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    [NSFetchedResultsController deleteCacheWithName:@"SigsCache"];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:@"SigsCache"];
    aFetchedResultsController.delegate = self;
    _fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    return _fetchedResultsController;
}

- (NSIndexPath *)adjustedIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = indexPath.row;
    row += self.firstElement;
    NSIndexPath *newIndexPath = [indexPath indexPathByRemovingLastIndex];
    newIndexPath = [newIndexPath indexPathByAddingIndex:row];
    return newIndexPath;
}

- (BOOL)isPortrait
{
    // get current orientation
    bool isDevicePortrait = YES;
    if (!self.renderPrint) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        isDevicePortrait = UIInterfaceOrientationIsPortrait(orientation);
    }
    return isDevicePortrait;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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
    if ([self isPortrait]) {
        maxRows = 6;
    }

    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSInteger rowsLeft = [sectionInfo numberOfObjects] - self.firstElement + 1;
    rowsLeft = MAX(rowsLeft, 0);
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
    NSIndexPath *realPath = [self adjustedIndexPath:indexPath];
    if ([realPath row] < [[[self.fetchedResultsController sections] objectAtIndex:[indexPath section]] numberOfObjects]) {
        [self configureCell:cell atIndexPath:[self adjustedIndexPath:indexPath]];
    } else {
        cell.textLabel.text = @"Add New Signature";
        cell.detailTextLabel.text = @"";
        cell.imageView.image = nil;
        cell.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.05];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *realPath = [self adjustedIndexPath:indexPath];
    if ([realPath row] < [[[self.fetchedResultsController sections] objectAtIndex:[indexPath section]] numberOfObjects]) {
        DetailViewController *detailView = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:[NSBundle mainBundle]];
        [detailView setSignature:[self.fetchedResultsController objectAtIndexPath:[self adjustedIndexPath:indexPath]]];

        [self.navigationController pushViewController:detailView animated:YES];
    } else {
        // add signature
        AddSignatureViewController *addVC = [[AddSignatureViewController alloc] initWithNibName:@"AddSignatureViewController" bundle:nil];
        addVC.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:addVC animated:YES completion:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([indexPath row] < [[[appDelegate currentEvent] signatures] count]) {
        Signature *sig = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = [sig.name description];
        cell.textLabel.font = [UIFont fontWithName:@"SnellRoundhand-Bold" size:25.0];
        cell.detailTextLabel.text = [sig.message description];
        cell.detailTextLabel.font = [UIFont italicSystemFontOfSize:16.0];
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.detailTextLabel.numberOfLines = 3;
        cell.imageView.image = [UIImage imageWithData:[sig thumbnail]];
        cell.backgroundColor = [UIColor clearColor];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
