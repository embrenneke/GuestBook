//
//  AddSignatureViewController.h
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddSignatureViewController : UIViewController {
    IBOutlet UITextField *name;
}

-(IBAction)submitSig:(id)sender;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
