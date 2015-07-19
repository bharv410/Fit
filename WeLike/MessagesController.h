//
//  MessagesController.h
//  ooVooSample
//
//  Created by Clement Barry on 12/18/13.
//  Copyright (c) 2013 ooVoo. All rights reserved.
//

#import "ParticipantsController.h"

@protocol MessagesControllerDelegate;


@interface MessagesController : NSObject

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, weak) ParticipantsController *participantsController;
@property (nonatomic, weak) id <MessagesControllerDelegate> delegate;
@property (nonatomic, copy) NSString *participantID; // Optional (only used for 1-on-1 direct messaging).

- (void)sendText:(NSString *)text;

@end


@interface Message : NSObject

@property (nonatomic, copy) NSDate *timestamp;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *from;
@property (nonatomic, assign) BOOL incoming;

@end


@protocol MessagesControllerDelegate <NSObject>

- (void)controllerWillChangeContent:(MessagesController *)controller;
- (void)controller:(MessagesController *)controller didInsertMessage:(Message *)message atIndexPath:(NSIndexPath *)indexPath;
- (void)controllerDidChangeContent:(MessagesController *)controller;

@end
