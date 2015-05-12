//
//  FitovateData.m
//  Fitovate
//
//  Created by Benjamin Harvey on 5/3/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import "FitovateData.h"
#import <Parse/Parse.h>
#import "WLIUser.h"
#import "WLIConnect.h"

@implementation FitovateData

@synthesize someProperty;
@synthesize myUsername;
@synthesize currentUser;

#pragma mark Singleton Methods

+ (id)sharedFitovateData {
    static FitovateData *sharedFitovateData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFitovateData = [[self alloc] init];
    });
    return sharedFitovateData;
}

- (id)init {
    if (self = [super init]) {
        NSString *someString = @" ";
        someProperty = [[NSString alloc] initWithString:someString];
    }
    return self;
}

- (NSDictionary *) parseUserToDictionary : (PFObject *) userFromParse {
    
    NSArray *temp = [[NSArray alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    temp = [userFromParse allKeys];
    
    NSEnumerator *e = [temp objectEnumerator]; id object; while (object = [e nextObject]) { [dict setValue:[userFromParse objectForKey:object] forKey:object]; }
    return dict;
}

- (NSArray *) getAllIdsThatUsersFollowing : (void (^)(void))completion{
    WLIConnect *sharedConnect = [WLIConnect sharedConnect];
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    NSNumber *myUserId = [NSNumber numberWithInt:sharedConnect.currentUser.userID];
    NSLog(@"logged in as user number %@",myUserId);
    [temp addObject:myUserId];
    
    PFQuery *getFollowings = [PFQuery queryWithClassName:@"Follows"];
    [getFollowings whereKey:@"follower" equalTo:[NSNumber numberWithInt:sharedConnect.currentUser.userID]];
    [getFollowings findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for(PFObject *object in objects){
    
                [temp addObject:object[@"following"]];
                NSLog(@"follwing = %@",object[@"following"]);
            }
            completion();
        }else{
            NSLog(@"error getting ids that users following");
        }
        
    }];
    return temp;
}


- (WLIUser *) pfobjectToWLIUser : (PFObject *) userFromParse {
    FitovateData *myData = [FitovateData sharedFitovateData];
    WLIUser *currUser = [[WLIUser alloc]initFromParse:[myData parseUserToDictionary:userFromParse]];
    //inits it to parse and then fixes the userAvatar by using pffile data and pfgeopint data
    PFFile *imageUrl = userFromParse[@"userAvatar"];
    currUser.userAvatarPath = imageUrl.url;
    
    PFGeoPoint *selectedLocation = [userFromParse objectForKey:@"location"];
    float selectedLatitude = selectedLocation.latitude; // returns object latitude float
    float selectedLongitude = selectedLocation.longitude; // returns object longitude
    currUser.coordinate = CLLocationCoordinate2DMake(selectedLatitude, selectedLongitude);
    return currUser;
}

- (void) followUserIdWithUserId : (NSNumber *) following :(NSNumber *) follower {
    
    PFObject *gameScore = [PFObject objectWithClassName:@"Follows"];
    gameScore[@"following"] = follower;
    gameScore[@"follower"] = following;
    [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Followed");
        } else {
            // There was a problem, check error.description
            NSLog(@"error following");
        }
    }];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *loggedInUserParse in objects) {
                
                if([loggedInUserParse[@"userID"] isEqualToNumber:following]){
                    NSNumber *oldFollowingAmount = loggedInUserParse[@"followingCount"];
                    loggedInUserParse[@"followingCount"] = [NSNumber numberWithInt:[oldFollowingAmount intValue] + 1];
                    [loggedInUserParse saveInBackground];
                }
                    if([loggedInUserParse[@"userID"] isEqualToNumber:follower]){
                    NSNumber *oldFollowerAmount = loggedInUserParse[@"followersCount"];
                    loggedInUserParse[@"followersCount"] = [NSNumber numberWithInt:[oldFollowerAmount intValue] + 1];
                    [loggedInUserParse saveInBackground];
                }
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void) unfollowUserIdWithUserId : (NSNumber *) following :(NSNumber *) follower {
    
    PFQuery *unfollowUser = [PFQuery queryWithClassName:@"Follows"];
    [unfollowUser whereKey:@"following" equalTo:follower];
    [unfollowUser whereKey:@"follower" equalTo:following];
    [unfollowUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for(PFObject *object in objects){
                [object deleteInBackground];
                NSLog(@"unFollowed");
            }
        }
    }];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Users"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *loggedInUserParse in objects) {
                
                if([loggedInUserParse[@"userID"] isEqualToNumber:following]){
                    NSNumber *oldFollowingAmount = loggedInUserParse[@"followingCount"];
                    loggedInUserParse[@"followingCount"] = [NSNumber numberWithInt:[oldFollowingAmount intValue] - 1];
                    [loggedInUserParse saveInBackground];
                }
                if([loggedInUserParse[@"userID"] isEqualToNumber:follower]){
                    NSNumber *oldFollowerAmount = loggedInUserParse[@"followersCount"];
                    loggedInUserParse[@"followersCount"] = [NSNumber numberWithInt:[oldFollowerAmount intValue] - 1];
                    [loggedInUserParse saveInBackground];
                }
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void) likeUserIdWithPostId : (NSNumber *) liker :(NSNumber *) liking : (void (^)(void))completion{
    
    PFObject *gameScore = [PFObject objectWithClassName:@"Likes"];
    gameScore[@"liker"] = liker;
    gameScore[@"postId"] = liking;
    [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"liked");
        } else {
            // There was a problem, check error.description
            NSLog(@"error following");
        }
    }];
    
    PFQuery *query = [PFQuery queryWithClassName:@"FitovatePhotos"];
    [query whereKey:@"postID" equalTo:liking];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *post in objects) {
                    NSNumber *oldLikes = post[@"totalLikes"];
                    post[@"totalLikes"] = [NSNumber numberWithInt:[oldLikes intValue] + 1];
                    [post saveInBackground];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        completion();
    }];
}

- (void) unlikeUserIdWithPostId : (NSNumber *) liker :(NSNumber *) liking : (void (^)(void))completion{
    
    PFQuery *unfollowUser = [PFQuery queryWithClassName:@"Likes"];
    [unfollowUser whereKey:@"liker" equalTo:liker];
    [unfollowUser whereKey:@"postId" equalTo:liking];
    [unfollowUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for(PFObject *object in objects){
                [object deleteInBackground];
                NSLog(@"unliked");
            }
        }
    }];
    
    PFQuery *query = [PFQuery queryWithClassName:@"FitovatePhotos"];
    [query whereKey:@"postID" equalTo:liking];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *post in objects) {
                    NSNumber *oldLikes = post[@"totalLikes"];
                    post[@"totalLikes"] = [NSNumber numberWithInt:[oldLikes intValue] - 1];
                    [post saveInBackground];
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        completion();
    }];
}
- (void) commentFromUserIdWithPostId : (NSNumber *) liker :(NSNumber *) liking :(NSString *) text : (void (^)(WLIComment *comment))completion{
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    FitovateData *myData = [FitovateData sharedFitovateData];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            PFObject *gameScore = [PFObject objectWithClassName:@"Comments"];
            gameScore[@"commenter"] = liker;
            gameScore[@"postId"] = liking;
            gameScore[@"comment"] = text;
            gameScore[@"commentId"] = [NSNumber numberWithInteger:objects.count + 1];
            [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"commented");
                    WLIComment *newComment = [[WLIComment alloc] init];
                    newComment.commentID = objects.count + 1;
                    newComment.commentDate = gameScore.createdAt;
                    newComment.commentText = text;
                    NSNumber *idOfCommenter = liker;
                    WLIUser *commenterUser = [myData.allUsersDictionary objectForKey:idOfCommenter];
                    newComment.user = commenterUser;
                    completion(newComment);
                } else {
                    // There was a problem, check error.description
                    NSLog(@"error following");
                    completion(nil);
                }
            }];
        }
    }];
}

//- (void) deleteCommentUserIdWithPostId : (NSNumber *) liker :(NSNumber *) liking {
//    
//    PFQuery *unfollowUser = [PFQuery queryWithClassName:@"Likes"];
//    [unfollowUser whereKey:@"liker" equalTo:liker];
//    [unfollowUser whereKey:@"postId" equalTo:liking];
//    [unfollowUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if(!error){
//            for(PFObject *object in objects){
//                [object deleteInBackground];
//                NSLog(@"unliked");
//            }
//        }
//    }];
//}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
