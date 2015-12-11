//
//  XCZQuoteFontSettingsViewController.m
//  xcz
//
//  Created by hustlzp on 15/12/11.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuoteFontSettingsViewController.h"
#import "Constants.h"
#import "XCZUtils.h"
#import <Masonry.h>

@interface XCZQuoteFontSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation XCZQuoteFontSettingsViewController

#pragma mark - LifeCycle

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置摘录字体";
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"QuoteFont"] isEqualToString:XCZFontHWFangsong]) {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    } else {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - View Helpers

- (void)createViews
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0) style:UITableViewStyleGrouped];
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

#pragma mark - Tableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    
    if (indexPath.row == 0) {
        [self configCell:cell text:@"品味传统文学之美" textFont:[UIFont fontWithName:XCZFontHWFangsong size:18] details:@"华文仿宋"];
    } else {
        [self configCell:cell text:@"品味传统文学之美" textFont:[UIFont fontWithName:XCZFontWYFangsong size:16] details:@"文悦古体仿宋"];
    }
    
    if ([indexPath compare:self.selectedIndexPath] == NSOrderedSame) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:XCZFontHWFangsong forKey:@"QuoteFont"];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:XCZFontWYFangsong forKey:@"QuoteFont"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XCZQuoteFontChangedNotification object:nil];
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.selectedIndexPath = indexPath;
}

#pragma mark - Internal Helpers

- (void)configCell:(UITableViewCell *)cell text:(NSString *)text textFont:(UIFont *)textFont details:(NSString *)details
{
    UILabel *textLabel = [UILabel new];
    textLabel.text = text;
    textLabel.font = textFont;
    [cell.contentView addSubview:textLabel];
    
    UILabel *detailsLabel = [UILabel new];
    detailsLabel.text = details;
    detailsLabel.textColor = [UIColor lightGrayColor];
    detailsLabel.font = [UIFont systemFontOfSize:12];
    [cell.contentView addSubview:detailsLabel];
    
    // 约束
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(cell.contentView).offset(10);
        make.left.equalTo(cell.contentView).offset([XCZUtils getCellHorizonalGap]);
    }];
    
    [detailsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textLabel.mas_bottom).offset(5);
        make.left.equalTo(textLabel);
        make.bottom.equalTo(cell.contentView).offset(-12);
    }];
}

#pragma mark - Getters & Setters

@end
