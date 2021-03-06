//
//  WLITimelineViewController.h
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"

@interface WLITimelineViewController : WLIViewController <WLIViewControllerRefreshProtocol>

@property (strong, nonatomic) IBOutlet UITableView *tableViewRefresh;
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) NSArray *allFollowings;
@property (nonatomic, assign) BOOL alertShowing;

- (void)firstLogin;
-(void)showMessagesButton;


@end
