//
//  XCZCollectionSectionHeaderView.m
//  xcz
//
//  Created by hustlzp on 15/11/15.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZCollectionSectionHeaderView.h"
#import "UIColor+Helper.h"
#import "XCZUtils.h"
#import <Masonry.h>

@interface XCZCollectionSectionHeaderView ()

@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation XCZCollectionSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.backgroundColor = [UIColor colorWithRGBA:0xF7F7F7FF];
    
    UILabel *titleLable = [UILabel new];
    self.titleLabel = titleLable;
    titleLable.font = [UIFont systemFontOfSize:16];
    titleLable.textColor = [UIColor XCZMainColor];
    [self addSubview:titleLable];
    
    [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset([XCZUtils getCellHorizonalGap]);
    }];
    
    return self;
}

- (void)updateWithTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

@end
