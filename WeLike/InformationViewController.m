//
// InformationViewController.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "InformationViewController.h"
#import <ooVooSDK-iOS/ooVooSDK-iOS.h>
#import "SwitchCell.h"

@implementation InformationViewController

#pragma mark - UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidJoin:) name:OOVOOParticipantDidJoinNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidLeave:) name:OOVOOParticipantDidLeaveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(participantDidChange:) name:OOVOOParticipantVideoStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStop:) name:OOVOOPreviewDidStopNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidStart:) name:OOVOOPreviewDidStartNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
	return [self.participantsController numberOfParticipants];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    SwitchCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
    
    Participant *participant = [self.participantsController participantAtIndex:indexPath.row];
	cell.textLabel.text = participant.displayName;
    cell.switcher.on = (participant.state == ooVooVideoOn && participant.switchState == ooVooVideoOn);
    cell.switcher.tag = indexPath.row;
    if (![cell.switcher actionsForTarget:self forControlEvent:UIControlEventValueChanged])
    {
        [cell.switcher addTarget:self action:@selector(toggleSwitch:) forControlEvents:UIControlEventValueChanged];
    }
    
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Participants", nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:NSLocalizedString(@"Conference ID: %@", nil), self.conferenceId];
}

#pragma mark - Actions
- (IBAction)toggleSwitch:(id)sender
{
    UISwitch *aSwitch = sender;
    
    BOOL enable = aSwitch.isOn;
    NSUInteger index = aSwitch.tag;
    
    Participant *participant = [self.participantsController participantAtIndex:index];
    participant.switchState = enable? ooVooVideoOn : ooVooVideoOff;
    [[ooVooController sharedController] receiveParticipantVideo:enable forParticipantID:participant.participantID];
    if (!enable) participant.state = ooVooVideoOff;
    
    [self.tableView reloadData];
}

#pragma mark - Notifications
- (void)participantDidJoin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        
    });
}

- (void)participantDidLeave:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        
    });    
}

- (void)participantDidChange:(NSNotification *)notification
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        
    });
}

- (void)videoDidStop:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        
    });
}

- (void)videoDidStart:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        
    });
}

@end
