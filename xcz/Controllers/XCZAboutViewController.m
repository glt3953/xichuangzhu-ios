//
//  AboutViewController.m
//  xcz
//
//  Created by hustlzp on 15/10/8.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import "XCZAboutViewController.h"
#import "XCZWorkViewController.h"
#import "LocalizeHelper.h"
#import "UIColor+Helper.h"
#import "Constants.h"
#import <Masonry/Masonry.h>

@interface XCZAboutViewController ()

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation XCZAboutViewController

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
}

#pragma mark - Layout

- (void)createViews
{
    // wap
    UIView *navTitleView = [self createNavTitleView];
    self.navigationItem.titleView = navTitleView;
    
    UIScrollView *scrollView = [UIScrollView new];
    [self.view addSubview:scrollView];

    UIView *contentView = [self createContentView];
    [scrollView addSubview:contentView];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.edges.equalTo(scrollView);
    }];
}

- (UIView *)createNavTitleView
{
    UIView *wapView = [UIView new];
    
    // logo
    UIImageView *logoView = [UIImageView new];
    logoView.image = [UIImage imageNamed:@"AppIcon40x40"];
    logoView.layer.cornerRadius = 3;
    logoView.layer.masksToBounds = YES;
    [wapView addSubview:logoView];
    
    // text
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"西窗烛 ") attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17]}];
    NSMutableAttributedString *versionText = [[NSMutableAttributedString alloc] initWithString:@"v1.10.0" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    [text appendAttributedString:versionText];
    UILabel *textLabel = [UILabel new];
    textLabel.attributedText = text;
    [wapView addSubview:textLabel];
    
    // 约束
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(wapView);
        make.width.height.equalTo(@20);
    }];
    
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(logoView);
        make.left.equalTo(logoView.mas_right).offset(5);
        make.right.equalTo(wapView);
    }];
    
    CGSize size = [wapView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    wapView.frame = CGRectMake(0, 0, size.width, size.height);
    
    return wapView;
}

- (UIView *)createContentView
{
    UIView *contentView = [UIView new];
    
    // slogan wap
    UIView *sloganWapView = [UIView new];
    sloganWapView.userInteractionEnabled = YES;
    sloganWapView.backgroundColor = [UIColor colorWithRGBA:0xF2F2F2FF];
    // tap gesture
    UITapGestureRecognizer *gestureForSlogan = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sloganTapped:)];
    [sloganWapView addGestureRecognizer:gestureForSlogan];
    // long press gesture
    UILongPressGestureRecognizer *longPressGestureForSlogan = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sloganLongPressed:)];
    [sloganWapView addGestureRecognizer:longPressGestureForSlogan];
    [contentView addSubview:sloganWapView];
    
    // slogan
    UILabel *sloganLabel = [UILabel new];
    sloganLabel.numberOfLines = 0;
    sloganLabel.lineBreakMode = NSLineBreakByWordWrapping;
    sloganLabel.font = [UIFont fontWithName:XCZFontWYFangsong size:20];
    NSString *sloganText = LocalizedString(@"何当共剪西窗烛，\n却话巴山夜雨时。");
    NSMutableAttributedString *attributedStringForSlogan = [[NSMutableAttributedString alloc] initWithString:sloganText];
    NSMutableParagraphStyle *paragraphStyleForSlogan = [[NSMutableParagraphStyle alloc] init];
    paragraphStyleForSlogan.alignment = NSTextAlignmentCenter;
    paragraphStyleForSlogan.lineSpacing = 5;
    [attributedStringForSlogan addAttribute:NSParagraphStyleAttributeName value:paragraphStyleForSlogan range:NSMakeRange(0, sloganText.length)];
    [attributedStringForSlogan addAttribute:NSKernAttributeName value:@(1.1)
                             range:NSMakeRange(0, sloganText.length)];
    sloganLabel.attributedText = attributedStringForSlogan;
    [sloganWapView addSubview:sloganLabel];
    
    // slogan from
    UILabel *sloganFromLabel = [UILabel new];
    sloganFromLabel.text = LocalizedString(@"— [唐]李商隐");
    sloganFromLabel.font = [UIFont fontWithName:XCZFontWYFangsong size:12];
    [sloganWapView addSubview:sloganFromLabel];
    
    // about
    UILabel *aboutLabel = [UILabel new];
    aboutLabel.numberOfLines = 0;
    aboutLabel.lineBreakMode = NSLineBreakByWordWrapping;
    aboutLabel.font = [UIFont systemFontOfSize:15];
    NSString *aboutText = LocalizedString(@"西窗烛旨在为大家提供一个干净的古典文学欣赏空间。大江东去的豪放明快、低头弄梅的婉媚曲折、西窗剪烛的情深意重，每次读到都会有所触动。文学之美，时光洗练。");
    NSMutableAttributedString *attributedStringForAbout = [[NSMutableAttributedString alloc] initWithString:aboutText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    [attributedStringForAbout addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, aboutText.length)];
    aboutLabel.attributedText = attributedStringForAbout;
    [contentView addSubview:aboutLabel];
    
    // contact
    UILabel *contactLabel = [UILabel new];
    contactLabel.numberOfLines = 0;
    contactLabel.lineBreakMode = NSLineBreakByWordWrapping;
    contactLabel.font = [UIFont systemFontOfSize:15];
    NSMutableAttributedString *contactPreString = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"邮件联系：\n") attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}];
    NSMutableAttributedString *contactProString = [[NSMutableAttributedString alloc] initWithString:@"hi@xichuangzhu.com" attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSFontAttributeName: [UIFont systemFontOfSize:13]}];
    [contactPreString appendAttributedString:contactProString];
    
    NSMutableParagraphStyle *paragraphStyleForContact = [NSMutableParagraphStyle new];
    paragraphStyleForContact.lineSpacing = 3;
    [contactPreString addAttribute:NSParagraphStyleAttributeName value:paragraphStyleForContact range:NSMakeRange(0, contactPreString.length)];
    
    contactLabel.attributedText = contactPreString;
    contactLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *gestureForContact = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contactTapped)];
    [contactLabel addGestureRecognizer:gestureForContact];
    [contentView addSubview:contactLabel];
    
    // website
    UILabel *websiteLabel = [UILabel new];
    websiteLabel.numberOfLines = 0;
    websiteLabel.lineBreakMode = NSLineBreakByWordWrapping;
    websiteLabel.font = [UIFont systemFontOfSize:15];
    NSMutableAttributedString *websitePreString = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"西窗烛网页版：\n") attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}];
    NSMutableAttributedString *websiteProString = [[NSMutableAttributedString alloc] initWithString:@"www.xichuangzhu.com" attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSFontAttributeName: [UIFont systemFontOfSize:13]}];
    [websitePreString appendAttributedString:websiteProString];
    
    NSMutableParagraphStyle *paragraphStyleForWebsite = [NSMutableParagraphStyle new];
    paragraphStyleForWebsite.lineSpacing = 3;
    [websitePreString addAttribute:NSParagraphStyleAttributeName value:paragraphStyleForWebsite range:NSMakeRange(0, websitePreString.length)];
    
    websiteLabel.attributedText = websitePreString;
    websiteLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *gestureForWebsite = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(websiteTapped)];
    [websiteLabel addGestureRecognizer:gestureForWebsite];
    [contentView addSubview:websiteLabel];
    
    // GitHub
    UILabel *githubLabel = [UILabel new];
    githubLabel.numberOfLines = 0;
    githubLabel.lineBreakMode = NSLineBreakByWordWrapping;
    githubLabel.font = [UIFont systemFontOfSize:15];
    NSMutableAttributedString *gitHubPreString = [[NSMutableAttributedString alloc] initWithString:@"GitHub 地址：\n" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]}];
    NSMutableAttributedString *gitHubProString = [[NSMutableAttributedString alloc] initWithString:@"hustlzp/xichuangzhu-ios" attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSFontAttributeName: [UIFont systemFontOfSize:13]}];
    [gitHubPreString appendAttributedString:gitHubProString];
    
    NSMutableParagraphStyle *paragraphStyleForGitHub = [NSMutableParagraphStyle new];
    paragraphStyleForGitHub.lineSpacing = 3;
    [gitHubPreString addAttribute:NSParagraphStyleAttributeName value:paragraphStyleForGitHub range:NSMakeRange(0, gitHubPreString.length)];
    
    githubLabel.attributedText = gitHubPreString;
    githubLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *gestureForGitHub = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gitHubTapped)];
    [githubLabel addGestureRecognizer:gestureForGitHub];
    [contentView addSubview:githubLabel];
    
    // 约束
    
    [sloganWapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(contentView);
    }];
    
    [sloganLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(sloganWapView);
        make.top.equalTo(sloganWapView).offset(45);
    }];
    
    [sloganFromLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(sloganWapView).offset(-30);
        make.top.equalTo(sloganLabel.mas_bottom).offset(20);
        make.bottom.equalTo(sloganWapView).offset(-15);
    }];
    
    [aboutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sloganWapView.mas_bottom).offset(25);
        make.left.equalTo(contentView).offset(20);
        make.right.equalTo(contentView).offset(-20);
    }];
    
    [contactLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(aboutLabel.mas_bottom).offset(20);
        make.left.right.equalTo(aboutLabel);
    }];
    
    [websiteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contactLabel.mas_bottom).offset(20);
        make.left.right.equalTo(contactLabel);
    }];
    
    [githubLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(websiteLabel.mas_bottom).offset(20);
        make.left.right.equalTo(contactLabel);
        make.bottom.equalTo(contentView).offset(-60);
    }];

    return contentView;
}

#pragma mark - Public Interface

#pragma mark - User Interface

- (void)contactTapped
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:hi@xichuangzhu.com"]];
}

- (void)websiteTapped
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.xichuangzhu.com"]];
}

- (void)gitHubTapped
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/hustlzp/xichuangzhu-ios"]];
}

- (void)sloganTapped:(UITapGestureRecognizer *)gesture
{
    gesture.view.backgroundColor = [UIColor colorWithRGBA:0xEAEAEAFF];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        gesture.view.backgroundColor = [UIColor colorWithRGBA:0xF2F2F2FF];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIViewController *controller = [[XCZWorkViewController alloc] initWithWorkId:10024];
            [self.navigationController pushViewController:controller animated:YES];
        });
    });
}

- (void)sloganLongPressed:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        gesture.view.backgroundColor = [UIColor colorWithRGBA:0xEAEAEAFF];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        gesture.view.backgroundColor = [UIColor colorWithRGBA:0xF2F2F2FF];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIViewController *controller = [[XCZWorkViewController alloc] initWithWorkId:10024];
            [self.navigationController pushViewController:controller animated:YES];
        });
    }
}

#pragma mark - SomeDelegate


#pragma mark - Internal Helpers


#pragma mark - Getters & Setters


@end
