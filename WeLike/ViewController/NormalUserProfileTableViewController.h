//
//  NormalUserProfileTableViewController.h
//  Fitovate
//
//  Created by Benjamin Harvey on 8/12/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIUser.h"

@interface NormalUserProfileTableViewController : UITableViewController

@property (nonatomic, retain) WLIUser *currentUser;
@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) NSArray *allFollowings;

@property (nonatomic, assign) BOOL loading;

@end
