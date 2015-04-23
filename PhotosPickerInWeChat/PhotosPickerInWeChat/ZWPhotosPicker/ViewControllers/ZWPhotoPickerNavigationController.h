//
//  ZWPhotoPickerNavigationController.h
//  ImageSelectorImitatedWeChat
//
//  Created by 张威 on 15/4/15.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZWPhotoPickerNavigationControllerDelegate;

@interface ZWPhotoPickerNavigationController : UINavigationController

- (instancetype)initWithMaximumSelectable:(NSUInteger)maximumSelectable;

// 选择图片完成时调用该方法
- (void)didFinishPickingPhotos:(NSArray *)photos;

// 最大可选择图片的数量
@property (nonatomic, assign, readonly) NSUInteger maximumSelectable;

@property (nonatomic, weak) id<ZWPhotoPickerNavigationControllerDelegate, UINavigationControllerDelegate> delegate;

@end

@protocol ZWPhotoPickerNavigationControllerDelegate <NSObject>

- (void)photoPicker:(ZWPhotoPickerNavigationController *)photoPicker didFinishPickingPhotos:(NSArray *)photos;

@end
