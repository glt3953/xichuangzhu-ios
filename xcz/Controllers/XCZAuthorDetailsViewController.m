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
#import "XCZWorkDetailViewController.h"
#import "XCZAuthorDetailsViewController.h"
#import "XCZAuthorQuotesViewController.h"
#import "XCZUtils.h"
#import <FMDB/FMDB.h>
#import <AVOSCloud/AVOSCloud.h>
#import <UITableView+FDTemplateLayoutCell.h>

static NSString * const cellIdentifier = @"WorkCell";

@interface XCZAuthorDetailsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *worksHeaderField;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *nameField;
@property (weak, nonatomic) IBOutlet UILabel *periodField;
@property (weak, nonatomic) IBOutlet UILabel *introField;

@property (nonatomic, strong) NSMutableDictionary *works;
@property (nonatomic) int worksCount;
@property (nonatomic, strong) XCZAuthor *author;

@end

@implementation XCZAuthorDetailsViewController

-(instancetype)initWithAuthorId:(int)authorId
{
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    self.author = [XCZAuthor getById:authorId];
    self.hidesBottomBarWhenPushed = YES;
    
    // 加载worksCount
    self.worksCount = [XCZAuthor getWorksCount:authorId];
    
    // 加载works
    self.works = [[NSMutableDictionary alloc] init];
    [self loadWorksByKind:@"文"];
    [self loadWorksByKind:@"诗"];
    [self loadWorksByKind:@"词"];
    [self loadWorksByKind:@"曲"];
    [self loadWorksByKind:@"赋"];
    
    return self;
}

// 根据类别加载作品
- (void)loadWorksByKind:(NSString *)kindCN
{
    NSMutableArray *works = [XCZWork getWorksByAuthorId:self.author.id kind:kindCN];
    
    if ([works count] > 0) {
        [self.works setObject:works forKey:kindCN];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.title = @"";
    
    [AVAnalytics beginLogPageView:[[NSString alloc] initWithFormat:@"author-%@", self.author.name ]];
    
    // 姓名
    self.nameField.text = self.author.name;
    
    // 时期
    if (![self.author.deathYear isEqualToString:@""]) {
        self.periodField.text = [[NSString alloc] initWithFormat:@"[%@]  %@ ~ %@", self.author.dynasty, self.author.birthYear, self.author.deathYear];
    } else {
        self.periodField.text = [[NSString alloc] initWithFormat:@"[%@]", self.author.dynasty];
    }

    // 简介
    NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    contentParagraphStyle.lineHeightMultiple = 1.3;
    self.introField.attributedText = [[NSAttributedString alloc] initWithString:self.author.intro attributes:@{NSParagraphStyleAttributeName: contentParagraphStyle}];
    self.introField.preferredMaxLayoutWidth = [XCZUtils currentWindowWidth] - 35;
    
    // 作品数目
    self.worksHeaderField.text = [[NSString alloc] initWithFormat:@"作品 / %d", self.worksCount];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = self.author.name;
    [AVAnalytics endLogPageView:[[NSString alloc] initWithFormat:@"author-%@", self.author.name ]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[XCZWorkTableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    UIView *headerView = self.headerView;
    [self.tableView setTableHeaderView:headerView];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // 计算introLabel的高度
    NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        contentParagraphStyle.lineHeightMultiple = 1.3;
    CGRect introSize = [self.author.intro
                        boundingRectWithSize:CGSizeMake([XCZUtils currentWindowWidth] - 35, CGFLOAT_MAX)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{NSFontAttributeName: self.introField.font, NSParagraphStyleAttributeName: contentParagraphStyle}
                        context:nil];
    CGFloat introHeight = introSize.size.height;
    
    CGFloat height = self.introField.frame.origin.y + introHeight;
    height += 15;   // “作品”与简介之间的垂直距离
    height += self.worksHeaderField.frame.size.height;
    height += 12;
    
    // 设置header view的实际高度
    CGRect headerFrame = self.headerView.frame;
    headerFrame.size.height = height;
    headerView.frame = headerFrame;

    [self.tableView setTableHeaderView:headerView];
    
    UIImage *quotesImg = [UIImage imageNamed:@"quotesGray"];
    quotesImg = [quotesImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *quotesButton = [[UIBarButtonItem alloc] initWithImage:quotesImg style:UIBarButtonItemStylePlain target:self action:@selector(redirectToAuthorQuotes)];
    self.navigationItem.rightBarButtonItem = quotesButton;
}

# pragma mark - User Interface

- (void)redirectToAuthorQuotes
{
    XCZAuthorQuotesViewController *controller = [[XCZAuthorQuotesViewController alloc] initWithAuthorId:self.author.id];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Table view data source

// section数目
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.works.count;
}

// 每个section的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *keys = [self.works allKeys];
    NSString* key = [keys objectAtIndex:section];
    NSArray *works = [self.works objectForKey:key];
    return works.count;
}

// 单元格内容
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

// 单元格高度
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


// Section标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *keys = [self.works allKeys];
    NSString *key = [keys objectAtIndex:section];
    return key;
}

// 选中某单元格后的操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *keys = [self.works allKeys];
    NSString* key = [keys objectAtIndex:indexPath.section];
    NSArray *works = [self.works objectForKey:key];
    XCZWork *work = works[indexPath.row];
    
    UIViewController *controller = [[XCZWorkDetailViewController alloc] initWithWork:work];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Getters & Setters

- (UIView *)headerView
{
    if(!_headerView){
        [[NSBundle mainBundle] loadNibNamed:@"XCZAuthorHeaderView" owner:self options:nil];
    }
    
    return _headerView;
}


@end
