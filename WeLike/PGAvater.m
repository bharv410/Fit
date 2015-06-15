//
//  PGAvater.m
//  Fitovate
//
//  Created by Benjamin Harvey on 6/14/15.
//  Copyright (c) 2015 Goran Vuksic. All rights reserved.
//

#import "PGAvater.h"

@implementation PGAvater
- (id) initWithImagePath: (NSString *)imagePath{
    _avatarImageURL = [NSURL URLWithString:imagePath];
    return self;
}
@end
