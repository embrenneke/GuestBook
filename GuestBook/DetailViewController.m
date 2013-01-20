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
#import <MediaPlayer/MPMoviePlayerController.h>

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [self.moviePlayer stop];
    self.moviePlayer = nil;
    self.signature = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(self.signature.mediaPath)
    {
        GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString* filePath = [[NSString alloc] initWithFormat:@"%@", [[[appDelegate applicationLibraryDirectory] URLByAppendingPathComponent:self.signature.mediaPath] path]];
        
        if([filePath hasSuffix:@"jpg"])
        {
           [self.imageView setImage:[UIImage imageWithContentsOfFile:filePath]];
        }
        else if([filePath hasSuffix:@"mp4"])
        {
            MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];
            [player stop];
            self.moviePlayer = player;
            self.moviePlayer.view.frame = self.imageView.frame;
            [self.view addSubview:self.moviePlayer.view];
            [self.moviePlayer play];
            [self performSelector:@selector(detectOrientation) withObject:nil afterDelay:0.2];
        }
    }
    else
    {
        NSString* pathToImageFile = [[NSBundle mainBundle] pathForResource:@"no-media" ofType:@"png"];
        [self.imageView setImage:[UIImage imageWithContentsOfFile:pathToImageFile]];
    }
    
    if(self.signature.message)
    {
        self.messageView.text = self.signature.message;
    }
    else
    {
        self.messageView.text = nil;
    }
    
    if(self.signature.message)
    {
        self.titleView.text = self.signature.name;
    }
    else
    {
        self.titleView.text = nil;
    }
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void) detectOrientation {
    if(self.moviePlayer)
    {
        self.moviePlayer.view.frame = self.imageView.frame;
    }
}

@end
