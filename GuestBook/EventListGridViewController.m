//
//  EventListGridViewController.m
//  GuestBook
//
//  Created by Matt Brenneke on 3/8/12.
//  Copyright 2013 Matt Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import "EventListGridViewController.h"
#import "GuestBookAppDelegate.h"
#import "Event.h"
#import "Signature.h"
#import "SignaturePageRootViewController.h"
#import "AddEventViewController.h"

@interface EventListGridViewController ()

@property (nonatomic, strong, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, strong, readwrite) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong, readwrite) UIActionSheet *actionSheet;

@end

@implementation EventListGridViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;

    self.navigationItem.title = @"Events";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent:)];

    [self.collectionView registerClass:[PSUICollectionViewCell class] forCellWithReuseIdentifier:@"AlbumCell"];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ios-linen.jpg"]];
    self.collectionView.backgroundColor = [UIColor clearColor];
}


- (void)viewWillAppear:(BOOL)animated
{
    // re-fetch data in case event was added
    [self.fetchedResultsController performFetch:nil];
    [self.collectionView reloadData];
}

- (void)addEvent:(id)sender
{
    // TODO: create just one add event view controller and keep it around
    AddEventViewController* aevController = [[AddEventViewController alloc] init];
    [aevController setFetchedResultsController:self.fetchedResultsController];
    [[self navigationController] pushViewController:aevController animated:YES];
}

- (void)handleLongPress:(UIGestureRecognizer*)gestureRecognizer
{
    if (self.actionSheet != nil) {
        // only handle on action at a time
        return;
    }

    UIView *view = self.collectionView;
    CGPoint touchPoint = [gestureRecognizer locationInView:view];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    self.selectedIndexPath = indexPath;
    Event* event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:event.name
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:@"Delete"
                                          otherButtonTitles:@"Share", nil];
    CGRect origin = CGRectMake(touchPoint.x, touchPoint.y, 1, 1);
    [self.actionSheet showFromRect:origin inView:view animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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

#pragma mark - actionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self deleteEventAtIndexPath:self.selectedIndexPath];
    } else if (buttonIndex == 1) {
        [self shareEventAtIndexPath:self.selectedIndexPath];
    }
    self.selectedIndexPath = nil;
    self.actionSheet = nil;
}


- (void)deleteEventAtIndexPath:(NSIndexPath *)indexPath
{
    // delete all associated signatures
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    // Force the fetchedResultsController to update
    [self.fetchedResultsController performFetch:nil];

    // remove the item from the collection view
    [self.collectionView deleteItemsAtIndexPaths:@[ self.selectedIndexPath ]];
}

- (void)shareEventAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - UICollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] firstObject];
    return [sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
    Event* event = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.backgroundColor = [UIColor whiteColor];

    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 50)];
    name.text = [[event name] description];
    [cell addSubview:name];

    UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 180, 50)];
    date.text = [self.dateFormatter stringFromDate:[event time]];
    [cell addSubview:date];

    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [cell addGestureRecognizer:gesture];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setCurrentEvent:[self.fetchedResultsController objectAtIndexPath:indexPath]];

    SignaturePageRootViewController*  sigView = [[SignaturePageRootViewController alloc] initWithNibName:@"SignaturePageRootViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:sigView animated:YES];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(224.0, 168.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

@end
