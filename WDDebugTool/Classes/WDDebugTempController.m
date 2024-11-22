//
//  WDDebugTempController.m
//  WDDebugTool
//
//  Created by jocelen on 2024/1/11.
//

#import "WDDebugTempController.h"

@interface WDDebugTempController ()
//window安全距离
@property (nonatomic, assign) UIEdgeInsets windowSafeAreaInsets;
@end

@implementation WDDebugTempController

- (BOOL)prefersStatusBarHidden {
    return NO;
}

-(void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    UIEdgeInsets safeAreaInsets = [[UIApplication sharedApplication] delegate].window.safeAreaInsets;
    if (!UIEdgeInsetsEqualToEdgeInsets(safeAreaInsets, _windowSafeAreaInsets)) {
        if (_safeAreaInsetsDidChangeBlock != nil) _safeAreaInsetsDidChangeBlock(safeAreaInsets);
        _windowSafeAreaInsets = safeAreaInsets;
    }
}

@end
