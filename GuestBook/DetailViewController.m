//
//  DetailViewController.m
//  GuestBook
//
//  Created by Matt Brenneke on 9/2/11.
//  Copyright 2013 Matt Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import "DetailViewController.h"
#import "GuestBookAppDelegate.h"
#import "Signature.h"
#import <MediaPlayer/MPMoviePlayerController.h>

@interface DetailViewController ()

@property (nonatomic, strong, readwrite) MPMoviePlayerController *moviePlayer;
@property (nonatomic, weak, readwrite) IBOutlet UIImageView *imageView;
@property (nonatomic, weak, readwrite) IBOutlet UITextView *messageView;
@property (nonatomic, weak, readwrite) IBOutlet UILabel *titleView;

@end

@implementation DetailViewController

- (void)dealloc
{
    [self.moviePlayer stop];
    self.moviePlayer = nil;
    self.signature = nil;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.signature.mediaPath) {
        GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *filePath = [[NSString alloc] initWithFormat:@"%@", [[[appDelegate applicationLibraryDirectory] URLByAppendingPathComponent:self.signature.mediaPath] path]];

        if ([filePath hasSuffix:@"jpg"]) {
            [self.imageView setImage:[UIImage imageWithContentsOfFile:filePath]];
        } else if ([filePath hasSuffix:@"mp4"]) {
            MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];
            [player stop];
            self.moviePlayer = player;
            self.moviePlayer.view.frame = self.imageView.frame;
            [self.view addSubview:self.moviePlayer.view];
        }
    }
    else {
        [self.imageView setImage:[UIImage imageNamed:@"no-media"]];
    }

    self.messageView.text = self.signature.message;
    self.titleView.text = self.signature.name;

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(detectOrientation)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:animated];

    [self detectOrientation];

    if (self.moviePlayer) {
        [self.moviePlayer play];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)detectOrientation
{
    if (self.moviePlayer) {
        self.moviePlayer.view.frame = self.imageView.frame;
    }
}

@end
