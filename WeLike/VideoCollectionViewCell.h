//
// VideoCollectionViewCell.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import <ooVooSDK-iOS/ooVooSDK-iOS.h>

@interface VideoCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) ooVooVideoView *videoView;
@property(nonatomic, strong) UIImageView *avatarImgView;
@property(nonatomic, strong) UILabel *userNameLabel;
@property(nonatomic, strong) UILabel *stateLabel;

- (void)hideAvatar;
- (void)showAvatar;
- (BOOL)isAvatarHidden;

- (void)showState:(NSString*)text;
- (void)hideState;

@end
