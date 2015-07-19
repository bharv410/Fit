//
//  ParticipantDetailViewController.h
//  ooVooSample
//
//  Created by Clement Barry on 12/12/13.
//  Copyright (c) 2013 ooVoo. All rights reserved.
//

#import "ParticipantsController.h"
#import "ConferenceToolbar.h"

@interface ParticipantDetailViewController : UIViewController

@property (nonatomic, strong) Participant *participant;
@property (nonatomic, weak) IBOutlet ConferenceToolbar *toolbar;

@end
