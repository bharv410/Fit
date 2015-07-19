//
// InformationViewController.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//


#import "ParticipantsController.h"

@interface InformationViewController : UITableViewController

@property (nonatomic, strong) ParticipantsController *participantsController;
@property (nonatomic, copy) NSString *conferenceId;

- (IBAction)toggleSwitch:(id)sender;
- (IBAction)done:(id)sender;

@end
