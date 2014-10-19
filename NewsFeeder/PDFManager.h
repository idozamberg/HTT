//
//  PDFManager.h
//  HeadToToe
//
//  Created by ido zamberg on 10/16/14.
//  Copyright (c) 2014 Cristian Ronaldo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFManager : NSObject

+ (PDFManager*) sharedInstance;

- (NSString*) createStringFromDictionaryForPdf : (NSMutableDictionary*) dict andShouldFilter : (BOOL) shouldFilter;
- (NSString*) createPdfFromDictionary : (NSMutableDictionary*) dict andShouldFilter : (BOOL) shouldFilter;

@end