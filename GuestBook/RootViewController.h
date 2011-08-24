//
//  RootViewController.h
//  GuestBook
//
//  Created by Emily Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "EventListController.h"

@interface RootViewController : UITableViewController {
    UIPopoverController *eventsPopup;
    UIPopoverController *addEntryPopup;
    EventListController *eventsView;
}

@property (nonatomic, retain) UIPopoverController *eventsPopup;
@property (nonatomic, retain) EventListController *eventsView;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(IBAction) segmentedControlIndexChanged:(id)index;
-(IBAction) chooseEvent:(id)sender;

@end
