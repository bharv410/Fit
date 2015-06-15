//
//  PGAvater.h
//  Fitovate
//
//  Created by Benjamin Harvey on 6/14/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Atlas/Atlas.h>

@interface PGAvater : NSObject <ATLAvatarItem>
@property (nonatomic, readonly) NSURL *avatarImageURL;
- (id) initWithImagePath: (NSString *)imagePath;
@end
