//
//  EventListController.h
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface EventListController : UITableViewController <NSFetchedResultsControllerDelegate, UIAlertViewDelegate> {
    NSIndexPath *pendingDeletePath;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSIndexPath *pendingDeletePath;

-(void)insertNewEvent;
@end
