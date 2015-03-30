//
//  YWLoginViewController.m
//  YunWan
//
//  Created by 张威 on 15/1/29.
//  Copyright (c) 2015年 ZhangWei. All rights reserved.
//

#import "YWLoginViewController2.h"
#import "AppDelegate.h"
#import "NSString+TyanTop.h"
#import "YWRegisterViewController2.h"
#import "YWForgetPasswordViewController2.h"
#import "MainNavigationController.h"
#import "UIButton+Activity.h"
#import "Masonry.h"
#import "AppDelegate.h"

@interface YWLoginViewController2 ()
<UITextFieldDelegate>

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

@property (strong, nonatomic) UIImageView *bgImageView;
@property (strong, nonatomic) UIView *loginView;
@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UIView *loginControlsBgView;
@property (strong, nonatomic) UITextField *userNameTextField;
@property (strong, nonatomic) UIView *lineViewBetweenTextFields;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIButton *forgetPwdButton;
@property (strong, nonatomic) UIButton *registerButton;

@property (strong, nonatomic) UIView *qqLoginView;
@property (strong, nonatomic) UIImageView *qqImageView;
@property (strong, nonatomic) UILabel *qqLabel;

@property (strong, nonatomic) UIView *weChatLoginView;
@property (strong, nonatomic) UIImageView *weChatImageView;
@property (strong, nonatomic) UILabel *weChatLabel;


@property (strong, nonatomic) UIImageView *leftCloudImageView;
@property (strong, nonatomic) UIImageView *rightCloudImageView;
@property (strong, nonatomic) UIImageView *centerCloudImageView;


@end

@implementation YWLoginViewController2 {
    CGFloat keyboardHeight;
    BOOL keyboardShowingFlag;
}

- (void)initViewAndSubViews {
#define CORNER_RADIUS   4.0
    self.view.backgroundColor = [UIColor whiteColor];
    
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

#define kTextFieldHeight      36.0
#define kLoginButtonHeight    36.0
#define kRegisterButtonHeight 20.0
#define kVSpacingBetweenViews 16.0
#define kLoginViewPadding     20.0
#define kQQLoginViewHeight    32.0

    /********************** 登录区域开始 **********************/
    self.loginView = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor =
        [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
        view.layer.cornerRadius = 2.0;
        view;
    });
    
    [self.view addSubview:self.loginView];
    
    CGFloat loginViewHeight =
    kLoginViewPadding + kTextFieldHeight * 2 + 1 + kVSpacingBetweenViews+
    kLoginButtonHeight + kVSpacingBetweenViews + kRegisterButtonHeight +
    kVSpacingBetweenViews + kQQLoginViewHeight + kLoginViewPadding;
    
    
    [self.loginView makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.view;
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 40, 40, 40);
        make.left.equalTo(superView).insets(insets);
        make.right.equalTo(superView).insets(insets);
        make.bottom.equalTo(superView).insets(insets);
        make.height.equalTo(@(loginViewHeight));
    }];
    
    // 登录框背景view
    self.loginControlsBgView = ({
        UIView *view            = [[UIView alloc] init];
        view.backgroundColor    = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        view.layer.cornerRadius = CORNER_RADIUS;
        view.backgroundColor    = [UIColor whiteColor];
        view.clipsToBounds      = YES;
        view;
    });
    [self.loginView addSubview:self.loginControlsBgView];
    
    // 登录按钮
    self.loginButton = ({
        UIButton *button          = [[UIButton alloc] init];
        button.layer.cornerRadius = CORNER_RADIUS;
        button.backgroundColor    = YunWanButtonBackgroundRedColor;
        button.titleLabel.font    = [UIFont systemFontOfSize:14.0];
        [button setTitle:@"登录"
                forState:UIControlStateNormal];
        [button setTitle:@"正在登录..."
                forState:UIControlStateDisabled];
        [button setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
        [button setTitleColor:YunWanButtonDisableTitleColor
                     forState:UIControlStateDisabled];
        [button addTarget:self
                   action:@selector(loginNow:)
         forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.loginView addSubview:self.loginButton];
    
    // 忘记密码
    self.forgetPwdButton = ({
        UIButton *button       = [[UIButton alloc] init];
        button.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [button setTitle:@"忘记密码"
                forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(forgetPassword:)
         forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.loginView addSubview:self.forgetPwdButton];
    
    // 新用户（注册）
    self.registerButton = ({
        UIButton *button       = [[UIButton alloc] init];
        button.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [button setTitle:@"新用户"
                forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor]
                     forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(registerNow:)
         forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    [self.loginView addSubview:self.registerButton];
    
    // QQ登录
    self.qqLoginView = ({
        UIView *view            = [[UIView alloc] init];
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
    [self.loginView addSubview:self.qqLoginView];
    
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
    [self.loginView addSubview:self.weChatLoginView];
    
    UIEdgeInsets loginViewInsets =
    UIEdgeInsetsMake(kLoginViewPadding, kLoginViewPadding, kLoginViewPadding, kLoginViewPadding);
    
    [self.loginControlsBgView makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.loginView;
        make.left.equalTo(superView).insets(loginViewInsets);
        make.right.equalTo(superView).insets(loginViewInsets);
        make.top.equalTo(superView).insets(loginViewInsets);
        make.height.equalTo(@(kTextFieldHeight * 2 + 1));
        
        make.bottom.equalTo(self.loginButton.top).offset(-kVSpacingBetweenViews);
    }];
    
    [self.loginButton makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.loginView;
        make.left.equalTo(superView).insets(loginViewInsets);
        make.right.equalTo(superView).insets(loginViewInsets);
        make.height.equalTo(@(kLoginButtonHeight));
        
        make.top.equalTo(self.loginControlsBgView.bottom).offset(kVSpacingBetweenViews);
        make.bottom.equalTo(self.forgetPwdButton.top).offset(-kVSpacingBetweenViews);
        make.bottom.equalTo(self.registerButton.top).offset(-kVSpacingBetweenViews);
    }];
    
    [self.forgetPwdButton makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.loginView;
        make.left.equalTo(superView).insets(loginViewInsets);
        make.height.equalTo(@(kRegisterButtonHeight));
        make.width.equalTo(@(54));
        
        make.top.equalTo(self.loginButton.bottom).offset(kVSpacingBetweenViews);
    }];
    
    [self.registerButton makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.loginView;
        make.right.equalTo(superView).insets(loginViewInsets);
        make.height.equalTo(@(kRegisterButtonHeight));
        make.width.equalTo(@(40));
        
        make.top.equalTo(self.loginButton.bottom).offset(kVSpacingBetweenViews);
    }];
    
    [self.qqLoginView makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.loginView;
        make.width.equalTo(@(96));
        make.height.equalTo(@(kQQLoginViewHeight));
        make.left.equalTo(superView).insets(loginViewInsets);
        make.bottom.equalTo(superView).insets(loginViewInsets);
    }];
    
    [self.weChatLoginView makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.loginView;
        make.width.equalTo(@(96));
        make.height.equalTo(@(kQQLoginViewHeight));
        make.right.equalTo(superView).insets(loginViewInsets);
        make.bottom.equalTo(superView).insets(loginViewInsets);
    }];

    
    // 登陆框之用户名
    self.userNameTextField = ({
        UITextField *textField    = [[UITextField alloc] init];
        textField.textColor       = [UIColor blackColor];
        textField.font            = [UIFont systemFontOfSize:14.0];
        textField.placeholder     = @"请输入账号";
        textField.borderStyle     = UITextBorderStyleNone;

        textField.leftViewMode    = UITextFieldViewModeAlways;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate        = self;
        textField.leftView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
            view;
        });
        
        textField;
    });
    [self.loginControlsBgView addSubview:self.userNameTextField];
    [self.userNameTextField makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.loginControlsBgView;
        make.left.equalTo(superView.left);
        make.right.equalTo(superView.right);
        make.top.equalTo(superView.top);
        make.height.equalTo(@(kTextFieldHeight));
    }];
    
    // 登陆框之分隔线
    self.lineViewBetweenTextFields = ({
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor lightGrayColor];
        view;
    });
    [self.loginControlsBgView addSubview:self.lineViewBetweenTextFields];
    [self.lineViewBetweenTextFields makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView   = self.loginControlsBgView;
        UIEdgeInsets insets = UIEdgeInsetsMake(kTextFieldHeight, 0, 0, 0);
        make.left.equalTo(superView).insets(insets);
        make.right.equalTo(superView).insets(insets);
        make.top.equalTo(superView).insets(insets);
        make.height.equalTo(@(1));
    }];
    
    // 登录框之密码框
    self.passwordTextField = ({
        UITextField *textField    = [[UITextField alloc] init];
        textField.textColor       = [UIColor blackColor];
        textField.font            = [UIFont systemFontOfSize:14.0];
        textField.placeholder     = @"请输入密码";
        textField.borderStyle     = UITextBorderStyleNone;
        textField.secureTextEntry = YES;

        textField.leftViewMode    = UITextFieldViewModeAlways;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.delegate        = self;
        textField.leftView = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
            view;
        });
        
        textField;
    });
    [self.loginControlsBgView addSubview:self.passwordTextField];
    [self.passwordTextField makeConstraints:^(MASConstraintMaker *make) {
        UIView *superView   = self.loginControlsBgView;
        UIEdgeInsets insets = UIEdgeInsetsMake(kTextFieldHeight+1, 0, 0, 0);
        make.left.equalTo(superView).insets(insets);
        make.right.equalTo(superView).insets(insets);
        make.top.equalTo(superView).insets(insets);
        make.height.equalTo(@(kTextFieldHeight));
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
        label.text          = @"QQ登录";
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
    
    /********************** 登录区域结束 **********************/
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViewAndSubViews];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 加载用户登录信息
    [self loadLastLoginUserInfo];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// 键盘呼出
- (void)keyBoardDidShow:(NSNotification *)notification {
    
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

- (void)updateViewConstraints {
    
    CGFloat loginViewHeight =
    kLoginViewPadding + kTextFieldHeight * 2 + 1 + kVSpacingBetweenViews+
    kLoginButtonHeight + kVSpacingBetweenViews + kRegisterButtonHeight +
    kVSpacingBetweenViews + kQQLoginViewHeight + kLoginViewPadding;
    
    [self.loginView remakeConstraints:^(MASConstraintMaker *make) {
        UIView *superView = self.view;
        UIEdgeInsets insets = {0,0,0,0};
        if (keyboardShowingFlag) {
            // 键盘呼出
            insets = UIEdgeInsetsMake(64, 40, 0, 40);
            make.top.equalTo(superView).insets(insets);
        } else {
            insets = UIEdgeInsetsMake(0, 40, 40, 40);
            make.bottom.equalTo(superView).insets(insets);
        }
        make.left.equalTo(superView).insets(insets);
        make.right.equalTo(superView).insets(insets);
        make.height.equalTo(@(loginViewHeight));
    }];
    
    [super updateViewConstraints];
}

// 键盘隐藏
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

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 隐藏navigation bar和status bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (BOOL)prefersStatusBarHidden {
    return true;
}

// 忘记密码
- (void)forgetPassword:(UIButton *)sender {
    [self hiddenKeyboard];
    
    // 1. init ViewController
    YWForgetPasswordViewController2 *VC = [[YWForgetPasswordViewController2 alloc] init];
    
    // 2. configure ViewController
    
    // 3. show ViewController
    [self.navigationController pushViewController:VC animated:YES];
}

// 新用户
- (void)registerNow:(UIButton *)sender {
    [self hiddenKeyboard];
    // 1. init ViewController
    YWRegisterViewController2 *VC =
    [[YWRegisterViewController2 alloc] init];
    
    // 2. configure ViewController
    
    // 3. show ViewController
    [self.navigationController pushViewController:VC animated:YES];
}

// 加载最近登录用户信息
- (void)loadLastLoginUserInfo {
    // loadLastLoginUserInfo
}

// load user info from disk by loginName
- (void)loadUserInfoWithLoginName:(NSString *)loginName {
    //
}

// 登录
- (void)loginNow:(UIButton *)sender {
    
    [self hiddenKeyboard];
    // 登录
}

// 登录成功
- (void)didLoginSucceed:(NSDictionary *)dict {
    // 登录成功
}

// 验证手机号
- (BOOL)isValidPhoneNumberWithString:(NSString *)string {
    NSError *error;
    BOOL b = FALSE;
    b = [NSString isValidMobilePhoneNumber:string error:&error];
    
    return b;
}

// 验证手机号
- (BOOL)isValidPasswordWithString:(NSString *)string {
    BOOL b = FALSE;
    b = ![string isEqualToString:@""];
    
    return b;
}

// 验证密码
- (void)vertifyPassword {
    // 验证密码
}

// 点击self.view其余部分隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

// 隐藏键盘
- (void)hiddenKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.userNameTextField) {
        [self loadUserInfoWithLoginName:self.userNameTextField.text];
    }
    return YES;
}

// QQ登陆
- (void)loginWithQQ:(UIGestureRecognizer *)gesture {
    // QQ登陆
}

- (void)loginWithWeChat:(UIGestureRecognizer *)gesture {
    // 微信登录
}

@end
