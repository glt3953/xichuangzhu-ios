//
//  XCZQuoteTableViewCell.m
//  xcz
//
//  Created by hustlzp on 15/10/20.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuoteTableViewCell.h"
#import "UIColor+Helper.h"
#import "XCZUtils.h"
#import <Masonry.h>

@interface XCZQuoteTableViewCell ()

@property (strong, nonatomic) XCZQuote *quote;
@property (strong, nonatomic) UILabel *quoteLabel;
@property (strong, nonatomic) UILabel *workLabel;

@end

@implementation XCZQuoteTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    UILabel *quoteLabel = [UILabel new];
    self.quoteLabel = quoteLabel;
    [self.contentView addSubview:quoteLabel];
    
    UILabel *workLabel = [UILabel new];
    workLabel.font = [UIFont systemFontOfSize:12];
    workLabel.textColor = [UIColor colorWithRGBA:0x999999FF];
    self.workLabel = workLabel;
    [self.contentView addSubview:workLabel];
    
    // 约束
    
    [quoteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset([XCZUtils getCellHorizonalGap]);
        make.top.equalTo(self.contentView).offset(11);
        make.right.equalTo(self.contentView).offset(-[XCZUtils getCellHorizonalGap]);
    }];
    
    [workLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(quoteLabel).offset(-5);
        make.top.equalTo(quoteLabel.mas_bottom).offset(5);
        make.right.equalTo(quoteLabel);
        make.bottom.equalTo(self.contentView).offset(-11);
    }];
    
    return self;
}

- (void)updateWithQuote:(XCZQuote *)quote
{
    self.quoteLabel.text = quote.quote;
    self.workLabel.text = [NSString stringWithFormat:@"《%@》", quote.work];
}

@end
