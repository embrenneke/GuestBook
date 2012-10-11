//
//  SignaturePageRootViewController.m
//  GuestBook
//
//  Created by Emily Brenneke on 3/10/12.
//  Copyright (c) 2012 UnspunProductions. All rights reserved.
//

#import "SignaturePageRootViewController.h"
#import "SignaturePageModelController.h"
#import "AddSignatureViewController.h"
#import "GuestBookAppDelegate.h"
#import "Event.h"

@interface SignaturePageRootViewController ()
@property (readonly, strong, nonatomic) SignaturePageModelController *modelController;
@end

@implementation SignaturePageRootViewController

@synthesize modelController = _modelController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // get current orientation
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);

        // Configure the page view controller and add it as a child view controller.
        NSDictionary * options = nil;
        if(landscape)
        {
            options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:UIPageViewControllerSpineLocationMid] forKey:UIPageViewControllerOptionSpineLocationKey];
        }
        self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
        self.pageViewController.delegate = self;
        self.pageViewController.dataSource = self.modelController;
        [self addChildViewController:self.pageViewController];
        [self.view addSubview:self.pageViewController.view];

        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        CGRect pageViewRect = self.view.bounds;
        pageViewRect = CGRectInset(pageViewRect, 10.0, 10.0);
        self.pageViewController.view.frame = pageViewRect;

        [self.pageViewController didMoveToParentViewController:self];
        // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
        self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;

        NSArray* viewControllers = nil;
        SignaturePageViewController *startingViewController = [self.modelController viewControllerAtIndex:0];
        if(landscape)
        {
            SignaturePageViewController *secondViewController = [self.modelController viewControllerAtIndex:1];
            viewControllers = [NSArray arrayWithObjects:startingViewController, secondViewController, nil];
        }
        else
        {
            viewControllers = [NSArray arrayWithObject:startingViewController];
        }

        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    }
    return self;
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

    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    Event* event = [appDelegate currentEvent];
    self.navigationItem.title = [event name];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSignature:)];
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

-(void)addSignature:(id)sender
{
    NSLog(@"Add Signature");
    AddSignatureViewController* addVC = [[AddSignatureViewController alloc] initWithNibName:@"AddSignatureViewController" bundle:nil];
    //[self presentModalViewController:addVC animated:YES];
    [self.navigationController pushViewController:addVC animated:YES];
}

-(NSUInteger)elementsPerPageForOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation)?6:4;
}

-(NSUInteger)fixFirstElement:(NSUInteger)oldElement forOrientation:(UIInterfaceOrientation)orienation
{
    // normalize index to multiple of 4 or 6
    NSUInteger pageSize = [self elementsPerPageForOrientation:orienation];
    return (oldElement / pageSize) * pageSize;
}

#pragma mark - UIPageViewController delegate methods

/*
 - (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
 {
 
 }
 */

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        // In portrait orientation: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        SignaturePageViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
        SignaturePageViewController *newVC = [[SignaturePageViewController alloc] initWithNibName:@"SignaturePageViewController" bundle:nil];
        newVC.firstElement = [self fixFirstElement:currentViewController.firstElement forOrientation:orientation];
        NSArray *viewControllers = [NSArray arrayWithObject:newVC];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
        
        self.pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }
    
    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
    SignaturePageViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    SignaturePageViewController *firstVC = [[SignaturePageViewController alloc] initWithNibName:@"SignaturePageViewController" bundle:nil];
    firstVC.firstElement = [self fixFirstElement:currentViewController.firstElement forOrientation:orientation];
    NSArray *viewControllers = nil;

    // TODO: this still doesn't seem first. probably need to adjust odd/evenness of page number when adjusting element count.
    // TODO: and do the math to figure out if we need to return a blank page as well at the end.
    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self.modelController pageViewController:self.pageViewController viewControllerAfterViewController:firstVC];
        viewControllers = [NSArray arrayWithObjects:firstVC, nextViewController, nil];
    } else {
        UIViewController *previousViewController = [self.modelController pageViewController:self.pageViewController viewControllerBeforeViewController:firstVC];
        viewControllers = [NSArray arrayWithObjects:previousViewController, firstVC, nil];
    }
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];

    return UIPageViewControllerSpineLocationMid;
}

@end
