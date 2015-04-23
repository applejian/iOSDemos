//
//  ZWPhotoProtocol.h
//  ImageSelectorImitatedWeChat
//
//  Created by 张威 on 15/4/21.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Notifications
#define kZWPhotoLoadingDidEndNotification @"ZWPHOTO_LOADING_DID_END_NOTIFICATION"
//#define kZWPhotoProcessingNotification    @"ZWPHOTO_PROGRESS_NOTIFICATION"        网络任务时会用到

@protocol ZWPhoto <NSObject>

@required

// Return underlying UIImage to be displayed
// Return nil if the image is not immediately available (loaded into memory, preferably
// already decompressed) and needs to be loaded from a source (cache, file, web, etc)
// IMPORTANT: You should *NOT* use this method to initiate
// fetching of images from any external of source. That should be handled
// in -loadUnderlyingImageAndNotify: which may be called by the photo browser if this
// methods returns nil.
@property (nonatomic, strong) UIImage *underlyingImage;

// Called when the browser has determined the underlying images is not
// already loaded into memory but needs it.
- (void)loadUnderlyingImageAndNotify;

// Fetch the image data from a source and notify when complete.
// You must load the image asyncronously (and decompress it for better performance).
// It is recommended that you use SDWebImageDecoder to perform the decompression.
// See MWPhoto object for an example implementation.
// When the underlying UIImage is loaded (or failed to load) you should post the following notification:

// [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
//                                                     object:self];
// ??? SDWebImageDecoder
//- (void)performLoadUnderlyingImageAndNotify;

// This is called when the photo browser has determined the photo data
// is no longer needed or there are low memory conditions
// You should release any underlying (possibly large and decompressed) image data
// as long as the image can be re-loaded (from cache, file, or URL)
- (void)unloadUnderlyingImage;

@end
