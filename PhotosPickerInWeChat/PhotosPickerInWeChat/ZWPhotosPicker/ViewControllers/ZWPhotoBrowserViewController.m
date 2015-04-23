//
//  ZWPhotoPreviewViewController.m
//  ImageSelectorImitatedWeChat
//
//  Created by 张威 on 15/4/15.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "ZWPhotoPickerNavigationController.h"
#import "ZWPhotoBrowserViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+Activity.h"
#import "ZWImageScrollView.h"

@interface ZWPhotoBrowserViewController()
<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIScrollView *pagingScrollView;

@property (nonatomic, assign) id<ZWPhotoBrowserViewControllerDelegate> delegate;

@property (nonatomic, strong) UILabel *photoSizeLabel;
@property (nonatomic, strong) UILabel *photoSizeResultLabel;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorViewForComputingPhotoSize;
@end

@implementation ZWPhotoBrowserViewController {

    NSMutableSet *visiblePages;
    NSMutableSet *invisiblePages;
    UIButton *checkButtonAtTop;
    UIButton *checkButtonAtBottom;
    
    NSInteger photosCount;
    BOOL originPhotoNeeded;
    
    UILabel *numberSelectedLabelAtBottom;
    UIButton *sendButtonAtBottom;
    
    NSUInteger _maximumPhotosSelectable;
}

- (instancetype)initWithDelegate:(id<ZWPhotoBrowserViewControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        originPhotoNeeded = false;
    }
    return self;
}

#define kSpacingBetweenPages   20.0

- (void)initViewAndSubViews {
    
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = false;
    
    [self.view addGestureRecognizer:({
        UITapGestureRecognizer *gesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
        gesture.numberOfTapsRequired = 1;
        gesture;
    })];
    
    CGRect mainBounds = [UIScreen mainScreen].bounds;
    
    self.pagingScrollView = ({
        UIScrollView *scrollView =
        [[UIScrollView alloc] initWithFrame:CGRectMake(-kSpacingBetweenPages, 0,
                                                       mainBounds.size.width + 2 * kSpacingBetweenPages,
                                                       mainBounds.size.height)];
        scrollView.backgroundColor                = [UIColor clearColor];
        scrollView.delegate                       = self;
        scrollView.pagingEnabled                  = YES;
        scrollView.showsVerticalScrollIndicator   = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        //scrollView.contentSize                    = [self contentSizeForPagingScrollView];
        scrollView;
    });
    [self.view addSubview:self.pagingScrollView];
    
    self.topView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainBounds.size.width, 64.0)];
        view.backgroundColor = [[UIColor alloc] initWithWhite:0.25 alpha:0.5];
        [view addGestureRecognizer:({
            UITapGestureRecognizer *gesture =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doNothing:)];
            gesture.numberOfTapsRequired = 1;
            gesture;
        })];
        view;
    });
    [self.view addSubview:self.topView];
    
    UIButton *backButton = ({
        //UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 12, 24)];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 44, 44)];
        [button setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.topView addSubview:backButton];
    
    checkButtonAtTop = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(mainBounds.size.width - 10 - 36, 14, 36, 36)];
        [button setImage:[UIImage imageNamed:@"unchecked2"] forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(checkButtonAtTopClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        button.adjustsImageWhenDisabled    = false;
        button.adjustsImageWhenHighlighted = false;
        button;
    });
    [self.topView addSubview:checkButtonAtTop];
    
    self.bottomView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, mainBounds.size.height - 44.0, mainBounds.size.width, 44.0)];
        view.backgroundColor = [[UIColor alloc] initWithWhite:0.25 alpha:0.5];
        [view addGestureRecognizer:({
            UITapGestureRecognizer *gesture =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doNothing:)];
            gesture.numberOfTapsRequired = 1;
            gesture;
        })];
        view;
    });
    
    checkButtonAtBottom = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 24, 24)];
        [button setImage:originPhotoNeeded ? [UIImage imageNamed:@"checked2"] : [UIImage imageNamed:@"unchecked2"]
                forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(checkButtonAtBottomClicked:)
         forControlEvents:UIControlEventTouchUpInside];
        button.adjustsImageWhenDisabled    = false;
        button.adjustsImageWhenHighlighted = false;
        button;
    });
    [self.bottomView addSubview:checkButtonAtBottom];
    
    _photoSizeLabel = ({
        UILabel *label =
        [[UILabel alloc] initWithFrame:CGRectMake(38, 0, 30, 44)];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [[UIColor alloc] initWithWhite:1.0 alpha:0.3];
        label.text = @"原图";
        label;
    });
    [self.bottomView addSubview:_photoSizeLabel];
    
    _photoSizeResultLabel = ({
        UILabel *label =
        [[UILabel alloc] initWithFrame:CGRectMake(68, 0, 60, 44)];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [[UIColor alloc] initWithWhite:1.0 alpha:0.3];
        label.text = @"";
        label;
    });
    [self.bottomView addSubview:_photoSizeResultLabel];
    
    _activityIndicatorViewForComputingPhotoSize = ({
        UIActivityIndicatorView *activity =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activity.hidesWhenStopped = YES;
        activity.frame = CGRectMake(0, 0, 44, 44);
        activity;
    });
    [_activityIndicatorViewForComputingPhotoSize stopAnimating];
    [_photoSizeResultLabel addSubview:_activityIndicatorViewForComputingPhotoSize];
    
    
    numberSelectedLabelAtBottom = ({
        UILabel *label =
        [[UILabel alloc] initWithFrame:CGRectMake(mainBounds.size.width - 10 - 36 - 26, 10, 24, 24)];
        label.backgroundColor     = [[UIColor alloc] initWithRed:34/255.f green:192/255.f blue:100/255.f alpha:1.0];
        label.textColor           = [UIColor whiteColor];
        label.font                = [UIFont systemFontOfSize:14.0];
        label.textAlignment       = NSTextAlignmentCenter;
        label.layer.cornerRadius  = 12.0;
        label.layer.masksToBounds = YES;
        label.hidden              = true;
        label;
    });
    [self.bottomView addSubview:numberSelectedLabelAtBottom];
    
    sendButtonAtBottom = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(mainBounds.size.width - 10 - 36, 0, 36, 44)];
        [button setTitle:@"完成" forState:UIControlStateNormal];
        [button setTitleColor:[[UIColor alloc] initWithRed:34/255.f green:192/255.f blue:100/255.f alpha:1.0]
                     forState:UIControlStateNormal];
        [button setTitleColor:[[UIColor alloc] initWithRed:34/255.f green:192/255.f blue:100/255.f alpha:0.3]
                     forState:UIControlStateDisabled];
        button.enabled = false;
        button.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [button addTarget:self
                   action:@selector(didFinishPickingPhotos)
         forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.bottomView addSubview:sendButtonAtBottom];

    [self.view addSubview:self.bottomView];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    [self initViewAndSubViews];
    
    // Listen for MWPhoto notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleMWPhotoLoadingDidEndNotification:)
                                                 name:kZWPhotoLoadingDidEndNotification
                                               object:nil];
    
    photosCount = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfPhotosInPhotoBrowser:)]) {
        photosCount = [self.delegate numberOfPhotosInPhotoBrowser:self];
    }
    
    // set pagingScrollView contentOffset
    self.pagingScrollView.contentSize   = [self contentSizeForPagingScrollView];
    self.pagingScrollView.contentOffset = [self contentOffsetForScrollView];
    
    visiblePages   = [NSMutableSet set];
    invisiblePages = [NSMutableSet set];
    
    [self preparePreviousAndNextPage];
    [self didStartViewingPageAtIndex:self.currentPageIndex];
    
    [self refreshSelectedLabelAndSendButton];
}

- (void)releaseOthersUnderlyingPhotos {
    for (int i = 0; i < photosCount; ++i) {
        if (i == self.currentPageIndex) {
            continue;
        }
        ZWPhoto *photo = [self photoAtIndex:i];
        [photo unloadUnderlyingImage];
    }
}

- (void)didReceiveMemoryWarning {
    
    [invisiblePages removeAllObjects];
    
    // 释放非current的photo
    [self releaseOthersUnderlyingPhotos];
    
    [super didReceiveMemoryWarning];
}

static dispatch_queue_t computing_photo_size_operation_processing_queue() {
    
    static dispatch_queue_t zw_compute_photo_size_operation_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zw_compute_photo_size_operation_processing_queue =
        dispatch_queue_create("com.zhangbuhuai.computing_photo_size.processing", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return zw_compute_photo_size_operation_processing_queue;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)preparePreviousAndNextPage {
    
    if (self.currentPageIndex >= photosCount) {
        NSLog(@"unexpected error in preparePreviousAndNextPage");
        return;
    }
    
    // 最多可能有2个page在同时出现，把它们找出来
    // 可能出现的page的组合是有三种：(leftPage-currentPage)或者(currentPage-rightPage)或者(currentPage)
    CGFloat contentOffsetX  = self.pagingScrollView.contentOffset.x;
    CGFloat scrollViewWidth = self.pagingScrollView.frame.size.width;
    NSInteger firstIndex    = (NSInteger)floorf((contentOffsetX + kSpacingBetweenPages * 2) / scrollViewWidth);
    NSInteger lastIndex     = (NSInteger)floorf((contentOffsetX + scrollViewWidth - kSpacingBetweenPages * 2 - 1) / scrollViewWidth);
    
    if (firstIndex < 0) {
        firstIndex = 0;
    } else if (firstIndex > photosCount - 1) {
        firstIndex = photosCount - 1;
    }
    
    if (lastIndex < 0) {
        lastIndex = 0;
    } else if (lastIndex > photosCount - 1) {
        lastIndex = photosCount - 1;
    }
    
    // 回收不会用到的page资源
    for (ZWImageScrollView *imageScrollView in visiblePages) {
        if (imageScrollView.index < firstIndex) {
            [invisiblePages addObject:imageScrollView];
            [imageScrollView removeFromSuperview];
            [imageScrollView prepareForReuse];
        }
    }
    [visiblePages minusSet:invisiblePages];
    // Only keep 2 invisible pages
    while (invisiblePages.count > 2) {
        [invisiblePages removeObject:[invisiblePages anyObject]];
    }
    
    // 补充[firstIndex, lastIndex]中缺失的page
    for (NSInteger index = firstIndex; index <= lastIndex; ++index) {
        if (![self isDisplayingPageAtIndex:index]) {
            // get a page from invisiblePages or create a new page
            ZWImageScrollView *imageScrollView = [invisiblePages anyObject];
            if (imageScrollView) {
                [invisiblePages removeObject:imageScrollView];
            } else {
                imageScrollView = [[ZWImageScrollView alloc] init];
            }
            
            // configure the page
            [self configurePage:imageScrollView atIndex:index];

            // add the page to visiblePages
            [visiblePages addObject:imageScrollView];
            
            // add page in pagingScrollView
            [self.pagingScrollView addSubview:imageScrollView];
        }
    }
}

- (void)goBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)checkButtonAtTopClicked:(UIButton *)sender {
    
    ZWPhoto *aPhoto = [self currentPhoto];
    if (aPhoto.checked) {
        aPhoto.checked = false;
        [sender setImage:[UIImage imageNamed:@"unchecked2"] forState:UIControlStateNormal];
        
        if ([self.delegate respondsToSelector:@selector(photoBrowser:didPhotoUnCheckedAtIndex:)]) {
            [self.delegate photoBrowser:self didPhotoUnCheckedAtIndex:self.currentPageIndex];
        }
        [self refreshSelectedLabelAndSendButton];
        
    } else {
        
        BOOL b = true;
        if ([self.delegate respondsToSelector:@selector(photoBrowser:shouldCheckPhotoAtIndex:)]) {
            b = [self.delegate photoBrowser:self shouldCheckPhotoAtIndex:self.currentPageIndex];
        }
        
        if (b) {
            aPhoto.checked = true;
            [sender setImage:[UIImage imageNamed:@"checked2"] forState:UIControlStateNormal];
            
            if ([self.delegate respondsToSelector:@selector(photoBrowser:didPhotoCheckedAtIndex:)]) {
                [self.delegate photoBrowser:self didPhotoCheckedAtIndex:self.currentPageIndex];
            }
            [self refreshSelectedLabelAndSendButton];
        }
    }
}

- (void)checkButtonAtBottomClicked:(UIButton *)sender {
    
    ZWPhoto *aPhoto = [self currentPhoto];
    if (originPhotoNeeded) {
        
        originPhotoNeeded        = false;
        aPhoto.originPhotoNeeded = false;
        [sender setImage:[UIImage imageNamed:@"unchecked2"] forState:UIControlStateNormal];
        
        _photoSizeLabel.textColor       = [[UIColor alloc] initWithWhite:1.0 alpha:0.3];
        _photoSizeResultLabel.textColor = [[UIColor alloc] initWithWhite:1.0 alpha:0.3];
        
    } else {
        // 若当前图片没被checked，就check它
        BOOL bPreviousChecked = aPhoto.checked;
        
        originPhotoNeeded              = true;
        _photoSizeLabel.textColor       = [UIColor whiteColor];
        _photoSizeResultLabel.textColor = [UIColor whiteColor];
        
        aPhoto.originPhotoNeeded = true;
        aPhoto.checked           = true;
        
        if (!bPreviousChecked) {
            if ([self.delegate respondsToSelector:@selector(photoBrowser:didPhotoCheckedAtIndex:)]) {
                [self.delegate photoBrowser:self didPhotoCheckedAtIndex:self.currentPageIndex];
            }
            [self refreshSelectedLabelAndSendButton];
        }
        
        [checkButtonAtTop setImage:[UIImage imageNamed:@"checked2"] forState:UIControlStateNormal];
        [sender setImage:[UIImage imageNamed:@"checked2"] forState:UIControlStateNormal];
        
        // 计算当前图片大小
        [self updatePhotoSizeInfo];
    }
}

// 计算当前图片大小
- (void)updatePhotoSizeInfo {
    
    _photoSizeResultLabel.text = @"";
    [_activityIndicatorViewForComputingPhotoSize startAnimating];
    
    ZWPhoto *markPhoto = [self currentPhoto];
    
    dispatch_async(computing_photo_size_operation_processing_queue(), ^{
        ZWPhoto *currentPhoto = [self currentPhoto];
        long long byteSize = [currentPhoto defaultRepresentationSize];

        __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (markPhoto == [weakSelf currentPhoto]) {
                [weakSelf.activityIndicatorViewForComputingPhotoSize stopAnimating];
                
                if (byteSize > 1024 * 1024) {
                    CGFloat mbSize = byteSize / (1024 * 1024);
                    weakSelf.photoSizeResultLabel.text = [NSString stringWithFormat:@"(%.1lfMB)", mbSize];
                } else if (byteSize > 1024) {
                    CGFloat kbSize = byteSize / 1024;
                    weakSelf.photoSizeResultLabel.text = [NSString stringWithFormat:@"(%.0lfKB)", kbSize];
                } else {
                    weakSelf.photoSizeResultLabel.text = [NSString stringWithFormat:@"(%lldB)", byteSize];
                }
            }
        });
    });
}

- (void)doNothing:(id)sender {
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidTapped:(UITapGestureRecognizer *)gesture {
    self.topView.hidden = !self.topView.hidden;
    self.bottomView.hidden = !self.bottomView.hidden;
}

- (void)didFinishPickingPhotos {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didFinishPickingPhotosWithInfo:)]) {
        [self.delegate photoBrowser:self didFinishPickingPhotosWithInfo:nil];
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView != self.pagingScrollView) {
        return;
    }

    // ready previous and next page
    [self preparePreviousAndNextPage];
    
    // calculate current page
    CGFloat currentContentOffsetX = self.pagingScrollView.contentOffset.x;
    NSInteger currentIndex =
    (NSInteger)(currentContentOffsetX  / (self.pagingScrollView.bounds.size.width) + 0.5);
    
    if (currentIndex < 0) {
        currentIndex = 0;
    }
    if (currentIndex > photosCount - 1) {
        currentIndex = photosCount - 1;
    }
    
    // previous current page index
    NSUInteger previousCurrentPageIndex = self.currentPageIndex;
    // update currentPageIndex
    self.currentPageIndex = currentIndex;
    if (previousCurrentPageIndex != currentIndex) {
        [self didStartViewingPageAtIndex:currentIndex];
    }
}

- (void)didStartViewingPageAtIndex:(NSInteger)index {
    if (index < 0 || index >= photosCount) {
        return;
    }
    
    // 1. release images further away than +/-1
    NSUInteger i;
    if (index > 0) {
        // Release anything < index - 1
        for (i = 0; i < index-1; i++) {
            id photo = [self photoAtIndex:i];
            if ([photo isKindOfClass:[ZWPhoto class]]) {
                [photo unloadUnderlyingImage];
                //NSLog(@"Released underlying image at index %lu", (unsigned long)i);
            }
        }
    }
    if (index < photosCount - 1) {
        // Release anything > index + 1
        for (i = index + 2; i < photosCount; i++) {
            id photo = [self photoAtIndex:i];
            if ([photo isKindOfClass:[ZWPhoto class]]) {
                [photo unloadUnderlyingImage];
                //NSLog(@"Released underlying image at index %lu", (unsigned long)i);
            }
        }
    }
    
    // 2. preload adjacent photos
    id<ZWPhoto> currentPhoto = [self currentPhoto];
    if ([currentPhoto underlyingImage]) {
        [self loadAdjacentPhotosIfNecessary];
    }
    
    // 3. update top view and bottom view
    ZWPhoto *aPhoto = nil;
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]) {
        aPhoto = [self.delegate photoBrowser:self photoAtIndex:index];
    }
    
    if (aPhoto.checked) {
        [checkButtonAtTop setImage:[UIImage imageNamed:@"checked2"] forState:UIControlStateNormal];
    } else {
        [checkButtonAtTop setImage:[UIImage imageNamed:@"unchecked2"] forState:UIControlStateNormal];
    }
    
    if (originPhotoNeeded) {
        [self updatePhotoSizeInfo];
    }
}

- (void)loadAdjacentPhotosIfNecessary {
    ZWPhoto *prevPhoto = [self photoAtIndex:self.currentPageIndex - 1];
    if (prevPhoto) {
        [prevPhoto loadUnderlyingImageAndNotify];
    }
    ZWPhoto *nextPhoto = [self photoAtIndex:self.currentPageIndex + 1];
    if (nextPhoto) {
        [nextPhoto loadUnderlyingImageAndNotify];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewWillBeginDragging");
}

-(void)scrollViewWillBeginDecelerating: (UIScrollView *)scrollView{
//    [scrollView setContentOffset:scrollView.contentOffset animated:YES];
}

- (void)refreshSelectedLabelAndSendButton {
    
    NSUInteger count = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfSelectedPhotosInPhotoBrowser:)]) {
        count = [self.delegate numberOfSelectedPhotosInPhotoBrowser:self];
    }
    
    if (count <= 0) {
        sendButtonAtBottom.enabled         = false;
        
        numberSelectedLabelAtBottom.hidden = YES;
        numberSelectedLabelAtBottom.text   = @"0";
    } else {
        sendButtonAtBottom.enabled            = true;
        
        numberSelectedLabelAtBottom.hidden    = false;
        numberSelectedLabelAtBottom.transform = CGAffineTransformMakeScale(0.8, 0.8);
        numberSelectedLabelAtBottom.text      = [NSString stringWithFormat:@"%d", (int)count];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             numberSelectedLabelAtBottom.transform = CGAffineTransformMakeScale(1.125, 1.125);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.2
                                              animations:^{
                                                  numberSelectedLabelAtBottom.transform = CGAffineTransformMakeScale(1/1.25, 1/1.25);
                                              }
                                              completion:nil];
                         }];
    }
}

#pragma mark - ZWPhoto Loading Notification

- (void)handleMWPhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <ZWPhoto> photo = [notification object];
    ZWImageScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        if ([photo underlyingImage]) {
            // Successful load
            [page displayImage];
            
        } else {
            // Failed to load
            [page displayImageFailure];
        }
    }
}

/***************************************helper methods***************************************/

// 获取当前的Photo
- (ZWPhoto *)currentPhoto {
    if (self.currentPageIndex >= photosCount) {
        return nil;
    }
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]) {
        return [self.delegate photoBrowser:self photoAtIndex:self.currentPageIndex];
    }
    return nil;
}

// 根据index获取photo
- (ZWPhoto *)photoAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]) {
        return [self.delegate photoBrowser:self photoAtIndex:index];
    }
    return nil;
}

// 计算self.scrollView的contentSize
- (CGSize)contentSizeForPagingScrollView {
    CGRect bounds = self.pagingScrollView.bounds;
    if (photosCount <= 0) {
        NSLog(@"unexpected error in contentSizeForPagingScrollView");
        return CGSizeZero;
    }
    return CGSizeMake(bounds.size.width * photosCount, bounds.size.height);
}

// 根据index计算page的frame
- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    CGRect bounds = self.pagingScrollView.bounds;
    CGRect imageFrame = CGRectMake((bounds.size.width) * index + kSpacingBetweenPages,
                                   0, bounds.size.width - 2 * kSpacingBetweenPages,
                                   bounds.size.height);
    return CGRectIntegral(imageFrame);
}

// 计算self.scrollView的contentOffset
- (CGPoint)contentOffsetForScrollView {
    CGRect bounds = self.pagingScrollView.bounds;
    CGPoint aPoint;
    aPoint.y = 0.f;
    aPoint.x = bounds.size.width * self.currentPageIndex;
    return aPoint;
}

// 配置page
- (void)configurePage:(ZWImageScrollView *)page atIndex:(NSUInteger)index {
    page.index = index;
    if (index < photosCount) {
        ZWPhoto *aPhoto = nil;
        if ([self.delegate respondsToSelector:@selector(photoBrowser:photoAtIndex:)]) {
            aPhoto = [self.delegate photoBrowser:self photoAtIndex:index];
        }
        page.photo = aPhoto;
    }

    page.frame = [self frameForPageAtIndex:index];
}

// 判断当前page是否附着在pagingScrollView中
- (BOOL)isDisplayingPageAtIndex:(NSInteger)index {
    if (index < 0 || index >= photosCount) {
        return NO;
    }
    for (ZWImageScrollView *imageScrollView in visiblePages) {
        if (imageScrollView.index == index) {
            return YES;
        }
    }
    return NO;
}

// 判断page是否附着在pagingScrollView中
- (ZWImageScrollView *)pageDisplayingPhoto:(ZWPhoto *)photo {
    
    for (ZWImageScrollView *imageScrollView in visiblePages) {
        if (imageScrollView.photo == photo) {
            return imageScrollView;
        }
    }
    return nil;
}

// 根据photo找到page
- (ZWImageScrollView *)pageForPhoto:(ZWPhoto *)photo {
    if (photo == nil) {
        return nil;
    }
    
    for (ZWImageScrollView *imageScrollView in visiblePages) {
        if (imageScrollView.photo == photo) {
            return imageScrollView;
        }
    }
    return nil;
}

@end
