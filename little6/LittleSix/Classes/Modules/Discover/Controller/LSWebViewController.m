//
//  LSWebViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSWebViewController.h"
#import <WebKit/WebKit.h>
#import "UIViewController+BackButtonHandler.h"
#import "ComfirmView.h"
#import "LSShareView.h"

@interface LSWebViewController () <WKNavigationDelegate, WKUIDelegate,WKScriptMessageHandler,BackButtonHandlerProtocol>

@property (nonatomic, strong) WKWebView *wkWebView;

//进度条view
@property (nonatomic, strong) UIProgressView *wkProgressView;

@property (nonatomic, strong) UIBarButtonItem *closeButtonItem;
@property (nonatomic, strong) UIBarButtonItem *backButtomItem;

@property (nonatomic, strong) UIBarButtonItem *rightButtonItem;

//分享内容
@property (nonatomic, copy) NSString *shareContent;
@property (nonatomic, copy) NSString *shareImage;

@end

@implementation LSWebViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self judgeType];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self installObserver];
    [self registerNotification];
    
    //显示分享按钮
    self.rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareAction)];
    
    self.navigationItem.rightBarButtonItem = self.rightButtonItem;
    
    if (self.localHtmlPath) {
        NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        NSString *html = [NSString stringWithContentsOfFile:self.localHtmlPath encoding:NSUTF8StringEncoding error:nil];
        [self.wkWebView loadHTMLString:html baseURL:baseURL];
        return;
    }
    
    _urlString = _urlString? _urlString: @"http://www.baidu.com";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
    
    [self.wkWebView loadRequest:request];
    
    [self updateNavigationItems];
}

- (void)registerNotification {
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kIntroduceLinkInInfoNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]];
        [self.wkWebView loadRequest:request];
    }];
}

- (void)installObserver {
    
    RACSignal *singal1 = RACObserve(self.wkWebView, loading);
    RACSignal *singal2 = RACObserve(self.wkWebView, title);
    RACSignal *singal3 = RACObserve(self.wkWebView, estimatedProgress);

    RACSignal *mergerSingal = [[singal1 merge:singal2] merge:singal3];
    
    @weakify(self)
    [mergerSingal subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        //加载完成
        if (!self.wkWebView.isLoading) {
            [self hideWKProgressView];
        }
        else {
            self.wkProgressView.alpha = 1;
            self.wkProgressView.progress = self.wkWebView.estimatedProgress;
        }
    }];
    
}

- (void)hideWKProgressView {
    //不显示进度条，返回
    [UIView animateWithDuration:0.5 animations:^{
        self.wkProgressView.alpha = 0;
    }];
}

- (void)updateNavigationItems {
    if ([self.wkWebView canGoBack]) {
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = 1;
        
        [self.navigationItem setLeftBarButtonItems:@[ self.backButtomItem, spaceButtonItem, self.closeButtonItem ] animated:NO];
    } else {
        [self.navigationItem setLeftBarButtonItems:@[ self.backButtomItem ] animated:NO];
    }
}

- (void)shareAction {
    
    NSURL *shareURL = self.wkWebView.URL;
    
    if (!shareURL) return;
    
    NSString *shareTitle;
    if (!self.title || self.title.length == 0) {
        shareTitle = @"嗨萌分享";
    }
    else {
        shareTitle = self.title;
    }
    
    NSMutableDictionary *shareParam = [NSMutableDictionary dictionary];
    
    if ([self.type isEqualToString:@"FuwaTop"]) {
        self.shareImage = ShareAppManager.loginUser.avatar;
    }

    NSString * logoImage = self.shareImage ? self.shareImage : ShareAppManager.loginUser.avatar;
    [shareParam SSDKSetupShareParamsByText:self.shareContent images:@[logoImage] url:shareURL title:shareTitle type:SSDKContentTypeWebPage];
    
    [LSShareView showInView:LSKeyWindow withItems:[LSShareView shareItems] actionBlock:^(SSDKPlatformType type) {
        //分享出去
        [LSShareView shareTo:type withParams:shareParam onStateChanged:nil];
    }];
}

#pragma mark - WKWebView
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.rightButtonItem.enabled = NO;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    self.rightButtonItem.enabled = YES;

    @weakify(self)
    [webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *title, NSError *error) {
        @strongify(self)
        self.title = title;
    }];
    
    [webView evaluateJavaScript:@"document.getElementsByName('description')[0].content" completionHandler:^(NSString *content, NSError *error) {
        @strongify(self)
        NSString * share = content.length > 50 ? [content substringWithRange:NSMakeRange(0,50)] : content;
        self.shareContent = share;
    }];
    
    [webView evaluateJavaScript:@"document.getElementsByName('shareimg')[0].content" completionHandler:^(NSString *content, NSError *error) {
        @strongify(self)
        self.shareImage = content;
    }];
    
    [self updateNavigationItems];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
        completionHandler(NO);
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *_Nonnull textField) {
        textField.placeholder = defaultText;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

// 防止在HTML <a> 中的 target="_blank"不发生响应
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    
    return nil;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
}

- (BOOL)navigationShouldPopOnBackButton {
    [self removeAllScriptMsgHandle];
    return YES;
}

-(void)removeAllScriptMsgHandle{
    WKUserContentController *controller = self.wkWebView.configuration.userContentController;
    [controller removeScriptMessageHandlerForName:@"AppModel"];
}

#pragma mark - Getter & Setter
- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:[self wkWebViewConfiguration]];
        
        _wkWebView.UIDelegate = self;
        _wkWebView.navigationDelegate = self;
        
        [self.view addSubview:_wkWebView];
        [_wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
            make.top.equalTo(self.mas_topLayoutGuide);
        }];
    }
    return _wkWebView;
}

- (WKWebViewConfiguration *)wkWebViewConfiguration {
    
    WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
    
    configuration.preferences                   = [WKPreferences new];
    configuration.preferences.minimumFontSize   = 10;
    configuration.preferences.javaScriptEnabled = YES;
    
    configuration.processPool = [WKProcessPool new];
    
    configuration.userContentController = [WKUserContentController new];
    [configuration.userContentController addScriptMessageHandler:self name:@"AppModel"];
    
    return configuration;
}

- (UIProgressView *)wkProgressView {
    if (!_wkProgressView) {
        _wkProgressView = [[UIProgressView alloc] init];
        [self.view addSubview:_wkProgressView];
        
        _wkProgressView.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), CGRectGetWidth(self.navigationController.navigationBar.frame), 3);
        
        _wkProgressView.progressTintColor = [UIColor blueColor];
        _wkProgressView.trackTintColor = [UIColor whiteColor];
        
        [_wkProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.wkWebView);
            make.height.offset(3);
        }];
    }
    
    return _wkProgressView;
}

- (UIBarButtonItem *)closeButtonItem {
    if (!_closeButtonItem) {
        UIButton *closeButton = [[UIButton alloc] init];
        [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [closeButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [closeButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        
        [closeButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
        
        [closeButton sizeToFit];
        
        [closeButton setImageEdgeInsets:UIEdgeInsetsMake(0, -8, 0, 0)];
        
        [closeButton sizeToFit];
        
        _closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
        
        @weakify(self)
        [[closeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _closeButtonItem;
}

- (UIBarButtonItem *)backButtomItem {
    if (!_backButtomItem) {
        UIImage *backItemImage = [[UIImage imageNamed:@"navbar_btn_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *backItemHlImage = [[UIImage imageNamed:@"navbar_btn_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIButton *backButton = [[UIButton alloc] init];
        
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        
        [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        
        [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        
        [backButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:15]];
        
        [backButton setImage:backItemImage forState:UIControlStateNormal];
        
        [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
        [backButton sizeToFit];
        
        [backButton setContentEdgeInsets:UIEdgeInsetsMake(0, -8, 0, -10)];
        [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
        
        [backButton sizeToFit];
        
        _backButtomItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        @weakify(self)
        [[backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if ([self.wkWebView canGoBack]) {
                [self.wkWebView goBack];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];

    }
    
    return _backButtomItem;
}

- (void)judgeType {

    if ([self.type isEqualToString:@"FuwaTop"]) {
        [self.navigationController.navigationBar setTranslucent:YES];
        UIImage *image = [[UIImage imageNamed:@"fuwa_top"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    
    if ([self.type isEqualToString:@"gameRule"]) {
        self.navigationItem.rightBarButtonItem = nil;
    }

    if (([self.type intValue] == 3 || [self.type intValue] == 4||[self.type intValue] == 5)&&[self.user_id isEqualToString:ShareAppManager.loginUser.user_id]) {

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"navi_chat_more"] forState:UIControlStateNormal];
        [button sizeToFit];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        @weakify(self)
        [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
            @strongify(self);
            ModelComfirm *item1 = [ModelComfirm comfirmModelWith:@"编辑" titleColor:[UIColor redColor] fontSize:16];
            ModelComfirm *cancelItem = [ModelComfirm comfirmModelWith:@"取消" titleColor:HEXRGB(0x666666) fontSize:16];
            //确认提示框
            [ComfirmView showInView:LSKeyWindow cancelItemWith:cancelItem dataSource:@[ item1 ] actionBlock:^(ComfirmView *view, NSInteger index) {
                UIViewController *vc = [[UIStoryboard storyboardWithName:@"LinkIn" bundle:nil] instantiateViewControllerWithIdentifier:@"LSEditProfile"];
                [vc setValue:self.s_id forKey:@"s_id"];
                [vc setValue:self.type forKey:@"type"];
                [vc setValue:self.desc forKey:@"desc"];
                [vc setValue:self.address forKey:@"address"];
                [vc setValue:self.phone forKey:@"phone"];
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }];
    }
}

@end
