//
//  MainNavigationController.m
//  YunWan
//
//  Created by 张威 on 15/2/4.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "MainNavigationController.h"

@interface MainNavigationController ()

@end

@implementation MainNavigationController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 配置navigation bar外观开始 */
    self.navigationBar.translucent = NO;
    self.navigationBar.titleTextAttributes =
    [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                forKey:NSForegroundColorAttributeName];
    self.navigationBar.tintColor = [UIColor whiteColor];    // 文字颜色
    self.navigationBar.barTintColor =     // navigation bar颜色
    [[UIColor alloc] initWithRed:7/255.0 green:185/255.0 blue:216/255.0 alpha:1.0];
    /* 配置navigation bar外观结束 */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
