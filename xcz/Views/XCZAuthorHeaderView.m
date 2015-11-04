//
//  XCZAuthorHeaderView.m
//  xcz
//
//  Created by hustlzp on 15/10/21.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZAuthorHeaderView.h"
#import "XCZCopyableLabel.h"
#import "Constants.h"
#import "UIColor+Helper.h"
#import "XCZUtils.h"
#import <Masonry.h>

@interface XCZAuthorHeaderView ()

@end

@implementation XCZAuthorHeaderView

- (instancetype)initWithAuthor:(XCZAuthor *)author
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // name
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = author.name;
    nameLabel.font = [UIFont systemFontOfSize:25];
    [self addSubview:nameLabel];
    
    // period
    UILabel *periodLabel = [UILabel new];
    if (![author.deathYear isEqualToString:@""]) {
        periodLabel.text = [[NSString alloc] initWithFormat:@"[%@]  %@ ~ %@", author.dynasty, author.birthYear, author.deathYear];
    } else {
        periodLabel.text = [[NSString alloc] initWithFormat:@"[%@]", author.dynasty];
    }
    [self addSubview:periodLabel];
    
    // intro header
    UILabel *introHeaderLabel = [UILabel new];
    introHeaderLabel.textColor = [UIColor XCZMainColor];
    introHeaderLabel.text = @"简介";
    [self addSubview:introHeaderLabel];
    
    // intro
    XCZCopyableLabel *introLabel = [XCZCopyableLabel new];
    introLabel.numberOfLines = 0;
    introLabel.lineBreakMode = NSLineBreakByWordWrapping;
    introLabel.font = [UIFont systemFontOfSize:15];
    
    NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    contentParagraphStyle.lineHeightMultiple = 1.3;
    introLabel.attributedText = [[NSAttributedString alloc] initWithString:author.intro attributes:@{NSParagraphStyleAttributeName: contentParagraphStyle}];
    [self addSubview:introLabel];
    
    // works header
    UILabel *worksHeaderLabel = [UILabel new];
    worksHeaderLabel.textColor = [UIColor XCZMainColor];
    worksHeaderLabel.text = [[NSString alloc] initWithFormat:@"作品 / %d", [XCZAuthor getWorksCount:author.id]];
    [self addSubview:worksHeaderLabel];
    
    // 约束
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset([XCZUtils getVerticalGap]);
        make.right.equalTo(self).offset(-[XCZUtils getVerticalGap]);
        make.top.equalTo(self).offset(25);
    }];
    
    [periodLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(nameLabel);
        make.top.equalTo(nameLabel.mas_bottom).offset(10);
    }];
    
    [introHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(nameLabel);
        make.top.equalTo(periodLabel.mas_bottom).offset(15);
    }];
    
    [introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(nameLabel);
        make.top.equalTo(introHeaderLabel.mas_bottom).offset(5);
    }];
    
    [worksHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(introLabel.mas_bottom).offset(15).priorityHigh();
        make.left.right.equalTo(nameLabel);
        make.bottom.equalTo(self).offset(-15);
    }];
    
    return self;
}



@end
