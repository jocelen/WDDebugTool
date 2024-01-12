//
//  WDDebugMonitor.h
//  WDDebugTool
//
//  Created by jocelen on 2024/1/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define WHSingletonH() +(instancetype)sharedInstance;
#define WHSingletonM() static id _instance;\
+ (instancetype)sharedInstance {\
    static dispatch_once_t onceToken;\
    dispatch_once(&onceToken, ^{\
        _instance = [[self alloc] init];\
    });\
    return _instance;\
}

typedef void(^UpdateValueBlock)(float value);

@interface WDDebugMonitor : NSObject

WHSingletonH()

- (void)startMonitoring;

- (void)stopMonitoring;

@property (nonatomic, copy) UpdateValueBlock valueBlock;

@end

NS_ASSUME_NONNULL_END
