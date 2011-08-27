//
//  Signature.h
//  GuestBook
//
//  Created by Matt Brenneke on 8/26/11.
//  Copyright (c) 2011 UnspunProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Signature : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * mediaPath;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) Event * event;

@end
