//
//  XCZWorkDetailViewController.m
//  xcz
//
//  Created by 刘志鹏 on 14-6-30.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuote.h"
#import "XCZLike.h"
#import "XCZLabel.h"
#import "XCZWorkDetailsView.h"
#import "XCZWorkDetailViewController.h"
#import "XCZQuoteViewController.h"
#import "XCZAuthorDetailsViewController.h"
#import "XCZWorkWikiViewController.h"
#import "UILabel+SetFont.h"
#import "XCZUtils.h"
#import "Constants.h"
#import "UIColor+Helper.h"
#import <AVOSCloud/AVOSCloud.h>
#import <ionicons/IonIcons.h>
#import <Masonry/Masonry.h>

@interface XCZWorkDetailViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIBarButtonItem *likeButton;
@property (strong, nonatomic) UIBarButtonItem *unlikeButton;
@property (strong, nonatomic) UIBarButtonItem *wikiButton;
@property (strong, nonatomic) UIBarButtonItem *authorButton;
@property (strong, nonatomic) XCZWorkDetailsView *detailsView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *quotes;

@end

@implementation XCZWorkDetailViewController

#pragma mark - LifeCycle

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.showAuthorButton = YES;
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
    
    // 初始化navbar按钮
    bool showLike = ![XCZLike checkExist:self.work.id];
    [self initNavbarShowAuthor:self.showAuthorButton showLike:showLike];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [AVAnalytics beginLogPageView:[[NSString alloc] initWithFormat:@"work-%@/%@", self.work.author, self.work.title]];
    
    self.navigationItem.title = @"";
    
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = self.work.title;
    
    [AVAnalytics endLogPageView:[[NSString alloc] initWithFormat:@"work-%@/%@", self.work.author, self.work.title]];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self sizeHeaderViewToFit];
}

#pragma mark - Layout

- (void)createViews
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.tableHeaderView = [self createHeaderView];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Public Interface

- (void)updateWithWork:(XCZWork *)work
{
    self.work = work;
    self.tableView.tableHeaderView = [self createHeaderView];
    self.quotes = [XCZQuote getByWorkId:self.work.id];
    [self.tableView reloadData];
    
    [self.view setNeedsLayout];
}

#pragma mark - User Interface

// 进入/退出全屏模式
//- (void)toggleBars:(UITapGestureRecognizer *)gesture
//{
//    BOOL isFullScreen = self.navigationController.navigationBar.hidden;
//    
//    // Toggle StatusBar & NavigationBar & TabBar
//    [[UIApplication sharedApplication] setStatusBarHidden:![[UIApplication sharedApplication] isStatusBarHidden] withAnimation:UIStatusBarAnimationSlide];
//    
//    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBar.hidden animated:YES];
//    
//    if (self.navigationController.viewControllers.count == 0) {
//        self.tabBarController.tabBar.hidden = !self.tabBarController.tabBar.hidden;
//    }
//    
//    // 全屏模式下，扩大title的顶部间距
//    if (isFullScreen) {
//        [self.detailsView exitFullScreenMode];
//    } else {
//        [self.detailsView enterFullScreenMode];
//    }
//    
//    [UIView animateWithDuration:0.4 animations:^{
//        [self.view setNeedsLayout];
//        [self.view layoutIfNeeded];
//    }];
//}

- (void)redirectToWiki
{
    [self.navigationItem setTitle:@"返回"];
    
    if (self.work.baiduWiki) {
        XCZWorkWikiViewController *controller = [[XCZWorkWikiViewController alloc] initWithURL:self.work.baiduWiki];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)redirectToAuthor:(id)sender
{
    [self.navigationItem setTitle:@"返回"];
    
    XCZAuthorDetailsViewController *authorDetailController = [[XCZAuthorDetailsViewController alloc] initWithAuthorId:self.work.authorId];
    [self.navigationController pushViewController:authorDetailController animated:YES];
}

- (void)likeWork:(id)sender
{
    if ([XCZLike like:self.work.id]) {
        [self initNavbarShowAuthor:self.showAuthorButton showLike:false];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLikesData" object:nil userInfo:nil];
}

- (void)unlikeWork:(id)sender
{
    if ([XCZLike unlike:self.work.id]) {
        [self initNavbarShowAuthor:self.showAuthorButton showLike:true];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLikesData" object:nil userInfo:nil];
}

#pragma mark - SomeDelegate

#pragma mark - Tableview Delegate

static NSString * const cellIdentifier = @"QuoteCell";

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.quotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZQuote *quote = self.quotes[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor colorWithRGBA:0x333333FF];
    cell.textLabel.text = quote.quote;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZQuote *quote = self.quotes[indexPath.row];
    UIViewController *controller = [[XCZQuoteViewController alloc] initWithQuote:quote];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Internal Helpers

// 设置navbar的按钮显示
- (void)initNavbarShowAuthor:(bool)showAuthor showLike:(bool)showLike
{
    NSMutableArray *btnArrays = [NSMutableArray new];
    
    // 是否显示作者按钮
    if (showAuthor) {
        [btnArrays addObject:self.authorButton];
    }
    
    if ([self.work.baiduWiki length] > 0) {
        [btnArrays addObject:self.wikiButton];
    }
    
    // 显示收藏/取消收藏按钮
    if (showLike) {
        [btnArrays addObject:self.likeButton];
    } else {
        [btnArrays addObject:self.unlikeButton];
    }
    
    self.navigationItem.rightBarButtonItems = btnArrays;
}

- (UIView *)createHeaderView
{
    XCZWorkDetailsView *detailsView = [[XCZWorkDetailsView alloc] initWithWork:self.work];
    self.detailsView = detailsView;
//    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toggleBars:)];
//    [detailsView addGestureRecognizer:gesture];
    return detailsView;
}

- (void)sizeHeaderViewToFit
{
    UIView *headerView = self.tableView.tableHeaderView;
    [headerView setNeedsLayout];
    [headerView layoutIfNeeded];
    CGSize size = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGRect frame = headerView.frame;
    frame.size.height = size.height;
    headerView.frame = frame;
    [self.tableView setTableHeaderView:headerView];
}

#pragma mark - Getters & Setters

- (UIBarButtonItem *)authorButton
{
    if (!_authorButton) {
        UIImage *authorIcon = [IonIcons imageWithIcon:ion_ios_person_outline
                                            iconColor:[UIColor grayColor]
                                             iconSize:31.0f
                                            imageSize:CGSizeMake(31.0f, 31.0f)];
        _authorButton = [[UIBarButtonItem alloc] initWithImage:authorIcon style:UIBarButtonItemStylePlain target:self action:@selector(redirectToAuthor:)];
    }
    
    return _authorButton;
}

- (UIBarButtonItem *)likeButton
{
    if (!_likeButton) {
        UIImage *likeIcon = [IonIcons imageWithIcon:ion_ios_star_outline
                                          iconColor:[UIColor grayColor]
                                           iconSize:27.0f
                                          imageSize:CGSizeMake(27.0f, 27.0f)];
        _likeButton = [[UIBarButtonItem alloc] initWithImage:likeIcon style:UIBarButtonItemStylePlain target:self action:@selector(likeWork:)];
    }
    
    return _likeButton;
}

- (UIBarButtonItem *)unlikeButton
{
    if (!_unlikeButton) {
        UIImage *unlikeIcon = [IonIcons imageWithIcon:ion_ios_star
                                            iconColor:self.view.tintColor
                                             iconSize:27.0f
                                            imageSize:CGSizeMake(27.0f, 27.0f)];
        _unlikeButton = [[UIBarButtonItem alloc] initWithImage:unlikeIcon style:UIBarButtonItemStylePlain target:self action:@selector(unlikeWork:)];
    }

    return _unlikeButton;
}

- (UIBarButtonItem *)wikiButton
{
    if (!_wikiButton) {
        UIImage *internetIcon = [IonIcons imageWithIcon:ion_ios_world_outline
                                            iconColor:[UIColor grayColor]
                                             iconSize:25.0f
                                            imageSize:CGSizeMake(27.0f, 27.0f)];
        _wikiButton = [[UIBarButtonItem alloc] initWithImage:internetIcon style:UIBarButtonItemStylePlain target:self action:@selector(redirectToWiki)];
    }
    
    return _wikiButton;
}

- (NSArray *)quotes
{
    if (!_quotes) {
        _quotes = [XCZQuote getByWorkId:self.work.id];
    }
    
    return _quotes;
}

@end
