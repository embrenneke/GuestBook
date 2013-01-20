//
//  SignaturePageModelController.h
//  GuestBook
//
//  Created by Matt Brenneke on 3/10/12.
//  Copyright 2013 Matt Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import <Foundation/Foundation.h>
#import "SignaturePageViewController.h"

@interface SignaturePageModelController : NSObject <UIPageViewControllerDataSource>

- (SignaturePageViewController *)viewControllerAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfViewController:(SignaturePageViewController *)viewController;

@end
