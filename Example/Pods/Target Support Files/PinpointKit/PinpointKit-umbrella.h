#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ASLLogger.h"
#import "PinpointKit.h"

FOUNDATION_EXPORT double PinpointKitVersionNumber;
FOUNDATION_EXPORT const unsigned char PinpointKitVersionString[];

