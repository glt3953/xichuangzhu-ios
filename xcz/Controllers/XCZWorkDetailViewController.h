//
//  XCZWorkDetailViewController.h
//  xcz
//
//  Created by 刘志鹏 on 14-6-30.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import <UIKit/UIKit.h>

@interface XCZWorkDetailViewController : UIViewController

- (instancetype)initWithWorkId:(int)workId;
- (instancetype)initWithWork:(XCZWork *)work;
- (void)updateWithWork:(XCZWork *)work;

@end
