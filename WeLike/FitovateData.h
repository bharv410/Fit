//
//  FitovateData.h
//  Fitovate
//
//  Created by Benjamin Harvey on 5/3/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <foundation/Foundation.h>
#import "WLIUser.h"

@interface FitovateData : NSObject {
    NSString *someProperty;
}

@property (nonatomic, retain) NSString *someProperty;
@property (nonatomic, retain) NSString *myUsername;
@property (strong, nonatomic) WLIUser *currentUser;

+ (id)sharedFitovateData;

- (void)loginUserWithUsername:(NSString*)username andPassword:(NSString*)password onCompletion:(void (^)(WLIUser *user, BOOL success))completion;


@end