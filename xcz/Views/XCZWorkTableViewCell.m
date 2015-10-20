//
//  XCZWorkTableViewCell.m
//  xcz
//
//  Created by hustlzp on 15/10/19.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "UIColor+Helper.h"
#import "Constants.h"
#import "XCZWorkTableViewCell.h"
#import <Masonry.h>

@interface XCZWorkTableViewCell ()

@property (strong, nonatomic) XCZWork *work;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *authorLabel;
@property (strong, nonatomic) UILabel *firstSentenceLabel;

@end

@implementation XCZWorkTableViewCell

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
    UILabel *firstSentenceLabel = [UILabel new];
    [self.contentView addSubview:firstSentenceLabel];
    firstSentenceLabel.font = [UIFont systemFontOfSize:12];
    firstSentenceLabel.textColor = [UIColor colorWithRGBA:0x999999FF];
    self.firstSentenceLabel = firstSentenceLabel;
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentView).offset(11);
    }];
    
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel);
        make.left.greaterThanOrEqualTo(titleLabel.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    [firstSentenceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(6);
        make.left.equalTo(titleLabel);
        make.right.equalTo(self.contentView).offset(-15);
        make.bottom.equalTo(self.contentView).offset(-11);
    }];
    
    return self;
}

- (void)updateWithWork:(XCZWork *)work showAuthor:(BOOL)showAuthor
{
    self.titleLabel.text = work.title;
    self.authorLabel.text = [NSString stringWithFormat:@"[%@] %@", work.dynasty, work.author];
    self.firstSentenceLabel.text = work.firstSentence;
    
    if (showAuthor) {
        self.authorLabel.hidden = NO;
    } else {
        self.authorLabel.hidden = YES;
    }
}

@end
