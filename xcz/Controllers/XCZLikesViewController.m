//
//  XCZLikesViewController.m
//  xcz
//
//  Created by 刘志鹏 on 15/1/1.
//  Copyright (c) 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZLike.h"
#import "XCZWork.h"
#import "XCZWorkTableViewCell.h"
#import "XCZLikesViewController.h"
#import "XCZWorkDetailViewController.h"
#import <UITableView+FDTemplateLayoutCell.h>

static NSString * const cellIdentifier = @"WorkCell";

@interface XCZLikesViewController () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *likes;
@property (nonatomic, strong) NSMutableArray *works;
@property (nonatomic, strong) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation XCZLikesViewController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"我的收藏";
        
        // 加载收藏作品
        [self loadData];
    }
    
    return self;
}

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[XCZWorkTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerClass:[XCZWorkTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.searchDisplayController.searchBar.placeholder = @"搜索";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //添加“编辑”按钮
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"编辑"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(toggleEditingMode:)];
    [self.navigationItem setRightBarButtonItem:rightButton];
    
    // 数据重载通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotificationReceived:) name:@"reloadLikesData" object:nil];
}

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

- (void)viewWillAppear:(BOOL)animated
{
    // 取消选中效果
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
}

- (void)reloadNotificationReceived:(NSNotification*) notification
{
    [self loadData];
    [self.tableView reloadData];
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
    XCZWork *work = nil;
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

// 以下代码解决了 searchResultsTableView 下方空间的 bug
// 参见：http://stackoverflow.com/questions/19161387/uisearchdisplaycontroller-tableview-content-offset-is-incorrect-after-keyboard-h
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
