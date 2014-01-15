//
//  UGBZipHTMLExport.h
//  GuestBook
//
//  Created by Matt Brenneke on 1/14/14.
//  Copyright (c) 2014 UnspunProductions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Event;

@interface UGBZipHTMLExport : NSObject

+ (NSData *)zipDataForEvent:(Event *)event;

@end
