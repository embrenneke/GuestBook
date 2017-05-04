//
//  Signature.h
//  GuestBook
//
//  Created by Emily Brenneke on 1/21/12.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

@import Foundation;
@import CoreData;

@class Event;

@interface Signature : NSManagedObject

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *mediaPath;
@property (nonatomic, retain) NSDate *timeStamp;
@property (nonatomic, retain) NSData *thumbnail;
@property (nonatomic, retain) Event *event;

@end

@interface Signature (Formatter)

@property (nonatomic, readonly) NSDateFormatter *formatSignatureDate;

@end
