//
//  XCZUtil.m
//  xcz
//
//  Created by hustlzp on 15/10/21.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "Constants.h"
#import "XCZUtil.h"

@implementation XCZUtil

+ (CGFloat)getVerticalGap
{
    if (IS_IPHONE_6P) {
        return 20;
    } else {
        return 15;
    }
}

@end
