//
//  WDDebugTempController.h
//  WDDebugTool
//
//  Created by jocelen on 2024/1/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WDDebugTempController : UIViewController

@property (nonatomic, copy, nullable) void(^safeAreaInsetsDidChangeBlock)(UIEdgeInsets safeAreaInsets);

@end

NS_ASSUME_NONNULL_END
