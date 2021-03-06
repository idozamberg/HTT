//
//  SystemsViewController.h
//  HeadToToe
//
//  Created by ido zamberg on 10/24/14.
//  Copyright (c) 2014 Cristian Ronaldo. All rights reserved.
//

#import "CustomNavViewController.h"

@interface SystemsViewController : CustomNavViewController <UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblSystem;
@property (nonatomic) menuMode currentMenuMode;
@property (nonatomic,strong) NSString* currentSystem;

@end
