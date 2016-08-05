//
//  ASLLogger.m
//  PinpointKit
//
//  Created by Andrew Harrison on 4/9/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

#import "ASLLogger.h"
#import <asl.h>

@interface ASLLogger ()

@property (nonatomic, nullable) NSString *bundleIdentifier;
@property (nonatomic, nullable) NSString *senderName;
@property (nonatomic) NSDate *logDate;

@end

@implementation ASLLogger

- (instancetype)initWithBundleIdentifier:(NSString *)bundleIdentifier {
    self = [super init];
    
    _bundleIdentifier = bundleIdentifier;
    [self commonInitialization];
    
    return self;
}

- (instancetype)initWithSenderName:(NSString *)senderName {
    self = [super init];
    
    _senderName = senderName;
    [self commonInitialization];
    
    return self;
}

- (void)commonInitialization {
    _logDate = [NSDate date];
}

- (NSArray<NSString *> *)retrieveLogs {
    NSMutableArray<NSString *> *logs = [NSMutableArray array];
    
    aslmsg query = NULL, message = NULL;
    aslresponse response = NULL;
    
    query = asl_new(ASL_TYPE_QUERY);
    
    if (self.bundleIdentifier) {
        asl_set_query(query, ASL_KEY_FACILITY, self.bundleIdentifier.UTF8String, ASL_QUERY_OP_EQUAL);
    } else if (self.senderName) {
        asl_set_query(query, ASL_KEY_SENDER, self.senderName.UTF8String, ASL_QUERY_OP_EQUAL);
    }

    response = asl_search(NULL, query);
    
    pid_t myPID = getpid();
    
    while ((message = asl_next(response)) != NULL) {
        
        if (myPID != atol(asl_get(message, ASL_KEY_PID))) {
            continue;
        }
        
        const char *content = asl_get(message, ASL_KEY_MSG);
        NSTimeInterval msgTime = (NSTimeInterval) atol(asl_get(message, ASL_KEY_TIME)) + ((NSTimeInterval) atol(asl_get(message, ASL_KEY_TIME_NSEC)) / 1000000000.0);
        
        if (self.logDate.timeIntervalSince1970 < msgTime) {
            NSString *contentString = [[NSString alloc] initWithUTF8String:content];
            NSString *timeString = [self stringFromTimeInterval:msgTime];
            NSString *loggedText = [NSString stringWithFormat:@"%@ %@", timeString, contentString];
            
            [logs addObject:loggedText];
        }
    }
    
    asl_release(response);
    asl_free(query);
    
    return logs;
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    char fdate[24];
    time_t timestamp = (time_t)interval;
    struct tm *lt = localtime(&timestamp);
    strftime(fdate, 24, "%B %d %T", lt);
    
    return [NSString stringWithFormat:@"%s", fdate];
}

@end
