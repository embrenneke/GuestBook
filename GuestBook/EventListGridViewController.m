//
//  EventListGridViewController.m
//  GuestBook
//
//  Created by Emily Brenneke on 3/8/12.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import "EventListGridViewController.h"
#import "GuestBookAppDelegate.h"
#import "Signature.h"
#import "SignaturePageRootViewController.h"
#import "AddEventViewController.h"
#import "Event.h"

@interface EventListGridViewController ()

@property (nonatomic, strong, readonly) NSDateFormatter *dateFormatter;

@end

@implementation EventListGridViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;

    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"AlbumCell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"AddNewCell"];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ios-linen.jpg"]];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.title = @"Events";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];

    // re-fetch data in case event was added
    [self.fetchedResultsController performFetch:nil];
    [self.collectionView reloadData];
}

#pragma mark - View Event Handlers

- (IBAction)addEvent:(id)sender
{
    AddEventViewController *viewController = [[AddEventViewController alloc] init];
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.presentedViewController != nil) {
        // only handle on action at a time
        return;
    }

    UIView *view = self.collectionView;
    CGPoint touchPoint = [gestureRecognizer locationInView:view];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:event.name message:@"What would you like to do?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"Share" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self shareEventAtIndexPath:indexPath];
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteEventAtIndexPath:indexPath];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:shareAction];
    [alertController addAction:deleteAction];

    CGRect origin = CGRectMake(touchPoint.x, touchPoint.y, 1, 1);
    UIPopoverPresentationController *popoverPresentationController = alertController.popoverPresentationController;
    popoverPresentationController.sourceRect = origin;
    popoverPresentationController.sourceView = self.view;
    alertController.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Event Actions

- (void)deleteEventAtIndexPath:(NSIndexPath *)indexPath
{
    // delete all associated signatures
    Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    for (Signature *signature in event.signatures) {
        if (signature.mediaPath) {
            NSError *error = nil;
            if (![[NSFileManager defaultManager] removeItemAtPath:signature.mediaPath error:&error]) {
                NSLog(@"Error deleting file at path %@\n%@", signature.mediaPath, [error localizedDescription]);
            }
        }
    }

    // if deleting currentEvent, set current event to nil
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate currentEvent] == event) {
        [appDelegate setCurrentEvent:nil];
    }

    // Delete the managed object for the given index path
    [self.managedObjectContext deleteObject:event];

    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    // Force the fetchedResultsController to update
    [self.fetchedResultsController performFetch:nil];

    // remove the item from the collection view
    [self.collectionView deleteItemsAtIndexPaths:@[ indexPath ]];
}

- (void)shareEventAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UICollectionView Data Source

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] firstObject];
    return [sectionInfo numberOfObjects] + 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    if ([indexPath row] < [[[self.fetchedResultsController sections] firstObject] numberOfObjects]) {
        cell = [cv dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
        Event *event = [self.fetchedResultsController objectAtIndexPath:indexPath];

        cell.backgroundColor = [UIColor whiteColor];

        // hacky hack hack just for testing purposes.  Eventually need to subclass UICollectionViewCell.
        if ([cell.contentView.subviews count] == 0) {
            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 180, 50)];
            name.text = [[event name] description];
            [cell.contentView addSubview:name];

            UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 180, 50)];
            date.text = [self.dateFormatter stringFromDate:[event time]];
            [cell.contentView addSubview:date];

            UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
            [cell addGestureRecognizer:gesture];
        }
    } else {
        cell = [cv dequeueReusableCellWithReuseIdentifier:@"AddNewCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor lightGrayColor];
        if ([cell.contentView.subviews count] == 0) {
            UILabel *action = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 200, 50)];
            action.text = @"Add New Event";
            [cell.contentView addSubview:action];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] < [[[self.fetchedResultsController sections] firstObject] numberOfObjects]) {
        GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setCurrentEvent:[self.fetchedResultsController objectAtIndexPath:indexPath]];

        SignaturePageRootViewController *sigView = [[SignaturePageRootViewController alloc] initWithNibName:@"SignaturePageRootViewController" bundle:[NSBundle mainBundle]];
        [self.navigationController pushViewController:sigView animated:YES];
    } else {
        [self addEvent:nil];
    }
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(224.0, 168.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(50, 20, 50, 20);
}

#pragma mark - Property Overrides

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
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

@end
