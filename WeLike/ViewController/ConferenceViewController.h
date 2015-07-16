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
{
    IBOutlet UIView *vImagePreview;             //<<<<<ADD THIS
}
@property(nonatomic, retain) IBOutlet UIView *vImagePreview;             //<<<<<ADD THIS

@property (strong, nonatomic) ooVooVideoView *videoView;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *callingTextLabel;
@property (strong, nonatomic) NSString *conferenceToJoin;
@property (strong, nonatomic) NSString *notificationSender;
@property (strong, nonatomic) IBOutlet UIButton *hangupButton;

+ (CGFloat) window_height;
+ (CGFloat) window_width;
- (void)videoCallThisUser;

@end
