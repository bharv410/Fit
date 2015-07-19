//
//  MessagesController.m
//  ooVooSample
//
//  Created by Clement Barry on 12/18/13.
//  Copyright (c) 2013 ooVoo. All rights reserved.
//

#import "MessagesController.h"

@implementation MessagesController

- (void)setParticipantsController:(ParticipantsController *)participantsController
{
    if (_participantsController != participantsController)
    {
        _participantsController = participantsController;
        self.messages = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incomingMessage:) name:OOVOOInCallMessageNotification object:nil];
    }
}

- (void)addMessage:(Message *)msg
{
    [self.messages addObject:msg];

    [self.delegate controllerWillChangeContent:self];
    
    [self.delegate controller:self
             didInsertMessage:msg
                  atIndexPath:[NSIndexPath indexPathForRow:(self.messages.count - 1) inSection:0]];
    
    [self.delegate controllerDidChangeContent:self];
}

- (void)incomingMessage:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{

        NSString *participantId = notification.userInfo[OOVOOParticipantIdKey];
        NSData *message = notification.userInfo[OOVOOParticipantInfoKey];
        
        if (self.participantID && ![self.participantID isEqualToString:participantId])
        {
            return;
        }
        
        Message *msg = [[Message alloc] init];
        msg.text = [[NSString alloc] initWithBytes:[message bytes] length:[message length] encoding:NSUTF8StringEncoding];
        msg.timestamp = [NSDate date];
        msg.incoming = YES;
        msg.from = [self.participantsController participantWithId:participantId].displayName;

        [self addMessage:msg];
    });
                   
}

- (void)sendText:(NSString *)text
{
    [[ooVooController sharedController] sendMessage:[text dataUsingEncoding:NSUTF8StringEncoding] toParticipantID:self.participantID];
    
    Message *msg = [[Message alloc] init];
    msg.text = text;
    msg.timestamp = [NSDate date];
    msg.incoming = NO;
    msg.from = @"Me";
    
    [self addMessage:msg];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation Message

@end