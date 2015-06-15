//
//  PGUser.h
//  Fitovate
//
//  Created by Benjamin Harvey on 6/14/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Atlas/Atlas.h>

@interface PGUser : NSObject <ATLParticipant, ATLAvatarItem>

@property(nonatomic, readonly) NSString *firstName;
@property(nonatomic, readonly) NSString *lastName;
@property(nonatomic, readonly) NSString *fullName;
@property(nonatomic, readonly) NSString *participantIdentifier;
@property(nonatomic, readonly) UIImage *avatarImage;
@property(nonatomic, readonly) NSString *avatarInitials;

- (instancetype)initWithParticipantIdentifier:(NSString *)participantIdentifier;

+ (instancetype)userWithParticipantIdentifier:(NSString *)participantIdentifier;


@end