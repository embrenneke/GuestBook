//
//  SignaturePageModelController.m
//  GuestBook
//
//  Created by Emily Brenneke on 3/10/12.
//  Copyright (c) 2012 UnspunProductions. All rights reserved.
//

#import "SignaturePageModelController.h"
#import "SignaturePageViewController.h"
#import "GuestBookAppDelegate.h"

@implementation SignaturePageModelController

- (NSUInteger)signaturesPerPage
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    return landscape?4:6;
}

- (SignaturePageViewController *)viewControllerAtIndex:(NSUInteger)index
{   
    // Create a new view controller and pass suitable data.
    SignaturePageViewController*  sigView = [[SignaturePageViewController alloc] initWithNibName:@"SignaturePageViewController" bundle:[NSBundle mainBundle]];
    sigView.firstElement = index*[self signaturesPerPage];
    return sigView;
}

- (NSUInteger)indexOfViewController:(SignaturePageViewController *)viewController
{   
    /*
     Return the index of the given data view controller.
     */
    // get current orientation

    NSUInteger pageNo = (viewController.firstElement)/[self signaturesPerPage];
    return pageNo;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(SignaturePageViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(SignaturePageViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;

    GuestBookAppDelegate* appDelegate = (GuestBookAppDelegate*)[[UIApplication sharedApplication] delegate];
    if (index*[self signaturesPerPage] > [[[appDelegate currentEvent] signatures] count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

@end
