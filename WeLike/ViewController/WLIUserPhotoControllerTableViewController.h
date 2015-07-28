//
//  WLIUserPhotoControllerTableViewController.h
//  Fitovate
//
//  Created by Benjamin Harvey on 7/28/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIUser.h"

@interface WLIUserPhotoControllerTableViewController : UITableViewController

@property (nonatomic, retain) WLIUser *currentUser;
@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) NSArray *allFollowings;

@property (nonatomic, assign) BOOL loading;

@end
