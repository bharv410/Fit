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
    
PFObject *newActivity = [PFObject objectWithClassName:@"Activity"];

    NSLog(postId);
newActivity[@"postID"] = postId;
    NSLog(sourceId);
    newActivity[@"sourceId"] = sourceId;
    NSLog(userId);
newActivity[@"userID"] = userId;
    NSLog(activityType);
newActivity[@"activityType"] = activityType;
    

[newActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    if (succeeded) {
        // The object has been saved.
        NSLog(@"succeeded recording activity");
    } else {
        // There was a problem, check error.description
        NSLog(error.description);
    }
}];
 }

@end
