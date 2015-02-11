//
//  ViewController.m
//  PopViewDemo
//
//  Created by 张威 on 15/2/11.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "ViewController.h"
#import "PopoverView.h"

@interface ViewController () <PopoverViewDelegate>

@end

@implementation ViewController

- (void)initViewAndSubViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 配置navigationItem开始

    self.navigationItem.titleView = ({
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:16.0];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = @"弹出窗";
        titleLabel;
    });
    
    self.navigationItem.rightBarButtonItem = ({
        //设置导航栏首页二维码(右视图）
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [button setBackgroundImage:[UIImage imageNamed:@"add_image"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(rightBarButtonItemClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        barButtonItem;
    });

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewAndSubViews];
    // Do any additional setup after loading the view, typically from a nib.
}

// rightBarButtonItemClicked
- (void)rightBarButtonItemClicked:(UIButton *)sender {
    
    
    CGPoint point =
    CGPointMake(sender.frame.origin.x + sender.frame.size.width / 2,
                64.0 + 3.0);
    NSArray *titles = @[@"扫描验证", @"输入验证码"];
    PopoverView *pop = [[PopoverView alloc] initWithPoint:point
                                                   titles:titles
                                               imageNames:@[@"scan", @"yanzheng"]];
    pop.delegate = self;
    
    [pop show];
}

#pragma mark - PopoverViewDelegate

- (void)didSelectedRowAtIndex:(NSInteger)index {
    
    if (index == 0) {
        // 扫描二维码
        NSLog(@"扫描二维码");
    } else if (index == 1) {
        // 扫描二维码
        NSLog(@"输入验证码");
    }

}

@end
