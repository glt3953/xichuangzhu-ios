//
//  XCZWorkDetailViewController.h
//  xcz
//
//  Created by 刘志鹏 on 14-6-30.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import "XCZQuote.h"
#import "XCZBaseViewController.h"
#import <UIKit/UIKit.h>

@interface XCZWorkViewController : XCZBaseViewController

- (instancetype)initWithWorkId:(int)workId;
- (instancetype)initWithWork:(XCZWork *)work;
- (instancetype)initWithWork:(XCZWork *)work quote:(XCZQuote *)quote;
- (void)updateWithWork:(XCZWork *)work;

@end
