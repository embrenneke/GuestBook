//
//  SignaturePageModelController.h
//  GuestBook
//
//  Created by Emily Brenneke on 3/10/12.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import "SignaturePageViewController.h"

@import UIKit;

@interface SignaturePageModelController : NSObject<UIPageViewControllerDataSource>

- (SignaturePageViewController *)viewControllerAtIndex:(NSUInteger)index;

- (NSUInteger)indexOfViewController:(SignaturePageViewController *)viewController;

@end
