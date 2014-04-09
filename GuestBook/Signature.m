//
//  Signature.m
//  GuestBook
//
//  Created by Emily Brenneke on 1/21/12.
//  Copyright 2013 Emily Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

#import "Signature.h"

@implementation Signature

@dynamic uuid;
@dynamic message;
@dynamic name;
@dynamic mediaPath;
@dynamic timeStamp;
@dynamic thumbnail;
@dynamic event;

@end

@implementation Signature (Formatter)

- (NSDateFormatter *)formatSignatureDate
{
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return dateFormatter;
}

@end
