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
@synthesize sortedSignatures;

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

- (NSArray *)sortedSignatures
{
    return [[self signatures] sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"timeStamp" ascending:YES selector:@selector(compare:)] ]];
}

@end
