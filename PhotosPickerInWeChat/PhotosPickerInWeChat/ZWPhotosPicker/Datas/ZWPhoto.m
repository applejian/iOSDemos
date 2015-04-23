//
//  ZWPhoto.m
//  ImageSelectorImitatedWeChat
//
//  Created by 张威 on 15/4/20.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "ZWPhoto.h"

@implementation ZWPhoto {
    ALAsset *_asset;
    BOOL _loadingInProgress;
}


@synthesize underlyingImage = _underlyingImage;

- (instancetype)initWithAsset:(ALAsset *)asset {
    self = [super init];
    if (self) {
        _asset             = asset;
        _loadingInProgress = false;
    }
    return self;
}

- (UIImage *)thumbnail {
    return [UIImage imageWithCGImage:_asset.thumbnail];
}

- (UIImage *)fullResolutionImage {
    if ([_underlyingImage isKindOfClass:[UIImage class]]) {
        return _underlyingImage;
    }
    return [UIImage imageWithCGImage:_asset.defaultRepresentation.fullResolutionImage];
}

- (long long)defaultRepresentationSize {
    return _asset.defaultRepresentation.size;
}

#pragma mark - <ZWPhoto>

- (UIImage *)underlyingImage {
    return _underlyingImage;
}

- (void)loadUnderlyingImageAndNotify {
    if (_loadingInProgress) {   // is loading image now
        return;
    }
    
    _loadingInProgress = YES;
    
    @try {
        if (self.underlyingImage) {
            [self imageLoadingComplete];
        } else {
            [self performLoadUnderlyingImageAndNotify];
        }
    }
    @catch (NSException *exception) {
        self.underlyingImage = nil;
        _loadingInProgress   = NO;
        [self imageLoadingComplete];
    }
    @finally {
    }
}

// This is called when the photo browser has determined the photo data
// is no longer needed or there are low memory conditions
// You should release any underlying (possibly large and decompressed) image data
// as long as the image can be re-loaded (from cache, file, or URL)
- (void)unloadUnderlyingImage {
    _loadingInProgress = false;
    _underlyingImage   = nil;
}

//////////////////////// ZWPhoto over ////////////////////////

- (void)imageLoadingComplete {
    // Complete so notify
    _loadingInProgress = NO;
    // Notify on next run loop
    // ???为什么不用“[self performSelector:@selector(postCompleteNotification)];”？
    [self performSelector:@selector(postCompleteNotification) withObject:nil afterDelay:0];
}

- (void)postCompleteNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kZWPhotoLoadingDidEndNotification
                                                        object:self];
}

// Fetch the image data from a source and notify when complete.
// You must load the image asyncronously (and decompress it for better performance).
// It is recommended that you use SDWebImageDecoder to perform the decompression.
// See MWPhoto object for an example implementation.
// When the underlying UIImage is loaded (or failed to load) you should post the following notification:

// [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
//                                                     object:self];
// ??? SDWebImageDecoder
- (void)performLoadUnderlyingImageAndNotify {
    // Load from asset library async
    
    __weak __typeof(self)weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            @try {
                CGImageRef iref = [_asset.defaultRepresentation fullScreenImage];
                weakSelf.underlyingImage = iref ? [UIImage imageWithCGImage:iref] : nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                
                    [weakSelf imageLoadingComplete];
                });
                
                /*
                // ???
                ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary assetForURL:_asset.defaultRepresentation.url
                               resultBlock:^(ALAsset *asset){
                                   ALAssetRepresentation *rep = [asset defaultRepresentation];
                                   CGImageRef iref = [rep fullScreenImage];
                                   if (iref) {
                                       self.underlyingImage = [UIImage imageWithCGImage:iref];
                                   }
                                   [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                               }
                              failureBlock:^(NSError *error) {
                                  self.underlyingImage = nil;
                                  NSLog(@"Photo from asset library error: %@",error);
                                  [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
                              }];
                 */
            } @catch (NSException *e) {
                NSLog(@"Photo from asset library error: %@", e);
                [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
            }
        }
    });
}

@end
