//
//  UGBZipHTMLExport.h
//  GuestBook
//
//  Created by Emily Brenneke on 1/14/14.
//  Copyright (c) 2014 UnspunProductions. All rights reserved.
//

@import Foundation;

@class Event;

@interface UGBZipHTMLExport : NSObject

+ (NSString *)zipDataForEvent:(Event *)event;

@end
