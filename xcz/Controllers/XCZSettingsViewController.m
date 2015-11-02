//
//  XCZSettingsViewController.m
//  xcz
//
//  Created by hustlzp on 15/11/2.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZSettingsViewController.h"
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
    
    self.navigationItem.title = @"设置";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Layout

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

- (void)changeBrightness
{
    [UIScreen mainScreen].brightness = self.slider.value;
}

#pragma mark - SomeDelegate

#pragma mark - Tableview Delegate

static NSString * const cellIdentifier = @"identifier";

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    
    [self configBrightnessCell:cell];
    
    return cell;
}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 50;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Internal Helpers

- (void)configBrightnessCell:(UITableViewCell *)cell
{
    UILabel *textLabel = [UILabel new];
    textLabel.text = @"屏幕亮度";
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
