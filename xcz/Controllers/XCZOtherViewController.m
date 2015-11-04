//
//  MeViewController.m
//  xcz
//
//  Created by hustlzp on 15/10/7.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZBadgeView.h"
#import "XCZOtherViewController.h"
#import "XCZSettingsViewController.h"
#import "XCZAboutViewController.h"
#import "XCZLikesViewController.h"
#import "UIColor+Helper.h"
#import <Masonry/Masonry.h>
#import <ionicons/IonIcons.h>
#import <LeanCloudFeedback/LeanCloudFeedback.h>
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"

@interface XCZOtherViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) XCZBadgeView *badgeView;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation XCZOtherViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.title = @"其他";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationItem.title = @"返回";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[LCUserFeedbackAgent sharedInstance] countUnreadFeedbackThreadsWithBlock:^(NSInteger number, NSError *error) {
        if (!error && number != 0) {
            [[[[[self tabBarController] tabBar] items]
              objectAtIndex:3] setBadgeValue:[NSString stringWithFormat:@"%ld", (long)number]];
        } else {
            [[[[[self tabBarController] tabBar] items]
              objectAtIndex:3] setBadgeValue:nil];
        }
        
        self.badgeView.number = number;
    }];
}

#pragma mark - Layout

- (void)createViews
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
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

# pragma mark - tableview delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 3;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"我的收藏";
    } else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            [self configFeedbackCell:cell];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"向朋友推荐「西窗烛」";
        } else {
            cell.textLabel.text = @"去 App Store 评价";
        }
    } else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"设置";
        } else {
            cell.textLabel.text = @"关于";
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            XCZLikesViewController *controller = [XCZLikesViewController new];
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            LCUserFeedbackViewController *feedbackViewController = [[LCUserFeedbackViewController alloc] init];
            feedbackViewController.navigationBarStyle = LCUserFeedbackNavigationBarStyleNone;
            feedbackViewController.contactHeaderHidden = YES;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:feedbackViewController];
            // Remove badge
            [self presentViewController:navigationController animated:YES completion: ^{
                [[[[[self tabBarController] tabBar] items]
                  objectAtIndex:3] setBadgeValue:nil];
                self.badgeView.number = 0;
            }];
        } else if (indexPath.row == 1) {
            [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeText;
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:nil
                                              shareText:@"「西窗烛」，干净优雅的诗词赏析应用。iPhone版下载地址：https://itunes.apple.com/cn/app/xi-chuang-zhu/id912139104"
                                             shareImage:[UIImage imageNamed:@"share.jpg"]
                                        shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline, UMShareToWechatSession,UMShareToSina, UMShareToDouban, nil]
                                               delegate:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/xi-chuang-zhu/id912139104"]];
        }
    } else {
        if (indexPath.row == 0) {
            UIViewController *controller = [XCZSettingsViewController new];
            [self.navigationController pushViewController:controller animated:YES];
        } else {
            UIViewController *controller = [XCZAboutViewController new];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

#pragma mark - Internal Helpers

- (void)configFeedbackCell:(UITableViewCell *)cell
{
    UILabel *textLabel = [UILabel new];
    textLabel.text = @"给我们反馈";
    [cell.contentView addSubview:textLabel];
    
    [cell.contentView addSubview:self.badgeView];
    
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cell.contentView);
        make.left.equalTo(cell.contentView).offset(15);
    }];
    
    [self.badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(textLabel.mas_right).offset(10);
        make.centerY.equalTo(cell.contentView);
    }];
}

#pragma mark - Getters & Setters

- (XCZBadgeView *)badgeView
{
    if (!_badgeView) {
        _badgeView = [XCZBadgeView new];
    }
    
    return _badgeView;
}

@end
