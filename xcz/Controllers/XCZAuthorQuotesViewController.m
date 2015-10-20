//
//  XCZAuthorQuotesViewController.m
//  xcz
//
//  Created by hustlzp on 15/10/19.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import "XCZQuote.h"
#import "XCZQuoteViewController.h"
#import "XCZWorkDetailViewController.h"
#import "XCZAuthorQuotesViewController.h"
#import <Masonry.h>

static NSString * const cellIdentifier = @"identifier";

@interface XCZAuthorQuotesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *quotes;
@property (nonatomic) int authorId;

@end

@implementation XCZAuthorQuotesViewController

#pragma mark - LifeCycle

- (instancetype)initWithAuthorId:(int)authorId
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.authorId = authorId;
    
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
    
    self.navigationItem.title = @"摘录";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
}

#pragma mark - Layout

- (void)createViews
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Public Interface

#pragma mark - User Interface

#pragma mark - SomeDelegate

#pragma mark - Tableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.quotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuoteCell"];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"QuoteCell"];
    }
    XCZQuote *quote = self.quotes[indexPath.row];
    cell.textLabel.text = quote.quote;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZQuote *quote = self.quotes[indexPath.row];
    UIViewController *controller = [[XCZQuoteViewController alloc] initWithQuote:quote];
    [self.navigationController pushViewController:controller animated:YES];
}

// 用于支持tableviewcell文字赋值
- (void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender {
    
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    XCZQuote *quote = self.quotes[indexPath.row];
    pasteboard.string = quote.quote;
}

- (BOOL)tableView:(UITableView*)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender {
    
    if (action == @selector(copy:)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath {
    return YES;
}

#pragma mark - Internal Helpers

#pragma mark - Getters & Setters

- (NSArray *)quotes
{
    if (!_quotes) {
        _quotes = [XCZQuote getByAuthorId:self.authorId];
    }
    
    return _quotes;
}

@end
