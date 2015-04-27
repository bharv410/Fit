//
//  ParseSingleton.h
//  Fitovate
//
//  Created by Benjamin Harvey on 4/27/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseSingleton : NSObject

+ (void)recordActivity:(NSString *)userId forSource:(NSString *)sourceId withActivitytype:(NSString *)activityType withPostId:(NSString *)postId;

@end
