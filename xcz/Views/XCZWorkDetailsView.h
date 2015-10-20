//
//  WorkDetailsView.h
//  xcz
//
//  Created by hustlzp on 15/10/7.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import <UIKit/UIKit.h>

@interface XCZWorkDetailsView : UIView

- (instancetype)initWithWork:(XCZWork *)work;
- (void)enterFullScreenMode;
- (void)exitFullScreenMode;

@end
