//
//  UISignaturePageViewController.h
//  GuestBook
//
//  Created by Emily Brenneke on 3/9/12.
//  Copyright (c) 2012 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignaturePageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic) BOOL clearsSelectionOnViewWillAppear;

@end
