//
// ConferenceViewController.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "ParticipantsController.h"

@interface ConferenceViewController : UICollectionViewController <ParticipantsControllerDelegate>

@property (nonatomic, copy) NSString *conferenceId;
@property (nonatomic, copy) NSString *participantId;
@property (nonatomic, copy) NSString *participantInfo;

- (IBAction)leaveConference:(id)sender;
- (IBAction)showInformation:(id)sender;

@end