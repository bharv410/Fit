//
//  CustomHeaderView.h
//  Fitovate
//
//  Created by Benjamin Harvey on 8/12/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomHeaderView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelFollowingCount;
@property (strong, nonatomic) IBOutlet UILabel *labelFollowersCount;

@property (strong, nonatomic) IBOutlet UILabel *labelBio;
@property (strong, nonatomic) IBOutlet UIButton *editProfileButton;

@property (strong, nonatomic) IBOutlet UIButton *buttonFollow;
@property (strong, nonatomic) IBOutlet UIButton *buttonMessage;

@end
