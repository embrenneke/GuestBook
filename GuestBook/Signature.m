//
//  Signature.m
//  GuestBook
//
//  Created by Matt Brenneke on 1/21/12.
//  Copyright 2013 Matt Brenneke. All rights reserved.
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

- (NSDictionary *)jsonObjectForSignature;
{
    NSMutableDictionary *signature = [NSMutableDictionary dictionary];
    if (self.name) {
        [signature setObject:self.name forKey:@"name"];
    }
    if (self.message) {
        [signature setObject:self.name forKey:@"message"];
    }
    if (self.timeStamp) {
        // TODO: cache data formatter
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [signature setObject:[dateFormatter stringFromDate:self.timeStamp] forKey:@"creationDate"];
    }
    if (self.uuid) {
        [signature setObject:self.uuid forKey:@"uuid"];
    }
    if (self.mediaPath) {
        // TODO: just the filename
        [signature setObject:self.mediaPath forKey:@"mediaPath"];
    }
    if (self.thumbnail) {
        // TODO: do mediaPath filename .jpg
    }

    return signature;
}

- (NSString *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:self.timeStamp];
}

@end
