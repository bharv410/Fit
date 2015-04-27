//
//  ActivityController.h
//  Fitovate
//
//  Created by Benjamin Harvey on 4/27/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *tableViewRefresh;
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSArray *postIDs;

@end
