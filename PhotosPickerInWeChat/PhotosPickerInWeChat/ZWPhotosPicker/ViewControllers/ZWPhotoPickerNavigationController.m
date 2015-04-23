//
//  ZWPhotoPickerNavigationController
//  ImageSelectorImitatedWeChat
//
//  Created by 张威 on 15/4/15.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "ZWPhotoPickerNavigationController.h"
#import "ZWPhotoGroupTableViewController.h"

@interface ZWPhotoPickerNavigationController ()

@end

@implementation ZWPhotoPickerNavigationController {
//    NSUInteger _maximumSelectable;   // 最大可选择图片的数量
}

@dynamic delegate;

- (instancetype)initWithMaximumSelectable:(NSUInteger)maximumSelectable {
    self = [super init];
    if (self) {
        _maximumSelectable = maximumSelectable;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* 配置navigation bar外观开始 */
    self.navigationBar.translucent = YES;
    self.navigationBar.titleTextAttributes =
    [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                forKey:NSForegroundColorAttributeName];
    self.navigationBar.tintColor = [UIColor whiteColor];    // 文字颜色
    self.navigationBar.barTintColor =     // navigation bar颜色
    [[UIColor alloc] initWithRed:17/255.0 green:169/255.0 blue:172/255.0 alpha:0.5];
    /* 配置navigation bar外观结束 */
    
    ZWPhotoGroupTableViewController *VC = [[ZWPhotoGroupTableViewController alloc] init];
    [self pushViewController:VC animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didFinishPickingPhotos:(NSArray *)photos {
    
    if ([self.delegate respondsToSelector:@selector(photoPicker:didFinishPickingPhotos:)]) {
        [self.delegate photoPicker:self didFinishPickingPhotos:photos];
    }
}


@end
