//
//  WDDebugConsoleLabel.h
//  WDDebugTool
//
//  Created by jocelen on 2024/1/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DebugToolLabelType) {
    DebugToolLabelTypeFPS,
    DebugToolLabelTypeMemory,
    DebugToolLabelTypeCPU
};

@interface WDDebugConsoleLabel : UILabel

- (void)updateLabelWith:(DebugToolLabelType)labelType value:(float)value;

@end

NS_ASSUME_NONNULL_END
