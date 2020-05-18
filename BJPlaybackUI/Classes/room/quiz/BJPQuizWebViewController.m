//
//  BJPQuizWebViewController.m
//  BJPlaybackUI
//
//  Created by fanyi on 2019/8/19.
//  Copyright © 2019 BaijiaYun. All rights reserved.
//

#import <BJLiveBase/BJLUserAgent.h>
#import <BJLiveBase/BJLButton.h>
#import <WebKit/WebKit.h>

#import "BJPQuizWebViewController.h"
#import "BJPAppearance.h"

#define jsLog           "log"
#define jsWebView       "webview"
#define jsWebViewClose      "close"
#define jsMessage       "message"

static NSString * const jsInjection = @
"(function() {\n"
"    var bjlapp = this.bjlapp = this.bjlapp || {};\n"
"    // APP implementation\n"
"    bjlapp.log = function(log) {\n"
"        window.webkit.messageHandlers." jsLog ".postMessage(log);\n"
"    };\n"
"    bjlapp.close = function() {\n"
"        window.webkit.messageHandlers." jsWebView ".postMessage('" jsWebViewClose "');\n"
"    };\n"
"    bjlapp.sendMessage = function(json) {\n"
"        window.webkit.messageHandlers." jsMessage ".postMessage(json);\n"
"    };\n"
"    // H5 implementation\n"
"    bjlapp.receivedMessage = bjlapp.receivedMessage || function(json) {\n"
"        // abstract\n"
"    };\n"
#if DEBUG
"    bjlapp.log('injected');\n"
#endif
"})();\n";


@interface BJPQuizWebViewController () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic) NSURLRequest *request;
@property (nonatomic, nullable) NSMutableArray<NSDictionary<NSString *, id> *> *messages;

@property (nonatomic) UIView *progressView, *topView;

@property (nonatomic) UIButton *reloadButton, *closeButton;

@end

@implementation BJPQuizWebViewController

+ (nullable instancetype)instanceWithQuizMessage:(NSDictionary<NSString *, id> *)message roomVM:(BJVRoomVM *)roomVM {
    NSString *messageType = [message bjl_stringForKey:@"message_type"];
    
    BOOL isQuizStart = [messageType isEqualToString:@"quiz_start"];
    BOOL isQuizResponse = [messageType isEqualToString:@"quiz_res"];
    BOOL isQuizSolution = [messageType isEqualToString:@"quiz_solution"];
    if (!isQuizStart && !isQuizResponse && !isQuizSolution) {
        return nil;
    }
    
    NSString *quizID = [message bjl_stringForKey:@"quiz_id"];
    BOOL quizEnd = [message bjl_boolForKey:@"end_flag"];
    BOOL quizDid = [message bjl_dictionaryForKey:@"solution"].count > 0;
    if (isQuizResponse
        && (!quizID.length || quizEnd || quizDid)) {
        return nil;
    }
    
    NSURLRequest *request = [roomVM quizRequestWithID:quizID error:nil];
    if (!request) {
        return nil;
    }
    
    return [[BJPQuizWebViewController alloc] initWithMessage:message
                                                     request:request];
}

+ (NSDictionary *)quizReqMessageWithUserNumber:(NSString *)userNumber {
    return @{@"message_type": @"quiz_req",
             @"user_number":  userNumber ?: @""};
}

- (instancetype)initWithMessage:(NSDictionary<NSString *, id> *)message
                        request:(NSURLRequest *)request {
    self = [super initWithConfiguration:({
        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsInjection
                                                          injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                       forMainFrameOnly:YES];
        WKWebViewConfiguration *configuration = [WKWebViewConfiguration new];
        configuration.userContentController = [WKUserContentController new];
        [configuration.userContentController addUserScript:userScript];
        [configuration.userContentController addScriptMessageHandler:self.wtfScriptMessageHandler
                                                                name:@(jsLog)];
        [configuration.userContentController addScriptMessageHandler:self.wtfScriptMessageHandler
                                                                name:@(jsWebView)];
        [configuration.userContentController addScriptMessageHandler:self.wtfScriptMessageHandler
                                                                name:@(jsMessage)];
        configuration;
    })];
    if (self) {
        self.request = request;
        self.messages = [NSMutableArray new];
        [self.messages bjl_addObject:message];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.userAgentSuffix = [BJLUserAgent defaultInstance].sdkUserAgent;
    
    self.progressView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor bjp_blueBrandColor];
        view;
    });
    
    self.reloadButton = ({
        UIButton *button = [UIButton new];
        [button setTitle:@"加载失败，点击重试" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor bjp_lightGrayTextColor] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor whiteColor];
        button;
    });
    
    self.topView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        view;
    });
    
    UILabel *label = ({
        UILabel *label = [UILabel new];
        label.font = [UIFont systemFontOfSize:16.0];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor bjp_blueBrandColor];
        label.text = @"测验";
        [self.topView addSubview:label];
        label;
    });

    self.closeButton = ({
        UIButton *button = [BJLButton new];
        [button setTitleColor:[UIColor bjp_blueBrandColor] forState:UIControlStateNormal];
        [button setTitleColor:[[UIColor bjp_blueBrandColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        button.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [button setTitle:@"关闭" forState:UIControlStateNormal];
        button;
    });
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.topView];
    [self.topView bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
        make.top.left.right.equalTo(self.view);
    }];
    [self.topView addSubview:self.closeButton];
    [label bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
        make.left.equalTo(self.topView.bjl_safeAreaLayoutGuide ?: self.topView).with.offset(BJPViewSpaceL);
        make.top.bottom.equalTo(self.topView.bjl_safeAreaLayoutGuide ?: self.topView);
        make.height.equalTo(@(30));
    }];
    [self.closeButton bjl_makeConstraints:^(BJLConstraintMaker * _Nonnull make) {
        make.right.equalTo(self.topView.bjl_safeAreaLayoutGuide ?: self.topView).with.offset(-BJPViewSpaceL);
        make.top.bottom.equalTo(self.topView.bjl_safeAreaLayoutGuide ?: self.topView);
        make.height.equalTo(label);
    }];
    
    [self.webView bjl_remakeConstraints:^(BJLConstraintMaker * _Nonnull make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.topView.bjl_bottom);
    }];
    
    bjl_weakify(self);
    [self bjl_kvo:BJLMakeProperty(self.webView, estimatedProgress)
         observer:^BOOL(id _Nullable now, id _Nullable old, BJLPropertyChange * _Nullable change) {
             bjl_strongify(self);
             if (self.progressView.superview) {
                 [self.progressView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
                     make.left.top.equalTo(self.view);
                     make.width.equalTo(self.view).multipliedBy(self.webView.estimatedProgress);
                     make.height.equalTo(@(BJPOnePixel));
                 }];
             }
             return YES;
         }];
    
    [self.reloadButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        [self.webView stopLoading];
        [self.webView loadRequest:self.request];
    }];
    
    [self.closeButton bjl_addHandler:^(__kindof UIControl * _Nullable sender) {
        bjl_strongify(self);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"确认关闭测验？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert bjl_addActionWithTitle:@"确认"
                                style:UIAlertActionStyleDestructive
                              handler:^(UIAlertAction * _Nonnull action) {
                                  [self.webView stopLoading];
                                  if (self.closeWebViewCallback) self.closeWebViewCallback();
                              }];
        [alert bjl_addActionWithTitle:@"取消"
                                style:UIAlertActionStyleCancel
                              handler:nil];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
    NSLog(@"[quiz] request: %@", self.request.URL);
    [self.webView loadRequest:self.request];
}

#pragma mark -

- (void)didReceiveQuizMessage:(NSDictionary<NSString *, id> *)message {
    if (self.messages) {
        [self.messages bjl_addObject:message];
    }
    else {
        [self forwardQuizMessage:message];
    }
}

- (void)forwardQuizMessage:(NSDictionary<NSString *, id> *)message {
    NSString *js = [NSString stringWithFormat:@"bjlapp.receivedMessage(%@)", ({
        NSData *data = [NSJSONSerialization dataWithJSONObject:message options:0 error:NULL];
        NSString *json = data.length ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
        bjl_return json;
    })];
    NSLog(@"[quiz] %@", js);
    // bjl_weakify(self);
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        // bjl_strongify(self);
        NSLog(@"[quiz] return: %@ || %@", result, error);
    }];
}

#pragma mark - loading state

- (void)didStartLoading {
    [self.view addSubview:self.progressView];
    [self.progressView bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        make.left.equalTo(self.topView);
        make.top.equalTo(self.topView.bjl_bottom);
        make.width.equalTo(self.view).multipliedBy(self.webView.estimatedProgress);
        make.height.equalTo(@(BJPOnePixel));
    }];
    
    [self.reloadButton removeFromSuperview];
}

- (void)didFailLoading {
    [self.progressView removeFromSuperview];
    
    [self.view addSubview:self.reloadButton];
    [self.reloadButton bjl_remakeConstraints:^(BJLConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

- (void)didFinishLoading {
    [self.progressView removeFromSuperview];
    
    NSArray<NSDictionary<NSString *, id> *> *messages = [self.messages copy];
    self.messages = nil;
    
    for (NSDictionary<NSString *, id> *message in messages) {
        [self forwardQuizMessage:message];
    }
}

#pragma mark - <WKNavigationDelegate>

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"[quiz] didStartProvisionalNavigation: %@", navigation);
    [self didStartLoading];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"[quiz] didFailProvisionalNavigation: %@ || %@", navigation, error);
    [self didFailLoading];
}

/*
 - (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
 NSLog(@"[quiz] didCommitNavigation: %@", navigation);
 } */

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"[quiz] didFailNavigation: %@ || %@", navigation, error);
    [self didFailLoading];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"[quiz] didFinishNavigation: %@", navigation);
    [self didFinishLoading];
}

#if DEBUG
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if (completionHandler) {
        NSURLCredential *credential = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}
#endif

#pragma mark - <WKUIDelegate>

#pragma mark - <WKScriptMessageHandler>

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"[quiz] %@.postMessage(%@)", message.name, message.body);
    
    if (message.webView != self.webView) {
        return;
    }
    
    if ([message.name isEqualToString:@(jsMessage)]) {
        NSDictionary *json = bjl_as(message.body, NSDictionary);
        if (self.sendQuizMessageCallback) self.sendQuizMessageCallback(json);
        return;
    }
    
    if ([message.name isEqualToString:@(jsWebView)]) {
        NSString *action = message.body;
        if ([action isEqualToString:@(jsWebViewClose)]) {
            if (self.closeWebViewCallback) self.closeWebViewCallback();
        }
        return;
    }
}

@end
