//
//  XCZAuthorDetailsViewController.m
//  xcz
//
//  Created by 刘志鹏 on 14-7-4.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//


#import "XCZWork.h"
#import "XCZAuthor.h"
#import "XCZWorkTableViewCell.h"
#import "XCZAuthorHeaderView.h"
#import "XCZWikiViewController.h"
#import "XCZWorkDetailViewController.h"
#import "XCZAuthorDetailsViewController.h"
#import "XCZAuthorQuotesViewController.h"
#import "XCZUtils.h"
#import <FMDB/FMDB.h>
#import <AVOSCloud/AVOSCloud.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import <Masonry.h>
#import <IonIcons.h>

static NSString * const cellIdentifier = @"WorkCell";

@interface XCZAuthorDetailsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) XCZAuthor *author;
@property (nonatomic, strong) NSMutableDictionary *works;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation XCZAuthorDetailsViewController

- (instancetype)initWithAuthorId:(int)authorId
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.author = [XCZAuthor getById:authorId];
    self.hidesBottomBarWhenPushed = YES;
    
    // 加载works
    self.works = [NSMutableDictionary new];
    [self loadWorksByKind:@"文"];
    [self loadWorksByKind:@"诗"];
    [self loadWorksByKind:@"词"];
    [self loadWorksByKind:@"曲"];
    [self loadWorksByKind:@"赋"];
    
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"";
    [AVAnalytics beginLogPageView:[[NSString alloc] initWithFormat:@"author-%@", self.author.name ]];
    
    // 取消选中效果
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = self.author.name;
    [AVAnalytics endLogPageView:[[NSString alloc] initWithFormat:@"author-%@", self.author.name ]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *btnArrays = [NSMutableArray new];
    
    // 摘录
    UIImage *quotesImg = [UIImage imageNamed:@"quotesGray"];
    quotesImg = [quotesImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *quotesButton = [[UIBarButtonItem alloc] initWithImage:quotesImg style:UIBarButtonItemStylePlain target:self action:@selector(redirectToAuthorQuotes)];
    [btnArrays addObject:quotesButton];
    
    // 百科
    if ([self.author.baiduWiki length] > 0) {
        UIImage *internetIcon = [IonIcons imageWithIcon:ion_ios_world_outline
                                              iconColor:[UIColor grayColor]
                                               iconSize:25.0f
                                              imageSize:CGSizeMake(27.0f, 27.0f)];
        UIBarButtonItem *wikiButton = [[UIBarButtonItem alloc] initWithImage:internetIcon style:UIBarButtonItemStylePlain target:self action:@selector(redirectToWiki)];
        [btnArrays addObject:wikiButton];
    }
    
    self.navigationItem.rightBarButtonItems = btnArrays;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self sizeHeaderViewToFit];
}

# pragma mark - User Interface

- (void)redirectToAuthorQuotes
{
    XCZAuthorQuotesViewController *controller = [[XCZAuthorQuotesViewController alloc] initWithAuthorId:self.author.id];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)redirectToWiki
{
    UIViewController *controller = [[XCZWikiViewController alloc] initWithURL:self.author.baiduWiki];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.works.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [self.works allKeys];
    NSString* key = [keys objectAtIndex:section];
    NSArray *works = [self.works objectForKey:key];
    return works.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.works allKeys];
    NSString *key = [keys objectAtIndex:indexPath.section];
    NSArray *works = [self.works objectForKey:key];
    XCZWork *work = works[indexPath.row];
    
    XCZWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell updateWithWork:work showAuthor:NO];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.works allKeys];
    NSString *key = [keys objectAtIndex:indexPath.section];
    NSArray *works = [self.works objectForKey:key];
    XCZWork *work = works[indexPath.row];
    
    return [tableView fd_heightForCellWithIdentifier:cellIdentifier cacheByKey:[NSString stringWithFormat:@"%d", work.id] configuration:^(XCZWorkTableViewCell *cell) {
        [cell updateWithWork:work showAuthor:NO];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *keys = [self.works allKeys];
    NSString *key = [keys objectAtIndex:section];
    return key;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.works allKeys];
    NSString* key = [keys objectAtIndex:indexPath.section];
    NSArray *works = [self.works objectForKey:key];
    XCZWork *work = works[indexPath.row];
    
    UIViewController *controller = [[XCZWorkDetailViewController alloc] initWithWork:work];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Internal Helpers

- (void)createViews
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[XCZWorkTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.tableHeaderView = [self createHeaderView];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (UIView *)createHeaderView
{
    return [[XCZAuthorHeaderView alloc] initWithAuthor:self.author];
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

// 根据类别加载作品
- (void)loadWorksByKind:(NSString *)kindCN
{
    NSMutableArray *works = [XCZWork getWorksByAuthorId:self.author.id kind:kindCN];
    
    if ([works count] > 0) {
        [self.works setObject:works forKey:kindCN];
    }
}

#pragma mark - Getters & Setters


@end
