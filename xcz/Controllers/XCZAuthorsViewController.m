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
#import "LocalizeHelper.h"
#import <FMDB/FMDB.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import <Masonry.h>
#import <AVOSCloud.h>

static NSString * const cellIdentifier = @"AuthorCell";

@interface XCZAuthorsViewController () <UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchController;

@property (nonatomic, strong) NSMutableArray *authors;
@property (nonatomic, strong) NSMutableArray *dynasties;
@property (nonatomic, strong) NSMutableDictionary *authorsForDynasty;
@property (nonatomic, strong) NSMutableArray *firstChars;
@property (strong, nonatomic) NSMutableDictionary *authorsForFirstChar;
@property (nonatomic, strong) NSArray *searchResult;

@property (nonatomic) BOOL orderAuthorsByAlphabet;

@end

@implementation XCZAuthorsViewController

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.authors = [XCZAuthor getAllAuthors];
    self.dynasties = [XCZDynasty getAll];
    self.authorsForDynasty = [NSMutableDictionary new];
    self.firstChars = [NSMutableArray new];
    self.authorsForFirstChar = [NSMutableDictionary new];
    
    for (XCZAuthor *author in self.authors) {
        if (![self.authorsForDynasty objectForKey:author.dynasty]) {
            [self.authorsForDynasty setObject:[NSMutableArray array] forKey:author.dynasty];
        }
        [[self.authorsForDynasty objectForKey:author.dynasty] addObject:author];
        
        if (![self.authorsForFirstChar objectForKey:author.firstChar]) {
            [self.authorsForFirstChar setObject:[NSMutableArray array] forKey:author.firstChar];
        }
        [[self.authorsForFirstChar objectForKey:author.firstChar] addObject:author];
    }
    
    for (char firstChar = 'A'; firstChar <= 'Z'; firstChar++) {
        NSString *firstCharInString = [NSString stringWithFormat:@"%c", firstChar];
        
        if ([self.authorsForFirstChar objectForKey:firstCharInString] != nil) {
            [self.firstChars addObject:firstCharInString];

            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            NSArray *sortedArray = [[self.authorsForFirstChar objectForKey:firstCharInString] sortedArrayUsingDescriptors:sortDescriptors];
            [self.authorsForFirstChar setObject:sortedArray forKey:firstCharInString];
        }
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
}

#pragma mark - Create Views

- (void)createViews
{
    self.navigationItem.title = @"文学家";
    
    UISearchBar *searchBar = [UISearchBar new];
    searchBar.placeholder = LocalizedString(@"搜索");
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

#pragma mark - Public Interface

- (void)turnOnAuthorsAlphabetMode
{
    [AVAnalytics event:@"turn_on_authors_alphabet_mode"];
    self.orderAuthorsByAlphabet = YES;
    [self.tableView reloadData];
}

- (void)turnOffAuthorsAlphabetMode
{
    [AVAnalytics event:@"turn_off_authors_alphabet_mode"];
    self.orderAuthorsByAlphabet = NO;
    [self.tableView reloadData];
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
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"nameSim contains[c] %@ OR nameTr contains[c] %@", searchText, searchText];
    self.searchResult = [self.authors filteredArrayUsingPredicate:resultPredicate];
}

// 以下代码解决了 searchResultsTableView 下方空间的 bug
// 参见：http://stackoverflow.com/questions/19161387/uisearchdisplaycontroller-tableview-content-offset-is-incorrect-after-keyboard-h
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    } else {
        if (self.orderAuthorsByAlphabet) {
            return self.firstChars.count;
        } else {
            return self.dynasties.count;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResult.count;
    } else {
        if (self.orderAuthorsByAlphabet) {
            NSString *firstChar = self.firstChars[section];
            NSArray *authors = [self.authorsForFirstChar objectForKey:firstChar];
            return authors.count;
        } else {
            XCZDynasty *dynasty = self.dynasties[section];
            NSArray *authors = [self.authorsForDynasty objectForKey:dynasty.name];
            return authors.count;
        }
    }
}

// Section标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return @"";
    } else {
        if (self.orderAuthorsByAlphabet) {
            return self.firstChars[section];
        } else {
            XCZDynasty *dynasty = self.dynasties[section];
            return dynasty.name;
        }
    }
}

// 索引
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return @[];
    } else {
        if (self.orderAuthorsByAlphabet) {
            return self.firstChars;
        } else {
            NSMutableArray *dynastyNames = [NSMutableArray new];
            
            for (int i = 0; i < self.dynasties.count; i++) {
                XCZDynasty *dynasty = self.dynasties[i];
                
                if ([dynasty.name hasPrefix:@"五代"]) {
                    [dynastyNames addObject:@"五代"];
                } else if ([dynasty.name hasPrefix:@"南北"]) {
                    [dynastyNames addObject:@"南北"];
                } else {
                    [dynastyNames addObject:dynasty.name];
                }
            }
            
            return dynastyNames;
        }
    }
}

// 单元格的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZAuthor *author = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        author = self.searchResult[indexPath.row];
    } else {
        if (self.orderAuthorsByAlphabet) {
            NSString *firstChar = self.firstChars[indexPath.section];
            NSArray *authors = [self.authorsForFirstChar objectForKey:firstChar];
            author = authors[indexPath.row];
        } else {
            XCZDynasty *dynasty = self.dynasties[indexPath.section];
            NSArray *authors = [self.authorsForDynasty objectForKey:dynasty.name];
            author = authors[indexPath.row];
        }
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
        if (self.orderAuthorsByAlphabet) {
            NSString *firstChar = self.firstChars[indexPath.section];
            NSArray *authors = [self.authorsForFirstChar objectForKey:firstChar];
            author = authors[indexPath.row];
        } else {
            XCZDynasty *dynasty = self.dynasties[indexPath.section];
            NSArray *authors = [self.authorsForDynasty objectForKey:dynasty.name];
            author = authors[indexPath.row];
        }
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
        if (self.orderAuthorsByAlphabet) {
            NSString *firstChar = self.firstChars[indexPath.section];
            NSArray *authors = [self.authorsForFirstChar objectForKey:firstChar];
            author = authors[indexPath.row];
        } else {
            XCZDynasty *dynasty = self.dynasties[indexPath.section];
            NSArray *authors = [self.authorsForDynasty objectForKey:dynasty.name];
            author = authors[indexPath.row];
        }
    }
    
    XCZAuthorViewController *detailController = [[XCZAuthorViewController alloc] initWithAuthorId:author.id];
    [self.navigationController pushViewController:detailController animated:YES];
}

@end
