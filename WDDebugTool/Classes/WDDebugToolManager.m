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

#define kDebugScreenWidth [UIScreen mainScreen].bounds.size.width

static inline CGFloat debugTool_safeEdgeTopMargin(void) {
    if (@available(iOS 11.0, *))
    {
        return [[UIApplication sharedApplication] delegate].window.safeAreaInsets.top;
    }
    return 0;
}

static NSInteger const kDebugLabelWidth = 70;
static NSInteger const kDebugLabelHeight = 20;
static NSInteger const KDebugMargin = 20;

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

- (void)setDebugWindow {
    self.debugWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, debugTool_safeEdgeTopMargin() - 10, kDebugScreenWidth, kDebugLabelHeight)];
    self.debugWindow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.debugWindow.windowLevel = UIWindowLevelAlert;
    self.debugWindow.rootViewController = [WDDebugTempController new];
    self.debugWindow.hidden = NO;
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
    [self.debugWindow addSubview:consoleLabel];
    CGRect consoleLabelFrame = CGRectZero;
    if (consoleLabel == self.cpuLabel) {
        consoleLabelFrame = CGRectMake((kDebugScreenWidth - kDebugLabelWidth) / 2, 0, kDebugLabelWidth, kDebugLabelHeight);
    } else if (consoleLabel == self.fpsLabel) {
        consoleLabelFrame = CGRectMake((kDebugScreenWidth + kDebugLabelWidth)/2 + KDebugMargin, 0, kDebugLabelWidth, kDebugLabelHeight);
    } else {
        consoleLabelFrame = CGRectMake((kDebugScreenWidth - kDebugLabelWidth) / 2 - KDebugMargin - kDebugLabelWidth, 0, kDebugLabelWidth, kDebugLabelHeight);
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
        self.cpuLabel.frame = CGRectMake((kDebugScreenWidth - kDebugLabelWidth) / 2, -kDebugLabelHeight, kDebugLabelWidth, kDebugLabelHeight);
        self.memoryLabel.frame = CGRectMake(-kDebugLabelWidth, 0, kDebugLabelWidth, kDebugLabelHeight);
        self.fpsLabel.frame = CGRectMake(kDebugScreenWidth + kDebugLabelWidth, 0, kDebugLabelWidth, kDebugLabelHeight);
    }completion:^(BOOL finished) {
        [self clearUp];
    }];
}

#pragma mark - Clear

- (void)clearUp {
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
        _cpuLabel = [[WDDebugConsoleLabel alloc] initWithFrame:CGRectMake((kDebugScreenWidth - kDebugLabelWidth) / 2, -kDebugLabelHeight, kDebugLabelWidth, kDebugLabelHeight)];
    }
    return _cpuLabel;
}

- (WDDebugConsoleLabel *)fpsLabel {
    if (!_fpsLabel) {
        _fpsLabel = [[WDDebugConsoleLabel alloc] initWithFrame:CGRectMake(kDebugScreenWidth + kDebugLabelWidth, 0, kDebugLabelWidth, kDebugLabelHeight)];
    }
    return _fpsLabel;
}

@end
