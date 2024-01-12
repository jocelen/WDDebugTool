//
//  WDViewController.m
//  WDDebugTool
//
//  Created by jocelen on 01/11/2024.
//  Copyright (c) 2024 jocelen. All rights reserved.
//

#import "WDViewController.h"
#import "WDDebugToolManager.h"

@interface WDViewController ()

@end

@implementation WDViewController

// MARK: -  life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadConfig];
    [self addSubviews];
}

// MARK: -  private methods

// 加载初始配置
-(void)loadConfig {
    self.title = @"性能监控";
    [WDDebugToolManager showWith:DebugToolTypeAll];
}

// 添加view
-(void)addSubviews {
    
    UIButton * button = [[UIButton alloc] init];
    [button setTitle:@"打开/关闭" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(toggleAction) forControlEvents:UIControlEventTouchDown];
    button.frame = CGRectMake((self.view.frame.size.width / 2) - 50, (self.view.frame.size.height / 2) - 30, 100, 60);
    [self.view addSubview:button];
}

- (void)toggleAction {
    [WDDebugToolManager toggleWith:DebugToolTypeAll];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
