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
    self.titleLabel.attributedText =[self generateAttributedString:workSearchResult.title];
    self.authorLabel.text = [NSString stringWithFormat:@"[%@] %@", workSearchResult.dynasty, workSearchResult.author];
    self.contentLabel.attributedText = [self generateAttributedString:workSearchResult.content];
}

#pragma mark - Private Helpers

- (NSAttributedString *)generateAttributedString:(NSString *)searchText
{
    NSMutableAttributedString *resultAttributedString = [NSMutableAttributedString new];
    
    __block NSUInteger prevLocation = 0;
    NSString *pattern = @"\\[[^\\[\\]]+\\]";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSRange range = NSMakeRange(0, [searchText length]);
    NSArray *matchResults = [expression matchesInString:searchText options:0 range:range];
    
    if (matchResults.count > 0) {
        for (NSTextCheckingResult *matchResult in matchResults) {
            NSRange range = [matchResult rangeAtIndex:0];
            
            if (range.location > prevLocation) {
                NSRange plainTextRange = NSMakeRange(prevLocation, range.location - prevLocation);
                NSAttributedString *plainText = [[NSAttributedString alloc] initWithString:[searchText substringWithRange:plainTextRange]];
                [resultAttributedString appendAttributedString:plainText];
            }
            
            NSRange highlightTextRange = NSMakeRange(range.location + 1, range.length - 2);
            NSAttributedString *highlightText = [[NSAttributedString alloc] initWithString:[searchText substringWithRange:highlightTextRange] attributes:@{NSBackgroundColorAttributeName: [UIColor yellowColor]}];
            [resultAttributedString appendAttributedString:highlightText];
            
            prevLocation = range.location + range.length;
        }
        
        if ([searchText length] > prevLocation) {
            NSRange plainTextRange = NSMakeRange(prevLocation, [searchText length] - prevLocation);
            NSAttributedString *plainText = [[NSAttributedString alloc] initWithString:[searchText substringWithRange:plainTextRange]];
            [resultAttributedString appendAttributedString:plainText];
        }
    } else {
        resultAttributedString = [[NSMutableAttributedString alloc] initWithString:searchText];
    }
    
    return resultAttributedString;
}

@end
