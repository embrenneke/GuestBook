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
#import "AddSignatureViewController.h"

@interface SignatureTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate, AddSignaturePopupProtocol> {
}

@property (nonatomic, strong) UIPopoverController *eventsPopup;
@property (nonatomic, strong) UIPopoverController *addEntryPopup;
@property (nonatomic, strong) EventListController *eventsView;
@property (nonatomic, strong) AddSignatureViewController *addSigView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSIndexPath *pendingDeletePath;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
