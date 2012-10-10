//
//  SignaturePageModelController.m
//  GuestBook
//
//  Created by Matt Brenneke on 3/10/12.
//  Copyright (c) 2012 UnspunProductions. All rights reserved.
//

#import "SignaturePageModelController.h"
#import "SignaturePageViewController.h"

@implementation SignaturePageModelController

- (SignaturePageViewController *)viewControllerAtIndex:(NSUInteger)index
{   
    // Create a new view controller and pass suitable data.
    SignaturePageViewController*  sigView = [[SignaturePageViewController alloc] initWithNibName:@"SignaturePageViewController" bundle:[NSBundle mainBundle]];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    NSUInteger sigsPerPage = landscape?4:6;
    sigView.firstElement = index*sigsPerPage;
    return sigView;
}

- (NSUInteger)indexOfViewController:(SignaturePageViewController *)viewController
{   
    /*
     Return the index of the given data view controller.
     */
    // get current orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    NSUInteger sigsPerPage = landscape?4:6;
    NSUInteger pageNo = (viewController.firstElement)/sigsPerPage;
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
    //if (index == LAST) {
    //    return nil;
   // }
    return [self viewControllerAtIndex:index];
}

@end
