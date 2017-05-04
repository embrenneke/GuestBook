//
//  AddSignatureViewController.m
//  GuestBook
//
//  Created by Emily Brenneke on 8/23/11.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import "AddSignatureViewController.h"
#import "GuestBookAppDelegate.h"
#import "Signature.h"
#import "UIImage+Resize.h"

@import AVFoundation;
@import MobileCoreServices;

@interface AddSignatureViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong, readwrite) NSString *mediaPath;
@property (nonatomic, strong, readwrite) UIImagePickerController *cameraUI;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak, readwrite) IBOutlet UITextField *name;
@property (nonatomic, weak, readwrite) IBOutlet UITextView *message;
@property (nonatomic, weak, readwrite) IBOutlet UIButton *imageButton;

@end

@implementation AddSignatureViewController

#pragma mark - Object Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.mediaPath = nil;
        self.title = @"Add Signature";
        GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = appDelegate.managedObjectContext;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.navigationController action:@selector(popViewControllerAnimated:)];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor grayColor];
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.preferredContentSize = CGSizeMake(515.0, 380.0);

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imageButton.hidden = YES;
        self.message.frame = ({
            CGRect frame = self.message.frame;
            frame.size.height += self.imageButton.frame.size.height;
            frame;
        });
    }

    [self clearFormState];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.name becomeFirstResponder];
    });
}

#pragma mark - Actions

- (IBAction)submitSig:(UIButton *)sender
{
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate currentEvent]) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Signature" inManagedObjectContext:self.managedObjectContext];
        Signature *signature = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:self.managedObjectContext];

        signature.timeStamp = [NSDate date];
        signature.name = self.name.text;
        signature.message = self.message.text;
        if (self.mediaPath) {
            signature.thumbnail = UIImageJPEGRepresentation(self.imageButton.imageView.image, 0.5);
        }
        signature.uuid = [[NSUUID UUID] UUIDString];
        signature.event = [appDelegate currentEvent];
        signature.mediaPath = [self.mediaPath lastPathComponent];

        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Active Event" message:@"Signatures cannot be added without selecting an Event. Please select an event first." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }

    // remove self from navigation stack
    [self dismissViewControllerAnimated:YES completion:nil];

    [self clearFormState];
}

- (IBAction)cancelSignature:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self clearFormState];
}

- (void)clearFormState
{
    [self.name setText:@""];
    [self.message setText:@""];
    [self.imageButton setImage:nil forState:UIControlStateNormal];
    [self.imageButton setTitle:@"Press to add image/video" forState:UIControlStateNormal];
    self.mediaPath = nil;
}

- (IBAction)addMultimedia:(UIButton *)sender
{
    // bring up camera view, capture image/video, set thumbnail to button image
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.cameraUI = [[UIImagePickerController alloc] init];
        self.cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;

        // Displays a control that allows the user to choose picture or
        // movie capture, if both are available:
        self.cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];

        // Hides the controls for moving & scaling pictures, or for
        // trimming movies. To instead show the controls, use YES.
        self.cameraUI.allowsEditing = NO;

        self.cameraUI.delegate = self;
        self.cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;

        [self presentViewController:self.cameraUI animated:YES completion:nil];
    } else {
        UIButton *button = sender;
        [button setTitle:@"Sorry, no camera found." forState:UIControlStateNormal];
    }
}

#pragma mark - UIImagePickerControllerDelegate Protocol

// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.cameraUI = nil;
}

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];

    // handle re-picking
    if (self.mediaPath) {
        NSError *error = nil;
        NSString *oldFilePath = [[NSString alloc] initWithFormat:@"%@", [[[appDelegate applicationLibraryDirectory] URLByAppendingPathComponent:self.mediaPath] path]];
        [[NSFileManager defaultManager] removeItemAtPath:oldFilePath error:&error];
        self.mediaPath = nil;
    }

    // Handle a still image capture
    if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];

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
        self.mediaPath = [[NSString alloc] initWithFormat:@"%@.jpg", [[[appDelegate applicationLibraryDirectory] URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] path]];
        [UIImageJPEGRepresentation(imageToSave, 1.0) writeToFile:self.mediaPath atomically:YES];
    }

    // Handle a movie capture
    if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeMovie]) {
        NSString *moviePath = [(NSURL *)[info objectForKey:UIImagePickerControllerMediaURL] path];

        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(moviePath)) {
            // handle movie
            self.mediaPath = [[NSString alloc] initWithFormat:@"%@.mp4", [[[appDelegate applicationLibraryDirectory] URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] path]];
            NSError *error = nil;
            [[NSFileManager defaultManager] copyItemAtPath:moviePath toPath:self.mediaPath error:&error];
            if (error) {
                NSLog(@"%@", [error localizedDescription]);
            }

            // use movie player to generate a thumbnail
            NSURL *videoURL = [NSURL fileURLWithPath:self.mediaPath];

            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
            AVAssetImageGenerator *generateImage = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            CMTime time = CMTimeMakeWithSeconds(1.0, 60);
            CGImageRef refImage = [generateImage copyCGImageAtTime:time actualTime:NULL error:&error];
            UIImage *thumb = [[UIImage alloc] initWithCGImage:refImage];

            CGSize buttonSize = CGSizeMake(245, 180);
            UIImage *thumbnailImage = [thumb resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:buttonSize interpolationQuality:kCGInterpolationDefault];
            [[self.imageButton imageView] setContentMode:UIViewContentModeScaleToFill];
            [self.imageButton setTitle:@"" forState:UIControlStateNormal];
            [self.imageButton setImage:thumbnailImage forState:UIControlStateNormal];
        }
    }

    [self dismissViewControllerAnimated:YES completion:nil];
    self.cameraUI = nil;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
