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

@property (nonatomic) NSMutableArray *logs;

@end

@implementation ASLLogger

- (void)updateLogs {
    if (!_logs) {
        _logs = [NSMutableArray array];
    }
    
    // This 10 is an offset so that logs get picked up.
    int _lastTime = (int)[NSDate date].timeIntervalSince1970 - 10;
    
    aslmsg query = NULL, message = NULL;
    aslresponse response = NULL;
    
    query = asl_new(ASL_TYPE_QUERY);
    const char *time = [[NSString stringWithFormat:@"%d", _lastTime] UTF8String];
    asl_set_query(query, ASL_KEY_TIME, time, ASL_QUERY_OP_GREATER | ASL_QUERY_OP_NUMERIC);
    asl_set_query(query, ASL_KEY_FACILITY, [[[NSBundle mainBundle] bundleIdentifier] UTF8String], ASL_QUERY_OP_EQUAL);
    
    response = asl_search(NULL, query);
    while (NULL != (message = asl_next(response))) {
        const char *content = asl_get(message, ASL_KEY_MSG);
        const char *time = asl_get(message, ASL_KEY_TIME);
        _lastTime = atoi(time);
        
        [self.logs addObject:[[NSString alloc] initWithUTF8String:content]];
    }
    
    asl_release(response);
    asl_free(query);
}

@end
