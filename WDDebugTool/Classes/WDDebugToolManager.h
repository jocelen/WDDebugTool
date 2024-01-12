//
//  WDDebugToolManager.h
//  WDDebugTool
//
//  Created by jocelen on 2024/1/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_OPTIONS(NSUInteger, DebugToolType) {
    DebugToolTypeFPS    = 1 << 0,
    DebugToolTypeCPU    = 1 << 1,
    DebugToolTypeMemory = 1 << 2,
    DebugToolTypeAll    = (DebugToolTypeFPS | DebugToolTypeCPU | DebugToolTypeMemory)
};

@interface WDDebugToolManager : NSObject

/** switch on/off */
+ (void)toggleWith:(DebugToolType)type;

+ (void)showWith:(DebugToolType)type;

+ (void)hide;


+ (instancetype)sharedInstance;

- (void)toggleWith:(DebugToolType)type;

- (void)showWith:(DebugToolType)type;

- (void)hide;

@end


NS_ASSUME_NONNULL_END
