//
//  XCZLikesViewController.m
//  xcz
//
//  Created by 刘志鹏 on 15/1/1.
//  Copyright (c) 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZLike.h"
#import "XCZWork.h"
#import "LocalizeHelper.h"
#import "XCZWorkTableViewCell.h"
#import "XCZLikesViewController.h"
#import "XCZWorkViewController.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import <Masonry.h>

static NSString * const CellIdentifier = @"WorkCell";

@interface XCZLikesViewController () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *likes;
@property (strong, nonatomic) NSMutableArray *works;
@property (strong, nonatomic) NSArray *searchResults;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchController;

@end

@implementation XCZLikesViewController

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self loadData];
    
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createViews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 数据重载通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotificationReceived:) name:@"reloadLikesData" object:nil];
}

#pragma mark - Create Views

- (void)createViews
{
    self.navigationItem.title = @"我的收藏";
    
    // “编辑”按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                                    initWithTitle:LocalizedString(@"编辑")
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(toggleEditingMode:)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    
    UISearchBar *searchBar = [UISearchBar new];
    searchBar.placeholder = LocalizedString(@"搜索");
    [self.view addSubview:searchBar];
    
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    [searchController.searchResultsTableView registerClass:[XCZWorkTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    searchController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchController = searchController;
    searchController.delegate = self;
    searchController.searchResultsDelegate = self;
    searchController.searchResultsDataSource = self;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[XCZWorkTableViewCell class] forCellReuseIdentifier:CellIdentifier];
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

- (void)viewWillAppear:(BOOL)animated
{
    // 取消选中效果
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
}

#pragma mark - User Interface

// 切换编辑模式
- (void)toggleEditingMode:(id)sender
{
    if (self.tableView.isEditing) {
        self.navigationItem.rightBarButtonItem.title = @"编辑";
        [self.tableView setEditing:NO animated:YES];
        
        // 在退出编辑模式时进行次序更新
        for (int i = 0; i < self.likes.count; i++) {
            XCZLike *like = self.likes[i];
            [XCZLike updateWork:like.workId showOrder:i];
            like.showOrder = i;
        }
    } else {
        self.navigationItem.rightBarButtonItem.title = @"完成";
        [self.tableView setEditing:YES animated:YES];
    }
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
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"titleSim contains[c] %@ OR titleTr contains[c] %@", searchText, searchText];
    self.searchResults = [self.works filteredArrayUsingPredicate:resultPredicate];
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
    XCZWork *work = nil;
    if (tableView == self.searchController.searchResultsTableView) {
        work = self.searchResults[indexPath.row];
    } else {
        work = self.works[indexPath.row];
    }
    
    XCZWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell updateWithWork:work showAuthor:YES];
    return cell;
}

// 单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZWork *work;
    if (tableView == self.searchController.searchResultsTableView) {
        work = self.searchResults[indexPath.row];
    } else {
        work = self.works[indexPath.row];
    }
    
    return [tableView fd_heightForCellWithIdentifier:CellIdentifier cacheByKey:[NSString stringWithFormat:@"%d", work.id] configuration:^(XCZWorkTableViewCell *cell) {
        [cell updateWithWork:work showAuthor:YES];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.5;
}

// 取消收藏
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        XCZWork *work = self.works[indexPath.row];
        [XCZLike unlike:work.id];
        [self.works removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// 交换次序
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (sourceIndexPath.row != destinationIndexPath.row) {
        XCZWork *sourceWork = self.works[sourceIndexPath.row];
        [self.works removeObjectAtIndex:sourceIndexPath.row];
        [self.works insertObject:sourceWork atIndex:destinationIndexPath.row];
        
        XCZLike *sourceLike = self.likes[sourceIndexPath.row];
        [self.likes removeObjectAtIndex:sourceIndexPath.row];
        [self.likes insertObject:sourceLike atIndex:destinationIndexPath.row];
    }
}

// 选中某单元格后的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZWork *work;
    
    if (tableView == self.searchController.searchResultsTableView) {
        work = self.searchResults[indexPath.row];
    } else {
        work = self.works[indexPath.row];
    }
    
    UIViewController *controller = [[XCZWorkViewController alloc] initWithWork:work];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Internal Helpers

// 加载数据
- (void)loadData
{
    self.works = [[NSMutableArray alloc] init];
    self.likes = [XCZLike getAll];
    
    for (int i = 0; i < self.likes.count; i++) {
        XCZLike *like = self.likes[i];
        XCZWork *work = [XCZWork getById:like.workId];
        self.works[i] = work;
    }
}

- (void)reloadNotificationReceived:(NSNotification*) notification
{
    [self loadData];
    [self.tableView reloadData];
}

@end
