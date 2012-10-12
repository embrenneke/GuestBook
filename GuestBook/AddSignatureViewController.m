//
//  AddSignatureViewController.m
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import "AddSignatureViewController.h"
#import "GuestBookAppDelegate.h"
#import "Signature.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <UIKit/UIImagePickerController.h>
#import <MediaPlayer/MPMoviePlayerController.h>

@interface AddSignatureViewController ()
@property (nonatomic, strong) NSString* mediaPath;
@property (nonatomic, strong) UIImagePickerController *cameraUI;
@end

@implementation AddSignatureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.mediaPath = nil;
        self.title = @"Add Signature";
        GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate*)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = appDelegate.managedObjectContext;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.navigationController action:@selector(popViewControllerAnimated:)];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor grayColor];
    }
    return self;
}

-(IBAction)submitSig:(UIButton*)sender
{
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate currentEvent])
    {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Signature" inManagedObjectContext:self.managedObjectContext];
        Signature *signature = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.managedObjectContext];

        signature.timeStamp = [NSDate date];
        signature.name = self.name.text;
        signature.message = self.message.text;
        if(self.mediaPath)
        {
            signature.thumbnail = UIImageJPEGRepresentation(self.imageButton.imageView.image, 0.5);
        }
        signature.uuid = [appDelegate generateUuidString];
        signature.event = [appDelegate currentEvent];
        signature.mediaPath = [self.mediaPath lastPathComponent];

        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.

             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Signatures cannot be added without selecting an Event.  Please select an event First." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }

    // remove self from navigation stack
    [[self navigationController] popViewControllerAnimated:YES];
    
    [self clearFormState];
}

-(void)clearFormState
{
    [self.name setText:@""];
    [self.message setText:@""];
    [self.imageButton setImage:nil forState:UIControlStateNormal];
    [self.imageButton setTitle:@"Press to add image/video"  forState:UIControlStateNormal];
    self.mediaPath = nil;
    
}

- (IBAction)addMultimedia:(UIButton*)sender
{
    // bring up camera view, capture image/video, set thumbnail to button image
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.cameraUI = [[UIImagePickerController alloc] init];
        self.cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        // Displays a control that allows the user to choose picture or
        // movie capture, if both are available:
        self.cameraUI.mediaTypes =
        [UIImagePickerController availableMediaTypesForSourceType:
         UIImagePickerControllerSourceTypeCamera];
        
        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        self.cameraUI.allowsEditing = NO;
        
        self.cameraUI.delegate = self;
        self.cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;

        [self presentModalViewController:self.cameraUI animated:YES];
    }
    else
    {
        UIButton *button = sender;
        [button setTitle:@"Sorry, no camera found." forState:UIControlStateNormal];
    }
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self.cameraUI dismissModalViewControllerAnimated:YES];
    self.cameraUI = nil;
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // handle re-picking
    if(self.mediaPath)
    {
        NSError *error = nil;
        NSString *oldFilePath = [[NSString alloc] initWithFormat:@"%@", [[[appDelegate applicationLibraryDirectory] URLByAppendingPathComponent:self.mediaPath] path]];
        [[NSFileManager defaultManager] removeItemAtPath:oldFilePath error:&error];
        self.mediaPath = nil;
    }
    
    // Handle a still image capture
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        // save image to directory, save thumbnail and path to coreData store.
        CGSize buttonSize = CGSizeMake(245, 180);
        UIImage *thumbnailImage = [imageToSave resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:buttonSize interpolationQuality:kCGInterpolationDefault];
        
        [[self.imageButton imageView] setContentMode:UIViewContentModeScaleToFill];
        [self.imageButton setTitle:@"" forState:UIControlStateNormal];
        [self.imageButton setImage:thumbnailImage forState:UIControlStateNormal];
        self.imageButton.layer.cornerRadius = 15;
        self.imageButton.layer.masksToBounds = YES;
        self.mediaPath = [[NSString alloc] initWithFormat:@"%@.jpg", [[[appDelegate applicationLibraryDirectory] URLByAppendingPathComponent:[appDelegate generateUuidString]] path]];
        [UIImageJPEGRepresentation(imageToSave, 1.0) writeToFile:self.mediaPath atomically:YES];        
    }
    
    // Handle a movie capture
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
        NSString *moviePath = [[info objectForKey:
                                UIImagePickerControllerMediaURL] path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            // handle movie
            self.mediaPath = [[NSString alloc] initWithFormat:@"%@.mp4", [[[appDelegate applicationLibraryDirectory] URLByAppendingPathComponent:[appDelegate generateUuidString]] path]];
            NSError *error = nil;
            [[NSFileManager defaultManager] copyItemAtPath:moviePath toPath:self.mediaPath error:&error];
            if(error)
            {
                NSLog(@"%@", [error localizedDescription]);
            }

            // use movie player to generate a thumbnail
            NSURL *videoURL = [NSURL fileURLWithPath:self.mediaPath];
            MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
            UIImage *thumb = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];
            CGSize buttonSize = CGSizeMake(245, 180);
            UIImage *thumbnailImage = [thumb resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:buttonSize interpolationQuality:kCGInterpolationDefault];
            [self.imageButton setImage:thumbnailImage forState:UIControlStateNormal];
            [player stop];
        }
    }
    
    [self.cameraUI dismissModalViewControllerAnimated:YES];
    self.cameraUI = nil;
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
    [self clearFormState];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self clearFormState];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.name becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
