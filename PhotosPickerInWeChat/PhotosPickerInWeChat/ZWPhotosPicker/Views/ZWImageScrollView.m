//
//  UIImageScrollView.m
//  ImageSelectorImitatedWeChat
//
//  Created by 张威 on 15/4/17.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "ZWImageScrollView.h"
#import "UIView+Activity.h"

@interface ZWImageScrollView ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation ZWImageScrollView {
    //UIImageView *_imageView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_imageView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        _imageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
    return self;
}

- (void)showActivityIndicator {
    self.loading = true;
}

- (void)hideActivityIndicator {
    self.loading = false;
}

- (void)setPhoto:(ZWPhoto *)photo {
    if (_photo == photo) {
        return;
    }
    
    _photo = photo;
    
    [self showActivityIndicator];
    
    UIImage *img = [[self class] imageForPhoto:_photo];
    if (img) {
        [self showActivityIndicator];
        [self displayImage];
    }
}

+ (UIImage *)imageForPhoto:(id<ZWPhoto>)photo {
    if (photo) {
        // Get image or obtain in background
        if ([photo underlyingImage]) {
            return [photo underlyingImage];
        } else {
            [photo loadUnderlyingImageAndNotify];
        }
    }
    return nil;
}

// Get and display image
- (void)displayImage {
    [self hideActivityIndicator];
    self.imageView.image = _photo.underlyingImage;
}

// Image failed so just show black!
- (void)displayImageFailure {
    [self hideActivityIndicator];
    self.imageView.image = [UIImage imageNamed:@"unchecked"];
}

/*
- (void)setPhoto:(ZWPhoto *)photo {
    
    if (_photo == photo) {
        return;
    }
    
    _photo = photo;
    
    if (_photo) {
        self.loading = true;
        __weak __typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            @try {
                UIImage *image = [_photo fullResolutionImage];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (photo == _photo) {
                        weakSelf.loading = false;
                        weakSelf.imageView.image = image;
                    }
                });
            }
            @catch (NSException *exception) {
                NSLog(@"Photo from asset library error: %@", exception);
                weakSelf.imageView.image = nil;
                weakSelf.loading = true;
            }
            @finally {
                
            }
        });
    } else {
        self.imageView.image = nil;
    }
}*/


- (void)prepareForReuse {
    _imageView.image = nil;
    _photo           = nil;
    _index           = NSUIntegerMax;
    [self setLoading:false];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect viewFrame = self.frame;
    _imageView.frame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
}

/*
 有待优化，非正常操作下会有如下不正常信息：
 Connection to assetsd was interrupted or assetsd died
 Received memory warning.
 */

@end
