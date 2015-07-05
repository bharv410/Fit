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
#import <AVFoundation/AVFoundation.h>

@interface ConferenceViewController ()
@end

@implementation ConferenceViewController

@synthesize vImagePreview;             //<<<<<ADD THIS

NSString *const OOVOOToken = @"MDAxMDAxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAoE%2FTxwzvba3Wy%2FupvESaKZhg1ngT4E8V7bqvT1RpL5F0UIW8FKbWarcsUJ51Nx%2BGwlHpeETeLbU4B8AYBUSRsopL5aGEZx7OrKL%2B%2B60kOeKuNLZuf%2FTVdRXKNLa1LuXU%3D";


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupIndicator];
    
    [[ooVooController sharedController] initSdk:@"12349983352060"
                               applicationToken:OOVOOToken baseUrl:[[NSUserDefaults standardUserDefaults] stringForKey:@"production"]];
    
    [[ooVooController sharedController] joinConference:self.conferenceToJoin applicationToken:OOVOOToken  applicationId:@"12349983352060" participantInfo:@"participant info"];
    
    self.title = [NSString stringWithFormat:@"%@",self.conferenceToJoin];
    
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
    
    FitovateData *myData = [FitovateData sharedFitovateData];
    if(![self.conferenceToJoin containsString:myData.currentUser.userUsername]){
        [self.indicator startAnimating];
    }
    
    UIImage *btnImage = [UIImage imageNamed:@"hangup.png"];
    UIButton *hangBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100, self.view.frame.size.height/2 - 50, 100.0, 50.0)];
    
    [hangBtn setImage:btnImage forState:UIControlStateNormal];
    [hangBtn addTarget:self action:@selector(hangUp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hangBtn];

    [self startPreview];
}


-(void) hangUp{
    [[ooVooController sharedController] leaveConference];
    NSLog(@"hanging up");
}

-(void) setupIndicator{
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicator.frame = CGRectMake(0.0, [UIScreen mainScreen].applicationFrame.size.height/2 +20, 40.0, 40.0);
    [self.videoView addSubview:self.indicator];
    [self.indicator bringSubviewToFront:self.videoView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
}

//********** VIEW DID UNLOAD **********
- (void)viewDidUnload
{
    [super viewDidUnload];
    vImagePreview = nil;
}

-(void) startPreview{
//    //-- Setup Capture Session.
//    _captureSession = [[AVCaptureSession alloc] init];
//    
//    //-- Creata a video device and input from that Device.  Add the input to the capture session.
//    AVCaptureDevice * videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    if(videoDevice == nil)
//        return;
//    
//    //-- Add the device to the session.
//    NSError *error;
//    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice
//                                                                        error:&error];
//    if(error)
//        return;
//    
//    [_captureSession addInput:input];
//    
//    //-- Configure the preview layer
//    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
//    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    
//    [_previewLayer setFrame:CGRectMake(0, 0,
//                                       self.cameraPreviewView.frame.size.width,
//                                       self.cameraPreviewView.frame.size.height)];
//    
//    //-- Add the layer to the view that should display the camera input
//    [self.cameraPreviewView.layer addSublayer:_previewLayer];
//    
//    //-- Start the camera
//    [_captureSession startRunning];
//    NSLog(@"started");
    
    [self.vImagePreview removeFromSuperview];
    self.vImagePreview =[[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100, self.view.frame.size.height/2 - 50, 100.0, 250.0)];
    NSLog(@"+50 WAS TOO LOW. 0 WAS HIGHER. THOGUTH -50 WOULD BE EVEN HIGHER N THEREFORE LOOK THE BESTPLACE");
    NSLog(@"+50 WAS TOO LOW. 0 WAS HIGHER. THOGUTH -50 WOULD BE EVEN HIGHER N THEREFORE LOOK THE BESTPLACE");
    NSLog(@"+50 WAS TOO LOW. 0 WAS HIGHER. THOGUTH -50 WOULD BE EVEN HIGHER N THEREFORE LOOK THE BESTPLACE");
    NSLog(@"+50 WAS TOO LOW. 0 WAS HIGHER. THOGUTH -50 WOULD BE EVEN HIGHER N THEREFORE LOOK THE BESTPLACE");
    NSLog(@"+50 WAS TOO LOW. 0 WAS HIGHER. THOGUTH -50 WOULD BE EVEN HIGHER N THEREFORE LOOK THE BESTPLACE");
    
    //----- SHOW LIVE CAMERA PREVIEW -----
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    
    CALayer *viewLayer = self.vImagePreview.layer;
    NSLog(@"viewLayer = %@", viewLayer);
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    
    captureVideoPreviewLayer.frame = self.vImagePreview.bounds;
    [self.vImagePreview.layer addSublayer:captureVideoPreviewLayer];
    
    NSArray *possibleDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    //AVCaptureDevice* device = [possibleDevices lastObject];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSLog(@"RTY BOTH THESE DEVICES TO SEE IF THEY WORK");
    NSLog(@"RTY BOTH THESE DEVICES TO SEE IF THEY WORK");
    NSLog(@"RTY BOTH THESE DEVICES TO SEE IF THEY WORK");
    NSLog(@"RTY BOTH THESE DEVICES TO SEE IF THEY WORK");
NSLog(@"RTY BOTH THESE DEVICES TO SEE IF THEY WORK");
    
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        // Handle the error appropriately.
        NSLog(@"ERROR: trying to open camera: %@", error);
    }else{
        NSLog(@"no error. show cam");
        [self.view addSubview:self.vImagePreview];
        
        UITextView *myTextView = [[UITextView alloc] init];
        myTextView.text = @"Calling...";
        [myTextView setTextColor:[UIColor redColor]];
        [self.videoView addSubview:myTextView];  
        [myTextView sizeToFit];
        
    }
    [session addInput:input];
    
    [session startRunning];
}

+ (CGFloat) window_height   {
    return [UIScreen mainScreen].applicationFrame.size.height;
}

+ (CGFloat) window_width   {
    return [UIScreen mainScreen].applicationFrame.size.width;
}

- (void)participantDidJoin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"participant joined");
        
        FitovateData *myData = [FitovateData sharedFitovateData];
        
        if(![self.conferenceToJoin containsString:myData.currentUser.userUsername]){
            //if I called them and they picked up
            [[ooVooController sharedController] receiveParticipantVideo:YES forParticipantID:self.conferenceToJoin];
            [self.indicator stopAnimating];
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
