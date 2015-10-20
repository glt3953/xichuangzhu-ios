//
//  XCZQuoteViewController.m
//  xcz
//
//  Created by hustlzp on 15/10/20.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuoteView.h"
#import "XCZWorkDetailViewController.h"
#import "XCZQuoteViewController.h"
#import "UIColor+Helper.h"
#import <Masonry.h>

@interface XCZQuoteViewController () <XCZQuoteViewDelegate>

@property (strong, nonatomic) XCZQuote *quote;

@end

@implementation XCZQuoteViewController

#pragma mark - LifeCycle

- (instancetype)initWithQuote:(XCZQuote *)quote
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.quote = quote;
    
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor colorWithRGBA:0xF8F8F8FF];
    
    [self createViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Layout

- (void)createViews
{
    XCZQuoteView *quoteView = [[XCZQuoteView alloc] initWithQuote:self.quote];
    quoteView.delegate = self;
    [self.view addSubview:quoteView];
    
    [quoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.equalTo(self.view).multipliedBy(.8);
    }];
}

#pragma mark - Public Interface

#pragma mark - User Interface

#pragma mark - XCZQuoteViewDelegate

- (void)quoteViewPressed:(XCZQuote *)quote
{
    XCZWork *work = [XCZWork getById:quote.workId];
    XCZWorkDetailViewController *controller = [XCZWorkDetailViewController new];
    controller.work = work;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Internal Helpers

#pragma mark - Getters & Setters

@end
