//
//  LibraryViewController.m
//  xcz
//
//  Created by hustlzp on 15/10/7.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import "XCZLibraryViewController.h"
#import "XCZWorksViewController.h"
#import "XCZAuthorsViewController.h"
#import "UIColor+Helper.h"
#import "LocalizeHelper.h"
#import "UIImage+FontAwesome.h"
#import <Masonry/Masonry.h>
#import <ionicons/IonIcons.h>

@interface XCZLibraryViewController ()

@property (strong, nonatomic) UISegmentedControl *segmentControl;
@property (strong, nonatomic) XCZWorksViewController *worksViewController;
@property (strong, nonatomic) XCZAuthorsViewController *authorsViewController;

@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (nonatomic) BOOL hasSetupViews;

@property (strong, nonatomic) NSArray *works;

@property (strong, nonatomic) UIBarButtonItem *refreshWorksButton;
@property (strong, nonatomic) UIBarButtonItem *turnOnAuthorsAlphabetModeButton;
@property (strong, nonatomic) UIBarButtonItem *turnOffAuthorsAlphabetModeButton;
@property (nonatomic) BOOL orderAuthorsByAlphabet;

@end

@implementation XCZLibraryViewController

#pragma mark - LifeCycle

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.worksViewController = [XCZWorksViewController new];
    [self addChildViewController:self.worksViewController];
    [self.worksViewController view];
    
    self.authorsViewController = [XCZAuthorsViewController new];
    [self addChildViewController:self.authorsViewController];
    [self.authorsViewController view];
    
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityView = activityView;
    [activityView startAnimating];
    [self.view bringSubviewToFront:activityView];
    [self.view addSubview:activityView];
    
    [activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self segmentControlTapped];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.hasSetupViews) {
        self.hasSetupViews = YES;
        
        [self createViews];
        [self.activityView stopAnimating];
    }
}

#pragma mark - Layout

- (void)createViews
{
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"作品", LocalizedString(@"文学家")]];
    self.segmentControl = segmentControl;
    self.segmentControl.selectedSegmentIndex = 0;
    [self.segmentControl addTarget:self action:@selector(segmentControlTapped) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentControl;
    
    [self.view addSubview:self.worksViewController.view];
    [self.worksViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.authorsViewController.view];
    [self.authorsViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Public Interface

- (void)updateTabBarTitle
{
    self.tabBarItem.title = LocalizedString(@"文库");
}

#pragma mark - User Interface

- (void)segmentControlTapped
{
    if (self.segmentControl.selectedSegmentIndex == 0) {
        self.authorsViewController.view.hidden = YES;
        self.worksViewController.view.hidden = NO;
        self.navigationItem.rightBarButtonItem = self.refreshWorksButton;
        self.navigationItem.title = self.worksViewController.navigationItem.title;
    } else {
        self.authorsViewController.view.hidden = NO;
        self.worksViewController.view.hidden = YES;
        self.navigationItem.title = self.authorsViewController.navigationItem.title;
        
        if (self.orderAuthorsByAlphabet) {
            self.navigationItem.rightBarButtonItem = self.turnOffAuthorsAlphabetModeButton;
        } else {
            self.navigationItem.rightBarButtonItem = self.turnOnAuthorsAlphabetModeButton;
        }
    }
}

- (void)reorderWorks
{
    [self.worksViewController reorderWorks];
}

- (void)turnOnAuthorsAlphabetMode
{
    self.orderAuthorsByAlphabet = YES;
    [self.authorsViewController turnOnAuthorsAlphabetMode];
    [self segmentControlTapped];
}

- (void)turnOffAuthorsAlphabetMode
{
    self.orderAuthorsByAlphabet = NO;
    [self.authorsViewController turnOffAuthorsAlphabetMode];
    [self segmentControlTapped];
}

#pragma mark - SomeDelegate

#pragma mark - Internal Helpers

#pragma mark - Getters & Setters

- (UIBarButtonItem *)refreshWorksButton
{
    if (!_refreshWorksButton) {
        UIImage *refreshIcon = [IonIcons imageWithIcon:ion_ios_loop_strong size:24 color:[UIColor colorWithRGBA:0x8D8D8DFF]];
        _refreshWorksButton = [[UIBarButtonItem alloc] initWithImage:refreshIcon style:UIBarButtonItemStylePlain target:self action:@selector(reorderWorks)];
    }
    
    return _refreshWorksButton;
}

- (UIBarButtonItem *)turnOnAuthorsAlphabetModeButton
{
    if (!_turnOnAuthorsAlphabetModeButton) {
        UIImage *alphabetIcon = [UIImage imageWithIcon:@"fa-sort-alpha-asc" backgroundColor:[UIColor clearColor] iconColor:[UIColor colorWithRGBA:0x8D8D8DFF] fontSize:20];
        alphabetIcon = [alphabetIcon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _turnOnAuthorsAlphabetModeButton = [[UIBarButtonItem alloc] initWithImage:alphabetIcon style:UIBarButtonItemStylePlain target:self action:@selector(turnOnAuthorsAlphabetMode)];
    }
    
    return _turnOnAuthorsAlphabetModeButton;
}

- (UIBarButtonItem *)turnOffAuthorsAlphabetModeButton
{
    if (!_turnOffAuthorsAlphabetModeButton) {
        UIImage *alphabetIcon = [UIImage imageWithIcon:@"fa-sort-alpha-asc" backgroundColor:[UIColor clearColor] iconColor:self.view.tintColor fontSize:20];
        alphabetIcon = [alphabetIcon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _turnOffAuthorsAlphabetModeButton = [[UIBarButtonItem alloc] initWithImage:alphabetIcon style:UIBarButtonItemStylePlain target:self action:@selector(turnOffAuthorsAlphabetMode)];
    }
    
    return _turnOffAuthorsAlphabetModeButton;
}

@end
