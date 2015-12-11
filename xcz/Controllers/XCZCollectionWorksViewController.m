//
//  XCZCollectionWorksViewController.m
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import "XCZCollectionCell.h"
#import "XCZCollectionWork.h"
#import "XCZWorkTableViewCell.h"
#import "XCZWorkViewController.h"
#import "XCZCollectionWorksViewController.h"
#import "UIColor+Helper.h"
#import "Constants.h"
#import "XCZUtils.h"
#import <Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <UITableView+FDTemplateLayoutCell.h>
#import <AVOSCloud.h>

static NSString * const CellIdentifier = @"CellIdentifier";

@interface XCZCollectionWorksViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) XCZCollection *collection;
@property (strong, nonatomic) NSArray *collectionWorks;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *titleLabel;

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
    
    
    // Custom titleView
    UILabel *titleLabel = [UILabel new];
    self.titleLabel = titleLabel;
    titleLabel.textColor = [UIColor clearColor];
    titleLabel.text = [NSString stringWithFormat:@"「 %@ 」", self.collection.name];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    CGSize size = [titleLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    titleLabel.frame = CGRectMake(0, 0, size.width, size.height);
    self.navigationItem.titleView = titleLabel;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [AVAnalytics beginLogPageView:[[NSString alloc] initWithFormat:@"collection-%@", self.collection.name]];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [AVAnalytics endLogPageView:[[NSString alloc] initWithFormat:@"collection-%@", self.collection.name]];
}

#pragma mark - View Helpers

- (void)createViews
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[XCZWorkTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    tableView.tableHeaderView = [self createHeaderView];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (UIView *)createHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    
    UIView *imageWapView = [UIView new];
    [headerView addSubview:imageWapView];
    imageWapView.backgroundColor = [UIColor whiteColor];
    imageWapView.layer.cornerRadius = [XCZCollectionCell getImageWidth] / 2;
    imageWapView.layer.masksToBounds = YES;
    imageWapView.layer.borderWidth = 1;
    imageWapView.layer.borderColor = [UIColor colorWithRGBA:0xE0E0E0FF].CGColor;
    
    UIImageView *imageView = [UIImageView new];
    imageView.layer.cornerRadius = [XCZCollectionCell getImageWidth] / 2 - 4;
    imageView.layer.masksToBounds = YES;
    [imageWapView addSubview:imageView];
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.collection.cover] placeholderImage:[UIImage imageNamed:@"DefaultCollectionCover.png"]];
    
    UILabel *collectionNameLabel = [UILabel new];
    collectionNameLabel.font = [UIFont systemFontOfSize:20];
    collectionNameLabel.text = self.collection.name;
    [headerView addSubview:collectionNameLabel];
    
    UILabel *collectionDescLabel = [UILabel new];
    collectionDescLabel.font = [UIFont systemFontOfSize:13];
    collectionDescLabel.text = self.collection.desc;
    collectionDescLabel.textColor = [UIColor colorWithRGBA:0x999999FF];
    [headerView addSubview:collectionDescLabel];
    
    UIView *bottomBorderView = [UIView new];
    bottomBorderView.backgroundColor = [UIColor colorWithRGBA:0xC8C7CCFF];
    [headerView addSubview:bottomBorderView];
    
    // 约束
    [imageWapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView).offset(10);
        make.left.equalTo(headerView).offset([XCZUtils getCellHorizonalGap]);
        make.bottom.equalTo(headerView).offset(-10);
        make.width.height.equalTo([NSNumber numberWithFloat:[XCZCollectionCell getImageWidth]]);
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(imageWapView);
        make.width.height.equalTo([NSNumber numberWithFloat:[XCZCollectionCell getImageWidth] - 8]);
    }];
    
    [collectionNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageWapView.mas_right).offset(10);
        make.top.equalTo(headerView).offset(18);
        make.right.equalTo(headerView).offset(-10);
    }];
    
    [collectionDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(collectionNameLabel);
        make.top.equalTo(collectionNameLabel.mas_bottom).offset(6);
        make.right.equalTo(collectionNameLabel);
    }];
    
    [bottomBorderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageWapView);
        make.right.equalTo(headerView);
        make.height.equalTo(@.5);
        make.bottom.equalTo(headerView);
    }];
    
    [headerView setNeedsLayout];
    [headerView layoutIfNeeded];
    CGSize size = [headerView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGRect frame = headerView.frame;
    frame.size.height = size.height;
    headerView.frame = frame;
    
    return headerView;
}

#pragma mark - Public Interface

#pragma mark - User Interface

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat alpha;
    
    if (offset < 0) {
        self.titleLabel.textColor = [UIColor clearColor];
    } else {
        alpha = MIN((offset - 100) / 200, 1.0);
        self.titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
    }
}

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
