//
//  Signature.h
//  GuestBook
//
//  Created by Matt Brenneke on 1/21/12.
//  Copyright (c) 2012 UnspunProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Signature : NSManagedObject

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * mediaPath;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) Event *event;

@end
