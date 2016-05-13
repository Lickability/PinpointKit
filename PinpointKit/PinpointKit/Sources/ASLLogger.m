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
    
    long lastTime = 0;
    
    aslmsg query = NULL, message = NULL;
    aslresponse response = NULL;
    
    query = asl_new(ASL_TYPE_QUERY);
    const char *time = [[NSString stringWithFormat:@"%ld", lastTime] UTF8String];
    asl_set_query(query, ASL_KEY_TIME, time, ASL_QUERY_OP_GREATER | ASL_QUERY_OP_NUMERIC);
    asl_set_query(query, ASL_KEY_FACILITY, [[[NSBundle mainBundle] bundleIdentifier] UTF8String], ASL_QUERY_OP_EQUAL);
    
    response = asl_search(NULL, query);
    
    pid_t myPID = getpid();
    
    while ((message = asl_next(response)) != NULL) {
        
        if (myPID != atol(asl_get(message, ASL_KEY_PID))) {
            continue;
        }
        
        const char *content = asl_get(message, ASL_KEY_MSG);
        const char *time = asl_get(message, ASL_KEY_TIME);
        lastTime = atoi(time);
        
        [logs addObject:[[NSString alloc] initWithUTF8String:content]];
    }
    
    asl_release(response);
    asl_free(query);
    
    return logs;
}

@end
