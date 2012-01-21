//
//  AddSignatureViewController.h
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddSignatureViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate> {
}

-(IBAction)submitSig:(UIButton*)sender;
-(IBAction)addMultimedia:(UIButton*)sender;
-(void)clearFormState;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) IBOutlet UITextField *name;
@property (nonatomic, weak) IBOutlet UITextView *message;
@property (nonatomic, weak) IBOutlet UIButton *imageButton;
@property (nonatomic, weak) IBOutlet UIImageView *image;

@end
