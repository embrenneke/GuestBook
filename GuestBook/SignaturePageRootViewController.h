//
//  SignaturePageRootViewController.h
//  GuestBook
//
//  Created by Emily Brenneke on 3/10/12.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import <UIKit/UIKit.h>

@interface SignaturePageRootViewController : UIViewController <UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;

@end
