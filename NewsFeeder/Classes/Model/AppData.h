//
//  AppData.h
//  iCare
//
//  Created by ido zamberg on 20/12/13.
//  Copyright (c) 2013 ido zamberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIHelper.h"
#import "UICustomNavigationController.h"


@interface AppData : NSObject

+ (AppData*) sharedInstance;

// Properties
@property (strong,nonatomic) NSMutableDictionary* filesList;
@property (strong,nonatomic) NSMutableDictionary* questionsList;
@property (strong,nonatomic) NSMutableDictionary* labValues;
@property (strong,nonatomic) UICustomNavigationController* currNavigationController;

// Methods & Functions
- (void) performStartupOperations;
- (NSMutableArray*) flattenedFilesArray;



@end
