//
//  XCZWorksViewController.m
//  xcz
//
//  Created by 刘志鹏 on 14-6-28.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import "XCZWorkSearchResult.h"
#import "XCZWorkTableViewCell.h"
#import "XCZWorksViewController.h"
#import "XCZWorkViewController.h"
#import "LocalizeHelper.h"
#import "XCZWorkSearchResultTableViewCell.h"
#import "Constants.h"
#import "OpenCCService.h"
#import <FMDB/FMDB.h>
#import <AVOSCloud/AVOSCloud.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import <Masonry.h>

static NSString * const cellIdentifier = @"WorkCell";
static NSString * const searchResultCellIdentifier = @"WorkSearchResultCellIdentifierCell";

@interface XCZWorksViewController () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *works;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (nonatomic) BOOL searching;

@end

@implementation XCZWorksViewController

#pragma mark - LifeCycle

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.searching = NO;
    self.works = [XCZWork getAll];

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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"openWorkView" object:nil];
}

// 收到通知中心通知后，进入特定的作品页面
//- (void)pushNotificationReceived:(NSNotification*) notification
//{
//    int workId = [[notification.userInfo objectForKey:@"workId"] intValue];
//    UIViewController *controller = [[XCZWorkDetailViewController alloc] initWithWorkId:workId];
//    [self.navigationController pushViewController:controller animated:YES];
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
}

#pragma mark - Create Views

- (void)createViews
{
    UISearchBar *searchBar = [UISearchBar new];
    searchBar.placeholder = LocalizedString(@"搜索");
    [self.view addSubview:searchBar];
    
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    [searchController.searchResultsTableView registerClass:[XCZWorkSearchResultTableViewCell class] forCellReuseIdentifier:searchResultCellIdentifier];
    searchController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchController = searchController;
    searchController.delegate = self;
    searchController.searchResultsDelegate = self;
    searchController.searchResultsDataSource = self;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[XCZWorkTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    // 约束
    [searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
    }];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(searchBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
}

#pragma mark - Public Methods

- (void)reorderWorks
{
    [AVAnalytics event:@"reorder_works"]; // “重排序”事件。
    self.works = [XCZWork reorderWorks];
    [UIView transitionWithView: self.tableView
                      duration: 0.15f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.tableView reloadData];
                    } completion:nil];
}

#pragma mark - SearchDisplayController

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    return YES;
}

// 过滤结果
- (void)filterContentForSearchText:(NSString*)searchText
{
    self.searching = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OpenCCService *service;
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
            service = [[OpenCCService alloc] initWithConverterType:OpenCCServiceConverterTypeT2S];
        } else {
            service = [[OpenCCService alloc] initWithConverterType:OpenCCServiceConverterTypeS2T];
        }

        NSArray *searchResults = [XCZWorkSearchResult fullTextSearch:[service convert:searchText]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.searching = NO;
            self.searchResults = searchResults;
            [self.searchController.searchResultsTableView reloadData];
        });
    });
}

// 以下代码解决了 searchResultsTableView 下方空间的 bug
// 参见：http://stackoverflow.com/questions/19161387/uisearchdisplaycontroller-tableview-content-offset-is-incorrect-after-keyboard-h
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

#pragma mark - TableView Delegate

// 表行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchController.searchResultsTableView) {
        return [self.searchResults count];
    } else {
        return [self.works count];
    }
}

// 单元格内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchController.searchResultsTableView) {
        XCZWorkSearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchResultCellIdentifier];
        XCZWorkSearchResult *workSearchResult = self.searchResults[indexPath.row];
        [cell updateWithWorkSearchResult:workSearchResult];
        return cell;
    } else {
        XCZWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        XCZWork *work = self.works[indexPath.row];
        [cell updateWithWork:work showAuthor:YES];
        return cell;
    }
}

// 单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.searchController.searchResultsTableView) {
        XCZWorkSearchResult *workSearchResult = self.searchResults[indexPath.row];
        return [tableView fd_heightForCellWithIdentifier:searchResultCellIdentifier cacheByKey:[NSString stringWithFormat:@"%d", workSearchResult.id] configuration:^(XCZWorkSearchResultTableViewCell *cell) {
            [cell updateWithWorkSearchResult:workSearchResult];
        }];
    } else {
        XCZWork *work = self.works[indexPath.row];
        return [tableView fd_heightForCellWithIdentifier:cellIdentifier cacheByKey:[NSString stringWithFormat:@"%d", work.id] configuration:^(XCZWorkTableViewCell *cell) {
            [cell updateWithWork:work showAuthor:YES];
        }];
    }
}

// 单元格预估高度
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.5;
}

// 选中某单元格后的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZWork *work;
    
    if (tableView == self.searchController.searchResultsTableView) {
        XCZWorkSearchResult *workSearchResult = self.searchResults[indexPath.row];
        work = [XCZWork getById:workSearchResult.id];
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    } else {
        work = self.works[indexPath.row];
    }
    
    UIViewController *controller = [[XCZWorkViewController alloc] initWithWork:work];
    [self.navigationController pushViewController:controller animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.searching) {
        UIView *headerView = [UIView new];
        headerView.backgroundColor = [UIColor whiteColor];
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [headerView addSubview:activityIndicatorView];
        [activityIndicatorView startAnimating];
        
        [activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(headerView);
            make.top.equalTo(headerView).offset(20);
        }];
        
        return headerView;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.searching) {
        return SCREEN_HEIGHT;
    } else {
        return CGFLOAT_MIN;
    }
}

#pragma mark - Internal Helpers

@end
