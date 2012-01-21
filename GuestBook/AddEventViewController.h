//
//  AddEventViewController.h
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
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
