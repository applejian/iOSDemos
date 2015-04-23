//
//  ZWPhotosCollectionViewController.m
//  ImageSelectorImitatedWeChat
//
//  Created by 张威 on 15/4/15.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "ZWPhotosCollectionViewController.h"
#import "ZWPhotoBrowserViewController.h"
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageDestination.h>
#import "ZWPhoto.h"

#import "ZWPhotoPickerNavigationController.h"

#define kMaxPhotosSelected      6

@protocol ZWPhotosCollectionViewCellDelegate;

@interface ZWPhotosCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, assign) BOOL checked;

@property (nonatomic, assign) id<ZWPhotosCollectionViewCellDelegate> delegate;

@end

@protocol ZWPhotosCollectionViewCellDelegate <NSObject>

- (void)button:(UIButton *)button clickedInCell:(ZWPhotosCollectionViewCell *)cell;

@end

@implementation ZWPhotosCollectionViewCell {
    UIImageView *thumbnailImageView;
    UIButton *checkButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _checked = false;
        
        thumbnailImageView =
        [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        thumbnailImageView.contentMode   = UIViewContentModeScaleAspectFill;
        thumbnailImageView.clipsToBounds = YES;
        
        checkButton =
        [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 24 - 2, 2, 24, 24)];
        [checkButton setImage:[UIImage imageNamed:@"unchecked"] forState:UIControlStateNormal];
        [checkButton addTarget:self
                        action:@selector(checkButtonDidClicked:)
              forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:thumbnailImageView];
        [self.contentView addSubview:checkButton];
    }
    return self;
}

- (void)checkButtonDidClicked:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(button:clickedInCell:)]) {
        [self.delegate button:button clickedInCell:self];
    }
}

- (void)setChecked:(BOOL)checked {
    if (_checked == checked) {
        return;
    }
    _checked = checked;
    UIImage *checkImage = _checked ? [UIImage imageNamed:@"checked"] : [UIImage imageNamed:@"unchecked"];
    [checkButton setImage:checkImage forState:UIControlStateNormal];
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    if (thumbnailImage == _thumbnailImage) {
        return;
    }
    _thumbnailImage = thumbnailImage;
    thumbnailImageView.image = _thumbnailImage;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ZWPhotosCollectionViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, ZWPhotosCollectionViewCellDelegate, ZWPhotoBrowserViewControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) NSMutableArray *photosArray;
@property (nonatomic, strong) NSMutableArray *photosSelectedArray;

@end


@implementation ZWPhotosCollectionViewController {
    UIButton *previewButton;
    UILabel *numberSelectedLabel;
    UIButton *sendButton;
    
    NSUInteger _maximumPhotosSelectable;
}

static NSString * const reuseIdentifier = @"reuseIdentifier";

- (void)loadView {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

#define kInteritemSpacing   3.0
#define kMinimumLineSpacing kInteritemSpacing
#define kCellNumberPerLine  4
    CGFloat thumbnailSideLength =
    (screenSize.width - kInteritemSpacing * (kCellNumberPerLine + 1)) / kCellNumberPerLine;
    CGSize thumbnailSize = CGSizeMake(thumbnailSideLength, thumbnailSideLength);
    
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize                     = thumbnailSize;
    layout.sectionInset                 = UIEdgeInsetsMake(kMinimumLineSpacing, 0, 0, 0);
    layout.minimumInteritemSpacing      = kInteritemSpacing;      // 列距
    layout.minimumLineSpacing           = kMinimumLineSpacing;      // 行距
    layout.footerReferenceSize          = CGSizeMake(0, kMinimumLineSpacing);
    
    // init collectionView
    self.collectionView =
    [[UICollectionView alloc] initWithFrame:CGRectMake(kInteritemSpacing, 0,
                                                       screenSize.width - kInteritemSpacing * 2,
                                                       screenSize.height - 44.0)
                       collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.bottomView = ({
        UIView *view =
        [[UIView alloc] initWithFrame:CGRectMake(0, screenSize.height - 44.0, screenSize.width, 44.0)];
        view.backgroundColor = [[UIColor alloc] initWithWhite:0.9 alpha:0.5];
        view;
    });
    
    previewButton =
    [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 36, 44)];
    [previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [previewButton setTitleColor:[[UIColor alloc] initWithWhite:0.0 alpha:1.0]
                        forState:UIControlStateNormal];
    [previewButton setTitleColor:[[UIColor alloc] initWithWhite:0.0 alpha:0.3]
                        forState:UIControlStateDisabled];
    previewButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    previewButton.enabled = false;
    [self.bottomView addSubview:previewButton];
    
    numberSelectedLabel = ({
        UILabel *label =
        [[UILabel alloc] initWithFrame:CGRectMake(screenSize.width - 10 - 36 - 26, 10, 24, 24)];
        label.backgroundColor     = [[UIColor alloc] initWithRed:34/255.f green:192/255.f blue:100/255.f alpha:1.0];
        label.textColor           = [UIColor whiteColor];
        label.font                = [UIFont systemFontOfSize:14.0];
        label.textAlignment       = NSTextAlignmentCenter;
        label.layer.cornerRadius  = 12.0;
        label.layer.masksToBounds = YES;
        label.hidden              = true;
        label;
    });
    [self.bottomView addSubview:numberSelectedLabel];
    
    sendButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - 10 - 36, 0, 36, 44)];
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
    [self.bottomView addSubview:sendButton];
    
    self.view                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
}

- (instancetype)initWithAssetGroup:(ALAssetsGroup *)assetsGroup {
    self = [super init];
    if (self) {
        _assetsGroup = assetsGroup;
        _photosArray = [NSMutableArray array];
    }
    return self;
}

- (void)initViewAndSubViews {
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    // configure navigation bar
    self.navigationItem.rightBarButtonItem = ({
        UIBarButtonItem *barButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(dismissNow)];
        barButtonItem;
    });
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _maximumPhotosSelectable = kMaxPhotosSelected;
    if ([self.navigationController isKindOfClass:[ZWPhotoPickerNavigationController class]]) {
        ZWPhotoPickerNavigationController *nav = (ZWPhotoPickerNavigationController *)self.navigationController;
        _maximumPhotosSelectable = nav.maximumSelectable;
    }
    
    [self initViewAndSubViews];
    
    // Register cell classes
    [self.collectionView registerClass:[ZWPhotosCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result && [[result valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypePhoto]) {
            ZWPhoto *aPhoto = [[ZWPhoto alloc] initWithAsset:result];
            aPhoto.checked = false;
            aPhoto.originPhotoNeeded = false;
            
            [self.photosArray addObject:aPhoto];
        } else if (self.photosArray.count > 0) {
            [self.collectionView reloadData];
        }
    };
    
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
    [self didNumberSelectedLabelChanged];
}

- (void)dismissNow {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSMutableArray *)photosSelectedArray {
    if (_photosSelectedArray == nil) {
        _photosSelectedArray = [[NSMutableArray alloc] initWithCapacity:_maximumPhotosSelectable];
    }
    return _photosSelectedArray;
}

#pragma mark <ZWPhotosCollectionViewCellDelegate>
- (void)button:(UIButton *)button clickedInCell:(ZWPhotosCollectionViewCell *)cell {
    
    if (!cell.checked && self.photosSelectedArray.count >= _maximumPhotosSelectable) {
        NSLog(@"最多只能选择%d张照片", (int)_maximumPhotosSelectable);
        return;
    }
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    ZWPhoto *aPhoto = [self.photosArray objectAtIndex:indexPath.row];
    
    cell.checked = !cell.checked;
    aPhoto.checked = cell.checked;
    
    if (cell.checked) {
        [self.photosSelectedArray addObject:aPhoto];
    } else {
        [self.photosSelectedArray removeObject:aPhoto];
    }
    
    [self didNumberSelectedLabelChanged];
}

- (void)didNumberSelectedLabelChanged {
    
    NSUInteger count = self.photosSelectedArray.count;
    if (count <= 0) {
        previewButton.enabled      = false;
        sendButton.enabled         = false;

        numberSelectedLabel.hidden = YES;
        numberSelectedLabel.text   = @"0";
    } else {
        previewButton.enabled         = true;
        sendButton.enabled            = true;

        numberSelectedLabel.hidden    = false;
        numberSelectedLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
        numberSelectedLabel.text      = [NSString stringWithFormat:@"%d", (int)count];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             numberSelectedLabel.transform = CGAffineTransformMakeScale(1.125, 1.125);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.2
                                              animations:^{
                                                  numberSelectedLabel.transform = CGAffineTransformMakeScale(1/1.25, 1/1.25);
                                              }
                                              completion:nil];
                         }];
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.assetsGroup.numberOfAssets;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZWPhotosCollectionViewCell *cell =
    (ZWPhotosCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                            forIndexPath:indexPath];
    cell.delegate = self;
    
    ZWPhoto *aPhoto = [self.photosArray objectAtIndex:indexPath.row];
    
    cell.thumbnailImage = [aPhoto thumbnail];;
    cell.checked = aPhoto.checked;
    
    //NSLog(@"图片大小: %lld", asset.defaultRepresentation.size / 1024);
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    /*
    ALAsset *asset = [self.photosArray objectAtIndex:indexPath.row];
    long long originSize = asset.defaultRepresentation.size;
    CGImageRef imageRef = asset.defaultRepresentation.fullResolutionImage;
    
    UIImage *originImage = [UIImage imageWithCGImage:imageRef];
    NSLog(@"图片类型：%@", asset.defaultRepresentation.UTI);
//    NSURL *originURL = asset.defaultRepresentation.url;
    
    //NSData *originData = [NSData dataWithContentsOfURL:originURL];
    //NSData *originData = [self getImagedataPhotoLibrary:asset.defaultRepresentation.metadata andImage:originImage];
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    Byte *buffer = (Byte*)malloc((long)rep.size);
    NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:(long)rep.size error:nil];
    NSData *originData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
    
    NSLog(@"原生图像1大小为：%lld字节", originSize);
    NSLog(@"原生图像2大小为：%lu字节", (unsigned long)originData.length);
    
    // public.jpeg
    NSData *dataTemp = UIImagePNGRepresentation(originImage);
    NSLog(@"PNG图像大小为：%u字节", dataTemp.length);
    
    // Array with all the representations available for a given asset (e.g. RAW, JPEG). It is expressed as UTIs.
//    id dontKnown = [asset valueForProperty:ALAssetPropertyRepresentations];
//    NSLog(@"dontKnown = %@", dontKnown);
    */

    // 1. init VC
    ZWPhotoBrowserViewController *VC = [[ZWPhotoBrowserViewController alloc] initWithDelegate:self];
    
    // 2. configure VC
    VC.currentPageIndex   = indexPath.row;
    
    // 3. show VC
    [self.navigationController pushViewController:VC animated:YES];
}

-(NSMutableData *)getImagedataPhotoLibrary:(NSDictionary *)pImgDictionary andImage:(UIImage *)pImage
{
    NSData* data = UIImagePNGRepresentation(pImage);
    
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    NSMutableDictionary *metadataAsMutable = [pImgDictionary mutableCopy];
    
    CFStringRef UTI = CGImageSourceGetType(source);
    
    NSMutableData *dest_data = [NSMutableData data];
    
    //For Mutabledata
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data, UTI, 1, NULL);
    
    if(!destination)
        dest_data = [data mutableCopy];
    else
    {
        CGImageDestinationAddImageFromSource(destination, source, 0, (CFDictionaryRef) metadataAsMutable);
        BOOL success = CGImageDestinationFinalize(destination);
        if(!success)
            dest_data = [data mutableCopy];
    }
    if(destination)
        CFRelease(destination);
    
    CFRelease(source);
    
    return dest_data;
}

- (void)didFinishPickingPhotos {
    ZWPhotoPickerNavigationController *nav = (ZWPhotoPickerNavigationController *)self.navigationController;
    if ([nav respondsToSelector:@selector(didFinishPickingPhotos:)]) {
        [nav didFinishPickingPhotos:self.photosSelectedArray];
    }
}

#pragma mark - <ZWPhotoBrowserViewControllerDelegate>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(ZWPhotoBrowserViewController *)photoBrowser {
    return self.photosArray.count;
}

- (NSUInteger)numberOfSelectedPhotosInPhotoBrowser:(ZWPhotoBrowserViewController *)photoBrowser {
    return self.photosSelectedArray.count;
}

- (ZWPhoto *)photoBrowser:(ZWPhotoBrowserViewController *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    if (index >= self.photosArray.count) {
        return nil;
    }
    
    ZWPhoto *aPhoto = [self.photosArray objectAtIndex:index];
    NSCParameterAssert([aPhoto isKindOfClass:[ZWPhoto class]]);
    return aPhoto;
}

- (BOOL)photoBrowser:(ZWPhotoBrowserViewController *)photoBrowser photoIsCheckedAtIndex:(NSUInteger)index {
    
    if (index >= self.photosArray.count) {
        return NO;
    }
    ZWPhoto *aPhoto = [self.photosArray objectAtIndex:index];
    
    if ([self.photosSelectedArray containsObject:aPhoto]) {
        return YES;
    }
    return NO;
}

- (BOOL)photoBrowser:(ZWPhotoBrowserViewController *)photoBrowser shouldCheckPhotoAtIndex:(NSUInteger)index {
    if (self.photosSelectedArray.count >= _maximumPhotosSelectable) {
        NSLog(@"最多只能选择%d张照片", (int)_maximumPhotosSelectable);
        return false;
    }
    return true;
}

- (void)photoBrowser:(ZWPhotoBrowserViewController *)photoBrowser didPhotoCheckedAtIndex:(NSUInteger)index {
    if (index >= self.photosArray.count) {
        return;
    }
    
    ZWPhoto *aPhoto = [self.photosArray objectAtIndex:index];
    if (![self.photosSelectedArray containsObject:aPhoto] && [aPhoto isKindOfClass:[ZWPhoto class]]) {
        [self.photosSelectedArray addObject:aPhoto];
    }
}

- (void)photoBrowser:(ZWPhotoBrowserViewController *)photoBrowser didPhotoUnCheckedAtIndex:(NSUInteger)index {
    if (index >= self.photosArray.count) {
        return;
    }
    
    ZWPhoto *aPhoto = [self.photosArray objectAtIndex:index];
    if ([self.photosSelectedArray containsObject:aPhoto]) {
        [self.photosSelectedArray removeObject:aPhoto];
    }
}

- (void)photoBrowser:(ZWPhotoBrowserViewController *)photoBrowser didFinishPickingPhotosWithInfo:(NSDictionary *)info {
    [self didFinishPickingPhotos];
}
/*
 我所学到的：
 UTI是ALAsset框架中的一个重要概念；ALAssetRepresentation对象包含一个叫UTI的属性；
 可以通过UTI这个属性获取ALAsset指定的ALAssetRepresentation（一种图片）
 方法：- (ALAssetRepresentation *)representationForUTI:(NSString *)representationUTI;
 我所知道的UTI包括："public.jpeg"   "public.png"
 
 获取ALAssetRepresentation尺寸，ALAssetRepresentation.dimensions
 获取ALAssetRepresentation大小，ALAssetRepresentation.size
 // Returns the size of the file for this representation.
 获取ALAssetRepresentation地址，ALAssetRepresentation.url，譬如：
 assets-library://asset/asset.JPG?id=7A2CC5A0-5EEF-49D0-A0AB-D1629642CB44&ext=JPG
 但这个NSData貌似不能通过这个URL读数据；
 
 获取ALAssetRepresentation源数据（详细信息），ALAssetRepresentation.metadata，这是一个NSDictionary信息，包括：
 像素高、像素宽、色域depth、colorModel等
 
 一个ALAsset可能对应多个representation（ALAssetRepresentation *），
 每个ALAssetRepresentation对应一种格式的图片，譬如raw、png、jpeg；
 
 UIImagePNGRepresentation不可随便使用，jpeg图片经过这种png转换会变小，png使用会增大，总之UIImagePNGRepresentation不好用；
 */
@end
