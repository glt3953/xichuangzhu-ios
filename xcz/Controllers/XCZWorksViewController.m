//
//  XCZWorksViewController.m
//  xcz
//
//  Created by 刘志鹏 on 14-6-28.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import "XCZWorkTableViewCell.h"
#import "XCZWorksViewController.h"
#import "XCZWorkDetailViewController.h"
#import <FMDB/FMDB.h>
#import <AVOSCloud/AVOSCloud.h>
#import <UITableView+FDTemplateLayoutCell.h>

static NSString * const cellIdentifier = @"WorkCell";

@interface XCZWorksViewController () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *works;
@property (nonatomic, strong) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation XCZWorksViewController

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.works = [XCZWork getAll];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"作品";
    
    [self.tableView registerClass:[XCZWorkTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerClass:[XCZWorkTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.searchDisplayController.searchBar.placeholder = @"搜索";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"openWorkView" object:nil];
}

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

// 收到通知中心通知后，进入特定的作品页面
- (void)pushNotificationReceived:(NSNotification*) notification
{
    int workId = [[notification.userInfo objectForKey:@"workId"] intValue];
    UIViewController *controller = [[XCZWorkDetailViewController alloc] initWithWorkId:workId];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
}

// 以下代码解决了 searchResultsTableView 下方空间的 bug
// 参见：http://stackoverflow.com/questions/19161387/uisearchdisplaycontroller-tableview-content-offset-is-incorrect-after-keyboard-h
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

// 过滤结果
- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"fullTitle contains[c] %@", searchText];
    self.searchResults = [self.works filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    return YES;
}

// 表行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    } else {
        return [self.works count];
    }
}

// 单元格内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZWork *work;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        work = self.searchResults[indexPath.row];
    } else {
        work = self.works[indexPath.row];
    }
    
    XCZWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell updateWithWork:work showAuthor:YES];
    return cell;
}

// 单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZWork *work;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        work = self.searchResults[indexPath.row];
    } else {
        work = self.works[indexPath.row];
    }
    
    return [tableView fd_heightForCellWithIdentifier:cellIdentifier cacheByKey:[NSString stringWithFormat:@"%d", work.id] configuration:^(XCZWorkTableViewCell *cell) {
        [cell updateWithWork:work showAuthor:YES];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.5;
}

// 选中某单元格后的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZWork *work;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        work = self.searchResults[indexPath.row];
    } else {
        work = self.works[indexPath.row];
    }
    
    UIViewController *controller = [[XCZWorkDetailViewController alloc] initWithWork:work];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
