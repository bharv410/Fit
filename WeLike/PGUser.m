//
//  PGUser.m
//  Fitovate
//
//  Created by Benjamin Harvey on 6/14/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import "PGUser.h"
#import "FitovateData.h"
#import <Parse/Parse.h>
#import "WLIUser.h"


@implementation PGUser

- (instancetype)initWithParticipantIdentifier:(NSString *)participantIdentifier {
    self = [super init];
    if (self) {
        _participantIdentifier = participantIdentifier;
        FitovateData *myData = [FitovateData sharedFitovateData];
        PFQuery *query = [PFQuery queryWithClassName:@"Users"];
        [query whereKey:@"username" equalTo:participantIdentifier];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *loggedInUserParse in objects) {
                    WLIUser *currentUser = [myData pfobjectToWLIUser:loggedInUserParse];
                    NSArray *ar=[currentUser.userFullName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    
                    NSString *firstName=[ar firstObject];
                    NSMutableString *rest= [[NSMutableString alloc] init];
                    for(int i=0; i<ar.count; i++)
                    {
                        [rest appendString:[ar objectAtIndex:i]];
                        [rest appendString:@" "];
                    };
                    
                    
                    _firstName = firstName;
                    _lastName = rest;
                    _fullName = currentUser.userFullName;
                    _avatarInitials = [currentUser.userFullName substringToIndex:1];
                    
                }
            }
        }];
    }
    
    return self;
}

+ (instancetype)userWithParticipantIdentifier:(NSString *)participantIdentifier {
    return [[self alloc] initWithParticipantIdentifier:participantIdentifier];
}

@end
