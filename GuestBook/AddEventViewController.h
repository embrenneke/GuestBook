//
//  AddEventViewController.h
//  GuestBook
//
//  Created by Emily Brenneke on 8/23/11.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AddEventViewController : UIViewController {
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) IBOutlet UITextField* name;
@property (nonatomic, weak) IBOutlet UIDatePicker* datePicker;

-(IBAction)createEvent:(UIButton*)sender;

@end
