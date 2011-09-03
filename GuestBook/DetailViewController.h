//
//  DetailViewController.h
//  GuestBook
//
//  Created by Matt Brenneke on 9/2/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Signature.h"

@interface DetailViewController : UIViewController {
    IBOutlet UIImageView *imageView;
    IBOutlet UITextView  *messageView;
    Signature            *signature;
}

@property (nonatomic, retain) Signature *signature;
@end
