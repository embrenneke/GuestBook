//
//  UGBZipHTMLExport.m
//  GuestBook
//
//  Created by Emily Brenneke on 1/14/14.
//  Copyright (c) 2014 UnspunProductions. All rights reserved.
//

#import "UGBZipHTMLExport.h"
#import "GRMustache.h"
#import "Event.h"

@implementation UGBZipHTMLExport

+ (NSData *)zipDataForEvent:(Event *)event
{
    NSURL *dirURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"eventExport"]];
    NSURL *mediaURL = [dirURL URLByAppendingPathComponent:@"media" isDirectory:YES];
    NSURL *thumbnailURL = [dirURL URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
    NSURL *indexURL = [dirURL URLByAppendingPathComponent:@"event.html" isDirectory:NO];

    [[NSFileManager defaultManager] createDirectoryAtURL:dirURL withIntermediateDirectories:YES attributes:nil error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtURL:mediaURL withIntermediateDirectories:YES attributes:nil error:NULL];
    [[NSFileManager defaultManager] createDirectoryAtURL:thumbnailURL withIntermediateDirectories:YES attributes:nil error:NULL];

    NSError *error;
    NSString *rendering = [GRMustacheTemplate renderObject:event
                                              fromResource:@"eventhtml"
                                                    bundle:nil
                                                     error:&error];
    if (error != nil) {
        NSLog(@"Error %@", [error localizedDescription]);
    }
    [rendering writeToURL:indexURL atomically:YES encoding:NSUTF8StringEncoding error:NULL];

    // TODO: copy media to media/, copy thumbnail data from coredata to thumbnails/, zip whole package, delete
    // export directory, return zipped data to email, drop in itunes, whatever
    NSLog(@"%@", [dirURL absoluteString]);

    return nil;
}

@end
