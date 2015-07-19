//
// MainViewController.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "MainViewController.h"
#import "ConferenceViewController.h"
#import "TextFieldCell.h"
#import <ooVooSDK-iOS/ooVooSDK-iOS.h>
#import "WLIAppDelegate.h"
#import "FitovateData.h"

static NSString *kDefaultConferenceId = @"bharv410";

@interface MainViewController () <UITextFieldDelegate>

@property (nonatomic, copy) NSString *conferenceId;
@property (nonatomic, copy) NSString *participantInfo;
@property (nonatomic, copy) NSString *participantId;
@property (nonatomic, assign) UITextField *currentTextField;
@property (nonatomic, strong) ooVooVideoView *preview;
@property(nonatomic, strong) UIImageView *avatarImgView;
@property (nonatomic, assign) CGFloat contentOffsetY;

@end

typedef enum
{
    ConferenceIdRow,
    ParticipantIdRow,
    DisplayNameRow,
    NUMBER_OF_LOGIN_ROWS
}
LoginRow;

@implementation MainViewController

- (void)layoutPreview
{
    if (self.contentOffsetY == 0) {
        self.contentOffsetY = self.tableView.contentOffset.y;
    }

    CGRect frame = self.preview.frame;

    frame.origin.y = self.view.bounds.origin.y - self.tableView.contentOffset.y + self.tableView.contentSize.height;
    frame.size.height = self.view.bounds.size.height + self.contentOffsetY - self.tableView.contentSize.height;

    self.preview.frame = frame;
    self.avatarImgView.frame = frame;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    FitovateData *fd =[FitovateData sharedFitovateData];
    self.conferenceId = fd.confernceId;
    self.participantInfo = [[UIDevice currentDevice] name];
    self.participantId = fd.participantId;
    
    self.avatarImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.avatarImgView.image = [UIImage imageNamed:@"user.png"];
    self.avatarImgView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:self.avatarImgView];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self performSegueWithIdentifier:@"Join" sender:nil];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStart:) name:OOVOOPreviewDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraDidStart:) name:OOVOOCameraDidStartNotification object:nil];
    
    WLIAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.isSdkInited) {
        [ooVooController sharedController].cameraEnabled = YES;
    }
    
    [self layoutPreview];
}

- (void) viewDidAppear:(BOOL) animated
{
    [super viewDidAppear:animated];
    
    [self layoutPreview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OOVOOPreviewDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OOVOOCameraDidStartNotification object:nil];
}

- (void)cameraDidStart:(NSNotification *)notification
{
    NSNumber *errorNumber = notification.userInfo[OOVOOErrorKey];
    BOOL ok = (errorNumber.intValue == 0);
    
    [ooVooController sharedController].previewEnabled = ok;
    [ooVooController sharedController].transmitEnabled = ok;
}

- (void)videoDidStart:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //[self configurePreview];
        [self.preview associateToID:@""];
        [self.avatarImgView setHidden:YES];
    });
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutPreview];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
	return NUMBER_OF_LOGIN_ROWS;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TextFieldCell"];
    cell.textField.delegate = self;
    cell.textField.tag = indexPath.row;
    
    switch (indexPath.row)
    {
        case ConferenceIdRow:
            cell.textLabel.text = @"Conference ID";
            cell.textField.text = self.conferenceId;
            break;

        case ParticipantIdRow:
            cell.textLabel.text = @"Participant ID";
            cell.textField.text = self.participantId;
            break;
            
        case DisplayNameRow:
            cell.textLabel.text = @"Display Name";
            cell.textField.text = self.participantInfo;
            break;
            
        default:
            break;
    }
    
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:NSLocalizedString(@"SDK Version: %@", nil), [ooVooController sharedController].sdkVersion];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentTextField = textField;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case ConferenceIdRow:
            self.conferenceId = textField.text;
            break;
            
        case ParticipantIdRow:
            self.participantId = textField.text;
            break;
        
        case DisplayNameRow:
            self.participantInfo = textField.text;
            break;
            
        default:
            break;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Actions
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.currentTextField resignFirstResponder];

    if ([segue.identifier isEqualToString:@"Join"])
    {
        UINavigationController *conferenceNav = segue.destinationViewController;
        ConferenceViewController *conferenceVC = conferenceNav.viewControllers[0];
        conferenceVC.conferenceId = self.conferenceId;
        conferenceVC.participantId = self.participantId;
        conferenceVC.participantInfo = self.participantInfo;
    }
}

@end
