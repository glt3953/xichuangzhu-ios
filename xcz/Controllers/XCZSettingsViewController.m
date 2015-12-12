//
//  XCZSettingsViewController.m
//  xcz
//
//  Created by hustlzp on 15/11/2.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZSettingsViewController.h"
#import "XCZChineseKindSettingsViewController.h"
#import "XCZQuoteFontSettingsViewController.h"
#import "LocalizeHelper.h"
#import "Constants.h"
#import <Masonry.h>

@interface XCZSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISlider *slider;

@end

@implementation XCZSettingsViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quoteFontChanged) name:XCZQuoteFontChangedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Layout

- (void)createViews
{
    self.navigationItem.title = LocalizedString(@"设置");
    
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

- (void)changeBrightness
{
    [UIScreen mainScreen].brightness = self.slider.value;
}

- (void)quoteFontChanged
{
    [self.tableView reloadData];
}

#pragma mark - SomeDelegate

#pragma mark - Tableview Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    NSString *chineseKind = [[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"] ? LocalizedString(@"简体") : LocalizedString(@"繁体");
    NSString *fontName;
    
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"QuoteFont"] isEqualToString:@"STFangsong"]) {
        fontName = LocalizedString(@"华文仿宋");
    } else {
        fontName = LocalizedString(@"文悦古体仿宋");
    }
    
    if (indexPath.row == 0) {
        [self configKeyValueCell:cell key:LocalizedString(@"简繁切换") value:chineseKind];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 1) {
        [self configKeyValueCell:cell key:LocalizedString(@"摘录字体") value:fontName];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        [self configBrightnessCell:cell];
    }
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 50;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        UIViewController *controller = [XCZChineseKindSettingsViewController new];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.row == 1) {
        UIViewController *controller = [XCZQuoteFontSettingsViewController new];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - Internal Helpers

- (void)configKeyValueCell:(UITableViewCell *)cell key:(NSString *)key value:(NSString *)value
{
    UILabel *keyLabel = [UILabel new];
    keyLabel.text = key;
    keyLabel.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:keyLabel];
    
    UILabel *valueLabel = [UILabel new];
    valueLabel.textColor = [UIColor grayColor];
    if (value) {
        valueLabel.text = value;
    }
    valueLabel.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:valueLabel];
    
    // 约束
    [keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell.contentView);
        make.left.equalTo(cell.contentView).offset(15);
    }];
    
    [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell.contentView);
        make.right.equalTo(cell.contentView);
    }];
}

- (void)configBrightnessCell:(UITableViewCell *)cell
{
    UILabel *textLabel = [UILabel new];
    textLabel.text = @"屏幕亮度";
    textLabel.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:textLabel];
    
    UISlider *slider = [UISlider new];
    self.slider = slider;
    slider.minimumValue = 0.0;
    slider.maximumValue = 0.5;
    slider.value = [UIScreen mainScreen].brightness;
    [slider addTarget:self action:@selector(changeBrightness) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:slider];
    
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell.contentView).offset(15);
        make.centerY.equalTo(cell.contentView);
    }];
    
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(textLabel.mas_right).offset(15);
        make.right.equalTo(cell.contentView).offset(-15);
        make.centerY.equalTo(cell.contentView);
    }];
}

#pragma mark - Getters & Setters


@end
