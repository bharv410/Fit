//
// VideoCollectionViewCell.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "VideoCollectionViewCell.h"

@implementation VideoCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit
{
    CGRect frame = self.frame;
    
    self.videoView = [[ooVooVideoView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
    [self.contentView addSubview:self.videoView];
    
    self.avatarImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
    self.avatarImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.avatarImgView];
    
    self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0/*frame.size.height * 4 / 5*/, frame.size.width, frame.size.height/5)];
    self.userNameLabel.textAlignment = NSTextAlignmentCenter;
    self.userNameLabel.textColor = [UIColor blackColor];
    self.userNameLabel.font = [UIFont boldSystemFontOfSize:12.0];
    self.userNameLabel.backgroundColor = [UIColor whiteColor];
    self.userNameLabel.alpha = 0.7f;
    [self.contentView addSubview:self.userNameLabel];
    
    self.stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height*3/8, frame.size.width, frame.size.height/4)];
    self.stateLabel.textAlignment = NSTextAlignmentCenter;
    self.stateLabel.textColor = [UIColor blackColor];
    self.stateLabel.font = [UIFont boldSystemFontOfSize:12.0];
    self.stateLabel.backgroundColor = [UIColor whiteColor];
    self.stateLabel.alpha = 0.5f;
    [self.contentView addSubview:self.stateLabel];
    [self.stateLabel setHidden:YES];
}

- (void)prepareForReuse
{
    [self.videoView removeFromSuperview];
    self.videoView = [[ooVooVideoView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    [self.contentView addSubview:self.videoView];
    [self.contentView addSubview:self.avatarImgView];
    [self.contentView addSubview:self.userNameLabel];
    [self.contentView addSubview:self.stateLabel];
}

- (void)hideAvatar
{
    [self.avatarImgView setHidden:YES];
}

- (void)showAvatar
{
    [self.avatarImgView setHidden:NO];
}

- (BOOL)isAvatarHidden
{
    return [self.avatarImgView isHidden];
}

- (void)showState:(NSString*)text
{
    self.stateLabel.text = text;
    [self.stateLabel setHidden:NO];
}

- (void)hideState
{
    [self.stateLabel setHidden:YES];
}

- (void)dealloc
{
    [self.videoView showVideo:NO];
}
@end
