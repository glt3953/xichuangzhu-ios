//
//  XCZAuthorTableViewCell.m
//  xcz
//
//  Created by hustlzp on 15/10/19.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZAuthorTableViewCell.h"
#import "UIColor+Helper.h"
#import "XCZUtil.h"
#import <Masonry.h>

@interface XCZAuthorTableViewCell ()

@property (strong, nonatomic) XCZAuthor *author;
@property (strong, nonatomic) UILabel *authorLabel;
@property (strong, nonatomic) UILabel *quoteLabel;

@end

@implementation XCZAuthorTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    // author
    UILabel *authorLabel = [UILabel new];
    [self.contentView addSubview:authorLabel];
    self.authorLabel = authorLabel;
    
    // quote
    UILabel *quoteLabel = [UILabel new];
    [self.contentView addSubview:quoteLabel];
    quoteLabel.font = [UIFont systemFontOfSize:12];
    quoteLabel.textColor = [UIColor colorWithRGBA:0x999999FF];
    self.quoteLabel = quoteLabel;
    
    // 约束
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset([XCZUtil getVerticalGap]);
        make.top.equalTo(self.contentView).offset(11);
        make.right.equalTo(self.contentView).offset(-[XCZUtil getVerticalGap]);
    }];
    
    [quoteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(authorLabel);
        make.top.equalTo(authorLabel.mas_bottom).offset(6);
        make.bottom.equalTo(self.contentView).offset(-11);
    }];
    
    return self;
}

- (void)updateWithAuthor:(XCZAuthor *)author
{
    self.authorLabel.text = author.name;
    if (author.randomQuote) {
        self.quoteLabel.text = author.randomQuote.quote;
        [self.quoteLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-11);
        }];
    } else {
        self.quoteLabel.text = @"";
        [self.quoteLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-6);
        }];
    }
}

@end
