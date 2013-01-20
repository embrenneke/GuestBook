//
//  DetailViewController.h
//  GuestBook
//
//  Created by Emily Brenneke on 9/2/11.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
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
