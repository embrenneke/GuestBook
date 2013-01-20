//
//  UISignaturePageViewController.h
//  GuestBook
//
//  Created by Emily Brenneke on 3/9/12.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import <UIKit/UIKit.h>

@interface SignaturePageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSUInteger firstElement;
@property (nonatomic) BOOL renderPrint;

@end
