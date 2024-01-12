//
//  WDDebugFPSMonitor.m
//  WDDebugTool
//
//  Created by jocelen on 2024/1/11.
//

#import "WDDebugFPSMonitor.h"

@interface WDDebugFPSMonitor()

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) NSTimeInterval lastTimestamp;

@property (nonatomic, assign) NSInteger performTimes;

@end

@implementation WDDebugFPSMonitor

WHSingletonM()

- (void)startMonitoring {
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTicks:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)displayLinkTicks:(CADisplayLink *)link {
    if (_lastTimestamp == 0) {
        _lastTimestamp = link.timestamp;
        return;
    }
    _performTimes ++;
    NSTimeInterval interval = link.timestamp - _lastTimestamp;
    if (interval < 1) { return; }
    _lastTimestamp = link.timestamp;
    float fps = _performTimes / interval;
    _performTimes = 0;
    if (self.valueBlock) {
        self.valueBlock(fps);
    }
}

- (void)stopMonitoring {
    [_displayLink invalidate];
}

@end
