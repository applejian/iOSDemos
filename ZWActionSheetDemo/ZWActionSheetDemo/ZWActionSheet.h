//
//  ZWActionSheet.h
//  类似微信ActionSheet
//
//  Created by 张威 on 15/2/16.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZWActionSheetDelegate;

@interface ZWActionSheet : UIView

@property (nonatomic, strong) id<ZWActionSheetDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title
                     delegate:(id<ZWActionSheetDelegate>)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles;

- (void)showInView:(UIView *)view;
//- (void)dismiss;
//- (void)dismissWithAnimation:(BOOL)animation;
//- (void)setHidden:(BOOL)hidden;

@end

@protocol ZWActionSheetDelegate <NSObject>

- (void)ZWActionSheet:(ZWActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
