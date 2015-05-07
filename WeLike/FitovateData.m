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
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];

    
    PFQuery *getFollowings = [PFQuery queryWithClassName:@"Follows"];
    [getFollowings whereKey:@"follower" equalTo:myUsername];
    NSArray *objects = [getFollowings findObjects];
    for(PFObject *object in objects){
        [temp addObject:object[@"following"]];
        NSLog(@"follwing = %d",object[@"following"]);
    }
//    [getFollowings findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if(!error){
//            for(PFObject *object in objects){
//                [temp addObject:object[@"following"]];
//                NSLog(@"follwing = %d",object[@"following"]);
//            }
//        }
//    }];
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
    gameScore[@"following"] = following;
    gameScore[@"follower"] = follower;
    [gameScore saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Followed");
        } else {
            // There was a problem, check error.description
            NSLog(@"error following");
        }
    }];
}

- (void) unfollowUserIdWithUserId : (NSNumber *) following :(NSNumber *) follower {
    
    PFQuery *unfollowUser = [PFQuery queryWithClassName:@"Follows"];
    [unfollowUser whereKey:@"following" equalTo:following];
    [unfollowUser whereKey:@"follower" equalTo:follower];
    [unfollowUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for(PFObject *object in objects){
                [object deleteInBackground];
                NSLog(@"Followed");
            }
        }
    }];
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
