//
//  SignaturePageRootViewController.m
//  GuestBook
//
//  Created by Matt Brenneke on 3/10/12.
//  Copyright 2013 Matt Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import "SignaturePageRootViewController.h"
#import "SignaturePageModelController.h"
#import "GuestBookAppDelegate.h"
#import "Event.h"

@interface SignaturePageRootViewController () <UIPageViewControllerDelegate>

@property (nonatomic, strong, readwrite) UIPageViewController *pageViewController;
@property (nonatomic, strong, readwrite) SignaturePageModelController *modelController;

@end

@implementation SignaturePageRootViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    Event* event = [appDelegate currentEvent];
    self.navigationItem.title = [event name];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }

    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self.modelController;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];

    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    pageViewRect = CGRectMake(pageViewRect.origin.x, pageViewRect.origin.y + 30., pageViewRect.size.width - 5., pageViewRect.size.height - 35.);
    self.pageViewController.view.frame = pageViewRect;

    [self.pageViewController didMoveToParentViewController:self];
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;

    // add a tap gesture recognizer to show the nav bar
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [gesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:gesture];

    SignaturePageViewController *startingViewController = [self.modelController viewControllerAtIndex:0];

    [self.pageViewController setViewControllers:@[ startingViewController ]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self performSelector:@selector(hideNavBar) withObject:nil afterDelay:2.0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)tapped:(UIGestureRecognizer *)gesture
{
    if (![self.pageViewController.view hitTest:[gesture locationInView:self.pageViewController.view] withEvent:nil]) {
        [self.navigationController setNavigationBarHidden:![self.navigationController isNavigationBarHidden] animated:YES];
        [self performSelector:@selector(hideNavBar) withObject:nil afterDelay:3.0];
    }
}

- (void)hideNavBar
{
    if (self.navigationController.topViewController == self) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (SignaturePageModelController *)modelController
{
    /*
     Return the model controller object, creating it if necessary.
     In more complex implementations, the model controller may be passed to the view controller.
     */
    if (!_modelController) {
        _modelController = [[SignaturePageModelController alloc] init];
    }
    return _modelController;
}

- (NSUInteger)elementsPerPageForOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation)?6:4;
}

- (NSUInteger)findFirstElement:(NSUInteger)oldElement forOrientation:(UIInterfaceOrientation)orienation
{
    // normalize index to multiple of 4 or 6
    NSUInteger pageSize = [self elementsPerPageForOrientation:orienation];
    return (oldElement / pageSize) * pageSize;
}

#pragma mark - UIPageViewController delegate methods

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    SignaturePageViewController *currentViewController = [self.pageViewController.viewControllers firstObject];
    SignaturePageViewController *newVC = [[SignaturePageViewController alloc] initWithNibName:@"SignaturePageViewController" bundle:nil];
    newVC.firstElement = [self findFirstElement:currentViewController.firstElement forOrientation:orientation];
    NSArray *viewControllers = [NSArray arrayWithObject:newVC];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    
    self.pageViewController.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}

@end
