//
// ParticipantsController.h
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import <ooVooSDK-iOS/ooVooSDK-iOS.h>

@class Participant;
@class MessagesController;
@protocol ParticipantsControllerDelegate;



@interface ParticipantsController : NSObject

@property (nonatomic, weak) id <ParticipantsControllerDelegate> delegate;
- (NSInteger)numberOfParticipants;
- (Participant *)participantAtIndex:(NSUInteger)index;

- (Participant *)participantWithId:(NSString *)participantId;
- (NSUInteger)indexOfParticipantWithId:(NSString *)participantId;

@end



@interface Participant : NSObject

@property (nonatomic, strong) NSString *participantID;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, assign) ooVooVideoState state;
@property (nonatomic, assign) ooVooVideoState switchState;
@property (nonatomic, assign) BOOL isMe;
@property (nonatomic, strong) MessagesController *messagesController; // direct messages

@end


    
@protocol ParticipantsControllerDelegate

typedef enum {
	ParticipantChangeInsert = 1,
	ParticipantChangeDelete = 2,
	ParticipantChangeUpdate = 4
	
}
ParticipantChangeType;

- (void)controller:(ParticipantsController *)controller didChangeParticipant:(Participant *)aParticipant atIndexPath:(NSIndexPath *)indexPath forChangeType:(ParticipantChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
- (void)controllerWillChangeContent:(ParticipantsController *)controller;
- (void)controllerDidChangeContent:(ParticipantsController *)controller;

@end
