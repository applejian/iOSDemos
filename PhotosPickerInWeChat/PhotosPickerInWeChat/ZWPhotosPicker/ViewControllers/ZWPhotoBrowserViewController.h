//
//  ZWPhotoBrowserViewController.h
//  ImageSelectorImitatedWeChat
//
//  Created by 张威 on 15/4/15.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ALAsset+PhotoPicker.h"
#import "ZWPhoto.h"

@protocol ZWPhotoBrowserViewControllerDelegate;

@interface ZWPhotoBrowserViewController : UIViewController

- (instancetype)initWithDelegate:(id<ZWPhotoBrowserViewControllerDelegate>)delegate;

//@property (nonatomic, strong) NSMutableArray *photosArray;
//@property (nonatomic, strong) NSMutableArray *photosSelectedArray;


@property (nonatomic, assign) NSUInteger currentPageIndex;

@end

@protocol ZWPhotoBrowserViewControllerDelegate <NSObject>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(ZWPhotoBrowserViewController *)photoBrowser;
- (NSUInteger)numberOfSelectedPhotosInPhotoBrowser:(ZWPhotoBrowserViewController *)photoBrowser;
- (ZWPhoto *)photoBrowser:(ZWPhotoBrowserViewController *)photoBrowser photoAtIndex:(NSUInteger)index;

- (BOOL)photoBrowser:(ZWPhotoBrowserViewController *)photoBrowser photoIsCheckedAtIndex:(NSUInteger)index;

- (void)photoBrowser:(ZWPhotoBrowserViewController *)photoBrowser didPhotoCheckedAtIndex:(NSUInteger)index;
- (void)photoBrowser:(ZWPhotoBrowserViewController *)photoBrowser didPhotoUnCheckedAtIndex:(NSUInteger)index;

- (BOOL)photoBrowser:(ZWPhotoBrowserViewController *)photoBrowser shouldCheckPhotoAtIndex:(NSUInteger)index;

- (void)photoBrowser:(ZWPhotoBrowserViewController *)photoBrowser didFinishPickingPhotosWithInfo:(NSDictionary *)info;

@optional
/*
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;
- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;
- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser;
 */
@end
