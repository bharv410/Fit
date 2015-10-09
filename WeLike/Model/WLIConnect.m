//
//  WLIConnect.m
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIConnect.h"
#import <AWSiOSSDKv2/S3.h>
#import <AWSiOSSDKv2/AWSCore.h>
#import "ParseSingleton.h"
#import "FitovateData.h"
#import <Parse/Parse.h>
#import "ConferenceViewController.h"

#define kBaseLink @"http://fitovate.elasticbeanstalk.com"
#define kAPIKey @"!#wli!sdWQDScxzczFžŽYewQsq_?wdX09612627364[3072∑34260-#"
#define kConnectionTimeout 30
#define kCompressionQuality 1.0f

//Server status responses
#define kOK @"OK"
#define kBAD_REQUEST @"BAD_REQUEST"
#define kNO_CONNECTION @"NO_CONNECTION"
#define kSERVICE_UNAVAILABLE @"SERVICE_UNAVAILABLE"
#define kPARTIAL_CONTENT @"PARTIAL_CONTENT"
#define kCONFLICT @"CONFLICT"
#define kUNAUTHORIZED @"UNAUTHORIZED"
#define kNOT_FOUND @"NOT_FOUND"
#define kUSER_CREATED @"USER_CREATED"
#define kUSER_EXISTS @"USER_EXISTS"
#define kLIKE_CREATED @"LIKE_CREATED"
#define kLIKE_EXISTS @"LIKE_EXISTS"
#define kFORBIDDEN @"FORBIDDEN"
#define kCREATED @"CREATED"


@implementation WLIConnect

static WLIConnect *sharedConnect;

+ (WLIConnect*) sharedConnect {
    
    if (sharedConnect != nil) {
        return sharedConnect;
    }
    sharedConnect = [[WLIConnect alloc] init];
    return sharedConnect;
}

- (id)init {
    self = [super init];
    
    // comment for user persistance
    
    //[self removeCurrentUser];
    
    if (self) {
        httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseLink]];
        [httpClient.requestSerializer setValue:kAPIKey forHTTPHeaderField:@"api_key"];
        httpClient.responseSerializer = [AFJSONResponseSerializer serializer];
        json = [[SBJsonParser alloc] init];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _dateOnlyFormatter = [[NSDateFormatter alloc] init];
        [_dateOnlyFormatter setDateFormat:@"MM/dd/yyyy"];
        [_dateOnlyFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
        
        NSData *archivedUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"_currentUser"];
        NSString *userUsername = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
        if (archivedUser) {
            [self logBackIn];
            _currentUser = [NSKeyedUnarchiver unarchiveObjectWithData:archivedUser];
            FitovateData *myData = [FitovateData sharedFitovateData];
            myData.currentUser = _currentUser;
            
            NSString *userUsername = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
            NSLog(@"benmark archived user %@", userUsername);
        }{
            NSLog(@"benmark no archived user ");
        }
    }
    return self;
}
- (void)setLayerClientNow{
    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"c6d3dfe6-a1a8-11e4-b169-142b010033d0"];
    self.layerClient = [LYRClient clientWithAppID:appID];
}

- (void)saveCurrentUser {
    
    if (self.currentUser) {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];  //load NSUserDefaults
        
        NSString *userUsername = self.currentUser.userUsername;
        NSString *userpassword = self.currentUser.userPassword;
        [prefs setObject:userUsername forKey:@"username"];
        [prefs setObject:userpassword forKey:@"password"];
        
        
        FitovateData *myData = [FitovateData sharedFitovateData];
        myData.currentUser = _currentUser;
        NSData *archivedUser = [NSKeyedArchiver archivedDataWithRootObject:_currentUser];
        [[NSUserDefaults standardUserDefaults] setObject:archivedUser forKey:@"_currentUser"];
    }
}

- (void)logBackIn {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [prefs arrayForKey:@"favourites"];
    NSString *userUsername = [prefs stringForKey:@"username"];
    NSString *userpassword = [prefs stringForKey:@"password"];
    
    
    [self loginUserWithUsername:userUsername andPassword:userpassword onCompletion:^(WLIUser *user, ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            self.currentUser = user;
            [self authentWithLayer:^{
                NSLog(@"done");
            }];
            
        } else if (serverResponseCode == NO_CONNECTION) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"No connection. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else if (serverResponseCode == NOT_FOUND) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong username. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else if (serverResponseCode == UNAUTHORIZED) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Wrong password. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (void)authentWithLayer : (void (^)(void))completion {
    
//    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"c6d3dfe6-a1a8-11e4-b169-142b010033d0"];
//    self.layerClient = [LYRClient clientWithAppID:appID];
    if(self.layerClient.isConnected){
        
        NSString *userIDString = _currentUser.userUsername;
        NSLog(@"_currentUser name = %@",_currentUser.userUsername);
        [self authenticateLayerWithUserID:userIDString completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Failed Authenticating Layer Client with error:%@", error);
            }else{
                completion();
            }
        }];
        
    }else{
    
    [self.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Failed to connect to Layer: %@", error);
        } else {
            NSString *userIDString = _currentUser.userUsername;
            NSLog(@"_currentUser name = %@",_currentUser.userUsername);
            [self authenticateLayerWithUserID:userIDString completion:^(BOOL success, NSError *error) {
                if (!success) {
                    NSLog(@"Failed Authenticating Layer Client with error:%@", error);
                }else{
                    completion();
                }
            }];
        }
    }];
        
    }
}

- (void)removeCurrentUser {
    self.currentUser = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"_currentUser"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - User

- (void)loginUserWithUsername:(NSString*)username andPassword:(NSString*)password onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion {
    
    
    if (!username.length || !password.length) {
        completion(nil, BAD_REQUEST);
    } else {
        FitovateData *myData = [FitovateData sharedFitovateData];
        PFQuery *query = [PFQuery queryWithClassName:@"Users"];
        [query whereKey:@"username" equalTo:username];
        [query whereKey:@"password" equalTo:password];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *loggedInUserParse in objects) {
                    
                    _currentUser = [myData pfobjectToWLIUser:loggedInUserParse];
                    myData.currentUser = _currentUser;
                    if(myData.currentUser.userUsername!=nil)
                        [self saveCurrentUser];
                    completion(_currentUser, OK);
                }
                if(objects.count==0)
                    completion(nil, kUNAUTHORIZED);
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                completion(nil, kUNAUTHORIZED);
            }
        }];
        
        // When users indicate they are Giants fans, we subscribe them to that channel.
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:username forKey:@"channels"];
        [currentInstallation saveInBackground];
        
        
        
        
        
//        NSDictionary *parameters = @{@"username": username, @"password": password};
//        [httpClient POST:@"/login" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSDictionary *rawUser = [responseObject objectForKey:@"item"];
//            _currentUser = [[WLIUser alloc] initWithDictionary:rawUser];
//            
//            [self saveCurrentUser];
//            
//            [self debugger:parameters.description methodLog:@"api/login" dataLogFormatted:responseObject];
//            completion(_currentUser, OK);
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [self debugger:parameters.description methodLog:@"api/login" dataLog:error.description];
//            if (operation.response) {
//                completion(nil, operation.response.statusCode);
//            } else {
//                completion(nil, NO_CONNECTION);
//            }
//        }];
    }
}

- (void)registerUserWithUsername:(NSString*)username password:(NSString*)password email:(NSString*)email userAvatar:(UIImage*)userAvatar userType:(int)userType userFullName:(NSString*)userFullName userInfo:(NSString*)userInfo latitude:(float)latitude longitude:(float)longitude companyAddress:(NSString*)companyAddress companyPhone:(NSString*)companyPhone companyWeb:(NSString*)companyWeb onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion {
    
    if (!username.length || !password.length || !email.length) {
        completion(nil, BAD_REQUEST);
    } else {
        NSDictionary *parameters = @{@"username" : username, @"password" : password, @"email" : email, @"userFullname" : userFullName, @"userTypeID" : @(userType), @"userInfo" : userInfo, @"userLat" : @(latitude), @"userLong" : @(longitude), @"userAddress" : companyAddress, @"userPhone" : companyPhone, @"userWeb" : companyWeb};
        [httpClient POST:@"/register" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (userAvatar) {
                NSData *imageData = UIImageJPEGRepresentation(userAvatar, kCompressionQuality);
                if (imageData) {
                    [formData appendPartWithFileData:imageData name:@"userAvatar" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                }
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawUser = [responseObject objectForKey:@"item"];
            _currentUser = [[WLIUser alloc] initWithDictionary:rawUser];
            if(_currentUser.userUsername!=nil)
                [self saveCurrentUser];
            [self debugger:parameters.description methodLog:@"api/register" dataLogFormatted:responseObject];
            completion(_currentUser, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/register" dataLog:error.description];
            if (operation.response) {
                completion(nil, operation.response.statusCode);
            } else {
                completion(nil, NO_CONNECTION);
            }
        }];
    }
}

- (void)userWithUserID:(int)userID onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion {
    
    if (userID < 1) {
        completion(nil, BAD_REQUEST);
    } else {
        
        
        FitovateData *myData = [FitovateData sharedFitovateData];
        PFQuery *query = [PFQuery queryWithClassName:@"Users"];
        [query orderByDescending:@"userID"];
        [query whereKey:@"userID" equalTo:[NSNumber numberWithInt:userID]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *loggedInUserParse in objects) {
                    WLIUser *currUser = [myData pfobjectToWLIUser:loggedInUserParse];
                    completion(currUser,kOK);
                }
            } else {
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        
        
//        NSDictionary *parameters = @{@"userID": [NSString stringWithFormat:@"%d", self.currentUser.userID], @"forUserID": [NSString stringWithFormat:@"%d", userID]};
//        [httpClient POST:@"getProfile" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSDictionary *rawUser = [responseObject objectForKey:@"item"];
//            WLIUser *user = [[WLIUser alloc] initWithDictionary:rawUser];
//            if (user.userID == _currentUser.userID) {
//                _currentUser = user;
//                [self saveCurrentUser];
//            }
//            [self debugger:parameters.description methodLog:@"api/getProfile" dataLogFormatted:responseObject];
//            completion(user, OK);
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            [self debugger:parameters.description methodLog:@"api/getProfile" dataLog:error.description];
//            completion(nil, UNKNOWN_ERROR);
//        }];
        
        
    }
}

- (void)updateUserWithUserID:(int)userID userType:(WLIUserType)userType userEmail:(NSString*)userEmail password:(NSString*)password userAvatar:(UIImage*)userAvatar userFullName:(NSString*)userFullName userInfo:(NSString*)userInfo latitude:(float)latitude longitude:(float)longitude companyAddress:(NSString*)companyAddress companyPhone:(NSString*)companyPhone companyWeb:(NSString*)companyWeb onCompletion:(void (^)(WLIUser *user, ServerResponse serverResponseCode))completion {
    
    if (userID < 1) {
        completion(nil, BAD_REQUEST);
    } else {
        
        PFQuery *query = [PFQuery queryWithClassName:@"Users"];
        [query whereKey:@"userID" equalTo:[NSNumber numberWithInt:userID]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject *example in objects) {

                WLIUser *updatedUser = sharedConnect.currentUser;
                if (userEmail.length) {
                    [example setObject:userEmail forKey:@"email"];
                    updatedUser.userEmail = userEmail;
                }
                if (password.length) {
                    [example setObject:password forKey:@"password"];
                    updatedUser.userPassword = password;
                }
                if (userFullName.length) {
                    [example setObject:userFullName forKey:@"fullname"];
                    updatedUser.userFullName = userFullName;
                }
                if (companyPhone.length) {
                    [example setObject:companyPhone forKey:@"youtubeString"];
                    updatedUser.youtubeString = companyPhone;
                }
                if (companyWeb.length) {
                    [example setObject:companyWeb forKey:@"website"];
                    updatedUser.companyWeb = companyWeb;
                }
                [example saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    NSLog(@"updated");
                    completion(updatedUser, OK);
                }];
            }
        }];
    }
}

- (void)newUsersWithPageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *users, ServerResponse serverResponseCode))completion {
    
    NSDictionary *parameters = @{@"userID": [NSString stringWithFormat:@"%d", self.currentUser.userID], @"take": [NSString stringWithFormat:@"%d", pageSize]};
    [httpClient POST:@"getNewUsers" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawUsers = [responseObject objectForKey:@"items"];
        
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
        for (NSDictionary *rawUser in rawUsers) {
            WLIUser *user = [[WLIUser alloc] initWithDictionary:rawUser];
            [users addObject:user];
        }
        
        [self debugger:parameters.description methodLog:@"api/getNewUsers" dataLogFormatted:responseObject];
        completion(users, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getNewUsers" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
}

- (void)usersForSearchString:(NSString*)searchString page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *users, ServerResponse serverResponseCode))completion {
    
    if (!searchString.length) {
        completion(nil, BAD_REQUEST);
    } else {
        FitovateData *myData = [FitovateData sharedFitovateData];
        PFQuery *query = [PFQuery queryWithClassName:@"Users"];
        [query whereKey:@"fullname" containsString:searchString];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                NSMutableArray *users = [NSMutableArray arrayWithCapacity:objects.count];
                for(PFObject *parseObject in objects){
                    WLIUser *parseUser = [myData pfobjectToWLIUser:parseObject];
                    [users addObject:parseUser];
                }
                completion(users, OK);
            }else{
                NSLog(@"error searching");
                completion(nil, UNKNOWN_ERROR);
            }
        }];
    }
}

- (void)timelineForUserID:(int)userID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion {
    
    if (userID < 1) {
        completion(nil, BAD_REQUEST);
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
        [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"forUserID"];
        [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
        [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
        
        [httpClient POST:@"getTimeline" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *rawPosts = [responseObject objectForKey:@"items"];
            
            NSMutableArray *posts = [NSMutableArray arrayWithCapacity:rawPosts.count];
            for (NSDictionary *rawPost in rawPosts) {
                WLIPost *post = [[WLIPost alloc] initWithDictionary:rawPost];
                [posts addObject:post];
            }
            
            [self debugger:parameters.description methodLog:@"api/getTimeline" dataLogFormatted:responseObject];
            completion(posts, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/getTimeline" dataLog:error.description];
            completion(nil, UNKNOWN_ERROR);
        }];
    }
}

- (void)usersAroundLatitude:(float)latitude longitude:(float)longitude distance:(float)distance page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *users, ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%f", latitude] forKey:@"latitude"];
    [parameters setObject:[NSString stringWithFormat:@"%f", longitude] forKey:@"longitude"];
    [parameters setObject:[NSString stringWithFormat:@"%f", distance] forKey:@"distance"];
    [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
    
    [httpClient POST:@"getLocationsForLatLong" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawUsers = [responseObject objectForKey:@"items"];
        
        NSMutableArray *users = [NSMutableArray arrayWithCapacity:rawUsers.count];
        for (NSDictionary *rawUser in rawUsers) {
            WLIUser *user = [[WLIUser alloc] initWithDictionary:rawUser];
            [users addObject:user];
        }
        
        [self debugger:parameters.description methodLog:@"api/getLocationsForLatLong" dataLogFormatted:responseObject];
        completion(users, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getLocationsForLatLong" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
}


#pragma mark - posts

- (void)sendPostWithTitle:(NSString*)postTitle postKeywords:(NSArray*)postKeywords postImage:(UIImage*)postImage onCompletion:(void (^)(WLIPost *post, ServerResponse serverResponseCode))completion {
    
    if (!postTitle.length && !postImage) {
        completion(nil, BAD_REQUEST);
    } else {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
        [parameters setObject:postTitle forKey:@"postTitle"];
        
        [httpClient POST:@"sendPost" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (postImage) {
                NSData *imageData = UIImageJPEGRepresentation(postImage, kCompressionQuality);
                if (imageData) {
                    [formData appendPartWithFileData:imageData name:@"postImage" fileName:@"image.jpg" mimeType:@"image/jpeg"];
                }
            }
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawPost = [responseObject objectForKey:@"item"];
            WLIPost *post = [[WLIPost alloc] initWithDictionary:rawPost];
            
            [self debugger:parameters.description methodLog:@"api/sendPost" dataLogFormatted:responseObject];
            completion(post, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/sendPost" dataLog:error.description];
            completion(nil, UNKNOWN_ERROR);
        }];
        
        /*
        [httpClient POST:@"api/sendPost" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *rawPost = [responseObject objectForKey:@"item"];
            WLIPost *post = [[WLIPost alloc] initWithDictionary:rawPost];
            
            [self debugger:parameters.description methodLog:@"api/sendPost" dataLogFormatted:responseObject];
            completion(post, OK);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self debugger:parameters.description methodLog:@"api/sendPost" dataLog:error.description];
            completion(nil, UNKNOWN_ERROR);
        }];
         */
    }
}

- (void)recentPostsWithPageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion {
    
    FitovateData *myData = [FitovateData sharedFitovateData];
    PFQuery *query = [PFQuery queryWithClassName:@"FitovatePhotos"];
    [query orderByDescending:@"createdAt"];
    query.limit = 15;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *temp = [NSMutableArray arrayWithCapacity:objects.count];
            for(PFObject *object in objects){
                PFFile *tempPhotoForUrl = object[@"userImage"];
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:  object[@"postID"], @"postID",
                                      object[@"postTitle"], @"postTitle",
                                      tempPhotoForUrl.url, @"postImage",
                                      object[@"createdAt"], @"postDate",
                                      object[@"createdAt"], @"timeAgo",
                                      [[NSDictionary alloc]init], @"user",
                                      [object[@"totalLikes"] integerValue], @"totalLikes",
                                      [object[@"totalComments"] integerValue], @"totalComments",
                                      object[@"isLiked"], @"isLiked",
                                      object[@"isCommented"], @"isCommented"
                                      , nil];
                WLIPost *postFromParse = [[WLIPost alloc]initWithDictionary:dict];
                postFromParse.user = [myData.allUsersDictionary objectForKey:object[@"userID"]];
                postFromParse.postLikesCount = [object[@"totalLikes"] integerValue];
                postFromParse.postCommentsCount = [object[@"totalComments"] integerValue];
                [temp addObject:postFromParse];
            }
            completion(temp, OK);
        } else {
            completion(nil, UNKNOWN_ERROR);
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}

- (void)popularPostsOnPage:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *posts, ServerResponse serverResponseCode))completion {
    
    FitovateData *myData = [FitovateData sharedFitovateData];
    PFQuery *query = [PFQuery queryWithClassName:@"FitovatePhotos"];
    [query orderByDescending:@"totalLikes"];
    query.limit = 15;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *temp = [NSMutableArray arrayWithCapacity:objects.count];
            for(PFObject *object in objects){
            
            PFFile *tempPhotoForUrl = object[@"userImage"];
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:  object[@"postID"], @"postID",
                                  object[@"postTitle"], @"postTitle",
                                  tempPhotoForUrl.url, @"postImage",
                                  object[@"createdAt"], @"postDate",
                                  object[@"createdAt"], @"timeAgo",
                                  [[NSDictionary alloc]init], @"user",
                                  [object[@"totalLikes"] integerValue], @"totalLikes",
                                  [object[@"totalComments"] integerValue], @"totalComments",
                                  object[@"isLiked"], @"isLiked",
                                  object[@"isCommented"], @"isCommented"
                                  , nil];
            WLIPost *postFromParse = [[WLIPost alloc]initWithDictionary:dict];
            postFromParse.user = [myData.allUsersDictionary objectForKey:object[@"userID"]];
                postFromParse.postLikesCount = [object[@"totalLikes"] integerValue];
            postFromParse.postCommentsCount = [object[@"totalComments"] integerValue];
                
                NSLog(@"%d is likes amount",postFromParse.postLikesCount);
            [temp addObject:postFromParse];
            }
            completion(temp, OK);
        } else {
            completion(nil, UNKNOWN_ERROR);
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


#pragma mark - comments

- (void)sendCommentOnPostID:(int)postID withCommentText:(NSString*)commentText onCompletion:(void (^)(WLIComment *comment, ServerResponse serverResponseCode))completion {
    
    FitovateData *myData = [FitovateData sharedFitovateData];
    [myData commentFromUserIdWithPostId:[NSNumber numberWithInt:myData.currentUser.userID] :[NSNumber numberWithInt:postID] :commentText :^(WLIComment *comment) {
        completion(comment, OK);
    }];
}

- (void)removeCommentWithCommentID:(int)commentID onCompletion:(void (^)(ServerResponse serverResponseCode))completion {
    PFQuery *unfollowUser = [PFQuery queryWithClassName:@"Comments"];
    [unfollowUser whereKey:@"commentId" equalTo:[NSNumber numberWithInt:commentID]];
    [unfollowUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for(PFObject *object in objects){
                [object deleteInBackground];
                NSLog(@"removed");
                completion(OK);
            }
        }else{
            completion(UNKNOWN_ERROR);
        }
    }];
}



- (void)commentsForPostID:(int)postID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *comments, ServerResponse serverResponseCode))completion {
    
    FitovateData *myData = [FitovateData sharedFitovateData];
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    [query whereKey:@"postId" equalTo:[NSNumber numberWithInt:postID]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *comments = [NSMutableArray arrayWithCapacity:objects.count];
            
            for (PFObject *comment in objects) {
                WLIComment *newComment = [[WLIComment alloc] init];
                NSNumber *commentNumber = comment[@"commentId"];
                newComment.commentID = [commentNumber integerValue];
                newComment.commentDate = comment.createdAt;
                newComment.commentText = comment[@"comment"];
                NSNumber *idOfCommenter = comment[@"commenter"];
                WLIUser *commenterUser = [myData.allUsersDictionary objectForKey:idOfCommenter];
                newComment.user = commenterUser;
                [comments addObject:newComment];
            }
            completion(comments, OK);
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            completion(nil, kUNAUTHORIZED);
        }
    }];

    
    //benmark
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
//    [parameters setObject:[NSString stringWithFormat:@"%d", postID] forKey:@"postID"];
//    [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
//    [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
//    [httpClient POST:@"getComments" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSArray *rawComments = [responseObject objectForKey:@"items"];
//        
//        NSMutableArray *comments = [NSMutableArray arrayWithCapacity:rawComments.count];
//        for (NSDictionary *rawComment in rawComments) {
//            WLIComment *comment = [[WLIComment alloc] initWithDictionary:rawComment];
//            [comments addObject:comment];
//        }
//        
//        [self debugger:parameters.description methodLog:@"api/getComments" dataLogFormatted:responseObject];
//        completion(comments, OK);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [self debugger:parameters.description methodLog:@"api/getComments" dataLog:error.description];
//        completion(nil, UNKNOWN_ERROR);
//    }];
}


#pragma mark - likes

- (void)setLikeOnPostID:(int)postID onCompletion:(void (^)(WLILike *like, ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", postID] forKey:@"postID"];
    [httpClient POST:@"setLike" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rawLike = [responseObject objectForKey:@"item"];
        WLILike *like = [[WLILike alloc] initWithDictionary:rawLike];
        
        [self debugger:parameters.description methodLog:@"api/setLike" dataLogFormatted:responseObject];
        completion(like, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/setLike" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
}

- (void)removeLikeWithLikeID:(int)postID onCompletion:(void (^)(ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", postID] forKey:@"postID"];
    [httpClient POST:@"removeLike" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self debugger:parameters.description methodLog:@"api/removeLike" dataLogFormatted:responseObject];
        completion(OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/removeLike" dataLog:error.description];
        completion(UNKNOWN_ERROR);
    }];
}

- (void)likesForPostID:(int)postID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *likes, ServerResponse serverResponseCode))completion {
    
    
    FitovateData *myData = [FitovateData sharedFitovateData];
    PFQuery *query = [PFQuery queryWithClassName:@"Likes"];
    [query whereKey:@"postId" equalTo:[NSNumber numberWithInt:postID]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *likes = [NSMutableArray arrayWithCapacity:objects.count];
            
            for (PFObject *like in objects) {
                WLILike *newLike = [[WLILike alloc] init];
                NSNumber *commentNumber = like[@"postId"];
                newLike.likeID = [commentNumber integerValue];
                //newComment.commentDate = comment.createdAt;
                NSNumber *idOfCommenter = like[@"liker"];
                WLIUser *commenterUser = [myData.allUsersDictionary objectForKey:idOfCommenter];
                newLike.user = commenterUser;
                [likes addObject:newLike];
            }
            completion(likes, OK);
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            completion(nil, kUNAUTHORIZED);
        }
    }];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", postID] forKey:@"postID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [parameters setObject:[NSString stringWithFormat:@"%d", pageSize] forKey:@"take"];
    [httpClient POST:@"getLikes" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *rawLikes = [responseObject objectForKey:@"items"];
        
        NSMutableArray *likes = [NSMutableArray arrayWithCapacity:rawLikes.count];
        for (NSDictionary *rawLike in rawLikes) {
            WLILike *like = [[WLILike alloc] initWithDictionary:rawLike];
            [likes addObject:like];
        }
        
        [self debugger:parameters.description methodLog:@"api/getLikes" dataLogFormatted:responseObject];
        completion(likes, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/getLikes" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
}


#pragma mark - follow

- (void)setFollowOnUserID:(int)userID onCompletion:(void (^)(WLIFollow *follow, ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", userID] forKey:@"followingID"];
    [httpClient POST:@"setFollow" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *rawFollow = [responseObject objectForKey:@"item"];
        WLIFollow *follow = [[WLIFollow alloc] initWithDictionary:rawFollow];
        self.currentUser.followingCount++;
        [self debugger:parameters.description methodLog:@"api/setFollow" dataLogFormatted:responseObject];
        completion(follow, OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/setFollow" dataLog:error.description];
        completion(nil, UNKNOWN_ERROR);
    }];
}

- (void)removeFollowWithFollowID:(int)followID onCompletion:(void (^)(ServerResponse serverResponseCode))completion {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[NSString stringWithFormat:@"%d", self.currentUser.userID] forKey:@"userID"];
    [parameters setObject:[NSString stringWithFormat:@"%d", followID] forKey:@"followingID"];
    [httpClient POST:@"removeFollow" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSDictionary *rawFollow = [responseObject objectForKey:@"item"];
        //WLIFollow *follow = [[WLIFollow alloc] initWithDictionary:rawFollow];
        self.currentUser.followingCount--;
        [self debugger:parameters.description methodLog:@"api/removeFollow" dataLogFormatted:responseObject];
        completion(OK);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self debugger:parameters.description methodLog:@"api/removeFollow" dataLog:error.description];
        completion(UNKNOWN_ERROR);
    }];
}

- (void)followersForUserID:(int)userID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *followers, ServerResponse serverResponseCode))completion {
    
    if (userID < 1) {
        completion(nil, BAD_REQUEST);
    } else {
        NSMutableArray *idsOfUsersFollowing = [[NSMutableArray alloc] init];
        
        PFQuery *getFollowings = [PFQuery queryWithClassName:@"Follows"];
        [getFollowings whereKey:@"following" equalTo:[NSNumber numberWithInt:userID]];
        [getFollowings findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                for(PFObject *object in objects){
                    NSNumber *followingId = object[@"follower"];
                    [idsOfUsersFollowing addObject:followingId];
                }
                FitovateData *myData = [FitovateData sharedFitovateData];
                PFQuery *query = [PFQuery queryWithClassName:@"Users"];
                [query whereKey:@"userID" containedIn:idsOfUsersFollowing];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (!error) {
                        NSMutableArray *users = [NSMutableArray arrayWithCapacity:objects.count];
                        for (PFObject *loggedInUserParse in objects) {
                            WLIUser *currUser = [myData pfobjectToWLIUser:loggedInUserParse];
                            [users addObject:currUser];
                        }
                        completion(users, OK);
                    } else {
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                        completion(nil,UNKNOWN_ERROR);
                    }
                }];
                
            }else{
                NSLog(@"error getting ids that users following");
                completion(nil,UNKNOWN_ERROR);
            }
        }];
    }
}

- (void)followingForUserID:(int)userID page:(int)page pageSize:(int)pageSize onCompletion:(void (^)(NSMutableArray *following, ServerResponse serverResponseCode))completion {
    
    if (userID < 1) {
        completion(nil, BAD_REQUEST);
    } else {
    NSMutableArray *idsOfUsersFollowing = [[NSMutableArray alloc] init];
    
    PFQuery *getFollowings = [PFQuery queryWithClassName:@"Follows"];
    [getFollowings whereKey:@"follower" equalTo:[NSNumber numberWithInt:userID]];
    [getFollowings findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            for(PFObject *object in objects){
                NSNumber *followingId = object[@"following"];
                [idsOfUsersFollowing addObject:followingId];
                NSLog(@" follwing id = %@",followingId);
            }
            FitovateData *myData = [FitovateData sharedFitovateData];
            PFQuery *query = [PFQuery queryWithClassName:@"Users"];
            [query whereKey:@"userID" containedIn:idsOfUsersFollowing];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    NSMutableArray *users = [NSMutableArray arrayWithCapacity:objects.count];
                    for (PFObject *loggedInUserParse in objects) {
                        WLIUser *currUser = [myData pfobjectToWLIUser:loggedInUserParse];
                        [users addObject:currUser];
                        NSLog(@" follwing name = %@",currUser.userUsername);
                    }
                    completion(users, OK);
                } else {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                    completion(nil,UNKNOWN_ERROR);
                }
            }];
            
        }else{
            NSLog(@"error getting ids that users following");
            completion(nil,UNKNOWN_ERROR);
        }
    }];
    }
}

- (void)logout {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation removeObject:_currentUser.userUsername forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    [self removeCurrentUser];
    [self.layerClient disconnect];
    [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"deuathenticated");
    }];
}

#pragma mark - debugger

- (void)debugger:(NSString *)post methodLog:(NSString *)method dataLog:(NSString *)data {
    
    #ifdef DEBUG
        NSLog(@"\n\nmethod: %@ \n\nparameters: %@ \n\nresponse: %@\n", method, post, (NSDictionary *) [json objectWithString:data]);
    #else
    #endif
}

- (void)debugger:(NSString *)post methodLog:(NSString *)method dataLogFormatted:(NSString *)data {
    
    #ifdef DEBUG
        NSLog(@"\n\nmethod: %@ \n\nparameters: %@ \n\nresponse: %@\n", method, post, data);
    #else
#endif
}
- (void)authenticateLayerWithUserID:(NSString *)userID completion:(void (^)(BOOL success, NSError * error))completion
{
    // If the user is authenticated you don't need to re-authenticate.
    if (self.layerClient.authenticatedUserID) {
        if ([self.layerClient.authenticatedUserID isEqualToString:_currentUser.userUsername]){
            NSLog(@"Layer Authenticated as previously User %@", self.layerClient.authenticatedUserID);
            if (completion) completion(YES, nil);
            return;
        }else {
            //If the authenticated userID is different, then deauthenticate the current client and re-authenticate with the new userID.
            [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
                if (!error){
                    
                    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
                        NSLog(@"Authentication nonce %@", nonce);
                        
                        // Upon reciept of nonce, post to your backend and acquire a Layer identityToken
                        if (nonce) {
                            //            PFUser *user = [PFUser currentUser];
                            //            NSString *userID  = user.objectId;
                            [PFCloud callFunctionInBackground:@"generateToken"
                                               withParameters:@{@"nonce" : nonce,
                                                                @"userID" : userID}
                                                        block:^(NSString *token, NSError *error) {
                                                            if (!error) {
                                                                // Send the Identity Token to Layer to authenticate the user
                                                                [self.layerClient authenticateWithIdentityToken:token completion:^(NSString *authenticatedUserID, NSError *error) {
                                                                    if (!error) {
                                                                        NSLog(@"Parse User authenticated with Layer Identity Token");
                                                                        
                                                                    }
                                                                    else{
                                                                        NSLog(@"Parse User failed to authenticate with token with error: %@", error);
                                                                    }
                                                                }];
                                                            }
                                                            else{
                                                                NSLog(@"Parse Cloud function failed to be called to generate token with error: %@", error);
                                                            }
                                                        }];
                        }
                    }];
                    
                } else {
                    if (completion){
                        completion(NO, error);
                    }
                }
            }];
        }
    }else{
    
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        NSLog(@"Authentication nonce %@", nonce);
        
        // Upon reciept of nonce, post to your backend and acquire a Layer identityToken
        if (nonce) {
//            PFUser *user = [PFUser currentUser];
//            NSString *userID  = user.objectId;
            [PFCloud callFunctionInBackground:@"generateToken"
                               withParameters:@{@"nonce" : nonce,
                                                @"userID" : userID}
                                        block:^(NSString *token, NSError *error) {
                                            if (!error) {
                                                // Send the Identity Token to Layer to authenticate the user
                                                [self.layerClient authenticateWithIdentityToken:token completion:^(NSString *authenticatedUserID, NSError *error) {
                                                    if (!error) {
                                                        NSLog(@"Parse User authenticated with Layer Identity Token");
                                                    }
                                                    else{
                                                        NSLog(@"Parse User failed to authenticate with token with error: %@", error);
                                                    }
                                                }];
                                            }
                                            else{
                                                NSLog(@"Parse Cloud function failed to be called to generate token with error: %@", error);
                                            }
                                        }];
        }
    }];
    }
}
//- (void)requestIdentityTokenForUserID:(NSString *)userID appID:(NSString *)appID nonce:(NSString *)nonce completion:(void(^)(NSString *identityToken, NSError *error))completion
//{
//    NSString *identityToken = [NSString stringWithFormat:@"%@%d",_currentUser.userUsername, _currentUser.userID];
//    completion(identityToken, nil);
//}


@end
