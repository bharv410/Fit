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

@interface FitovateData : NSObject {
    NSString *someProperty;
}

@property (nonatomic, retain) NSString *someProperty;
@property (nonatomic, retain) NSString *myUsername;
@property (nonatomic, retain) NSMutableDictionary *followingTheseUsers;

+ (id)sharedFitovateData;
- (NSDictionary *) parseUserToDictionary : (PFObject *) userFromParse;
- (WLIUser *) pfobjectToWLIUser : (PFObject *) userFromParse;

@end