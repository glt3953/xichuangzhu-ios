//
//  XCZAuthorsViewController.m
//  xcz
//
//  Created by 刘志鹏 on 14-7-3.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//

#import "XCZAuthor.h"
#import "XCZDynasty.h"
#import "XCZWork.h"
#import "XCZAuthorTableViewCell.h"
#import "XCZAuthorsViewController.h"
#import "XCZAuthorViewController.h"
#import "UIColor+Helper.h"
#import <FMDB/FMDB.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import <Masonry.h>

static NSString * const cellIdentifier = @"AuthorCell";

@interface XCZAuthorsViewController () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchController;

// 正常显示
@property (nonatomic, strong) NSMutableArray *dynasties;
@property (nonatomic, strong) NSMutableDictionary *authors;

// 用于搜索
@property (nonatomic, strong) NSMutableArray *authorsForSearch;
@property (nonatomic, strong) NSArray *searchResult;

@end

@implementation XCZAuthorsViewController

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.dynasties = [XCZDynasty getNames];
    self.authors = [NSMutableDictionary new];
    self.authorsForSearch = [XCZAuthor getAllAuthors];
    
    for (XCZAuthor *author in self.authorsForSearch) {
        if (![self.authors objectForKey:author.dynasty]) {
            [self.authors setObject:[NSMutableArray array] forKey:author.dynasty];
        }
        
        [[self.authors objectForKey:author.dynasty] addObject:author];
    }
    
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
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"文学家";
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

#pragma mark - Create Views

- (void)createViews
{
    UISearchBar *searchBar = [UISearchBar new];
    searchBar.placeholder = @"搜索";
    [self.view addSubview:searchBar];
    
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    [searchController.searchResultsTableView registerClass:[XCZAuthorTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    searchController.searchResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.searchController = searchController;
    searchController.delegate = self;
    searchController.searchResultsDelegate = self;
    searchController.searchResultsDataSource = self;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[XCZAuthorTableViewCell class] forCellReuseIdentifier:cellIdentifier];
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

#pragma mark - SearchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    return YES;
}

// 过滤结果
- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.searchResult = [self.authorsForSearch filteredArrayUsingPredicate:resultPredicate];
}

// 以下代码解决了 searchResultsTableView 下方空间的 bug
// 参见：http://stackoverflow.com/questions/19161387/uisearchdisplaycontroller-tableview-content-offset-is-incorrect-after-keyboard-h
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

#pragma mark - TableView Delegate

// Section数目
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        return self.dynasties.count;
    }
}

// 每个Section的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResult.count;
    } else {
        NSString *dynastyName = [self.dynasties objectAtIndex:section];
        NSArray *authors = [self.authors objectForKey:dynastyName];
        return authors.count;
    }
}

// Section标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return @"";
    } else {
        return self.dynasties[section];
    }
}

// 索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return @[];
    } else {
        NSMutableArray *dynasties = [self.dynasties mutableCopy];
        for (int i = 0; i < dynasties.count; i++) {
            if ([dynasties[i] isEqualToString:@"五代十国"]) {
                dynasties[i] = @"五代";
            } else if ([dynasties[i] isEqualToString:@"南北朝"]) {
                dynasties[i] = @"南北";
            }
        }
        
        return dynasties;
    }
}

// 单元格的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZAuthor *author = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        author = self.searchResult[indexPath.row];
    } else {
        NSString *dynastyName = [self.dynasties objectAtIndex:indexPath.section];
        NSArray *authors = [self.authors objectForKey:dynastyName];
        author = authors[indexPath.row];
    }

    XCZAuthorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell updateWithAuthor:author];
    return cell;
}

// 单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZAuthor *author;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        author = self.searchResult[indexPath.row];
    } else {
        NSString *dynastyName = [self.dynasties objectAtIndex:indexPath.section];
        NSArray *authors = [self.authors objectForKey:dynastyName];
        author = authors[indexPath.row];
    }

    return [tableView fd_heightForCellWithIdentifier:cellIdentifier cacheByKey:[NSString stringWithFormat:@"%d", author.id] configuration:^(id cell) {
        [cell updateWithAuthor:author];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.5;
}

// 选中单元格
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZAuthor *author = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        author = self.searchResult[indexPath.row];
        [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    } else {
        NSString *dynastyName = [self.dynasties objectAtIndex:indexPath.section];
        NSArray *authors = [self.authors objectForKey:dynastyName];
        author = authors[indexPath.row];
    }
    
    XCZAuthorViewController *detailController = [[XCZAuthorViewController alloc] initWithAuthorId:author.id];

    [self.navigationController pushViewController:detailController animated:YES];
}

@end
