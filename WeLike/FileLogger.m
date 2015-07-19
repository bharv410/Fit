//
//  FileLogger.m
//  ooVooSample
//
//  Created by Anton Ianovski on 7/28/14.
//  Copyright (c) 2014 ooVoo. All rights reserved.
//

#import "FileLogger.h"
#import <Foundation/NSFileHandle.h>
//#import "ooVooController.h"
#import <ooVooSDK-iOS/ooVooSDK-iOS.h>

@interface FileLogger()
{
//@property (nonatomic) NSFileHandle *mLogFile;
    
    NSFileHandle *mLogFile;
}

- (id) init;
- (void) dealloc;

- (void) createLogFile;

- (void) logFatal: (NSString*)message;
- (void) logTrace: (NSString*)message;
- (void) logError: (NSString*)message;
- (void) logWarning: (NSString*)message;
- (void) logInfo: (NSString*)message;
- (void) logDebug: (NSString*)message;

- (void) writeLogToFile: (NSString*)message;

@end


@implementation FileLogger

-(id) init
{
    if (self = [super init]) {
        
        mLogFile = nil;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnLog:) name:OOVOOLogNotification object:nil];
    }
    
    return self;
}

+(FileLogger *) sharedInstance
{
    static FileLogger *instance = nil;
    if (instance == nil) {
        instance = [[FileLogger alloc] init];
    }
    
    return instance;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OOVOOLogNotification object:nil];
}

-(void) createLogFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    if (paths != nil && [paths count] > 0) {
        NSString *documentsDirectory = [paths firstObject];
        
        if (documentsDirectory != nil) {
            
            NSString *logFilesFolder = [documentsDirectory stringByAppendingString:@"/Logs"];
            
            NSFileManager* fileManager = [NSFileManager defaultManager];
            
            BOOL isFolderExists = [fileManager fileExistsAtPath:logFilesFolder];
            
            if (!isFolderExists){
                NSError *createDirError = nil;
                BOOL isDirCreatedSuccess = [fileManager createDirectoryAtPath:logFilesFolder withIntermediateDirectories:NO attributes:nil error:&createDirError];
                if (!isDirCreatedSuccess){
                    NSLog(@"Failed to create directory %@ with the error: %@", logFilesFolder, [createDirError localizedDescription]);
                    return;
                }
            }
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd-MM-yyyy"];
            
            NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
            [timeFormat setDateFormat:@"HH.mm.ss.SSS"];
            
            NSDate *now = [NSDate date];
            
            NSString *theDate = [dateFormat stringFromDate:now];
            NSString *theTime = [timeFormat stringFromDate:now];
            
            NSString *filePath = [logFilesFolder stringByAppendingString:[NSString stringWithFormat:@"/ooVooSampleLogFile_%@_%@.txt", theDate, theTime]];

            BOOL isFileExists = [fileManager fileExistsAtPath:filePath];
            
            if (!isFileExists) {
                BOOL isFileCreated = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
                
                if (isFileCreated) {
                    mLogFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
                }
                else{
                    NSLog(@"Failed to create file: %@ %s", filePath, strerror(errno));
                }
            }
        }
        
    }
}

- (void) logFatal: (NSString*)message
{
    NSString *logMsg = [NSString stringWithFormat:@"[FATAL  ] %@", message];
    NSLog(@"%@", logMsg);
    [self writeLogToFile:logMsg];
}

- (void) logError: (NSString*)message
{
    NSString *logMsg = [NSString stringWithFormat:@"[ERROR  ] %@", message];
    NSLog(@"%@", logMsg);
    [self writeLogToFile:logMsg];
}

- (void) logWarning: (NSString*)message
{
    NSString *logMsg = [NSString stringWithFormat:@"[WARNING] %@", message];
    NSLog(@"%@", logMsg);
    [self writeLogToFile:logMsg];
}

- (void) logInfo: (NSString*)message
{
    NSString *logMsg = [NSString stringWithFormat:@"[INFO   ] %@", message];
    NSLog(@"%@", logMsg);
    [self writeLogToFile:logMsg];
}

- (void) logTrace: (NSString*)message
{
    NSString *logMsg = [NSString stringWithFormat:@"[TRACE  ] %@", message];
    NSLog(@"%@", logMsg);
    [self writeLogToFile:logMsg];
}

- (void) logDebug: (NSString*)message
{
    NSString *logMsg = [NSString stringWithFormat:@"[DEBUG  ] %@", message];
    NSLog(@"%@", logMsg);
    [self writeLogToFile:logMsg];
}

- (void) writeLogToFile: (NSString*)message
{
    if (mLogFile == nil) {
        return;
    }
    
    static NSDateFormatter *sDateTimeFormatter = nil;

    if (sDateTimeFormatter == nil){
        sDateTimeFormatter = [[NSDateFormatter alloc] init];
        [sDateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    }
    
    NSString *currentDateTime = [sDateTimeFormatter stringFromDate:[NSDate date]];
    
    NSString *logMsgLine = [NSString stringWithFormat:@"%@ %@\n", currentDateTime, message];
    
    [mLogFile writeData:[logMsgLine dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) PrintLog:(ooVooLoggerLevel)level WithContent:(NSString *)message
{
    if (mLogFile == nil)
    {
        [self createLogFile];
    }
    
    switch (level)
    {
        case ooVooFatal:
            [self logFatal:message];
            break;
            
        case ooVooError:
            [self logError:message];
            break;
            
        case ooVooWarning:
            [self logWarning:message];
            break;
            
        case ooVooInfo:
            [self logInfo:message];
            break;
            
        case ooVooTrace:
            [self logTrace:message];
            break;
            
        case ooVooDebug:
        default:
            [self logDebug:message];
            break;
    }
}

-(void) OnLog:(NSNotification *)notification
{
    NSString *message = [notification.userInfo objectForKey:OOVOOLogKey];
    NSNumber *level = [notification.userInfo objectForKey:OOVOOLogLevelKey];
    
    [self PrintLog:[level integerValue] WithContent:message];
}

@end
