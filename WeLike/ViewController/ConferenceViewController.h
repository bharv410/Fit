//
//  ConferenceViewController.h
//  Fitovate
//
//  Created by Benjamin Harvey on 5/16/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ooVooSDK-iOS/ooVooVideoView.h>

@interface ConferenceViewController : UIViewController

@property (strong, nonatomic) ooVooVideoView *videoView;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *callingTextLabel;
@property (strong, nonatomic) NSString *conferenceToJoin;
@property (strong, nonatomic) NSString *notificationSender;


+ (CGFloat) window_height;
+ (CGFloat) window_width;

@end
