//
//  EventListGridViewController.h
//  GuestBook
//
//  Created by Emily Brenneke on 3/8/12.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"

@interface EventListGridViewController : UIViewController <GMGridViewDataSource, GMGridViewActionDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet GMGridView *gridView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
