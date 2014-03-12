//
//  GuestBookAppDelegate.h
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2013 Matt Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Event.h"

@interface GuestBookAppDelegate : NSObject<UIApplicationDelegate>

@property (nonatomic, strong, readwrite) Event *currentEvent;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readwrite) IBOutlet UIWindow *window;

- (NSURL *)applicationLibraryDirectory;

- (NSString *)generateUuidString;

@end
