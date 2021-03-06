//
//  PDFManager.h
//  HeadToToe
//
//  Created by ido zamberg on 10/16/14.
//  Copyright (c) 2014 Cristian Ronaldo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppData.h"
#import "INDAPVScanner.h"

@interface PDFManager : NSObject


+ (PDFManager*) sharedInstance;


@property (nonatomic,strong) NSDictionary* documentsUrls;
@property (nonatomic,strong) INDAPVScanner* scanner;


- (NSString*) createStringFromDictionaryForPdf : (NSMutableDictionary*) dict andShouldFilter : (BOOL) shouldFilter;
- (NSString*) createPdfFromDictionary : (NSMutableDictionary*) dict andShouldFilter : (BOOL) shouldFilter;
- (NSMutableArray*) findStringInPdfLibrary : (NSString*) searchPhrase;

@end
