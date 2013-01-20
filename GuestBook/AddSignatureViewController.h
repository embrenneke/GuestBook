//
//  AddSignatureViewController.h
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2013 Matt Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import <UIKit/UIKit.h>

@interface AddSignatureViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
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
