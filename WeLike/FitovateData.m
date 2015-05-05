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

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
