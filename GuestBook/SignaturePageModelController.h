//
//  SignaturePageModelController.h
//  GuestBook
//
//  Created by Emily Brenneke on 3/10/12.
//  Copyright (c) 2012 UnspunProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignaturePageViewController.h"

@interface SignaturePageModelController : NSObject <UIPageViewControllerDataSource>

- (SignaturePageViewController *)viewControllerAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfViewController:(SignaturePageViewController *)viewController;

@end
