//
// UIScrollView+SVPullToRefresh.m
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <QuartzCore/QuartzCore.h>
#import "UIScrollView+SVPullToRefresh.h"

//fequal() and fequalzro() from http://stackoverflow.com/a/1614761/184130
#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)

static CGFloat const SVPullToRefreshViewHeight = 60.0;


@interface SVPullToRefreshView ()

@property (nonatomic, copy) void (^pullToRefreshActionHandler)(void);

@property (nonatomic, readwrite) SVPullToRefreshState state;
@property (nonatomic, readwrite) SVPullToRefreshPosition position;

@property (nonatomic, strong) NSMutableArray *viewForState;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, readwrite) CGFloat originalTopInset;
@property (nonatomic, readwrite) CGFloat originalBottomInset;

@property (nonatomic, assign) BOOL wasTriggeredByUser;
@property (nonatomic, assign) BOOL showsPullToRefresh;
@property (nonatomic, assign) BOOL showsDateLabel;
@property(nonatomic, assign) BOOL isObserving;

- (void)resetScrollViewContentInset;
- (void)setScrollViewContentInsetForLoading;
- (void)setScrollViewContentInset:(UIEdgeInsets)insets;

@end



#pragma mark - UIScrollView (SVPullToRefresh)
#import <objc/runtime.h>

static char UIScrollViewPullToRefreshView;

@implementation UIScrollView (SVPullToRefresh)

@dynamic pullToRefreshView, showsPullToRefresh;

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler position:(SVPullToRefreshPosition)position {
    
    if(!self.pullToRefreshView) {
        CGFloat yOrigin;
        switch (position) {
            case SVPullToRefreshPositionTop:
                yOrigin = -SVPullToRefreshViewHeight;
                break;
            case SVPullToRefreshPositionBottom:
                yOrigin = self.contentSize.height;
                break;
            default:
                return;
        }
        SVPullToRefreshView *view =
        [[SVPullToRefreshView alloc] initWithFrame:CGRectMake(0, yOrigin, self.bounds.size.width, SVPullToRefreshViewHeight)];
        view.backgroundColor =
        [UIColor colorWithWhite:0.8 alpha:0.2];
        view.pullToRefreshActionHandler = actionHandler;
        view.scrollView = self;
        [self addSubview:view];
        
        view.originalTopInset = self.contentInset.top;
        view.originalBottomInset = self.contentInset.bottom;
        view.position = position;
        self.pullToRefreshView = view;
        self.showsPullToRefresh = YES;
    }
    
}

- (void)addPullToRefreshWithActionHandler:(void (^)(void))actionHandler {
    [self addPullToRefreshWithActionHandler:actionHandler position:SVPullToRefreshPositionTop];
}

- (void)triggerPullToRefresh {
    self.pullToRefreshView.state = SVPullToRefreshStateTriggered;
    [self.pullToRefreshView startAnimating];
}

- (void)setPullToRefreshView:(SVPullToRefreshView *)pullToRefreshView {
    [self willChangeValueForKey:@"SVPullToRefreshView"];
    objc_setAssociatedObject(self, &UIScrollViewPullToRefreshView,
                             pullToRefreshView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"SVPullToRefreshView"];
}

- (SVPullToRefreshView *)pullToRefreshView {
    return objc_getAssociatedObject(self, &UIScrollViewPullToRefreshView);
}

- (void)setShowsPullToRefresh:(BOOL)showsPullToRefresh {
    self.pullToRefreshView.hidden = !showsPullToRefresh;
    
    if(!showsPullToRefresh) {
        if (self.pullToRefreshView.isObserving) {
            [self removeObserver:self.pullToRefreshView forKeyPath:@"contentOffset"];
            [self removeObserver:self.pullToRefreshView forKeyPath:@"contentSize"];
            [self removeObserver:self.pullToRefreshView forKeyPath:@"frame"];
            [self.pullToRefreshView resetScrollViewContentInset];
            self.pullToRefreshView.isObserving = NO;
        }
    }
    else {
        if (!self.pullToRefreshView.isObserving) {
            [self addObserver:self.pullToRefreshView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.pullToRefreshView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.pullToRefreshView forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
            self.pullToRefreshView.isObserving = YES;
            
            CGFloat yOrigin = 0;
            switch (self.pullToRefreshView.position) {
                case SVPullToRefreshPositionTop:
                    yOrigin = -SVPullToRefreshViewHeight;
                    break;
                case SVPullToRefreshPositionBottom:
                    yOrigin = self.contentSize.height;
                    break;
            }
            
            self.pullToRefreshView.frame = CGRectMake(0, yOrigin, self.bounds.size.width, SVPullToRefreshViewHeight);
        }
    }
}

- (BOOL)showsPullToRefresh {
    return !self.pullToRefreshView.hidden;
}

@end

#pragma mark - SVPullToRefresh
@implementation SVPullToRefreshView

// public properties
@synthesize pullToRefreshActionHandler;

@synthesize state = _state;
@synthesize scrollView = _scrollView;
@synthesize showsPullToRefresh = _showsPullToRefresh;


- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        // default styling values
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.state = SVPullToRefreshStateIDLE;
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        // 初识状态View
        UIView *view1 = ({
            UIView *view =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, SVPullToRefreshViewHeight)];
            
            UILabel *label =
            [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, SVPullToRefreshViewHeight)];
            label.font = [UIFont systemFontOfSize:14.0];
            label.textColor = [UIColor grayColor];
            label.text = @"下拉即可刷新";
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            
            view;
        });
        
        // 下拉状态View
        UIView *view2 = ({
            UIView *view =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, SVPullToRefreshViewHeight)];
            
            UILabel *label =
            [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, SVPullToRefreshViewHeight)];
            label.font = [UIFont systemFontOfSize:14.0];
            label.textColor = [UIColor grayColor];
            label.text = @"释放即可刷新";
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            
            view;
        });
        
        // 加载状态View
        UIView *view3 = ({
            UIView *view =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, SVPullToRefreshViewHeight)];
            
            UILabel *label =
            [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, SVPullToRefreshViewHeight)];
            label.font = [UIFont systemFontOfSize:14.0];
            label.textColor = [UIColor grayColor];
            label.text = @"努力载入中...";
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            
            view;
        });
        
        // 加载成功View
        UIView *view4 = ({
            UIView *view =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, SVPullToRefreshViewHeight)];
            
            UILabel *label =
            [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, SVPullToRefreshViewHeight)];
            label.font = [UIFont systemFontOfSize:14.0];
            label.textColor = [UIColor grayColor];
            label.text = @"加载成功";
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            
            view;
        });
        
        // 加载失败View
        UIView *view5 = ({
            UIView *view =
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, SVPullToRefreshViewHeight)];
            
            UILabel *label =
            [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, SVPullToRefreshViewHeight)];
            label.font = [UIFont systemFontOfSize:14.0];
            label.textColor = [UIColor grayColor];
            label.text = @"加载失败";
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            
            view;
        });
        
        self.viewForState = [NSMutableArray arrayWithObjects:view1, view2, view3, view4, view5, nil];
        
        self.wasTriggeredByUser = YES;
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        //use self.superview, not self.scrollView. Why self.scrollView == nil here?
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showsPullToRefresh) {
            if (self.isObserving) {
                //If enter this branch, it is the moment just before "SVPullToRefreshView's dealloc", so remove observer here
                [scrollView removeObserver:self forKeyPath:@"contentOffset"];
                [scrollView removeObserver:self forKeyPath:@"contentSize"];
                [scrollView removeObserver:self forKeyPath:@"frame"];
                self.isObserving = NO;
            }
        }
    }
}

- (void)layoutSubviews {
    
    for(id otherView in self.viewForState) {
        if([otherView isKindOfClass:[UIView class]])
            [otherView removeFromSuperview];
    }
    
    id customView = [self.viewForState objectAtIndex:self.state];
    BOOL hasCustomView = [customView isKindOfClass:[UIView class]];
    
    if(hasCustomView) {
        [self addSubview:customView];
        CGRect viewBounds = [customView bounds];
        CGPoint origin = CGPointMake(roundf((self.bounds.size.width-viewBounds.size.width)/2),
                                     roundf((self.bounds.size.height-viewBounds.size.height)/2));
        [customView setFrame:CGRectMake(origin.x, origin.y, viewBounds.size.width, viewBounds.size.height)];
    }
}

#pragma mark - Scroll View

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    switch (self.position) {
        case SVPullToRefreshPositionTop:
            currentInsets.top = self.originalTopInset;
            break;
        case SVPullToRefreshPositionBottom:
            currentInsets.bottom = self.originalBottomInset;
            currentInsets.top = self.originalTopInset;
            break;
    }
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForLoading {
    CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    switch (self.position) {
        case SVPullToRefreshPositionTop:
            currentInsets.top = MIN(offset, self.originalTopInset + self.bounds.size.height);
            break;
        case SVPullToRefreshPositionBottom:
            currentInsets.bottom = MIN(offset, self.originalBottomInset + self.bounds.size.height);
            break;
    }
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:NULL];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    } else if([keyPath isEqualToString:@"contentSize"]) {
        [self layoutSubviews];
        
        CGFloat yOrigin;
        switch (self.position) {
            case SVPullToRefreshPositionTop:
                yOrigin = -SVPullToRefreshViewHeight;
                break;
            case SVPullToRefreshPositionBottom:
                yOrigin = MAX(self.scrollView.contentSize.height, self.scrollView.bounds.size.height);
                break;
        }
        self.frame = CGRectMake(0, yOrigin, self.bounds.size.width, SVPullToRefreshViewHeight);
    } else if([keyPath isEqualToString:@"frame"]) {
        [self layoutSubviews];
    }

}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if(self.state != SVPullToRefreshStateLoading) {
        CGFloat scrollOffsetThreshold = 0;
        CGFloat scrollOffsetThreshold2 = 1-SVPullToRefreshViewHeight;
        switch (self.position) {
            case SVPullToRefreshPositionTop:
                scrollOffsetThreshold = self.frame.origin.y - self.originalTopInset;
                break;
            case SVPullToRefreshPositionBottom:
                scrollOffsetThreshold = MAX(self.scrollView.contentSize.height - self.scrollView.bounds.size.height, 0.0f)
                + self.bounds.size.height + self.originalBottomInset;
                break;
        }
        
        if(!self.scrollView.isDragging && self.state == SVPullToRefreshStateTriggered) {
            
            self.state = SVPullToRefreshStateLoading;
        } else if(contentOffset.y < scrollOffsetThreshold &&
                  self.scrollView.isDragging &&
                  self.state == SVPullToRefreshStateIDLE &&
                  self.position == SVPullToRefreshPositionTop) {
            
            self.state = SVPullToRefreshStateTriggered;
        } else if (contentOffset.y >= scrollOffsetThreshold &&
                   self.state == SVPullToRefreshStateSucceed &&
                   self.position == SVPullToRefreshPositionTop) {
            
            //
        } else if (contentOffset.y <= scrollOffsetThreshold2 &&
                    self.state == SVPullToRefreshStateSucceed &&
                    self.position == SVPullToRefreshPositionTop) {
            
            self.state = SVPullToRefreshStateIDLE;
        } else if (contentOffset.y >= scrollOffsetThreshold &&
                   self.state == SVPullToRefreshStateFailed &&
                   self.position == SVPullToRefreshPositionTop) {
            
            //
        } else if (contentOffset.y <= scrollOffsetThreshold2 &&
                   self.state == SVPullToRefreshStateFailed &&
                   self.position == SVPullToRefreshPositionTop) {
            
            self.state = SVPullToRefreshStateIDLE;
        } else if(contentOffset.y >= scrollOffsetThreshold &&
                  self.state != SVPullToRefreshStateIDLE &&
                  self.position == SVPullToRefreshPositionTop) {
            
            self.state = SVPullToRefreshStateIDLE;
        } else if(contentOffset.y > scrollOffsetThreshold &&
                  self.scrollView.isDragging &&
                  self.state == SVPullToRefreshStateIDLE &&
                  self.position == SVPullToRefreshPositionBottom) {
            
            self.state = SVPullToRefreshStateTriggered;
        } else if(contentOffset.y <= scrollOffsetThreshold &&
                  self.state != SVPullToRefreshStateIDLE &&
                  self.position == SVPullToRefreshPositionBottom) {
            
            self.state = SVPullToRefreshStateIDLE;
        }
    } else {
        CGFloat offset;
        UIEdgeInsets contentInset;
        switch (self.position) {
            case SVPullToRefreshPositionTop:
                offset = MAX(self.scrollView.contentOffset.y * -1, 0.0f);
                offset = MIN(offset, self.originalTopInset + self.bounds.size.height);
                contentInset = self.scrollView.contentInset;
                self.scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right);
                break;
            case SVPullToRefreshPositionBottom:
                if (self.scrollView.contentSize.height >= self.scrollView.bounds.size.height) {
                    offset = MAX(self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.bounds.size.height, 0.0f);
                    offset = MIN(offset, self.originalBottomInset + self.bounds.size.height);
                    contentInset = self.scrollView.contentInset;
                    self.scrollView.contentInset = UIEdgeInsetsMake(contentInset.top, contentInset.left, offset, contentInset.right);
                } else if (self.wasTriggeredByUser) {
                    offset = MIN(self.bounds.size.height, self.originalBottomInset + self.bounds.size.height);
                    contentInset = self.scrollView.contentInset;
                    self.scrollView.contentInset = UIEdgeInsetsMake(-offset, contentInset.left, contentInset.bottom, contentInset.right);
                }
                break;
        }
    }
}

#pragma mark -

- (void)triggerRefresh {
    [self.scrollView triggerPullToRefresh];
}

- (void)startAnimating{
    switch (self.position) {
        case SVPullToRefreshPositionTop:
            
            if(fequalzero(self.scrollView.contentOffset.y)) {
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x,
                                                              -self.frame.size.height) animated:YES];
                self.wasTriggeredByUser = NO;
            } else {
                self.wasTriggeredByUser = YES;
            }
            
            break;
        case SVPullToRefreshPositionBottom:
            
            if((fequalzero(self.scrollView.contentOffset.y) && self.scrollView.contentSize.height < self.scrollView.bounds.size.height)
               || fequal(self.scrollView.contentOffset.y, self.scrollView.contentSize.height - self.scrollView.bounds.size.height)) {
                [self.scrollView setContentOffset:(CGPoint){.y = MAX(self.scrollView.contentSize.height - self.scrollView.bounds.size.height, 0.0f) + self.frame.size.height} animated:YES];
                self.wasTriggeredByUser = NO;
            }
            else
                self.wasTriggeredByUser = YES;
            
            break;
    }
    
    self.state = SVPullToRefreshStateLoading;
}

- (void)stopAnimatingWithState:(SVRefreshState)state {
    
    if (state == SVRefreshStateSucceed) {
        self.state = SVPullToRefreshStateSucceed;
    } else {
        self.state = SVPullToRefreshStateFailed;
    }
    
    switch (self.position) {
        case SVPullToRefreshPositionTop:
            if(!self.wasTriggeredByUser) {
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x,
                                                              -self.originalTopInset)
                                         animated:YES];
            }
            break;
        case SVPullToRefreshPositionBottom:
            if(!self.wasTriggeredByUser) {
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x,
                                                              self.scrollView.contentSize.height -
                                                              self.scrollView.bounds.size.height +
                                                              self.originalBottomInset)
                                         animated:YES];
            }
            break;
    }
}

- (void)setState:(SVPullToRefreshState)newState {
    
    if(_state == newState)
        return;
    
    SVPullToRefreshState previousState = _state;
    _state = newState;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    if (newState == SVPullToRefreshStateIDLE) {
        [self resetScrollViewContentInset];
    } else if (newState == SVPullToRefreshStateLoading) {
        [self setScrollViewContentInsetForLoading];
        
        if(previousState == SVPullToRefreshStateTriggered && pullToRefreshActionHandler) {
            pullToRefreshActionHandler();
        }
    } else if (newState == SVPullToRefreshStateSucceed || newState == SVPullToRefreshStateFailed) {
        __weak __typeof(self) weakSelf = self;
        int64_t delayInMicroSeconds = 500;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMicroSeconds * NSEC_PER_MSEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf resetScrollViewContentInset];
        });
    }
}

@end

