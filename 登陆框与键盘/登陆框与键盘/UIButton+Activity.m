//
//  UIButton+Activity.m
//  YunWan
//
//  Created by 张威 on 15/2/7.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "UIButton+Activity.h"
#import <objc/runtime.h>

@implementation UIButton (Activity)

static char kActivityIndicatorKey;
@dynamic activityIndicator;
static char kWokingKey;
@dynamic working;

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator {
    objc_setAssociatedObject(self, &kActivityIndicatorKey,
                             activityIndicator,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIActivityIndicatorView *)activityIndicator {
    return objc_getAssociatedObject(self, &kActivityIndicatorKey);
}

- (void)setWorking:(BOOL)working{
    objc_setAssociatedObject(self, &kWokingKey,
                             [NSNumber numberWithBool:working],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (working) {
        if (self.activityIndicator == nil) {
            self.activityIndicator = ({
                UIActivityIndicatorView *activityIndicator =
                [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                
                activityIndicator.hidesWhenStopped = YES;
                
                [self addSubview:activityIndicator];
                activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
                [self addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
                
                activityIndicator;
            });
        }
        self.enabled = false;
        [self.activityIndicator startAnimating];
    } else {
        self.enabled = true;
        [self.activityIndicator stopAnimating];
    }

}

- (BOOL)isWorking {
    NSNumber *temp = objc_getAssociatedObject(self, &kWokingKey);
    return temp.boolValue;
}

@end
