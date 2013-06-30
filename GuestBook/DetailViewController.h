//
//  DetailViewController.h
//  GuestBook
//
//  Created by Emily Brenneke on 9/2/11.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import <UIKit/UIKit.h>

@class Signature;

@interface DetailViewController : UIViewController

@property (nonatomic, strong) Signature *signature;

@end
