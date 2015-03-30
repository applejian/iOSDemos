//
//  YWRegisterViewController2.m
//  YunWan
//
//  Created by 张威 on 15/2/2.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "YWRegisterViewController2.h"
#import "NSString+TyanTop.h"
#import "UIButton+Activity.h"
#import "AppDelegate.h"
#import "MainNavigationController.h"
#import "Masonry.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define VERTIRY_OK_IMAGE_NAME       @"vertify_ok"
#define VERTIRY_ERROR_IMAGE_NAME    @"vertify_error"


@interface YWRegisterViewController2 () <UITextFieldDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIView *bgView;

@property (strong, nonatomic) UIView *registerView;
//@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UITextField *userNameTextField;
@property (strong, nonatomic) UITextField *firstPasswordTextField;
@property (strong, nonatomic) UITextField *secondPasswordTextField;
@property (strong, nonatomic) UITextField *vertifyCodeTextField;
@property (strong, nonatomic) UIButton *getVertifyCodeButton;
@property (strong, nonatomic) UIButton *registerButton;

@property (strong, nonatomic) UIImageView *phoneNumberImageView;
@property (strong, nonatomic) UIImageView *firstPasswordImageView;
@property (strong, nonatomic) UIImageView *secondPasswordImageView;

@property (strong, nonatomic) UILabel *labelForCountDown;   // 倒计时使用的

@property (strong, nonatomic) UIView *qqLoginView;
@property (strong, nonatomic) UIImageView *qqImageView;
@property (strong, nonatomic) UILabel *qqLabel;

@property (strong, nonatomic) UIView *weChatLoginView;
@property (strong, nonatomic) UIImageView *weChatImageView;
@property (strong, nonatomic) UILabel *weChatLabel;

@property (nonatomic, assign) long countdownNumber; // 倒计时时间
@property (nonatomic, strong) NSTimer *countDownTimer;

@property (nonatomic, strong) UIAlertView *alertViewForBackButton;

@property (weak) UITextField *activeField;

@property (strong, nonatomic) UIImageView *leftCloudImageView;
@property (strong, nonatomic) UIImageView *rightCloudImageView;
@property (strong, nonatomic) UIImageView *centerCloudImageView;

@property (assign, nonatomic) BOOL phoneNumberIsValid;
@property (strong, nonatomic) NSString *phoneNumberString;
@property (assign, nonatomic) BOOL firstPasswordIsValid;
@property (strong, nonatomic) NSString *firstPassword;
@property (assign, nonatomic) BOOL secondPasswordIsValid;
@property (strong, nonatomic) NSString *secondPassword;
@property (assign, nonatomic) BOOL vertifyCodeIsValid;
@property (strong, nonatomic) NSString *vertifyCode;

@end

@implementation YWRegisterViewController2 {
    CGFloat keyboardHeight;
    BOOL keyboardShowingFlag;
}

- (void)initViewAndSubViews {
    
#define CORNER_RADIUS   4.0
    self.view.backgroundColor      = [UIColor whiteColor];
    UIFont *fontForTextField       = [UIFont systemFontOfSize:13.0];
    UIFont *fontForButton          = [UIFont systemFontOfSize:14.0];
    UIColor *textColorForTextField = [UIColor lightGrayColor];
    UIColor *textColorForButton    = [UIColor whiteColor];
    
    // 背景图片
    self.bgImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"loginBg"];
        imageView;
    });
    [self.view addSubview:self.bgImageView];
    [self.bgImageView makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.view;
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 0, 0);
        make.edges.equalTo(superView).insets(insets);
    }];
    
    /********************** 漂浮的云开始 **********************/
    self.leftCloudImageView = ({
        UIImageView *imageview= [[UIImageView alloc] initWithFrame:CGRectMake(10, 40, 100, 50)];
        imageview.image=[UIImage imageNamed:@"leftCloud"];
        imageview;
    });
    [self.view addSubview:self.leftCloudImageView];
    
    self.rightCloudImageView = ({
        UIImageView *imageview =
        [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80 - 10,
                                                      60, 80, 40)];
        imageview.image=[UIImage imageNamed:@"rightCloud"];
        imageview;
    });
    [self.view addSubview:self.rightCloudImageView];
    
    self.centerCloudImageView = ({
        UIImageView *imageview = [[UIImageView alloc] init];
        imageview.image=[UIImage imageNamed:@"centerCloud"];
        imageview;
    });
    [self.view addSubview:self.centerCloudImageView];
    
    [self.centerCloudImageView makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.view;
        UIEdgeInsets insets = UIEdgeInsetsMake(100, 0, 0, 0);
        
        make.width.equalTo(@(153));
        make.height.equalTo(@(202));
        make.centerX.equalTo(superView.centerX);
        make.top.equalTo(superView).insets(insets);
    }];
    
    [UIView beginAnimations:Nil context:Nil];
    
    [UIView setAnimationDuration:10.0];
    
    //有位置要求：写在动画效果的上面
    //RepeatCount:重复次数
    //设置动画的重复次数   LONG_MAX：无穷大
    [UIView setAnimationRepeatCount:LONG_MAX];
    //reverse:相反
    //设置反动画
    [UIView setAnimationRepeatAutoreverses:YES];
    
    //Curve:弯曲、曲线
    //设置动画的速度 Ease:缓慢
    //EaseIn：起始慢，后来快
    //EaseOut:开始快，结束时慢
    //EaseInOut:中间快，两头慢
    //Linear：匀速运动
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    self.leftCloudImageView.frame = CGRectMake(SCREEN_WIDTH - 80 - 10, 50, 50, 40);
    self.rightCloudImageView.frame = CGRectMake(10, 70, 100, 50);
    [UIView commitAnimations];
    
    /********************** 漂浮的云结束 **********************/

#define kTextFieldHeight                   36.0
#define kRegisterButtonHeight              36.0
#define kVSpacingBetweenTextField          10.0
#define kVSpacingBetweenTextFieldAndButton 16.0
#define kRegisterViewPadding               20.0
#define kQQLoginViewHeight                 32.0
    
    /********************** 注册区域开始 **********************/
    self.registerView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor =
        [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
        view.layer.cornerRadius = 2.0;
        view;
    });
    
    [self.view addSubview:self.registerView];
    
    CGFloat registerViewHeight =
    kRegisterViewPadding +
    kTextFieldHeight + kVSpacingBetweenTextField +              // 用户名
    kTextFieldHeight + kVSpacingBetweenTextField +              // 验证码
    kTextFieldHeight + kVSpacingBetweenTextField +              // 密码1
    kTextFieldHeight + kVSpacingBetweenTextFieldAndButton +     // 密码2
    kRegisterButtonHeight + kVSpacingBetweenTextFieldAndButton +// 注册
    kQQLoginViewHeight + kRegisterViewPadding;
    
    [self.registerView makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.view;
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 20, 20, 20);
        make.left.equalTo(superView).insets(insets);
        make.right.equalTo(superView).insets(insets);
        make.bottom.equalTo(superView).insets(insets);
        make.height.equalTo(@(registerViewHeight));
    }];
    
    // 用户名输入框
    self.userNameTextField = ({
        UITextField *textField       = [[UITextField alloc] init];
        textField.borderStyle        = UITextBorderStyleNone;
        textField.backgroundColor    = [UIColor whiteColor];
        textField.font               = fontForTextField;
        textField.textColor          = textColorForTextField;
        textField.placeholder        = @"请输入手机号";
        textField.layer.cornerRadius = CORNER_RADIUS;
        textField.leftViewMode       = UITextFieldViewModeAlways;
        textField.clearButtonMode    = UITextFieldViewModeWhileEditing;
        textField.keyboardType       = UIKeyboardTypePhonePad;
        textField.delegate           = self;
        textField.leftView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
            view;
        });
        textField;
    });
    [self.registerView addSubview:self.userNameTextField];
    
    self.phoneNumberImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView;
    });
    [self.registerView addSubview:self.phoneNumberImageView];
    
    // 验证码输入框
    self.vertifyCodeTextField = ({
        UITextField *textField       = [[UITextField alloc] init];
        textField.borderStyle        = UITextBorderStyleNone;
        textField.backgroundColor    = [UIColor whiteColor];
        textField.font               = fontForTextField;
        textField.textColor          = textColorForTextField;
        textField.placeholder        = @"验证码";
        textField.layer.cornerRadius = CORNER_RADIUS;
        textField.leftViewMode       = UITextFieldViewModeAlways;
        textField.clearButtonMode    = UITextFieldViewModeWhileEditing;
        textField.keyboardType       = UIKeyboardTypeNumberPad;
        textField.delegate           = self;
        textField.leftView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
            view;
        });
        textField;
    });
    [self.registerView addSubview:self.vertifyCodeTextField];
    
    // 获取验证码按钮
    self.getVertifyCodeButton = ({
        UIButton *button          = [[UIButton alloc] init];
        button.layer.cornerRadius = CORNER_RADIUS;
        [button setTitle:@"获取验证码" forState:UIControlStateNormal];
        [button setTitle:@"获取中..." forState:UIControlStateDisabled];
        button.titleLabel.font    = fontForButton;
        [button setTitleColor:textColorForButton forState:UIControlStateNormal];
        [button setTitleColor:YunWanButtonDisableTitleColor
                     forState:UIControlStateDisabled];
        button.backgroundColor    = YunWanButtonBackgroundRedColor;
        [button addTarget:self
                   action:@selector(getVertifyCodeNow:)
         forControlEvents:UIControlEventTouchDown];
        button;
    });
    [self.registerView addSubview:self.getVertifyCodeButton];
    
    // 倒计时Label
    self.labelForCountDown = ({
        UILabel *label      = [[UILabel alloc] init];
        label.font          = fontForButton;
        label.textColor     = textColorForButton;
        label.textAlignment = NSTextAlignmentCenter;
        label.text          = @"";
        label.hidden        = YES;
        label;
    });
    [self.registerView addSubview:self.labelForCountDown];
    
    // firstPasswordTextField
    self.firstPasswordTextField = ({
        UITextField *textField       = [[UITextField alloc] init];
        textField.borderStyle        = UITextBorderStyleNone;
        textField.backgroundColor    = [UIColor whiteColor];
        textField.font               = fontForTextField;
        textField.textColor          = textColorForTextField;
        textField.placeholder        = @"请输入密码";
        textField.layer.cornerRadius = CORNER_RADIUS;
        textField.leftViewMode       = UITextFieldViewModeAlways;
        textField.clearButtonMode    = UITextFieldViewModeWhileEditing;
        textField.delegate           = self;
        textField.secureTextEntry    = YES;
        textField.leftView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
            view;
        });

        textField;
    });
    [self.registerView addSubview:self.firstPasswordTextField];
    
    self.firstPasswordImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView;
    });
    [self.registerView addSubview:self.firstPasswordImageView];
    
    // secondPasswordTextField
    self.secondPasswordTextField = ({
        UITextField *textField       = [[UITextField alloc] init];
        textField.borderStyle        = UITextBorderStyleNone;
        textField.backgroundColor    = [UIColor whiteColor];
        textField.font               = fontForTextField;
        textField.textColor          = textColorForTextField;
        textField.placeholder        = @"请确认密码";
        textField.layer.cornerRadius = CORNER_RADIUS;
        textField.leftViewMode       = UITextFieldViewModeAlways;
        textField.clearButtonMode    = UITextFieldViewModeWhileEditing;
        textField.delegate           = self;
        textField.secureTextEntry    = YES;
        textField.leftView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
            view;
        });
        
        textField;
    });
    [self.registerView addSubview:self.secondPasswordTextField];
    
    self.secondPasswordImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView;
    });
    [self.registerView addSubview:self.secondPasswordImageView];
    
    // 注册按钮
    self.registerButton = ({
        UIButton *button = [[UIButton alloc] init];
        button.layer.cornerRadius = CORNER_RADIUS;
        [button setTitle:@"注册" forState:UIControlStateNormal];
        [button setTitle:@"正在注册..." forState:UIControlStateDisabled];
        [button setTitleColor:YunWanButtonDisableTitleColor
                     forState:UIControlStateDisabled];
        button.titleLabel.font = fontForButton;
        [button setTitleColor:textColorForButton forState:UIControlStateNormal];
        button.backgroundColor = YunWanButtonBackgroundRedColor;
        [button addTarget:self
                   action:@selector(registerNow:)
         forControlEvents:UIControlEventTouchDown];
        button;
    });
    [self.registerView addSubview:self.registerButton];
    
    // QQ登录
    self.qqLoginView = ({
        UIView *view = [[UIView alloc] init];
        view.layer.cornerRadius = CORNER_RADIUS;
        view.layer.borderColor = [[UIColor whiteColor] CGColor];
        view.layer.borderWidth = 1.0;
        view.backgroundColor = [UIColor clearColor];
        [view addGestureRecognizer:({
            UITapGestureRecognizer *gesture =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginWithQQ:)];
            gesture.numberOfTapsRequired = 1;
            gesture;
        })];
        view;
    });
    [self.registerView addSubview:self.qqLoginView];
    
    // 微信登录
    self.weChatLoginView = ({
        UIView *view            = [[UIView alloc] init];
        view.layer.cornerRadius = CORNER_RADIUS;
        view.layer.borderColor = [[UIColor whiteColor] CGColor];
        view.layer.borderWidth = 1.0;
        view.backgroundColor = [UIColor clearColor];
        [view addGestureRecognizer:({
            UITapGestureRecognizer *gesture =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginWithWeChat:)];
            gesture.numberOfTapsRequired = 1;
            gesture;
        })];
        view;
    });
    [self.registerView addSubview:self.weChatLoginView];
    
    /********************************* 布局TextField和button *********************************/
    UIEdgeInsets registerViewInsets =
    UIEdgeInsetsMake(kRegisterViewPadding, kRegisterViewPadding, kRegisterViewPadding, kRegisterViewPadding);
    
    [self.userNameTextField makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.registerView;
        make.top.equalTo(superView).insets(registerViewInsets);
        make.height.equalTo(@(kTextFieldHeight));
        make.left.equalTo(superView).insets(registerViewInsets);
        make.right.equalTo(superView).insets(registerViewInsets);
        make.right.equalTo(self.phoneNumberImageView.right).offset(8);
        
        make.bottom.equalTo(self.vertifyCodeTextField.top).offset(-kVSpacingBetweenTextField);
    }];
    
    [self.phoneNumberImageView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(23));
        make.height.equalTo(@(22));
        make.centerY.equalTo(self.userNameTextField.centerY);
        make.right.equalTo(self.userNameTextField.right).offset(-8);
    }];
    
    [self.vertifyCodeTextField makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.registerView;
        make.left.equalTo(superView).insets(registerViewInsets);
        make.right.equalTo(self.getVertifyCodeButton.left).offset(-kVSpacingBetweenTextField);
        make.height.equalTo(@(kTextFieldHeight));
        make.width.equalTo(self.getVertifyCodeButton.width);
        
        make.top.equalTo(self.userNameTextField.bottom).offset(kVSpacingBetweenTextField);
        make.bottom.equalTo(self.firstPasswordTextField.top).offset(-kVSpacingBetweenTextField);
    }];
    
    [self.getVertifyCodeButton makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.registerView;
        make.right.equalTo(superView).insets(registerViewInsets);
        make.left.equalTo(self.vertifyCodeTextField.right).offset(kVSpacingBetweenTextField);
        make.height.equalTo(@(kTextFieldHeight));
        make.width.equalTo(self.vertifyCodeTextField.width);
        
        make.top.equalTo(self.vertifyCodeTextField.top);
    }];
    
    [self.labelForCountDown makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.getVertifyCodeButton.left);
        make.right.equalTo(self.getVertifyCodeButton.right);
        make.top.equalTo(self.getVertifyCodeButton.top);
        make.bottom.equalTo(self.getVertifyCodeButton.bottom);
    }];
    
    [self.firstPasswordTextField makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.registerView;
        make.left.equalTo(superView).insets(registerViewInsets);
        make.right.equalTo(superView).insets(registerViewInsets);
        make.right.equalTo(self.firstPasswordImageView.right).offset(8);
        make.height.equalTo(@(kTextFieldHeight));
        
        make.top.equalTo(self.vertifyCodeTextField.bottom).offset(kVSpacingBetweenTextField);
        make.bottom.equalTo(self.secondPasswordTextField.top).offset(-kVSpacingBetweenTextField);
    }];
    
    [self.firstPasswordImageView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(23));
        make.height.equalTo(@(22));
        make.centerY.equalTo(self.firstPasswordTextField.centerY);
        make.right.equalTo(self.firstPasswordTextField.right).offset(-8);
    }];
    
    [self.secondPasswordTextField makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.registerView;
        make.left.equalTo(superView).insets(registerViewInsets);
        make.right.equalTo(superView).insets(registerViewInsets);
        make.right.equalTo(self.secondPasswordImageView.right).offset(8);
        make.height.equalTo(@(kTextFieldHeight));
        
        make.top.equalTo(self.firstPasswordTextField.bottom).offset(kVSpacingBetweenTextField);
        make.bottom.equalTo(self.registerButton.top).offset(-kVSpacingBetweenTextFieldAndButton);
    }];
    
    [self.secondPasswordImageView makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(23));
        make.height.equalTo(@(22));
        make.centerY.equalTo(self.secondPasswordTextField.centerY);
        make.right.equalTo(self.secondPasswordTextField.right).offset(-8);
    }];
    
    [self.registerButton makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.registerView;
        make.left.equalTo(superView).insets(registerViewInsets);
        make.right.equalTo(superView).insets(registerViewInsets);
        make.height.equalTo(@(kTextFieldHeight));
        
        make.top.equalTo(self.secondPasswordTextField.bottom).offset(kVSpacingBetweenTextFieldAndButton);
        make.bottom.equalTo(self.qqLoginView.top).offset(-kVSpacingBetweenTextFieldAndButton);
    }];
    
    [self.qqLoginView makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.registerView;
        make.width.equalTo(@(96));
        make.height.equalTo(@(kQQLoginViewHeight));
        make.left.equalTo(superView).insets(registerViewInsets);
        make.bottom.equalTo(superView).insets(registerViewInsets);
    }];
    
    [self.weChatLoginView makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.registerView;
        make.width.equalTo(@(96));
        make.height.equalTo(@(kQQLoginViewHeight));
        make.right.equalTo(superView).insets(registerViewInsets);
        make.bottom.equalTo(superView).insets(registerViewInsets);
    }];
    
    self.qqImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image        = [UIImage imageNamed:@"qqwhite"];
        imageView;
    });
    [self.qqLoginView addSubview:self.qqImageView];
    
    self.qqLabel = ({
        UILabel *label      = [[UILabel alloc] init];
        label.textColor     = [UIColor whiteColor];
        label.font          = [UIFont systemFontOfSize:13.0];
        label.text          = @"QQ登陆";
        label.textAlignment = NSTextAlignmentRight;
        label;
    });
    [self.qqLoginView addSubview:self.qqLabel];
    
    [self.qqImageView makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView   = self.qqLoginView;
        UIEdgeInsets insets = UIEdgeInsetsMake(4, 8, 0, 0);
        make.left.equalTo(superView).insets(insets);
        make.top.equalTo(superView).insets(insets);
        make.width.equalTo(@24);
        make.height.equalTo(@(24));
    }];
    
    [self.qqLabel makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView   = self.qqLoginView;
        UIEdgeInsets insets = UIEdgeInsetsMake(6, 30, 0, 0);
        make.left.equalTo(superView).insets(insets);
        make.top.equalTo(superView).insets(insets);
        make.width.equalTo(@54);
        make.height.equalTo(@(20));
    }];
    
    self.weChatImageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image        = [UIImage imageNamed:@"wx_logo"];
        imageView;
    });
    [self.weChatLoginView addSubview:self.weChatImageView];
    
    self.weChatLabel = ({
        UILabel *label      = [[UILabel alloc] init];
        label.textColor     = [UIColor whiteColor];
        label.font          = [UIFont systemFontOfSize:13.0];
        label.text          = @"微信登录";
        label.textAlignment = NSTextAlignmentRight;
        label;
    });
    [self.weChatLoginView addSubview:self.weChatLabel];
    
    [self.weChatImageView makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView   = self.weChatLoginView;
        UIEdgeInsets insets = UIEdgeInsetsMake(4, 8, 0, 0);
        make.left.equalTo(superView).insets(insets);
        make.top.equalTo(superView).insets(insets);
        make.width.equalTo(@24);
        make.height.equalTo(@(24));
    }];
    
    [self.weChatLabel makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView   = self.weChatLoginView;
        UIEdgeInsets insets = UIEdgeInsetsMake(6, 30, 0, 0);
        make.left.equalTo(superView).insets(insets);
        make.top.equalTo(superView).insets(insets);
        make.width.equalTo(@58);
        make.height.equalTo(@(20));
    }];
    
    /********************** 注册区域结束 **********************/

    // 配置navigation bar开始
    self.navigationItem.leftBarButtonItem = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 12, 22)];
        [button setBackgroundImage:[UIImage imageNamed:@"back_arrow"]
                          forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(getBackLastPage:)
         forControlEvents:UIControlEventTouchDown];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]
                                          initWithCustomView:button];
        barButtonItem;
    });
    
    self.navigationItem.titleView = ({
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = NAVIGATION_BAR_TITLE_FONT;
        titleLabel.textColor = NAVIGATION_BAR_TITLE_COLOR;
        titleLabel.text = @"注册";
        titleLabel;
    });
    // 配置navigation bar结束
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViewAndSubViews];
    // Do any additional setup after loading the view.
    
    // notification for keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [self.userNameTextField addObserver:self
                             forKeyPath:@"text"
                                options:NSKeyValueObservingOptionNew
                                context:nil];
    [self.firstPasswordTextField addObserver:self
                                  forKeyPath:@"text"
                                     options:NSKeyValueObservingOptionNew
                                     context:nil];
    [self.secondPasswordTextField addObserver:self
                                   forKeyPath:@"text"
                                      options:NSKeyValueObservingOptionNew
                                      context:nil];
    [self.vertifyCodeTextField addObserver:self
                                forKeyPath:@"text"
                                   options:NSKeyValueObservingOptionNew
                                   context:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 显示navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponders];
    
    [super viewWillDisappear:animated];
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
    if ([object isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)object;
        NSString *textFieldNewText = [change objectForKey:NSKeyValueChangeNewKey];
        
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        textFieldNewText = [textFieldNewText stringByTrimmingCharactersInSet:whitespace];
        NSError *error;
        
        if (textField == self.userNameTextField) {
            self.phoneNumberIsValid = [NSString isValidMobilePhoneNumber:textFieldNewText error:&error];
            
            if (!self.phoneNumberIsValid) {
                self.phoneNumberImageView.image = [UIImage imageNamed:VERTIRY_ERROR_IMAGE_NAME];
            } else {
                self.phoneNumberString = textFieldNewText;
                self.phoneNumberImageView.image = [UIImage imageNamed:VERTIRY_OK_IMAGE_NAME];
            }
        } else if (textField == self.firstPasswordTextField) {
            self.firstPasswordIsValid = [NSString isValidPassword:textFieldNewText error:&error];
            if (self.firstPasswordIsValid) {
                self.firstPasswordImageView.image = [UIImage imageNamed:VERTIRY_OK_IMAGE_NAME];
                self.firstPassword = textFieldNewText;
            } else {
                self.firstPasswordImageView.image = [UIImage imageNamed:VERTIRY_ERROR_IMAGE_NAME];
            }
        } else if (textField == self.secondPasswordTextField) {
            self.secondPasswordIsValid = [NSString isValidPassword:textFieldNewText error:&error];
            
            if (self.secondPasswordIsValid) {
                self.secondPasswordImageView.image = [UIImage imageNamed:VERTIRY_OK_IMAGE_NAME];
                self.secondPassword = textFieldNewText;
            } else {
                self.secondPasswordImageView.image = [UIImage imageNamed:VERTIRY_ERROR_IMAGE_NAME];
            }
        } else if (textField == self.vertifyCodeTextField) {
            self.vertifyCodeIsValid = [NSString isValidVerifyCode:textFieldNewText error:&error];
            if (self.vertifyCodeIsValid) {
                self.vertifyCode = textFieldNewText;
            }
        }
    }
    
}

- (UIAlertView *)alertViewForBackButton {
    if (_alertViewForBackButton == nil) {
        _alertViewForBackButton =
        [[UIAlertView alloc] initWithTitle:@"确定离开？"
                                   message:@"如果离开，验证码将无效！"
                                  delegate:self
                         cancelButtonTitle:@"取消"
                         otherButtonTitles:@"确定", nil];
        [self.view addSubview:_alertViewForBackButton];
    }
    return _alertViewForBackButton;
}

// 返回“上一页”
- (void)getBackLastPage:(UIButton *)sender {
    if (self.countdownNumber > 0) {
        [self.alertViewForBackButton show];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// 点击self.view其余部分隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// 隐藏键盘
- (void)resignFirstResponders {
    [self.view endEditing:YES];
}

// 获取验证码
- (void)getVertifyCodeNow:(UIButton *)sender {
    [self resignFirstResponders];
    // get Vertify Code Now
}

// 注册
- (void)registerNow:(id)sender {
    
    // register now
}

/* 处理验证码倒计时开始 */

- (void)refrushCountDownButtonTitle {
    self.countdownNumber--;
    self.labelForCountDown.text = [NSString stringWithFormat:@"%ld", self.countdownNumber];
}

// 倒计时终止
- (void)terminateCountDown {
    
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
    
    self.getVertifyCodeButton.enabled = YES;
    self.labelForCountDown.hidden = YES;
    self.countdownNumber = 0;
    [self.getVertifyCodeButton setTitle:@"重新获取" forState:UIControlStateNormal];
    [self.getVertifyCodeButton setTitle:@"获取中..." forState:UIControlStateDisabled];
}

- (void)refreshCountInButton {
    
    if (self.countdownNumber > 0) {
        [self refrushCountDownButtonTitle];
    } else {
        [self terminateCountDown];
    }
}

/* 处理验证码倒计时结束 */

#pragma mark -- UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //textField.layer.borderColor = [UIColor CDoomTextFieldEditingBorderColor].CGColor;
    if (textField == self.userNameTextField) {
        self.phoneNumberImageView.image = nil;
    } else if (textField == self.firstPasswordTextField) {
        self.firstPasswordImageView.image = nil;
    } else if (textField == self.secondPasswordTextField) {
        self.secondPasswordImageView.image = nil;
    }

    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.alertViewForBackButton) {
        if (buttonIndex == 1) {
            // 返回到上一页
            [self.navigationController popViewControllerAnimated:YES];
        } else if (buttonIndex == 0) {
            return;
        }
    }
}

// QQ登陆
- (void)loginWithQQ:(UIGestureRecognizer *)gesture {
    // QQ登陆
}

- (void)loginWithWeChat:(UIGestureRecognizer *)gesture {
    // @"微信登录"
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.countDownTimer invalidate];
    self.countDownTimer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self.userNameTextField removeObserver:self forKeyPath:@"text"];
    [self.firstPasswordTextField removeObserver:self forKeyPath:@"text"];
    [self.secondPasswordTextField removeObserver:self forKeyPath:@"text"];
    [self.vertifyCodeTextField removeObserver:self forKeyPath:@"text"];
}

/* 处理键盘挡住文本框问题开始 */

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

- (void)keyBoardDidShow:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    
    CGSize keyboardSize =
    [[keyboardInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    keyboardHeight = keyboardSize.height;
    keyboardShowingFlag = true;
    
    // tell constraints they need updating
    [self.view setNeedsUpdateConstraints];
    
    // update constraints now so we can animate the change
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];

}

// this is Apple's recommended place for adding/updating constraints
- (void)updateViewConstraints {
    
    CGFloat registerViewHeight =
    kRegisterViewPadding +
    kTextFieldHeight + kVSpacingBetweenTextField +              // 用户名
    kTextFieldHeight + kVSpacingBetweenTextField +              // 验证码
    kTextFieldHeight + kVSpacingBetweenTextField +              // 密码1
    kTextFieldHeight + kVSpacingBetweenTextFieldAndButton +     // 密码2
    kRegisterButtonHeight + kVSpacingBetweenTextFieldAndButton +// 注册
    kQQLoginViewHeight + kRegisterViewPadding;
    
    
    [self.registerView remakeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.view;
        UIEdgeInsets insets = {0,0,0,0};
        if (keyboardShowingFlag) {
            // 键盘呼出
            insets = UIEdgeInsetsMake(0, 20, 0, 20);
            make.top.equalTo(superView).insets(insets);
        } else {
            insets = UIEdgeInsetsMake(0, 20, 20, 20);
            make.bottom.equalTo(superView).insets(insets);
        }
        make.left.equalTo(superView).insets(insets);
        make.right.equalTo(superView).insets(insets);
        make.height.equalTo(@(registerViewHeight));
    }];
    
    [super updateViewConstraints];
}


- (void)keyBoardWillHide:(NSNotification *)notification {
    keyboardShowingFlag = false;
    
    // tell constraints they need updating
    [self.view setNeedsUpdateConstraints];
    
    // update constraints now so we can animate the change
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    [self resignFirstResponders];
}

/* handle login begin */

// 登录
- (void)loginWithAcount:(NSString *)acount password:(NSString *)password {
    // login with account
}

/* handle login end */

@end
