//
//  FileLogger.h
//  ooVooSample
//
//  Created by Anton Ianovski on 7/28/14.
//  Copyright (c) 2014 ooVoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSFileHandle;

@interface FileLogger : NSObject

+(FileLogger *) sharedInstance;

-(void) OnLog:(NSNotification *)notification;

@end
