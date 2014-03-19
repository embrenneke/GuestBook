//
//  SignatureTableViewController.h
//  GuestBook
//
//  Created by Emily Brenneke on 8/23/11.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "EventListController.h"
#import "AddSignatureViewController.h"

@interface SignatureTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate> {
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
