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
}

@property (nonatomic, strong) Signature *signature;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITextView  *messageView;
@property (nonatomic, weak) IBOutlet UILabel     *titleView;
@end
