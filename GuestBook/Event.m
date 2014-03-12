//
//  Event.m
//  GuestBook
//
//  Created by Matt Brenneke on 1/21/12.
//  Copyright 2013 Matt Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import "Event.h"
#import "Signature.h"

@implementation Event

@dynamic name;
@dynamic time;
@dynamic uuid;
@dynamic signatures;

- (NSDictionary *)jsonObjectForEvent
{
    NSMutableDictionary *eventDictionary = [NSMutableDictionary dictionary];
    if (self.name) {
        [eventDictionary setObject:self.name forKey:@"name"];
    }
    if (self.time) {
        // TODO: cache data formatter
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [eventDictionary setObject:[dateFormatter stringFromDate:self.time] forKey:@"creationDate"];
    }
    if (self.uuid) {
        [eventDictionary setObject:self.uuid forKey:@"uuid"];
    }
    NSMutableArray *signatures = [NSMutableArray arrayWithCapacity:[self.signatures count]];
    for (Signature *signature in self.signatures) {
        NSDictionary *jsonSignature = [signature jsonObjectForSignature];
        if (jsonSignature) {
            [signatures addObject:jsonSignature];
        }
    }
    [eventDictionary setObject:signatures forKey:@"signatures"];

    return eventDictionary;
}

@end
