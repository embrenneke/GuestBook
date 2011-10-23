//
//  AddSignatureViewController.h
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddSignatureViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate> {
    IBOutlet UITextField *name;
    IBOutlet UITextView *message;
    IBOutlet UIImageView *image;
    IBOutlet UIButton* imageButton;
    NSString* mediaPath;
    UIPopoverController* cameraPopover;
}

-(IBAction)submitSig:(id)sender;
-(IBAction)addMultimedia:(id)sender;
-(void)clearFormState;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSString* mediaPath;
@property (nonatomic, retain) UIPopoverController* cameraPopover;
@end
