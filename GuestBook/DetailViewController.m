//
//  DetailViewController.m
//  GuestBook
//
//  Created by Matt Brenneke on 9/2/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import "DetailViewController.h"
#import <MediaPlayer/MPMoviePlayerController.h>


@implementation DetailViewController

@synthesize signature;
@synthesize moviePlayer;

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
    [super dealloc];
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
    if(signature.mediaPath)
    {
        if([signature.mediaPath hasSuffix:@"jpg"])
        {
           [imageView setImage:[UIImage imageWithContentsOfFile:[signature mediaPath]]];

        }
        else if([signature.mediaPath hasSuffix:@"mp4"])
        {
            MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:signature.mediaPath]];
            moviePlayer = player;
            player.view.frame = imageView.frame;
            [self.view addSubview:player.view];
            [player play];
        }
    }
    if(signature.message)
    {
        messageView.text = signature.message;
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
    if(moviePlayer)
    {
        moviePlayer.view.frame = imageView.frame;
    }
}

@end
