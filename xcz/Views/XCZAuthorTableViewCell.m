//
//  XCZAuthorTableViewCell.m
//  xcz
//
//  Created by hustlzp on 15/10/19.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZAuthorTableViewCell.h"
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
    quoteLabel.textColor = [UIColor grayColor];
    self.quoteLabel = quoteLabel;
    
    // 约束
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentView).offset(10);
        make.right.equalTo(self.contentView);
    }];
    
    [quoteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(authorLabel);
        make.top.equalTo(authorLabel.mas_bottom).offset(5);
        make.right.equalTo(authorLabel);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
    
    return self;
}

- (void)updateWithAuthor:(XCZAuthor *)author
{
    self.authorLabel.text = author.name;
    if (author.randomQuote) {
        self.quoteLabel.text = author.randomQuote.quote;
        [self.quoteLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-10);
        }];
    } else {
        self.quoteLabel.text = @"";
        [self.quoteLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-5);
        }];
    }
}

@end
