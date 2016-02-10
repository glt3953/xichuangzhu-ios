//
//  XCZWorkSearchResultTableViewCell.m
//  xcz
//
//  Created by hustlzp on 16/2/10.
//  Copyright © 2016年 Zhipeng Liu. All rights reserved.
//

#import "UIColor+Helper.h"
#import "Constants.h"
#import "XCZWorkSearchResultTableViewCell.h"
#import "XCZUtils.h"
#import "XCZWorkSearchResultTableViewCell.h"
#import <Masonry.h>

@interface XCZWorkSearchResultTableViewCell ()

@property (strong, nonatomic) XCZWorkSearchResult *work;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *authorLabel;
@property (strong, nonatomic) UILabel *contentLabel;

@end

@implementation XCZWorkSearchResultTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    // title
    UILabel *titleLabel = [UILabel new];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    // author
    UILabel *authorLabel = [UILabel new];
    authorLabel.font = [UIFont systemFontOfSize:14];
    authorLabel.textColor = [UIColor colorWithRGBA:0x999999FF];
    [self.contentView addSubview:authorLabel];
    self.authorLabel = authorLabel;
    
    // first sentence
    UILabel *contentLabel = [UILabel new];
    [self.contentView addSubview:contentLabel];
    contentLabel.font = [UIFont systemFontOfSize:12];
    contentLabel.textColor = [UIColor colorWithRGBA:0x999999FF];
    self.contentLabel = contentLabel;
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset([XCZUtils getCellHorizonalGap]);
        make.top.equalTo(self.contentView).offset(11);
    }];
    
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel);
        make.left.greaterThanOrEqualTo(titleLabel.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-[XCZUtils getCellHorizonalGap]);
    }];
    
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(6);
        make.left.equalTo(titleLabel);
        make.right.equalTo(authorLabel);
        make.bottom.equalTo(self.contentView).offset(-11);
    }];
    
    return self;
}

- (void)updateWithWorkSearchResult:(XCZWorkSearchResult *)workSearchResult
{
    self.titleLabel.text = workSearchResult.title;
    self.authorLabel.text = [NSString stringWithFormat:@"[%@] %@", workSearchResult.dynasty, workSearchResult.author];
    self.contentLabel.text = workSearchResult.content;
}

@end
