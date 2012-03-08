//
//  EventListGridViewController.h
//  GuestBook
//
//  Created by Matt Brenneke on 3/8/12.
//  Copyright (c) 2012 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"

@interface EventListGridViewController : UIViewController <AQGridViewDelegate, AQGridViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) IBOutlet AQGridView * gridView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
