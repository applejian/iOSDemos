//
//  ZWImageScrollView.h
//  ImageSelectorImitatedWeChat
//
//  Created by 张威 on 15/4/17.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWPhoto.h"

@interface ZWImageScrollView : UIScrollView

//@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL usable;
//@property (nonatomic, strong) ALAsset *asset;

@property (nonatomic, strong) ZWPhoto *photo;

@property (nonatomic, assign) NSUInteger index;

- (void)prepareForReuse;

- (void)displayImage;

- (void)displayImageFailure;

@end
