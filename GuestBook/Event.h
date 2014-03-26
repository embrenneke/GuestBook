//
//  Event.h
//  GuestBook
//
//  Created by Emily Brenneke on 1/21/12.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Signature;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *time;
@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSSet *signatures;

@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addSignaturesObject:(Signature *)value;

- (void)removeSignaturesObject:(Signature *)value;

- (void)addSignatures:(NSSet *)values;

- (void)removeSignatures:(NSSet *)values;

@end

@interface Event (Formatter)

@property (nonatomic, readonly) NSDateFormatter *formatDate;

@end