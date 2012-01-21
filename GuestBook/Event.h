//
//  Event.h
//  GuestBook
//
//  Created by Emily Brenneke on 1/21/12.
//  Copyright (c) 2012 UnspunProductions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Signature;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSSet *signatures;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addSignaturesObject:(Signature *)value;
- (void)removeSignaturesObject:(Signature *)value;
- (void)addSignatures:(NSSet *)values;
- (void)removeSignatures:(NSSet *)values;

@end
