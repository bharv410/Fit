//
// ParticipantsController.m
// 
// Created by ooVoo on July 22, 2013
//
// © 2013 ooVoo, LLC.  Used under license. 
//

#import "ParticipantsController.h"
#import "MessagesController.h"
#import <ooVooSDK-iOS/ooVooSDK-iOS.h>


@implementation Participant
@end

@interface ParticipantsController()
@property (nonatomic, strong) NSMutableArray *participants;
@property (nonatomic, strong) NSMutableDictionary *participantsByID;
@end

@implementation ParticipantsController

- (id)init
{
    if ((self = [super init]))
    {
        _participants = [NSMutableArray array];
        _participantsByID = [NSMutableDictionary dictionary];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(conferenceDidBegin:)
                                                     name:OOVOOConferenceDidBeginNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(participantDidJoin:)
                                                     name:OOVOOParticipantDidJoinNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(participantDidLeave:)
                                                     name:OOVOOParticipantDidLeaveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(participantDidChange:)
                                                     name:OOVOOParticipantVideoStateDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoDidStop:)
                                                     name:OOVOOPreviewDidStopNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoDidStart:)
                                                     name:OOVOOPreviewDidStartNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)numberOfParticipants
{
 	return [self.participants count];
}

- (Participant *)participantAtIndex:(NSUInteger)index
{
    if ([self.participants count] > index)
    {
        return [self.participants objectAtIndex:index];
    }
    
    return nil;
}

- (Participant *)participantWithId:(NSString *)participantId
{
    return [self.participantsByID valueForKey:participantId];
}

- (NSUInteger)indexOfParticipantWithId:(NSString *)participantId
{
    NSUInteger index = NSNotFound;
    Participant *participant = [self participantWithId:participantId];
    if (participant)
    {
        index = [self.participants indexOfObject:participant];
    }
    
    return index;
}

#pragma mark - State
- (void)setState:(ooVooVideoState)state forParticipant:(NSString*)participantId
{
    Participant *participant = [self participantWithId:participantId];
    participant.state = state;
}

#pragma mark - Notifications
- (void)conferenceDidBegin:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString *myParticipantID = userInfo[OOVOOParticipantIdKey];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate controllerWillChangeContent:self];
        
        Participant *me = [[Participant alloc] init];
        me.displayName = NSLocalizedString(@"Me", nil);
        me.participantID = myParticipantID;
        me.state = ooVooVideoUninitialized;
        me.switchState = ooVooVideoOn;
        me.isMe = YES;
        
        [self.participants addObject:me];
        self.participantsByID[myParticipantID] = me;
        
        NSUInteger index = [self.participants indexOfObject:me];
        [self.delegate controller:self didChangeParticipant:me atIndexPath:nil forChangeType:ParticipantChangeInsert newIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [self.delegate controllerDidChangeContent:self];
    });
}

- (void)participantDidJoin:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *userInfo = notification.userInfo;
        NSString *participantID = userInfo[OOVOOParticipantIdKey];
        NSString *displayName = userInfo[OOVOOParticipantInfoKey];
        
        [self.delegate controllerWillChangeContent:self];
        
        Participant *participantToAdd = [[Participant alloc] init];
        participantToAdd.participantID = participantID;
        participantToAdd.displayName = displayName;
        participantToAdd.state = ooVooVideoUninitialized;
        participantToAdd.switchState = ooVooVideoOn;

        MessagesController *msgController = [[MessagesController alloc] init];
        msgController.participantID = participantID;
        msgController.participantsController = self;
        participantToAdd.messagesController = msgController;
        
        self.participantsByID[participantID] = participantToAdd;
        [self.participants addObject:participantToAdd];
        
        NSUInteger index = [self.participants indexOfObject:participantToAdd];
        [self.delegate controller:self didChangeParticipant:participantToAdd atIndexPath:nil forChangeType:ParticipantChangeInsert newIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [self.delegate controllerDidChangeContent:self];

    });
}

- (void)participantDidLeave:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *userInfo = notification.userInfo;
        NSString *removedParticipantID = userInfo[OOVOOParticipantIdKey];
        
        Participant *participantToRemove = self.participantsByID[removedParticipantID];
        
        if (participantToRemove)
        {
            [self.delegate controllerWillChangeContent:self];
            
            NSUInteger index = [self.participants indexOfObject:participantToRemove];
            [self.participants removeObject:participantToRemove];
            //            [self.participantsByID removeObjectForKey:removedParticipantID];
            [self.delegate controller:self didChangeParticipant:participantToRemove atIndexPath:[NSIndexPath indexPathForRow:index inSection:0] forChangeType:ParticipantChangeDelete newIndexPath:nil];
            [self.delegate controllerDidChangeContent:self];
        }
        
    });
}

- (void)participantDidChange:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *userInfo = notification.userInfo;
        NSString *changedParticipantID = userInfo[OOVOOParticipantIdKey];
        ooVooVideoState state = (ooVooVideoState)[userInfo[OOVOOParticipantStateKey] integerValue];
        
        Participant *participant = self.participantsByID[changedParticipantID];
        
        if (participant)
        {
            [self.delegate controllerWillChangeContent:self];
            
            participant.state = state;
            NSUInteger index = [self.participants indexOfObject:participant];
            [self.delegate controller:self didChangeParticipant:participant atIndexPath:[NSIndexPath indexPathForRow:index inSection:0] forChangeType:ParticipantChangeUpdate newIndexPath:nil];
            
            
            [self.delegate controllerDidChangeContent:self];
        }
        
    });
    
}

- (void)videoDidStop:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.participants.count > 0)
        {
            Participant *participant = [self.participants objectAtIndex:0];
            [self.delegate controllerWillChangeContent:self];
            
            participant.state = ooVooVideoOff;
            [self.delegate controller:self didChangeParticipant:participant atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forChangeType:ParticipantChangeUpdate newIndexPath:nil];
            
            [self.delegate controllerDidChangeContent:self];
        }
    });
}

- (void)videoDidStart:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.participants.count>0)
        {
            Participant *participant = [self.participants objectAtIndex:0];
            [self.delegate controllerWillChangeContent:self];
            
            participant.state = ooVooVideoOn;
            [self.delegate controller:self didChangeParticipant:participant atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] forChangeType:ParticipantChangeUpdate newIndexPath:nil];
            
            [self.delegate controllerDidChangeContent:self];
        }
    });
}

@end
