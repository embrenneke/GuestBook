//
//  AddSignatureViewController.h
//  GuestBook
//
//  Created by Emily Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddSignatureViewController : UIViewController {
    NSManagedObject* currentEvent;
}

-(IBAction)submitSig:(id)sender;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObject *currentEvent;

@end
