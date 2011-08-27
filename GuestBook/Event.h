//
//  Event.h
//  GuestBook
//
//  Created by Emily Brenneke on 8/26/11.
//  Copyright (c) 2011 UnspunProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Signature;

@interface Event : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSSet* signatures;

@end
