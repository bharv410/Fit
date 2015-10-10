//
//  ParseSingleton.m
//  Fitovate
//
//  Created by Benjamin Harvey on 4/27/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import "ParseSingleton.h"
#import <Parse/Parse.h>

@implementation ParseSingleton

+ (void)recordActivity:(NSString *)userId forSource:(NSString *)sourceId withActivitytype:(NSString *)activityType withPostId:(NSString *)postId {
    
    NSString *activityText = [NSString stringWithFormat:@"%@ added a %@ on your photo",sourceId,activityType];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          activityText, @"alert",
                          @"Increment", @"badge",
                          nil];
    PFPush *push = [[PFPush alloc] init];
    [push setChannels:[NSArray arrayWithObjects:sourceId, nil]];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(succeeded){
            NSLog(@"sent this push \n %@",activityText);
        }
    }];
    
    
    
PFObject *newActivity = [PFObject objectWithClassName:@"Activity"];

newActivity[@"postID"] = postId;
newActivity[@"sourceId"] = sourceId;
newActivity[@"userID"] = userId;
newActivity[@"activityType"] = activityType;
newActivity[@"read"] = [NSNumber numberWithBool:NO];

[newActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (succeeded) {
        NSLog(@"sent this activity \n %@",activityText);

    } else {
        NSLog(error.description);
    }
}];
 }

@end
