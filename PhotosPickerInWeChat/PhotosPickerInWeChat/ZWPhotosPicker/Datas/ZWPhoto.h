//
//  ZWPhoto.h
//  ImageSelectorImitatedWeChat
//
//  Created by 张威 on 15/4/20.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "ZWPhotoProtocol.h"

@interface ZWPhoto : NSObject <ZWPhoto>

- (instancetype)initWithAsset:(ALAsset *)asset;

- (UIImage *)thumbnail;
- (UIImage *)fullResolutionImage;

@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) BOOL originPhotoNeeded;

- (long long)defaultRepresentationSize;

@end
