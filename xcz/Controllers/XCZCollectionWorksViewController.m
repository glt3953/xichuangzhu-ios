//
//  XCZCollectionWorksViewController.m
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import "XCZCollectionWork.h"
#import "XCZWorkTableViewCell.h"
#import "XCZWorkViewController.h"
#import "XCZCollectionWorksViewController.h"
#import <Masonry.h>
#import <UITableView+FDTemplateLayoutCell.h>

static NSString * const CellIdentifier = @"CellIdentifier";

@interface XCZCollectionWorksViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) XCZCollection *collection;
@property (strong, nonatomic) NSArray *collectionWorks;
@property (weak, nonatomic) UITableView *tableView;

@end

@implementation XCZCollectionWorksViewController

#pragma mark - LifeCycle

- (instancetype)initWithCollection:(XCZCollection *)collection
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.collection = collection;
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
    
    self.navigationItem.title = self.collection.fullName;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - View Helpers

- (void)createViews
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[XCZWorkTableViewCell class] forCellReuseIdentifier:CellIdentifier];
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

#pragma mark - TableView Delegate

// 表行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.collectionWorks count];
}

// 单元格内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZCollectionWork *collectionWork = self.collectionWorks[indexPath.row];
    XCZWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell updateWithCollectionWork:collectionWork];
    return cell;
}

// 单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZCollectionWork *collectionWork = self.collectionWorks[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:CellIdentifier cacheByKey:[NSString stringWithFormat:@"%ld", (long)collectionWork.id] configuration:^(XCZWorkTableViewCell *cell) {
        [cell updateWithCollectionWork:collectionWork];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.5;
}

// 选中某单元格后的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZCollectionWork *collectionWork = self.collectionWorks[indexPath.row];
    XCZWork *work = [XCZWork getById:(int)collectionWork.workId];
    UIViewController *controller = [[XCZWorkViewController alloc] initWithWork:work];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Internal Helpers

#pragma mark - Getters & Setters

- (NSArray *)collectionWorks
{
    if (!_collectionWorks) {
        _collectionWorks = [XCZCollectionWork getByCollectionId:self.collection.id];
    }
    
    return _collectionWorks;
}

@end
