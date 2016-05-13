//
//  ASLLogger.m
//  PinpointKit
//
//  Created by Andrew Harrison on 4/9/16.
//  Copyright © 2016 Lickability. All rights reserved.
//

#import "ASLLogger.h"
#import <asl.h>

@implementation ASLLogger

- (NSArray<NSString *> *)retrieveLogs {
    NSMutableArray<NSString *> *logs = [NSMutableArray array];
    
    aslmsg query = NULL, message = NULL;
    aslresponse response = NULL;
    
    query = asl_new(ASL_TYPE_QUERY);
    asl_set_query(query, ASL_KEY_FACILITY, [[[NSBundle mainBundle] bundleIdentifier] UTF8String], ASL_QUERY_OP_EQUAL);
    
    response = asl_search(NULL, query);
    
    pid_t myPID = getpid();
    
    while ((message = asl_next(response)) != NULL) {
        
        if (myPID != atol(asl_get(message, ASL_KEY_PID))) {
            continue;
        }
        
        const char *content = asl_get(message, ASL_KEY_MSG);
        NSTimeInterval msgTime = (NSTimeInterval) atol(asl_get(message, ASL_KEY_TIME)) + ((NSTimeInterval) atol(asl_get(message, ASL_KEY_TIME_NSEC)) / 1000000000.0);
        
        NSString *contentString = [[NSString alloc] initWithUTF8String:content];
        NSString *timeString = [self stringFromTimeInterval:msgTime];
        NSString *loggedText = [NSString stringWithFormat:@"%@ %@", timeString, contentString];
        
        [logs addObject:loggedText];
    }
    
    asl_release(response);
    asl_free(query);
    
    return logs;
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

@end
