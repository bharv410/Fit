//
//  ParticipantDetailViewController.m
//  ooVooSample
//
//  Created by Clement Barry on 12/12/13.
//  Copyright (c) 2013 ooVoo. All rights reserved.
//

#import "ParticipantDetailViewController.h"
#import <ooVooSDK-iOS/ooVooSDK-iOS.h>
#import "MessagesViewController.h"

@interface ParticipantDetailViewController ()

@property (nonatomic, strong) ooVooVideoView *fullScreenVideoView;
@property (nonatomic, weak)   UIPopoverController *filtersPopoverController;

@end

@implementation ParticipantDetailViewController

- (void)configureVideoView
{
    NSUInteger maskUI  = [self supportedInterfaceOrientations];
    NSUInteger maskApp = [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
    NSUInteger mask = maskUI & maskApp;
    BOOL isRotationSupported = !( UIDeviceOrientationIsPortrait(mask) || UIDeviceOrientationIsLandscape(mask));
    BOOL isPreview = self.participant.isMe;
    
    self.fullScreenVideoView.fitVideoMode = NO;
    self.fullScreenVideoView.supportOrientation = (isRotationSupported ? isPreview : !isPreview);
    ooVooCameraDevice camera = [ooVooController sharedController].currentCamera;
    self.fullScreenVideoView.mirrored =(isPreview && (camera == ooVooFrontCamera));
    self.fullScreenVideoView.preview = isPreview;
    [self.fullScreenVideoView showVideo:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.participant.displayName;
    self.fullScreenVideoView = [[ooVooVideoView alloc] initWithFrame:self.view.bounds];
    [self configureVideoView];
    
    self.fullScreenVideoView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomOut:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.fullScreenVideoView addGestureRecognizer:singleTapGestureRecognizer];
    
    [self.view insertSubview:self.fullScreenVideoView belowSubview:self.toolbar];
    
    [self.fullScreenVideoView associateToID:self.participant.participantID];
    
    if (self.participant.isMe)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStop:) name:OOVOOPreviewDidStopNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStart:) name:OOVOOPreviewDidStartNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidLeave:) name:OOVOOParticipantDidLeaveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidChange:) name:OOVOOParticipantVideoStateDidChangeNotification object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.participant.isMe)
    {
        int filtersCount = [[[ooVooController sharedController] availableVideoFilters] count];
        if (filtersCount > 0)
        {
            self.toolbar.filtersEnabled = YES;
        }
        else
        {
            self.toolbar.filtersEnabled = NO;
        }
    }
    
    self.toolbar.items = nil;
    [self.toolbar setNeedsLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.participant.isMe)
    {
        self.toolbar.filtersBarButtonItem.target = self;
        self.toolbar.filtersBarButtonItem.action = @selector(showFilters:);
    }
    else
    {
        self.toolbar.messagesBarButtonItem.target = self;
        self.toolbar.messagesBarButtonItem.action = @selector(showMessages:);
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.filtersPopoverController dismissPopoverAnimated:YES];
}

#pragma mark - Actions
- (void)zoomOut:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.fullScreenVideoView clear];
    [self.fullScreenVideoView removeFromSuperview];
    self.fullScreenVideoView = nil;
    
    if (self.participant.isMe)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:OOVOOPreviewDidStopNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:OOVOOPreviewDidStartNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:OOVOOParticipantDidLeaveNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:OOVOOParticipantVideoStateDidChangeNotification object:nil];
    }

    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showFilters:(id)sender
{
    if (self.filtersPopoverController)
    {
        [self.filtersPopoverController dismissPopoverAnimated:YES];
    }
    else
    {
        [self performSegueWithIdentifier:@"Filters" sender:self];
    }
}

- (IBAction)showMessages:(id)sender
{
    [self performSegueWithIdentifier:@"DirectMessages" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Filters"])
    {
        if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]])
        {
            self.filtersPopoverController = ((UIStoryboardPopoverSegue *)segue).popoverController;
            UINavigationController *navigationController = segue.destinationViewController;
            navigationController.navigationBar.translucent = NO;
        }
    }
    else if ([segue.identifier isEqualToString:@"DirectMessages"])
    {
        MessagesViewController *messagesViewController;
        UINavigationController *navigationController = segue.destinationViewController;
        messagesViewController = navigationController.viewControllers[0];
        messagesViewController.messagesController = self.participant.messagesController;
    }
}

#pragma mark - Notifications
- (void)participantDidLeave:(NSNotification *)notification
{
    if ([[notification.userInfo objectForKey:OOVOOParticipantIdKey] isEqualToString:self.participant.participantID])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self zoomOut:nil];
            
        });
    }
}

- (void)participantDidChange:(NSNotification *)notification
{
    if ([[notification.userInfo objectForKey:OOVOOParticipantIdKey] isEqualToString:self.participant.participantID])
    {
        if (([[notification.userInfo objectForKey:OOVOOParticipantStateKey] integerValue] == ooVooVideoOff) ||
            ([[notification.userInfo objectForKey:OOVOOParticipantStateKey] integerValue] == ooVooVideoPaused))
        {
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [self zoomOut:nil];
            
            });
        }
    }
}

- (void)videoDidStop:(NSNotification *)notification
{
// Uncomment to force zoom-out when the app gets inactive
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        [self zoomOut:nil];
//        
//    });
}

- (void)videoDidStart:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self configureVideoView];
        [self.fullScreenVideoView associateToID:self.participant.participantID];
        
    });
}

@end
