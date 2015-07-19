//
//  ConferenceToolbar.m
//  ooVooSample
//
//  Created by Clement Barry on 12/12/13.
//  Copyright (c) 2013 ooVoo. All rights reserved.
//

#import "ConferenceToolbar.h"
#import <ooVooSDK-iOS/ooVooSDK-iOS.h>

@interface ConferenceToolbar () <UIActionSheetDelegate>

@property (nonatomic, strong) UIBarButtonItem *microphoneBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *speakerBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *cameraBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *resolutionBarButtonItem;
@property (nonatomic, strong) NSMutableArray  *toolbarButtonItems;

@end

@implementation ConferenceToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupNotifications];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupNotifications];
    }
    return self;
}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStop:) name:OOVOOPreviewDidStopNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStart:) name:OOVOOPreviewDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(microphoneDidChange:) name:OOVOOUserDidMuteMicrophoneNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(microphoneDidChange:) name:OOVOOUserDidUnmuteMicrophoneNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speakerDidChange:) name:OOVOOUserDidMuteSpeakerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speakerDidChange:) name:OOVOOUserDidUnmuteSpeakerNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.items)
    {
        self.microphoneBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[self imageForMicrophone:[ooVooController sharedController].microphoneEnabled]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(muteMicPressed:)];
        
        self.speakerBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[self imageForSpeaker:[ooVooController sharedController].speakerEnabled]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(muteSpeakerPressed:)];
        
        if ([ooVooController sharedController].availableCameras.count > 1)
        {
            self.cameraBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[self imageForCamera:[ooVooController sharedController].currentCamera]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(cameraPressed:)];
        }
        
        self.resolutionBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self stringForResolution:[[ooVooController sharedController] cameraResolutionLevel]]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(resButtonPressed:)];
        
        if (self.filtersEnabled)
        {
            self.filtersBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filters"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:nil
                                                                        action:nil];
        }
        else if ([ooVooController sharedController].inCallMessagesPermitted)
        {
            self.messagesBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bubble-min"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:nil
                                                                         action:nil];
        }

        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSMutableArray *items = [NSMutableArray arrayWithObjects:self.microphoneBarButtonItem, flexibleSpace, self.speakerBarButtonItem, flexibleSpace, nil];
        
        if ([ooVooController sharedController].availableCameras.count > 1)
        {
            [items addObjectsFromArray:@[self.cameraBarButtonItem, flexibleSpace]];
        }
        
        [items addObjectsFromArray:@[self.resolutionBarButtonItem, flexibleSpace]];
        
        if (self.filtersEnabled)
        {
            [items addObject:self.filtersBarButtonItem];
        }
        else if ([ooVooController sharedController].inCallMessagesPermitted)
        {
            [items addObject:self.messagesBarButtonItem];
        }
        
        self.items = [NSArray arrayWithArray:items];
    }
}

#pragma - Actions
- (void)muteMicPressed:(id)sender
{
    [ooVooController sharedController].microphoneEnabled = ![ooVooController sharedController].microphoneEnabled;
}

- (void)muteSpeakerPressed:(id)sender
{
    [ooVooController sharedController].speakerEnabled = ![ooVooController sharedController].speakerEnabled;
}

- (void)cameraPressed:(id)sender
{
    ooVooCameraDevice camera = [[ooVooController sharedController] currentCamera];
    
    if (camera == ooVooFrontCamera)
    {
        camera = ooVooRearCamera;
    }
    else if (camera == ooVooRearCamera)
    {
        camera = ooVooFrontCamera;
    }
    
    self.resolutionBarButtonItem.enabled = NO;
    self.cameraBarButtonItem.enabled = NO;
    [[ooVooController sharedController] selectCamera:camera];
}

- (void)resButtonPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Change resolution" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    NSArray *resolutionNames = [[ooVooController sharedController] availableCameraResolutionLevelNames];
    for (NSString *title in resolutionNames) [actionSheet addButtonWithTitle:title];
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = [resolutionNames count];
    actionSheet.destructiveButtonIndex = [[[ooVooController sharedController] availableCameraResolutionLevels] indexOfObject:@([[ooVooController sharedController] cameraResolutionLevel])];
    
    [actionSheet showFromToolbar:self];
    
    self.cameraBarButtonItem.enabled = NO;
    self.resolutionBarButtonItem.enabled = NO;
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        ooVooCameraResolutionLevel level = [([[ooVooController sharedController] availableCameraResolutionLevels])[buttonIndex] integerValue];
        
        if (level != [[ooVooController sharedController] cameraResolutionLevel]) {
            [[ooVooController sharedController] setCameraResolutionLevel:level];
            
            return;
        }
    }

    self.resolutionBarButtonItem.enabled = YES;
    self.cameraBarButtonItem.enabled = YES;
}

#pragma mark - Notifications
- (void)microphoneDidChange:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        BOOL isMicrophoneEnabled = [ooVooController sharedController].microphoneEnabled;
        self.microphoneBarButtonItem.image = [self imageForMicrophone:isMicrophoneEnabled];
        
    });
}

- (void)speakerDidChange:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        BOOL isSpeakerEnabled = [ooVooController sharedController].speakerEnabled;
        self.speakerBarButtonItem.image = [self imageForSpeaker:isSpeakerEnabled];
        
    });
}

- (void)videoDidStart:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.cameraBarButtonItem.enabled = YES;
        self.resolutionBarButtonItem.enabled = YES;
        self.cameraBarButtonItem.image = [self imageForCamera:[ooVooController sharedController].currentCamera];
        self.resolutionBarButtonItem.title = [self stringForResolution:[[ooVooController sharedController] cameraResolutionLevel]];
        
    });
}

- (void)videoDidStop:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{

        self.cameraBarButtonItem.enabled = YES;
        self.resolutionBarButtonItem.enabled = YES;

    });
}

#pragma mark - Resources
- (UIImage *)imageForMicrophone:(BOOL)enabled
{
    return [UIImage imageNamed:(enabled?@"ic_mic":@"ic_mic_off")];
}

- (UIImage *)imageForSpeaker:(BOOL)enabled
{
    return [UIImage imageNamed:(enabled?@"ic_speaker":@"ic_speaker_off")];
}

- (UIImage *)imageForCamera:(ooVooCameraDevice)cameraType
{
    switch (cameraType) {
        case ooVooFrontCamera: return [UIImage imageNamed:@"ic_camera"];
        case ooVooRearCamera : return [UIImage imageNamed:@"video-camera"];
        default:
            break;
    }
    return nil;
}

- (NSString*)stringForResolution:(ooVooCameraResolutionLevel)resolution
{
    switch (resolution) {
        case ooVooCameraResolutionLow:    return NSLocalizedString(@"Low", nil);
        case ooVooCameraResolutionMedium: return NSLocalizedString(@"Med", nil);
        case ooVooCameraResolutionHigh:    return NSLocalizedString(@"High", nil);
        case ooVooCameraResolutionHD: return NSLocalizedString(@"HD", nil);
        default:
            break;
    }
    return nil;
}

@end
