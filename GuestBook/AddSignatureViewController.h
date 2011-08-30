//
//  AddSignatureViewController.h
//  GuestBook
//
//  Created by Emily Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddSignatureViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    IBOutlet UITextField *name;
    IBOutlet UITextView *message;
    IBOutlet UIImageView *image;
    IBOutlet UIButton* imageButton;
}

-(IBAction)submitSig:(id)sender;
-(IBAction)addMultimedia:(id)sender;
-(void)clearFormState;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
