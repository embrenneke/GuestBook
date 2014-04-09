//
//  Event.m
//  GuestBook
//
//  Created by Emily Brenneke on 1/21/12.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import "Event.h"
#import "Signature.h"

@implementation Event

@dynamic name;
@dynamic time;
@dynamic uuid;
@dynamic signatures;

@end

@implementation Event (Formatter)

- (NSDateFormatter *)formatEventDate
{
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    return dateFormatter;
}

@end
