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

@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    UISegmentedControl *segmentedControl;
    UIPopoverController *eventsPopup;
    UIPopoverController *addEntryPopup;
    EventListController *eventsView;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UIPopoverController *eventsPopup;
@property (nonatomic, retain) EventListController *eventsView;

-(IBAction) segmentedControlIndexChanged;
-(IBAction) chooseEvent:(id)sender;

@end
