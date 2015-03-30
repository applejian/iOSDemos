//
//  YWRegisterViewController2.h
//  YunWan
//
//  Created by 张威 on 15/2/2.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWRegisterViewController2: UIViewController

@end

@protocol YWRegisterViewController2Delegate <NSObject>

- (void)didRegisterFinishWithAcount:(NSString *)acount
                        andPassword:(NSString *)password;

@end
