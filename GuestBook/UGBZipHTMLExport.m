//
//  UGBZipHTMLExport.m
//  GuestBook
//
//  Created by Emily Brenneke on 1/14/14.
//  Copyright (c) 2014 UnspunProductions. All rights reserved.
//

#import "UGBZipHTMLExport.h"

#import "Event.h"

@implementation UGBZipHTMLExport

+ (NSData *)zipDataForEvent:(Event *)event
{
    NSURL *dirURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"eventExport"]];
    NSURL *mediaURL = [dirURL URLByAppendingPathComponent:@"media" isDirectory:YES];
    NSURL *thumbnailURL = [dirURL URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
    NSURL *eventDataURL = [dirURL URLByAppendingPathComponent:@"event.json" isDirectory:NO];
    NSURL *indexURL = [dirURL URLByAppendingPathComponent:@"event.html" isDirectory:NO];
    NSURL *sourceIndexURL = [[NSBundle mainBundle] URLForResource:@"event" withExtension:@"html"];

    [[NSFileManager defaultManager] createDirectoryAtURL:dirURL withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtURL:mediaURL withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createDirectoryAtURL:thumbnailURL withIntermediateDirectories:YES attributes:nil error:nil];

    NSDictionary *eventDictionary = [event jsonObjectForEvent];
    NSData *eventData = [NSJSONSerialization dataWithJSONObject:eventDictionary options:NSJSONWritingPrettyPrinted error:nil];
    [eventData writeToURL:eventDataURL atomically:YES];

    [[NSFileManager defaultManager] copyItemAtURL:sourceIndexURL toURL:indexURL error:nil];

    // TODO: copy media to media/, copy thumbnail data from coredata to thumbnails/, zip whole package, delete
    // export directory, return zipped data to email, drop in itunes, whatever

    NSLog(@"%@", [dirURL absoluteString]);

    return nil;
}

@end
