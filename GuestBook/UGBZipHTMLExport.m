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
#import "Signature.h"
#import "GuestBookAppDelegate.h"
#import "SSZipArchive.h"

@implementation UGBZipHTMLExport

+ (NSString *)zipDataForEvent:(Event *)event
{
    NSError *error = nil;
    NSString *uniqueString = [[NSProcessInfo processInfo] globallyUniqueString];
    NSURL *dirURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:uniqueString] isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:dirURL withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        NSLog(@"Error %@", [error localizedDescription]);
        return nil;
    }

    NSURL *mediaURL = [dirURL URLByAppendingPathComponent:@"media" isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:mediaURL withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        NSLog(@"Error %@", [error localizedDescription]);
        return nil;
    }

    NSURL *thumbnailURL = [dirURL URLByAppendingPathComponent:@"thumbnails" isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:thumbnailURL withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        NSLog(@"Error %@", [error localizedDescription]);
        return nil;
    }

    NSString *rendering = [GRMustacheTemplate renderObject:event
                                              fromResource:@"eventhtml"
                                                    bundle:nil
                                                     error:&error];
    if (error != nil) {
        NSLog(@"Error %@", [error localizedDescription]);
        return nil;
    }

    NSURL *indexURL = [dirURL URLByAppendingPathComponent:@"guestbook.html" isDirectory:NO];
    [rendering writeToURL:indexURL atomically:YES encoding:NSUTF8StringEncoding error:NULL];

    GuestBookAppDelegate *appDelegate = (GuestBookAppDelegate *)[[UIApplication sharedApplication] delegate];
    for (Signature *signature in [event signatures]) {
        NSString *imageName = [signature mediaPath];
        if (imageName) {
            NSURL *existingFileURL = [[appDelegate applicationLibraryDirectory] URLByAppendingPathComponent:imageName isDirectory:NO];
            NSURL *newFileURL = [mediaURL URLByAppendingPathComponent:imageName isDirectory:NO];
            [[NSFileManager defaultManager] copyItemAtURL:existingFileURL toURL:newFileURL error:&error];
            if (error) {
                NSLog(@"Error %@", [error localizedDescription]);
                return nil;
            }
        }

        NSData *thumbnailData = [signature thumbnail];
        if (thumbnailData && imageName) {
            NSURL *thumbnailImageURL = [thumbnailURL URLByAppendingPathComponent:imageName isDirectory:NO];
            [thumbnailData writeToURL:thumbnailImageURL options:nil error:&error];
            if (error) {
                NSLog(@"Error %@", [error localizedDescription]);
                return nil;
            }
        }
    }

    NSString *zipContents = [dirURL path];
    NSString *zippedPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self zipFileNameForEvent:event]];
    [SSZipArchive createZipFileAtPath:zippedPath withContentsOfDirectory:zipContents];

    [[NSFileManager defaultManager] removeItemAtURL:dirURL error:&error];
    if (error != nil) {
        NSLog(@"Error %@", [error localizedDescription]);
        return nil;
    }

    return zippedPath;
}

+ (NSString *)zipFileNameForEvent:(Event *)event
{
    NSString *name = [event name];
    NSCharacterSet *illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>:"];
    name = [[name componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
    if ([name length] == 0) {
        name = [event uuid];
    }
    return [name stringByAppendingPathExtension:@"zip"];
}

@end
