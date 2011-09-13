//
//  DetailViewController.m
//  GuestBook
//
//  Created by Emily Brenneke on 9/2/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import "DetailViewController.h"
#import "GuestBookAppDelegate.h"
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
    [moviePlayer stop];
    moviePlayer = nil;
    signature = nil;
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
        GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString* filePath = [[NSString alloc] initWithFormat:@"%@", [[[appDelegate applicationLibraryDirectory] URLByAppendingPathComponent:signature.mediaPath] path]];
        
        if([filePath hasSuffix:@"jpg"])
        {
           [imageView setImage:[UIImage imageWithContentsOfFile:filePath]];
        }
        else if([filePath hasSuffix:@"mp4"])
        {
            MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:filePath]];
            [player stop];
            moviePlayer = player;
            moviePlayer.view.frame = imageView.frame;
            [self.view addSubview:moviePlayer.view];
            [moviePlayer play];
            [self performSelector:@selector(detectOrientation) withObject:nil afterDelay:0.2];
        }
        [filePath release];
    }
    else
    {
        NSString* pathToImageFile = [[NSBundle mainBundle] pathForResource:@"no-media" ofType:@"png"];
        [imageView setImage:[UIImage imageWithContentsOfFile:pathToImageFile]];
    }
    
    if(signature.message)
    {
        messageView.text = signature.message;
    }
    else
    {
        messageView.text = nil;
    }
    
    if(signature.message)
    {
        titleView.text = signature.name;
    }
    else
    {
        titleView.text = nil;
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
