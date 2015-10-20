//
//  XCZRandomQuoteViewController.m
//  xcz
//
//  Created by hustlzp on 15/10/20.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuote.h"
#import "XCZWork.h"
#import "XCZWorkDetailViewController.h"
#import "XCZRandomQuoteViewController.h"
#import "Constants.h"
#import "UIColor+Helper.h"
#import <ionicons/IonIcons.h>
#import <Masonry.h>

@interface XCZRandomQuoteViewController () <XCZQuoteViewDelegate>

@property (strong, nonatomic) NSMutableArray *quoteViews;

@end

@implementation XCZRandomQuoteViewController

#pragma mark - LifeCycle

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
    
    //添加“换一换”按钮
    UIImage *refreshIcon = [IonIcons imageWithIcon:ion_ios_loop_strong size:24 color:[UIColor grayColor]];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:refreshIcon style:UIBarButtonItemStylePlain target:self action:@selector(refreshQuote)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"摘录";
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

#pragma mark - Layout

- (void)createViews
{
    [self loadQuoteView];
    [self loadQuoteView];
}

#pragma mark - Public Interface

#pragma mark - User Interface

- (void)refreshQuote
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [(XCZQuoteView *)[self.quoteViews firstObject] leftClickAction];
}

#pragma mark - XCZQuoteViewDelegate

- (void)quoteViewPressed:(XCZQuote *)quote
{
    XCZWork *work = [XCZWork getById:quote.workId];
    XCZWorkDetailViewController *controller = [XCZWorkDetailViewController new];
    controller.work = work;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)quoteViewSwipedLeft:(UIView *)quoteView
{
    [self.quoteViews removeObjectAtIndex:0];
    [self loadQuoteView];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)quoteViewSwipedRight:(UIView *)quoteView
{
    [self.quoteViews removeObjectAtIndex:0];
    [self loadQuoteView];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - Internal Helpers

- (void)loadQuoteView
{
    XCZQuoteView *quoteView = [[XCZQuoteView alloc] initWithQuote:[XCZQuote getRandomQuote]];
    quoteView.delegate = self;
    
    if (self.quoteViews.count == 0) {
        [self.view addSubview:quoteView];
    } else {
        [self.view insertSubview:quoteView belowSubview:[self.quoteViews lastObject]];
    }
    
    [quoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.equalTo(self.view).multipliedBy(.8);
    }];
    
    [self.quoteViews addObject:quoteView];
}

#pragma mark - Getters & Setters

- (NSMutableArray *)quoteViews
{
    if (!_quoteViews) {
        _quoteViews = [NSMutableArray new];
    }
    
    return _quoteViews;
}

@end
