//
//  TLWebViewController.m
//  TLChat
//
//  Created by 李伯坤 on 16/2/10.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLWebViewController.h"
#import <MobClick.h>
#import <WebKit/WebKit.h>

@interface TLWebViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation TLWebViewController

- (void)loadView
{
    [super loadView];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"WebVC"];
    [self.progressView setProgress:0.0f];
    [self.webView loadRequest:[NSURLRequest requestWithURL:TLURL(self.url)]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"WebVC"];
}

- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
#ifdef DEBUG_MEMERY
    NSLog(@"dealloc WebVC");
#endif
}

#pragma mark - Public Methods -
- (void)setUrl:(NSString *)url
{
    _url = url;
    if ([self.view isFirstResponder]) {
        [self.progressView setProgress:0.0f];
        [self.webView loadRequest:[NSURLRequest requestWithURL:TLURL(self.url)]];
    }
}

#pragma mark - Event Response -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self.webView) {
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        
        if(self.webView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Delegate -
//MARK: WKNavigationDelegate
- (void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.navigationItem setTitle:webView.title];
}

#pragma mark - Getter -
- (WKWebView *) webView
{
    if (_webView == nil) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, HEIGHT_NAVBAR + HEIGHT_STATUSBAR, WIDTH_SCREEN, HEIGHT_SCREEN - HEIGHT_NAVBAR - HEIGHT_STATUSBAR)];
        [_webView setAllowsBackForwardNavigationGestures:YES];
        [_webView setNavigationDelegate:self];
    }
    return _webView;
}

- (UIProgressView *) progressView
{
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, HEIGHT_NAVBAR + HEIGHT_STATUSBAR, WIDTH_SCREEN, 10.0f)];
        [_progressView setTransform: CGAffineTransformMakeScale(1.0f, 2.0f)];
        [_progressView setProgressTintColor:[UIColor colorDefaultGreen]];
        [_progressView setTrackTintColor:[UIColor clearColor]];
        
    }
    return _progressView;
}

@end
