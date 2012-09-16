//
//  AddSignatureViewController.h
//  GuestBook
//
//  Created by Emily Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddSignaturePopupProtocol;

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
@property (nonatomic, weak) id<AddSignaturePopupProtocol> delegate;
@end

@protocol AddSignaturePopupProtocol <NSObject>
@required
-(void)presentCameraViewController:(UIViewController*)viewController;
-(void)finishedPickingImage;
@end