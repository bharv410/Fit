//
//  FitovateData.h
//  Fitovate
//
//  Created by Benjamin Harvey on 5/3/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <foundation/Foundation.h>
#import <Parse/Parse.h>
#import "WLIUser.h"
#import "PGAvater.h"
#import "WLIComment.h"

@interface FitovateData : NSObject {
    NSString *someProperty;
    NSString *confernceId;
    NSString *participantId;
    WLIUser *currentUser;
}

@property (nonatomic, retain) NSString *someProperty;
@property (nonatomic, retain) NSString *participantId;
@property (nonatomic, retain) NSString *confernceId;
@property (nonatomic, retain) WLIUser *currentUser;
@property (nonatomic, retain) NSString *myUsername;
@property (nonatomic, retain) NSMutableDictionary *allUsersDictionary;
@property (nonatomic) BOOL layerAuthenticated;

+ (id)sharedFitovateData;
-(void) hasAMessage : (NSString *)username;
- (NSDictionary *) parseUserToDictionary : (PFObject *) userFromParse;
- (WLIUser *) pfobjectToWLIUser : (PFObject *) userFromParse;
- (void) unfollowUserIdWithUserId : (NSNumber *) following :(NSNumber *) follower;
- (void) followUserIdWithUserId : (NSNumber *) following :(NSNumber *) follower;
- (NSArray *) getAllIdsThatUsersFollowing : (void (^)(void))completion;
- (void) likeUserIdWithPostId : (NSNumber *) liker :(NSNumber *) liking: (void (^)(void))completion;
- (void) unlikeUserIdWithPostId : (NSNumber *) liker :(NSNumber *) liking: (void (^)(void))completion;
- (void) commentFromUserIdWithPostId : (NSNumber *) liker :(NSNumber *) liking :(NSString *) text : (void (^)(WLIComment *comment))completion;
- (void) oovooConferenceStarted;
- (void) startOovoo;
-(void) joinConference : (NSString *)currentUsername :(NSString *)userToJoin;
-(PGAvater *)avatarForUser : (NSString *) participant;

@end