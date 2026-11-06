//
//  WDDebugToolManager.m
//  WDDebugTool
//
//  Created by jocelen on 2024/1/11.
//

#import "WDDebugToolManager.h"
#import "WDDebugFPSMonitor.h"
#import "WDDebugCpuMonitor.h"
#import "WDDebugMemoryMonitor.h"
#import "WDDebugConsoleLabel.h"
#import "WDDebugTempController.h"

static NSInteger const kDebugLabelWidth = 70;
static NSInteger const kDebugLabelHeight = 20;
static NSInteger const KDebugMargin = 20;
static NSInteger const KDebugWindowWidth = kDebugLabelWidth*3 + KDebugMargin*2;

@interface WDDebugToolManager()
@property (nonatomic, assign) BOOL isShowing;
@property(nonatomic, strong) UIWindow *debugWindow;
@property (nonatomic, strong) WDDebugConsoleLabel *memoryLabel;
@property (nonatomic, strong) WDDebugConsoleLabel *fpsLabel;
@property (nonatomic, strong) WDDebugConsoleLabel *cpuLabel;
@end

@implementation WDDebugToolManager

static id _instance;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - Class function

+ (void)toggleWith:(DebugToolType)type {
    [[self sharedInstance] toggleWith:type];
}

+ (void)showWith:(DebugToolType)type {
    [[self sharedInstance] showWith:type];
}

+ (void)hide {
    [[self sharedInstance] hide];
}

#pragma mark - Show with type

- (void)toggleWith:(DebugToolType)type {
    if (self.isShowing) {
        [self hide];
    } else {
        [self showWith:type];
    }
}

- (void)showWith:(DebugToolType)type {
    [self clearUp];
    [self setDebugWindow];
    
    if (type & DebugToolTypeFPS) {
        [self showFPS];
    }
    
    if (type & DebugToolTypeMemory) {
        [self showMemory];
    }
    
    if (type & DebugToolTypeCPU) {
        [self showCPU];
    }
}

#pragma mark - Window

- (UIWindowScene *)activeScene {
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
            return (UIWindowScene *)scene;
        }
    }
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            return (UIWindowScene *)scene;
        }
    }
    return nil;
}

- (void)onSceneActive:(NSNotification *)noti {
    if ([noti.object isKindOfClass:[UIWindowScene class]] && !self.debugWindow.windowScene) {
        UIWindowScene *scene = (UIWindowScene *)noti.object;
        self.debugWindow.windowScene = scene;
        CGFloat screenWidth = scene.coordinateSpace.bounds.size.width;
        CGRect frame = self.debugWindow.frame;
        frame.origin.x = (screenWidth - KDebugWindowWidth) / 2;
        self.debugWindow.frame = frame;
        self.debugWindow.hidden = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UISceneDidActivateNotification object:nil];
    }
}

- (void)setDebugWindow {
    UIWindowScene *scene = [self activeScene];
    self.debugWindow = scene ? [[UIWindow alloc] initWithWindowScene:scene] : [[UIWindow alloc] initWithFrame:CGRectZero];
    CGFloat screenWidth = scene ? scene.coordinateSpace.bounds.size.width : [UIScreen mainScreen].bounds.size.width;
    self.debugWindow.frame = CGRectMake((screenWidth - KDebugWindowWidth) / 2, 20, KDebugWindowWidth, kDebugLabelHeight);
    self.debugWindow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.debugWindow.windowLevel = UIWindowLevelAlert + 1000;
    WDDebugTempController * vc = [WDDebugTempController new];
    /// 更新安全距离
    __weak typeof(self) weakSelf = self;
    vc.safeAreaInsetsDidChangeBlock = ^(UIEdgeInsets safeAreaInsets) {
        CGFloat curWidth = weakSelf.debugWindow.windowScene ? weakSelf.debugWindow.windowScene.coordinateSpace.bounds.size.width : [UIScreen mainScreen].bounds.size.width;
        CGFloat originY = safeAreaInsets.top > 0 ? safeAreaInsets.top - kDebugLabelHeight/2 : kDebugLabelHeight/2;
        weakSelf.debugWindow.frame = CGRectMake((curWidth - KDebugWindowWidth) / 2, originY, KDebugWindowWidth, kDebugLabelHeight);
    };
    self.debugWindow.rootViewController = vc;
    self.debugWindow.hidden = NO;

    if (!self.debugWindow.windowScene) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSceneActive:) name:UISceneDidActivateNotification object:nil];
    }
}

#pragma mark - Show

- (void)showFPS {
    [[WDDebugFPSMonitor sharedInstance] startMonitoring];
    [WDDebugFPSMonitor sharedInstance].valueBlock = ^(float value) {
        [self.fpsLabel updateLabelWith:DebugToolLabelTypeFPS value:value];
    };
    [self show:self.fpsLabel];
}

- (void)showMemory {
    [[WDDebugMemoryMonitor sharedInstance] startMonitoring];
    [WDDebugMemoryMonitor sharedInstance].valueBlock = ^(float value) {
        [self.memoryLabel updateLabelWith:DebugToolLabelTypeMemory value:value];
    };
    [self show:self.memoryLabel];
}

- (void)showCPU {
    [[WDDebugCpuMonitor sharedInstance] startMonitoring];
    [WDDebugCpuMonitor sharedInstance].valueBlock = ^(float value) {
        [self.cpuLabel updateLabelWith:DebugToolLabelTypeCPU value:value];
    };
    [self show:self.cpuLabel];
}

- (void)show:(WDDebugConsoleLabel *)consoleLabel {
    UIView *container = self.debugWindow.rootViewController.view ?: self.debugWindow;
    [container addSubview:consoleLabel];
    CGRect consoleLabelFrame = CGRectZero;
    if (consoleLabel == self.cpuLabel) {
        consoleLabelFrame = CGRectMake((KDebugWindowWidth - kDebugLabelWidth) / 2, 0, kDebugLabelWidth, kDebugLabelHeight);
    } else if (consoleLabel == self.fpsLabel) {
        consoleLabelFrame = CGRectMake((KDebugWindowWidth + kDebugLabelWidth)/2 + KDebugMargin, 0, kDebugLabelWidth, kDebugLabelHeight);
    } else {
        consoleLabelFrame = CGRectMake((KDebugWindowWidth - kDebugLabelWidth) / 2 - KDebugMargin - kDebugLabelWidth, 0, kDebugLabelWidth, kDebugLabelHeight);
    }
    [UIView animateWithDuration:0.3 animations:^{
        consoleLabel.frame = consoleLabelFrame;
    }completion:^(BOOL finished) {
        self.isShowing = YES;
    }];
}

#pragma mark - Hide

- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        self.cpuLabel.frame = CGRectMake((KDebugWindowWidth - kDebugLabelWidth) / 2, -kDebugLabelHeight, kDebugLabelWidth, kDebugLabelHeight);
        self.memoryLabel.frame = CGRectMake(-kDebugLabelWidth, 0, kDebugLabelWidth, kDebugLabelHeight);
        self.fpsLabel.frame = CGRectMake(KDebugWindowWidth + kDebugLabelWidth, 0, kDebugLabelWidth, kDebugLabelHeight);
    }completion:^(BOOL finished) {
        [self clearUp];
    }];
}

#pragma mark - Clear

- (void)clearUp {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UISceneDidActivateNotification object:nil];
    [[WDDebugFPSMonitor sharedInstance] stopMonitoring];
    [[WDDebugMemoryMonitor sharedInstance] stopMonitoring];
    [[WDDebugCpuMonitor sharedInstance] stopMonitoring];
    [self.fpsLabel removeFromSuperview];
    [self.memoryLabel removeFromSuperview];
    [self.cpuLabel removeFromSuperview];
    self.debugWindow.hidden = YES;
    self.fpsLabel = nil;
    self.memoryLabel = nil;
    self.cpuLabel = nil;
    self.debugWindow = nil;
    self.isShowing = NO;
}

#pragma mark - Label

- (WDDebugConsoleLabel *)memoryLabel {
    if (!_memoryLabel) {
        _memoryLabel = [[WDDebugConsoleLabel alloc] initWithFrame:CGRectMake(-kDebugLabelWidth, 0, kDebugLabelWidth, kDebugLabelHeight)];
    }
    return _memoryLabel;
}

-(WDDebugConsoleLabel *)cpuLabel {
    if (!_cpuLabel) {
        _cpuLabel = [[WDDebugConsoleLabel alloc] initWithFrame:CGRectMake((KDebugWindowWidth - kDebugLabelWidth) / 2, -kDebugLabelHeight, kDebugLabelWidth, kDebugLabelHeight)];
    }
    return _cpuLabel;
}

- (WDDebugConsoleLabel *)fpsLabel {
    if (!_fpsLabel) {
        _fpsLabel = [[WDDebugConsoleLabel alloc] initWithFrame:CGRectMake(KDebugWindowWidth + kDebugLabelWidth, 0, kDebugLabelWidth, kDebugLabelHeight)];
    }
    return _fpsLabel;
}

@end
