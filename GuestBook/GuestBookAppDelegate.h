//
//  GuestBookAppDelegate.h
//  GuestBook
//
//  Created by Matt Brenneke on 8/23/11.
//  Copyright 2011 UnspunProductions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Event.h"

@interface GuestBookAppDelegate : NSObject <UIApplicationDelegate> {
    Event *currentEvent;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) Event *currentEvent;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
// return a new autoreleased UUID string
- (NSString *)generateUuidString;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
