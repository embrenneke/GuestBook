//
//  AddEventViewController.h
//  GuestBook
//
//  Created by Emily Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AddEventViewController : UIViewController {
    IBOutlet UITextField* name;
    IBOutlet UIDatePicker* datePicker;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

-(IBAction)createEvent:(id)sender;

@end
