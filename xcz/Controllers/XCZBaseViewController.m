//
//  XCZBaseViewController.m
//  xcz
//
//  Created by hustlzp on 15/12/12.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "Constants.h"
#import "XCZBaseViewController.h"

@interface XCZBaseViewController ()

@end

@implementation XCZBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chineseKindChanged) name:XCZChineseKindChangedNotification object:nil];
}

- (void)createViews
{
    // Should be overrided by subclass.
}

- (void)updateBarTitles
{
    // Should be overrided by subclass.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)chineseKindChanged
{
    [self updateBarTitles];
    
    for (UIView *subView in self.view.subviews) {
        [subView removeFromSuperview];
    }
    
    [self createViews];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

@end
