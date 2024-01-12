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

#import "WDDebugConsoleLabel.h"
#import "WDDebugCpuMonitor.h"
#import "WDDebugFPSMonitor.h"
#import "WDDebugMemoryMonitor.h"
#import "WDDebugMonitor.h"
#import "WDDebugTempController.h"
#import "WDDebugToolManager.h"

FOUNDATION_EXPORT double WDDebugToolVersionNumber;
FOUNDATION_EXPORT const unsigned char WDDebugToolVersionString[];

