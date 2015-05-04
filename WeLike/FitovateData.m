//
//  FitovateData.m
//  Fitovate
//
//  Created by Benjamin Harvey on 5/3/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import "FitovateData.h"
#import "WLIUser.h"
#import <Parse/Parse.h>

@implementation FitovateData

@synthesize someProperty;
@synthesize myUsername;

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

- (void)loginUserWithUsername:(NSString*)username andPassword:(NSString*)password onCompletion:(void (^)(WLIUser *user, BOOL success))completion {
    
    if (!username.length || !password.length) {
        completion(nil, NO);
    } else {
        
        PFQuery *query = [PFQuery queryWithClassName:@"Users"];
        [query whereKey:@"username" equalTo:username];
        [query whereKey:@"password" equalTo:password];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                
                PFObject *loggedInUserParse = [objects objectAtIndex:0];
                NSLog(@"succesful login through parse!!!");
                
                PFGeoPoint *userLoc = loggedInUserParse[@"location"];
                NSDictionary *rawUser = [NSDictionary dictionaryWithObjectsAndKeys:
                                          loggedInUserParse[@"userID"], @"userID",
                                          loggedInUserParse[@"userTypeID"], @"userTypeID",
                                          loggedInUserParse[@"password"], @"password",
                                          loggedInUserParse[@"email"], @"email",
                                          loggedInUserParse[@"fullname"], @"userFullname",
                                          loggedInUserParse[@"username"], @"username",
                                          loggedInUserParse[@"userinfo"], @"userinfo",
                                          loggedInUserParse[@"followersCount"], @"followersCount",
                                          loggedInUserParse[@"followingCount"], @"followingCount",
                                          loggedInUserParse[@"phone"], @"userPhone",
                                          loggedInUserParse[@"website"], @"userWeb",
                                          loggedInUserParse[@"userLat"], userLoc.latitude,
                                          loggedInUserParse[@"userLong"], userLoc.longitude, nil];
                
                _currentUser = [[WLIUser alloc]initFromParse:rawUser];
                [self saveCurrentUser];
                
                completion(_currentUser, YES);
            }else{
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                completion(nil, NO);
            }
        }];
    }
}
    

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void)saveCurrentUser {
        
        if (self.currentUser) {
            NSData *archivedUser = [NSKeyedArchiver archivedDataWithRootObject:_currentUser];
            [[NSUserDefaults standardUserDefaults] setObject:archivedUser forKey:@"_currentUser"];
        }
}
    
@end
