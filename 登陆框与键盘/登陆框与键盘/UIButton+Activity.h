//
//  UIButton+Activity.h
//  YunWan
//  button上加上UIActivityIndicatorView
//  Created by 张威 on 15/2/7.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Activity)

@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign, getter=isWorking) BOOL working;

@end
