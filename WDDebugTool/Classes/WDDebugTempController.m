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
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                for (UIWindow *win in ((UIWindowScene *)scene).windows) {
                    if (win != self.view.window && !UIEdgeInsetsEqualToEdgeInsets(win.safeAreaInsets, UIEdgeInsetsZero)) {
                        safeAreaInsets = win.safeAreaInsets;
                        break;
                    }
                }
                if (!UIEdgeInsetsEqualToEdgeInsets(safeAreaInsets, UIEdgeInsetsZero)) break;
            }
        }
    }
    if (UIEdgeInsetsEqualToEdgeInsets(safeAreaInsets, UIEdgeInsetsZero)) {
        safeAreaInsets = [[UIApplication sharedApplication] delegate].window.safeAreaInsets;
    }
    if (!UIEdgeInsetsEqualToEdgeInsets(safeAreaInsets, _windowSafeAreaInsets)) {
        if (_safeAreaInsetsDidChangeBlock != nil) _safeAreaInsetsDidChangeBlock(safeAreaInsets);
        _windowSafeAreaInsets = safeAreaInsets;
    }
}

@end
