//
//  ConferenceViewController.m
//  Fitovate
//
//  Created by Benjamin Harvey on 5/16/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import "ConferenceViewController.h"
#import <ooVooSDK-iOS/ooVooSDK-iOS.h>
#import <ooVooSDK-iOS/ooVooVideoView.h>
#import "FitovateData.h"

@interface ConferenceViewController ()

@end

@implementation ConferenceViewController

NSString *const OOVOOToken = @"MDAxMDAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAoE%2FTxwzvba3Wy%2FupvESaKZhg1ngT4E8V7bqvT1RpL5F0UIW8FKbWarcsUJ51Nx%2BGwlHpeETeLbU4B8AYBUSRsopL5aGEZx7OrKL%2B%2B60kOeKuNLZuf%2FTVdRXKNLa1LuXU%3D";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[ooVooController sharedController] initSdk:@"12349983352060"
                               applicationToken:OOVOOToken baseUrl:[[NSUserDefaults standardUserDefaults] stringForKey:@"production"]];
    
    [[ooVooController sharedController] joinConference:self.conferenceToJoin applicationToken:OOVOOToken  applicationId:@"12349983352060" participantInfo:@"participant info"];
    
    
    self.videoView = [[ooVooVideoView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height/2)];
    [self.view addSubview:self.videoView];
    
    [ooVooController sharedController].cameraEnabled = YES;
    
    [ooVooController sharedController].speakerEnabled = YES;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(participantDidJoin:)
                                                 name:OOVOOParticipantDidJoinNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(conferenceDidEnd:)
                                                 name:OOVOOConferenceDidEndNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cameraDidStart:)
                                                 name:OOVOOCameraDidStartNotification
                                               object:nil];
}

- (void)participantDidJoin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"participant joined");
        
        FitovateData *myData = [FitovateData sharedFitovateData];
        
        if(![self.conferenceToJoin containsString:myData.currentUser.userUsername]){
            //if I called them and they picked up
            [[ooVooController sharedController] receiveParticipantVideo:YES forParticipantID:self.conferenceToJoin];
        }else{
            
            //they called me and I just joined
            [[ooVooController sharedController] receiveParticipantVideo:YES forParticipantID:self.notificationSender];
        }
        
        
        
    });
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if (![parent isEqual:self.parentViewController]) {
        NSLog(@"Back pressed");
        [[ooVooController sharedController] leaveConference];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    [[ooVooController sharedController] leaveConference];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)conferenceDidEnd:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        
    });
}

- (void)cameraDidStart:(NSNotification *)notification
{
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
