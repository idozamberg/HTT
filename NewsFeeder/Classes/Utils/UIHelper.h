//
//  UIHelper.h
//  HeadToToe
//
//  Created by ido zamberg on 10/11/14.
//  Copyright (c) 2014 Cristian Ronaldo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIHelper : NSObject

+ (NSMutableDictionary*) dictionaryFromPlistWithName : (NSString*) plistName;
+ (NSArray*) seprateStringsWithString : (NSString*) stringToSeparate;


@end
