//
//  ViewController.m
//  PhotosPickerInWeChat
//
//  Created by 张威 on 15/4/22.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "ViewController.h"
#import "ZWPhotosPicker/ZWPhotosPicker.h"

@interface ViewController ()
<ZWPhotoPickerNavigationControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *imageViews;

@property (nonatomic, strong) NSMutableArray *photos;

@end

@implementation ViewController

- (NSMutableArray *)photos {
    if (_photos == nil) {
        _photos = [NSMutableArray arrayWithCapacity:6];
    }
    return _photos;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    UIButton *openPhotosPickerButton = ({
        UIButton *button =
        [[UIButton alloc] initWithFrame:CGRectMake(30, 100, 100, 44)];
        [button setTitle:@"打开相册" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
        [button addTarget:self
                   action:@selector(showPictureSelector:)
         forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.view addSubview:openPhotosPickerButton];
    
    UIButton *clearPhotosButton = ({
        UIButton *button =
        [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 100 - 30, 100, 100, 44)];
        [button setTitle:@"重置" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
        [button addTarget:self
                   action:@selector(clearImages:)
         forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.view addSubview:clearPhotosButton];
    
    self.imageViews = [NSMutableArray array];
    
    /* 6 UIImageViews */
    for (int i = 0; i < 6; ++i) {
        CGRect imageViewFrame         = [self getFrameForImageViewAtIndex:i];
        UIImageView *imageView        = [[UIImageView alloc] initWithFrame:imageViewFrame];
        imageView.backgroundColor     = [[UIColor alloc] initWithWhite:0.7 alpha:0.5];
        imageView.contentMode         = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        [self.view addSubview:imageView];
        
        [self.imageViews addObject:imageView];
    }
}

- (CGRect)getFrameForImageViewAtIndex:(NSUInteger)index {
    CGFloat screenWidth     = [UIScreen mainScreen].bounds.size.width;

    CGFloat imageViewWidth  = floorf((screenWidth - 40) / 3);
    CGFloat imageViewHeight = imageViewWidth;

    CGFloat originX         = (imageViewWidth + 10) * (index % 3) + 10;
    CGFloat originY         = (imageViewWidth + 10) * (index / 3) + 200;
    
    return CGRectMake(originX, originY, imageViewWidth, imageViewHeight);
}

- (void)showPictureSelector:(UIButton *)button {
    NSLog(@"打开相册");
    
    ZWPhotoPickerNavigationController *VC = //[[ZWPhotoPickerNavigationController alloc] init];
    [[ZWPhotoPickerNavigationController alloc] initWithMaximumSelectable:(6-self.photos.count)];
    VC.delegate = self;
    [self presentViewController:VC animated:YES completion:nil];
}

- (void)clearImages:(UIButton *)button {
    [self.photos removeAllObjects];
    
    for (UIImageView *imageView in self.imageViews) {
        imageView.image = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <ZWPhotoPickerNavigationControllerDelegate>

- (void)photoPicker:(ZWPhotoPickerNavigationController *)photoPicker didFinishPickingPhotos:(NSArray *)photos {
    [photoPicker dismissViewControllerAnimated:YES completion:nil];
    
    NSUInteger iBegin = self.photos.count;
    [self.photos addObjectsFromArray:photos];
    
    for (NSUInteger index = iBegin; index < self.photos.count && index < self.imageViews.count; ++index) {
        ZWPhoto *aPhoto        = [self.photos objectAtIndex:index];
        UIImageView *imageView = [self.imageViews objectAtIndex:index];

        imageView.loading      = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImage *image = [aPhoto fullResolutionImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.loading = NO;
                imageView.image   = image;
            });
        });
    }
}

@end
