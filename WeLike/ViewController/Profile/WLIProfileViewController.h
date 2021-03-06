//
//  WLIProfileViewController.h
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIConnect.h"
#import "UIImageView+AFNetworking.h"
#import "WLIViewController.h"
#import "LQSChatMessageCell.h"

@interface WLIProfileViewController : WLIViewController <UIAlertViewDelegate,UITableViewDelegate, UITableViewDataSource> {
    WLIUser *_user;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewUserProfile;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelFollowingCount;
@property (strong, nonatomic) IBOutlet UILabel *labelFollowersCount;

@property (strong, nonatomic) IBOutlet UILabel *labelAddress;
@property (strong, nonatomic) IBOutlet UILabel *labelPhone;
@property (strong, nonatomic) IBOutlet UILabel *labelWeb;
@property (strong, nonatomic) IBOutlet UILabel *labelEmail;
@property (strong, nonatomic) IBOutlet UILabel *labelBio;

@property (strong, nonatomic) IBOutlet UIButton *buttonFollow;
@property (strong, nonatomic) IBOutlet UIButton *buttonMessage;
@property (strong, nonatomic) IBOutlet UIButton *buttonLogout;
@property (strong, nonatomic) IBOutlet UIButton *buttonEditProfile;

@property (weak, nonatomic) IBOutlet UIView *movieView;
@property (nonatomic) LYRConversation *conversation;
@property (strong, nonatomic) IBOutlet UITableView *postsTableView;

@property (strong, nonatomic, setter = setUser:) WLIUser *user;
@property (strong, nonatomic) NSArray *allFollowings;
@property (strong, nonatomic) UIAlertView *messageAlert;

//postsview stuff
@property (nonatomic, retain) WLIUser *currentUser;
@property (strong, nonatomic) NSMutableArray *posts;


- (IBAction)goToMessages:(id)sender;
- (IBAction)buttonFollowToggleTouchUpInside:(id)sender;
- (IBAction)buttonFollowingTouchUpInside:(id)sender;
- (IBAction)buttonFollowersTouchUpInside:(id)sender;
- (IBAction)buttonLogoutTouchUpInside:(UIButton *)sender;
- (IBAction)barButtonItemEditTouchUpInside:(id)sender;
- (IBAction)onMorePhotosClick:(id)sender;

@end








