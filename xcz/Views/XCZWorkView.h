//
//  WorkDetailsView.h
//  xcz
//
//  Created by hustlzp on 15/10/7.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuote.h"
#import "XCZWork.h"
#import <UIKit/UIKit.h>

@interface XCZWorkView : UIView

@property (weak, nonatomic) UIViewController *delegate;

- (instancetype)initWithWork:(XCZWork *)work;
- (void)enterFullScreenMode;
- (void)exitFullScreenMode;
- (void)highlightQuote:(XCZQuote *)quote;

@end
