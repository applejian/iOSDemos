//
//  ZWPhotosCollectionViewController.h
//  ImageSelectorImitatedWeChat
//
//  Created by 张威 on 15/4/15.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ZWPhotosCollectionViewController : UIViewController

@property (nonatomic, strong, readonly) ALAssetsGroup *assetsGroup;
- (instancetype)initWithAssetGroup:(ALAssetsGroup *)assetsGroup;

@end
