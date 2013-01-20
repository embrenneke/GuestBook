//
//  GuestBookAppDelegate.h
//  GuestBook
//
//  Created by Emily Brenneke on 8/23/11.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Event.h"

@interface GuestBookAppDelegate : NSObject <UIApplicationDelegate> {
}

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) Event *currentEvent;
@property (nonatomic, weak) IBOutlet UINavigationController *navigationController;
@property (nonatomic, strong) IBOutlet UIWindow* window;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)applicationLibraryDirectory;
- (NSString *)generateUuidString;

@end
