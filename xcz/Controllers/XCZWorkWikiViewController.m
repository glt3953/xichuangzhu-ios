//
//  XCZWorkWikiViewController.m
//  xcz
//
//  Created by hustlzp on 15/10/18.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZWorkWikiViewController.h"
#import <Masonry.h>
#import <IonIcons.h>

@interface XCZWorkWikiViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *pageTitle;

@end

@implementation XCZWorkWikiViewController

#pragma mark - LifeCycle

- (instancetype)initWithURL:(NSString *)url
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.url = url;
    self.hidesBottomBarWhenPushed = YES;
    
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    activityIndicator.color = [UIColor lightGrayColor];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    self.navigationItem.rightBarButtonItem = barButton;
    [activityIndicator startAnimating];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Layout

- (void)createViews
{
    UIWebView *webView = [UIWebView new];
    webView.delegate = self;
    webView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:webView];
    self.webView = webView;
    
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(0);
    }];
}

#pragma mark - Public Interface

#pragma mark - User Interface

#pragma mark - SomeDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Internal Helpers

#pragma mark - Getters & Setters


@end
