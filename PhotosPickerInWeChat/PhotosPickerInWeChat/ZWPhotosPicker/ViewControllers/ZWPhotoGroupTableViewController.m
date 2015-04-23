//
//  ZWPhotoGroupTableViewController.m
//  ImageSelectorImitatedWeChat
//
//  Created by 张威 on 15/4/15.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "ZWPhotoGroupTableViewController.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "ZWPhotosCollectionViewController.h"

#define kCellHeight         70.0        // cell height
#define kThumbnailLength    60.0        // poster image length

@interface ZWPhotoGroupTableViewController ()

@property (nonatomic, strong) NSMutableArray *photoGroupArray;

@end

@interface ZWPhotoGroupTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImage *posterImage;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int assetsNumber;

@end

@implementation ZWPhotoGroupTableViewCell {
    UIImageView *posterImageView;
    UILabel *nameLabel;
    UILabel *assetsNumberLabel;
    UIView *separatorView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        posterImageView   = [[UIImageView alloc] init];
        [self.contentView addSubview:posterImageView];
        
        nameLabel           = [[UILabel alloc] init];
        nameLabel.font      = [UIFont boldSystemFontOfSize:16.0];
        nameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:nameLabel];
        
        assetsNumberLabel           = [[UILabel alloc] init];
        assetsNumberLabel.font      = [UIFont systemFontOfSize:16.0];
        assetsNumberLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:assetsNumberLabel];
        
        separatorView                 = [[UIView alloc] init];
        separatorView.backgroundColor = [[UIColor alloc] initWithWhite:235/255.f alpha:1.0];
        [self.contentView addSubview:separatorView];

        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize viewSize         = self.frame.size;

    posterImageView.frame   = CGRectMake((kCellHeight - kThumbnailLength) / 2,
                                         (kCellHeight - kThumbnailLength) / 2,
                                       kThumbnailLength, kThumbnailLength);
    
    CGRect nameLabelFrame      = nameLabel.frame;
    nameLabelFrame.origin.x    = viewSize.height + 10;
    nameLabelFrame.origin.y    = 0;
    nameLabelFrame.size.height = viewSize.height;
    nameLabel.frame            = nameLabelFrame;

    assetsNumberLabel.frame = CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width + 10,
                                         0, 40, viewSize.height);
    separatorView.frame     = CGRectMake(viewSize.height, viewSize.height - 1,
                                         viewSize.width - viewSize.height, 1);
}

- (void)setName:(NSString *)name {
    if ([name isEqualToString:_name]) {
        return;
    }
    _name = name;
    CGRect textRect =
    [name boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 44.0)
                       options:NSStringDrawingUsesLineFragmentOrigin
                    attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0]}
                       context:nil];
    nameLabel.text            = _name;
    CGRect nameLabelFrame     = nameLabel.frame;
    nameLabelFrame.size.width = textRect.size.width;
    nameLabel.frame           = nameLabelFrame;
}

- (void)setAssetsNumber:(int)assetsNumber {
    if (assetsNumber == _assetsNumber) {
        return;
    }
    _assetsNumber = assetsNumber;
    assetsNumberLabel.text = [NSString stringWithFormat:@"(%d)", _assetsNumber];
    
    CGRect assetsNumberLabelFrame     = assetsNumberLabel.frame;
    assetsNumberLabelFrame.origin.x = nameLabel.frame.origin.x + nameLabel.frame.size.width + 10;
}

- (void)setPosterImage:(UIImage *)posterImage {
    if (_posterImage == posterImage) {
        return;
    }
    _posterImage = posterImage;
    posterImageView.image = _posterImage;
}

@end

@implementation ZWPhotoGroupTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _photoGroupArray = [NSMutableArray array];
    }
    return self;
}

- (void)initViewAndSubViews {
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // configure navigation bar
    self.title = @"照片";
    self.navigationItem.rightBarButtonItem = ({
        UIBarButtonItem *barButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(dismissNow)];
        barButtonItem;
    });
}

static NSString * const cellReuseIdentifier = @"UITableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViewAndSubViews];
    
    [self.tableView registerClass:[ZWPhotoGroupTableViewCell class]
           forCellReuseIdentifier:cellReuseIdentifier];
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group && group.numberOfAssets > 0) {
            [self.photoGroupArray addObject:group];
            [group enumerateAssetsWithOptions:0
                                   usingBlock:nil];
        } else if (self.photoGroupArray.count > 0) {
            [self.tableView reloadData];
        }
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
    };
    
    ALAssetsGroupType type =
    ALAssetsGroupAll;
    
    [self.sharedAssetsLibrary enumerateGroupsWithTypes:type
                                            usingBlock:resultsBlock
                                          failureBlock:failureBlock];
}

- (void)dismissNow {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (ALAssetsLibrary *)sharedAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *assetsLibrary = nil;
    dispatch_once(&pred, ^{
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    });
    return assetsLibrary;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.photoGroupArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWPhotoGroupTableViewCell *cell =
    (ZWPhotoGroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier
                                                                 forIndexPath:indexPath];
    
    // configure cell
    ALAssetsGroup *group = [self.photoGroupArray objectAtIndex:indexPath.row];
    
    cell.name                = [group valueForProperty:ALAssetsGroupPropertyName];
    cell.assetsNumber        = (int)group.numberOfAssets;
    
    CGImageRef posterImage   = group.posterImage;
    size_t height            = CGImageGetHeight(posterImage);
    float scale              = height / kThumbnailLength;
    cell.posterImage         = [UIImage imageWithCGImage:posterImage scale:scale orientation:UIImageOrientationUp];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    
    ALAssetsGroup *assetGroup = [self.photoGroupArray objectAtIndex:indexPath.row];
    
    ZWPhotosCollectionViewController *VC =
    [[ZWPhotosCollectionViewController alloc] initWithAssetGroup:assetGroup];
    
    [self.navigationController pushViewController:VC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

@end
