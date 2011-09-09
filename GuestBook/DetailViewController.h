//
//  DetailViewController.h
//  GuestBook
//
//  Created by Matt Brenneke on 9/2/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import "Signature.h"

@interface DetailViewController : UIViewController {
    IBOutlet UIImageView *imageView;
    IBOutlet UITextView  *messageView;
    IBOutlet UILabel     *titleView;
    Signature            *signature;
    MPMoviePlayerController *moviePlayer;
}

@property (nonatomic, retain) Signature *signature;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;

@end
