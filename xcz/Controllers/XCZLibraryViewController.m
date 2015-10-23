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
#import <Masonry/Masonry.h>
#import <ionicons/IonIcons.h>

@interface XCZLibraryViewController ()

@property (strong, nonatomic) UISegmentedControl *segmentControl;
@property (strong, nonatomic) XCZWorksViewController *worksViewController;
@property (strong, nonatomic) XCZAuthorsViewController *authorsViewController;
@property (strong, nonatomic) UIBarButtonItem *rightButton;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (nonatomic) BOOL hasSetupViews;

@property (strong, nonatomic) NSArray *works;

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
    self.worksViewController.view;
    
    self.authorsViewController = [XCZAuthorsViewController new];
    [self addChildViewController:self.authorsViewController];
    
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
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"作品", @"文学家"]];
    self.segmentControl = segmentControl;
    self.segmentControl.selectedSegmentIndex = 0;
    [self.segmentControl addTarget:self action:@selector(segmentControlTapped) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = segmentControl;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.hasSetupViews) {
        self.hasSetupViews = YES;
        
        [self createViews];
        [self segmentControlTapped];
        [self.activityView stopAnimating];
    }
}

#pragma mark - Layout

- (void)createViews
{
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

#pragma mark - User Interface

- (void)segmentControlTapped
{
    if (self.segmentControl.selectedSegmentIndex == 0) {
        self.authorsViewController.view.hidden = YES;
        self.worksViewController.view.hidden = NO;
        self.navigationItem.rightBarButtonItem = self.rightButton;
        self.navigationItem.title = self.worksViewController.navigationItem.title;
    } else {
        self.authorsViewController.view.hidden = NO;
        self.worksViewController.view.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.title = self.authorsViewController.navigationItem.title;
    }
}

- (void)reorderWorks
{
    [self.worksViewController reorderWorks];
}

#pragma mark - SomeDelegate

#pragma mark - Internal Helpers

#pragma mark - Getters & Setters

- (UIBarButtonItem *)rightButton
{
    if (!_rightButton) {
        UIImage *refreshIcon = [IonIcons imageWithIcon:ion_ios_loop_strong size:24 color:[UIColor grayColor]];
        _rightButton = [[UIBarButtonItem alloc] initWithImage:refreshIcon style:UIBarButtonItemStylePlain target:self action:@selector(reorderWorks)];
    }
    
    return _rightButton;
}

@end
