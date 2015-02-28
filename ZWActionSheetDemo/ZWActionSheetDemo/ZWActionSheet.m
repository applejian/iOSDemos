//
//  ZWActionSheet.m
//  类似微信ActionSheet
//
//  Created by 张威 on 15/2/16.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "ZWActionSheet.h"

@interface ZWActionSheet () {
    CGFloat titleHeight;
}

@property (nonatomic, strong) UIWindow *actionWindow;

// sub views
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UIButton *cancelButton;

// titles
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *destructiveButtonTitle;
@property (nonatomic, strong) NSString *cancelButtonTitle;
@property (nonatomic, strong) NSArray *otherButtonTitles;

@end

@implementation ZWActionSheet

#define TITLE_FONT          [UIFont systemFontOfSize:13.0]
#define BUTTON_TITLE_FONT   [UIFont systemFontOfSize:16.0]
#define ANIMATION_DURATION  0.2

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
}

- (instancetype)initWithTitle:(NSString *)title
                     delegate:(id<ZWActionSheetDelegate>)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles {
    self = [super init];
    if (self) {
        [self commonInit];
        _buttons = [NSMutableArray array];
        
        _title = title;
        _destructiveButtonTitle = destructiveButtonTitle;
        _cancelButtonTitle = cancelButtonTitle;
        _otherButtonTitles = [otherButtonTitles copy];
        
        // titleLabel
        if (title != nil) {
            _titleView = [[UIView alloc] init];
            _titleView.backgroundColor = [UIColor whiteColor];
            
            _titleLabel = [[UILabel alloc] init];
            _titleLabel.text = title;
            _titleLabel.textColor = [UIColor lightGrayColor];
            _titleLabel.font = TITLE_FONT;
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            _titleLabel.numberOfLines = 0;
            
            [_titleView addSubview:_titleLabel];
            
            [self addSubview:_titleView];
        }
        
        // destructive button
        if (destructiveButtonTitle != nil) {
            UIButton *button = [[UIButton alloc] init];
            button.backgroundColor = [UIColor whiteColor];
            button.titleLabel.font = BUTTON_TITLE_FONT;
            [button setTitle:destructiveButtonTitle forState:UIControlStateNormal];
            [button setTitleColor:[[UIColor alloc] initWithRed:245/255.0 green:91./255.0 blue:87/255.0 alpha:1.0]
                         forState:UIControlStateNormal];
            [button addTarget:self
                       action:@selector(didButtonClicked:)
             forControlEvents:UIControlEventTouchDown];
            [_buttons addObject:button];
            [self addSubview:button];
        }
        
        // other button
        for (NSString *title in otherButtonTitles) {
            UIButton *button = [[UIButton alloc] init];
            button.backgroundColor = [UIColor whiteColor];
            button.titleLabel.font = BUTTON_TITLE_FONT;
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button addTarget:self
                       action:@selector(didButtonClicked:)
             forControlEvents:UIControlEventTouchDown];
            [_buttons addObject:button];
            [self addSubview:button];
        }
        
        // cancel button
        _cancelButton = [[UIButton alloc] init];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        _cancelButton.titleLabel.font = BUTTON_TITLE_FONT;
        [_cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self
                          action:@selector(didCancelButtonClicked:)
                forControlEvents:UIControlEventTouchDown];
        [self addSubview:_cancelButton];
        
        // view frame
        // screenWidth
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        self.frame = CGRectMake(0, 0, screenWidth, [self getViewHeight]);
        
        self.delegate = delegate;
    }
    return self;
}

#define BUTTON_HEIGHT                                               44.0
#define LABEL_MARGIN                                                16.0
#define SEPARATOR_HEIGHT                                            1.0
#define SEPARATOR_HEIGHT_BETWEEN_CANCEL_BUTTON_AND_OTHER_BUTTONS    8.0

// 计算title高度
- (CGFloat)getTitleHeight {
    
    // screenWidth
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGRect tempFrame =
    [_title boundingRectWithSize:CGSizeMake(screenWidth - LABEL_MARGIN * 2, CGFLOAT_MAX)
                         options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{NSFontAttributeName:TITLE_FONT}
                         context:nil];
    return tempFrame.size.height;
}

- (CGFloat)getViewHeight {
    
    // self.frame.size.height
    CGFloat viewHeight = 0.0;
    
    titleHeight = [self getTitleHeight];
    viewHeight += titleHeight + LABEL_MARGIN * 2;
    
    viewHeight += self.buttons.count * (BUTTON_HEIGHT + SEPARATOR_HEIGHT);
    
    // seperator height between cancel button and other buttons
    viewHeight += SEPARATOR_HEIGHT_BETWEEN_CANCEL_BUTTON_AND_OTHER_BUTTONS;
    // cancel button height
    viewHeight += BUTTON_HEIGHT;
    
    return viewHeight;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // screenWidth
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

    CGFloat tempY = 0.0;
    
    // layout titleView and titleLabel
    CGRect titleViewFrame =
    CGRectMake(0, 0, screenWidth, titleHeight + 2 * LABEL_MARGIN);
    self.titleView.frame = titleViewFrame;
    
    CGRect titleLabelFrame =
    CGRectMake(LABEL_MARGIN, LABEL_MARGIN,
               screenWidth - 2 * LABEL_MARGIN,
               titleHeight);
    self.titleLabel.frame = titleLabelFrame;
    tempY += titleHeight + LABEL_MARGIN * 2;
    
    // layout destructive button and other buttons
    for (int i = 0; i < self.buttons.count; ++i) {
        
        UIButton *button = self.buttons[i];
        button.frame =
        CGRectMake(0, tempY + SEPARATOR_HEIGHT,
                   screenWidth, BUTTON_HEIGHT);
        tempY += BUTTON_HEIGHT + SEPARATOR_HEIGHT;
    }
    
    //[self addSubview:seperatorView];
    tempY += SEPARATOR_HEIGHT_BETWEEN_CANCEL_BUTTON_AND_OTHER_BUTTONS;
    
    // layout cancel button
    self.cancelButton.frame =
    CGRectMake(0, tempY, screenWidth, BUTTON_HEIGHT);
    tempY += BUTTON_HEIGHT;
}

- (void)dismiss {
    [self dismissWithAnimation:YES];
}

- (void)dismissWithAnimation:(BOOL)animation {
    
    if (!animation) {
        [self removeFromSuperview];
        self.actionWindow.hidden = YES;
        self.actionWindow = nil;
        return;
    }
    
    CGRect viewFrameBegin = self.frame;
    
    CGRect viewFrameEnd = viewFrameBegin;
    viewFrameEnd.origin.y = self.actionWindow.bounds.size.height;
    
    __weak __typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^{
                         weakSelf.frame = viewFrameEnd;
                     }
                     completion:^(BOOL finished) {
                         [weakSelf removeFromSuperview];
                         self.actionWindow.hidden = YES;
                         weakSelf.actionWindow = nil;
                     }];

}

- (void)showInView:(UIView *)view {
    
    // create a window
    CGRect viewBounds = view.frame;
    self.actionWindow.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    self.actionWindow = [[UIWindow alloc] initWithFrame:viewBounds];
    self.actionWindow.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.05];
    self.actionWindow.windowLevel = UIWindowLevelAlert;
    
    // add tap gesture action in window
    [self.actionWindow addGestureRecognizer:({
        UITapGestureRecognizer *gesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(dismiss)];
        gesture.numberOfTapsRequired = 1;
        gesture;
    })];
    
    // make window visible
    _actionWindow.hidden = NO;
    
    [self showAnimation:YES];
}

- (void)showAnimation:(BOOL)animation {
    if (self.actionWindow == nil) {
        return;
    }
    if (!animation) {
        [_actionWindow addSubview:self];
    } else if (animation) {
        CGRect viewFrameBegin = self.frame;
        viewFrameBegin.origin.y = self.actionWindow.bounds.size.height;
        
        CGRect viewFrameEnd = viewFrameBegin;
        viewFrameEnd.origin.y = self.actionWindow.bounds.size.height - viewFrameEnd.size.height;
        
        self.frame = viewFrameBegin;
        [_actionWindow addSubview:self];
        
        __weak __typeof(self) weakSelf = self;
        
        [UIView animateWithDuration:ANIMATION_DURATION
                         animations:^{
                             weakSelf.frame = viewFrameEnd;
                         }
                         completion:^(BOOL finished) {
                             nil;
                         }];
    }
}

- (void)didCancelButtonClicked:(UIButton *)sender {
    [self dismissWithAnimation:YES];
}

- (void)didButtonClicked:(UIButton *)sender {
    [self dismissWithAnimation:YES];
    NSInteger buttonIndex = [self.buttons indexOfObject:sender];
    if (buttonIndex >= 0 &&
        [self.delegate respondsToSelector:@selector(ZWActionSheet:clickedButtonAtIndex:)]) {
        [self.delegate ZWActionSheet:self clickedButtonAtIndex:buttonIndex];
    }
}


@end
