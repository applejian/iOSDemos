//
//  ViewController.m
//  ZWActionSheetDemo
//
//  Created by 张威 on 15/2/22.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "ViewController.h"
#import "ZWActionSheet.h"

@interface ViewController ()
<ZWActionSheetDelegate>

@property (nonatomic, strong) UIButton *showActionSheetButton;

@end

@implementation ViewController

- (void)initViewAndSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    self.showActionSheetButton =
    [[UIButton alloc] initWithFrame:CGRectMake(0, 100, screenWidth, 44)];
    [self.showActionSheetButton setTitle:@"show action sheet" forState:UIControlStateNormal];
    [self.showActionSheetButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.showActionSheetButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.showActionSheetButton];
    [self.showActionSheetButton addTarget:self action:@selector(showActionSheet:) forControlEvents:UIControlEventTouchDown];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViewAndSubViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showActionSheet:(UIButton *)sender {
    
    ZWActionSheet *actionSheet =
    [[ZWActionSheet alloc] initWithTitle:@"退出后不会删除任何历史数据，下次登录依然可以使用本账号"
                                delegate:self
                       cancelButtonTitle:@"取消"
                  destructiveButtonTitle:@"退出登录"
                       otherButtonTitles:@[@"开个玩笑", @"别介意"]];
    [actionSheet showInView:self.view];
}

#pragma mark - ZWActionSheetDelegate
- (void)ZWActionSheet:(ZWActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"你点击了第%ld个button", (long)buttonIndex);
}

@end

