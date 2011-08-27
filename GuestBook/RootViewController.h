//
//  RootViewController.h
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "EventListController.h"
#import "AddSignatureViewController.h"

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    UIPopoverController        *eventsPopup;
    UIPopoverController        *addEntryPopup;
    EventListController        *eventsView;
    AddSignatureViewController *addSigView;
    NSFetchedResultsController *fetchedResultsController_;
}

@property (nonatomic, retain) UIPopoverController *eventsPopup;
@property (nonatomic, retain) UIPopoverController *addEntryPopup;
@property (nonatomic, retain) EventListController *eventsView;
@property (nonatomic, retain) AddSignatureViewController *addSigView;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(IBAction) chooseEvent:(id)sender;
-(void) updatePredicate;

@end
