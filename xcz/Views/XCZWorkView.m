//
//  WorkDetailsView.m
//  xcz
//
//  Created by hustlzp on 15/10/7.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZCollection.h"
#import "XCZTagListView.h"
#import "XCZQuoteView.h"
#import "XCZCopyableLabel.h"
#import "XCZWorkView.h"
#import "XCZCollectionWorksViewController.h"
#import "UIColor+Helper.h"
#import "LocalizeHelper.h"
#import "XCZUtils.h"
#import <Masonry/Masonry.h>

@interface XCZWorkView ()

@property (strong, nonatomic) XCZWork *work;
@property (strong, nonatomic) HTCopyableLabel *titleLabel;
@property (strong, nonatomic) UILabel *authorLabel;
@property (strong, nonatomic) XCZCopyableLabel *contentLabel;
@property (strong, nonatomic) UILabel *introHeaderLabel;
@property (strong, nonatomic) XCZCopyableLabel *introLabel;
@property (strong, nonatomic) UILabel *collectionsHeaderLabel;
@property (strong, nonatomic) UILabel *quotesHeaderLabel;

@end

@implementation XCZWorkView

- (instancetype)initWithWork:(XCZWork *)work
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.work = work;
    
    NSInteger quotesCount = [XCZQuote getByWorkId:self.work.id].count;
    
    // 标题
    HTCopyableLabel *titleLabel = [HTCopyableLabel new];
    self.titleLabel = titleLabel;
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.font = [UIFont systemFontOfSize:25];
    NSMutableParagraphStyle *titleParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    titleParagraphStyle.lineHeightMultiple = 1.2;
    titleParagraphStyle.alignment = NSTextAlignmentCenter;
    titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.work.title attributes:@{NSParagraphStyleAttributeName: titleParagraphStyle}];
    [self addSubview:titleLabel];
    
    // 作者
    UILabel *authorLabel = [UILabel new];
    self.authorLabel = authorLabel;
    authorLabel.textAlignment = NSTextAlignmentCenter;
    authorLabel.text = [NSString stringWithFormat:@"[%@] %@", self.work.dynasty, self.work.author];
    [self addSubview:authorLabel];
    
    // 内容
    XCZCopyableLabel *contentLabel = [XCZCopyableLabel new];
    self.contentLabel = contentLabel;
    contentLabel.numberOfLines = 0;
    contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    if ([self.work.layout isEqual: @"indent"]) {
        // 缩进排版
        contentParagraphStyle.firstLineHeadIndent = 25;
        contentParagraphStyle.paragraphSpacing = 10;
        contentParagraphStyle.lineHeightMultiple = 1.35;
    } else {
        // 居中排版
        contentParagraphStyle.alignment = NSTextAlignmentCenter;
        contentParagraphStyle.paragraphSpacing = 10;
        contentParagraphStyle.lineHeightMultiple = 1;
    }
    contentLabel.attributedText = [[NSAttributedString alloc] initWithString:self.work.content attributes:@{NSParagraphStyleAttributeName: contentParagraphStyle}];
    [self addSubview:contentLabel];
    
    // 评析header
    UILabel *introHeaderLabel = [UILabel new];
    self.introHeaderLabel = introHeaderLabel;
//    if ([self.work.intro length] > 0) {
        introHeaderLabel.text = LocalizedString(@"评析");
        introHeaderLabel.textColor = [UIColor XCZMainColor];
        [self addSubview:introHeaderLabel];
//    }
    
    // 评析
    XCZCopyableLabel *introLabel = [XCZCopyableLabel new];
    self.introLabel = introLabel;
//    if ([self.work.intro length] > 0) {
        introLabel.numberOfLines = 0;
        introLabel.lineBreakMode = NSLineBreakByWordWrapping;
        introLabel.font = [UIFont systemFontOfSize:14];
        introLabel.textColor = [UIColor colorWithRGBA:0x333333FF];
        NSMutableParagraphStyle *introParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        introParagraphStyle.lineHeightMultiple = 1.3;
        introParagraphStyle.paragraphSpacing = 8;
        introLabel.attributedText = [[NSAttributedString alloc] initWithString:self.work.intro attributes:@{NSParagraphStyleAttributeName: introParagraphStyle}];
        [self addSubview:introLabel];
//    }
    
    UILabel *collectionsHeaderLabel = [UILabel new];
    self.collectionsHeaderLabel = collectionsHeaderLabel;
//    if (self.work.collections.count > 0) {
        collectionsHeaderLabel.text = @"分类";
        collectionsHeaderLabel.textColor = [UIColor XCZMainColor];
        [self addSubview:collectionsHeaderLabel];
//    }
    
    XCZTagListView *collectionsView = [XCZTagListView new];
    collectionsView.cornerRadius = 1.5;
    collectionsView.borderColor = [UIColor colorWithRGBA:0xD8D8D8FF];
    collectionsView.tagBackgroundColor = [UIColor colorWithRGBA:0xEEEEEEFF];
    collectionsView.tagSelectedBackgroundColor = [UIColor colorWithRGBA:0xDDDDDDFF];
    collectionsView.textColor = [UIColor colorWithRGBA:0x444444FF];
    collectionsView.paddingX = 8;
    collectionsView.paddingY = 5;
    collectionsView.marginX = 7;
    collectionsView.marginY = 7;
//    if (self.work.collections.count > 0) {
        for (XCZCollection *collection in self.work.collections) {
            [collectionsView addTag:collection.name].onTap = ^void(void) {
                UIViewController *controller = [[XCZCollectionWorksViewController alloc] initWithCollection:collection];
                if (self.delegate) {
                    [self.delegate.navigationController pushViewController:controller animated:YES];
                }
            };
        }
        [self addSubview:collectionsView];
//    }
    
    // 摘录header
    UILabel *quotesHeaderLabel = [UILabel new];
    self.quotesHeaderLabel = quotesHeaderLabel;
//    if (quotesCount > 0) {
        quotesHeaderLabel.text = @"摘录";
        quotesHeaderLabel.textColor = [UIColor XCZMainColor];
        [self addSubview:quotesHeaderLabel];
//    }
    
    // 约束
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(40);
        make.left.equalTo(self).offset(30);
        make.right.equalTo(self).offset(-30);
    }];
    
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(15);
        make.left.equalTo(self).offset([XCZUtils getCellHorizonalGap]);
        make.right.equalTo(self).offset(-[XCZUtils getCellHorizonalGap]);
    }];
    
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([self.work.layout isEqual: @"indent"]) {
            make.top.equalTo(authorLabel.mas_bottom).offset(10);
        } else {
            make.top.equalTo(authorLabel.mas_bottom).offset(16);
        }
        
        make.left.right.equalTo(authorLabel);
    }];
    
//    if ([self.work.intro length] > 0) {
        [introHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(authorLabel);
            make.top.equalTo(contentLabel.mas_bottom).offset(20).priorityHigh();
        }];
        
        [introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(introHeaderLabel.mas_bottom).offset(5);
            make.left.right.equalTo(authorLabel);
        }];
//    }
    
    [collectionsHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(authorLabel);
        make.top.equalTo(introLabel.mas_bottom).offset(15);
    }];
    
    [collectionsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(authorLabel);
        make.top.equalTo(collectionsHeaderLabel.mas_bottom).offset(10);
    }];
    
//    if (quotesCount > 0) {
        [quotesHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(authorLabel);
            make.top.equalTo(collectionsView.mas_bottom).offset(15);
            make.bottom.equalTo(self);
        }];
//    }
    
//    if ([self.work.intro length] > 0) {
//        if (quotesCount > 0) {
//            [quotesHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(introLabel.mas_bottom).offset(15);
//            }];
//        } else {
//            [introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.bottom.equalTo(self).offset(-15);
//            }];
//        }
//    } else {
//        if (quotesCount > 0) {
//            [quotesHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(contentLabel.mas_bottom).offset(20);
//            }];
//        } else {
//            [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.bottom.equalTo(self).offset(-15);
//            }];
//        }
//    }
    
    return self;
}

#pragma mark - public methods

- (void)enterFullScreenMode
{
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(60);
    }];
}

- (void)exitFullScreenMode
{
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(40);
    }];
}

@end
