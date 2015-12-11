//
//  XCZChineseKindSettingsViewController.m
//  xcz
//
//  Created by hustlzp on 15/12/11.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZChineseKindSettingsViewController.h"
#import "Constants.h"
#import <Masonry.h>

@interface XCZChineseKindSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation XCZChineseKindSettingsViewController

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
    
    self.navigationItem.title = @"简繁切换";
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
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
        [self configCell:cell text:@"简体"];
    } else {
        [self configCell:cell text:@"繁体"];
    }
    
    if ([indexPath compare:self.selectedIndexPath] == NSOrderedSame) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SimplifiedChinese"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SimplifiedChinese"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XCZChineseKindChangedNotification object:nil];
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.selectedIndexPath = indexPath;
}

#pragma mark - Internal Helpers

- (void)configCell:(UITableViewCell *)cell text:(NSString *)text
{
    UILabel *textLabel = [UILabel new];
    textLabel.text = text;
    textLabel.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:textLabel];
    
    // 约束
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell.contentView);
        make.left.equalTo(cell.contentView).offset(15);
    }];
}

#pragma mark - Getters & Setters


@end
