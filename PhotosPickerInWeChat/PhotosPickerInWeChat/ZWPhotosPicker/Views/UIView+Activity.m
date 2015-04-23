//
//  UIView+Activity.m
//  YunWan
//
//  Created by 张威 on 15/2/7.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "UIView+Activity.h"
#import <objc/runtime.h>

@implementation UIView (Activity)

static char kActivityIndicatorKey;
@dynamic activityIndicator;
static char kLoadingKey;
@dynamic loading;

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator {
    objc_setAssociatedObject(self, &kActivityIndicatorKey,
                             activityIndicator,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIActivityIndicatorView *)activityIndicator {
    return objc_getAssociatedObject(self, &kActivityIndicatorKey);
}

- (void)setLoading:(BOOL)loading {
    objc_setAssociatedObject(self, &kLoadingKey,
                             [NSNumber numberWithBool:loading],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (loading) {
        if (self.activityIndicator == nil) {
            self.activityIndicator = ({
                UIActivityIndicatorView *activityIndicator =
                [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                
                activityIndicator.hidesWhenStopped = YES;
                
                [self addSubview:activityIndicator];
                activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
                [self addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
                
                activityIndicator;
            });
        }
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }

}

- (BOOL)isLoading {
    NSNumber *temp = objc_getAssociatedObject(self, &kLoadingKey);
    return temp.boolValue;
}

@end
