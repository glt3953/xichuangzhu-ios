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
#import "NSArray+Helper.h"
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
    
    UIView *introWapView;
    if ([self.work.intro length] > 0) {
        introWapView = [self createIntroWapView];
        [self addSubview:introWapView];
    }
    
    UIView *collectionWapView;
    if (self.work.collections.count > 0) {
        collectionWapView = [self createCollectionWapView];
        [self addSubview:collectionWapView];
    }
    
    UILabel *quotesHeaderLabel;
    if (quotesCount > 0) {
        quotesHeaderLabel = [UILabel new];
        quotesHeaderLabel.text = LocalizedString(@"摘录");
        quotesHeaderLabel.textColor = [UIColor XCZMainColor];
        [self addSubview:quotesHeaderLabel];
    }
    
    // 约束
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(40);
        
        if ([work.title rangeOfString:@" · "].location == NSNotFound) {
            if (work.title.length == 11) {
                make.left.equalTo(self).offset(15);
                make.right.equalTo(self).offset(-15);
            } else {
                make.left.equalTo(self).offset(30);
                make.right.equalTo(self).offset(-30);
            }
        } else {
            if (work.title.length == 13) {
                make.left.equalTo(self).offset(20);
                make.right.equalTo(self).offset(-20);
            } else {
                make.left.equalTo(self).offset(30);
                make.right.equalTo(self).offset(-30);
            }
        }
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
    
    UIView *prevView;
    BOOL hasMakeConstraintToContentLabel = NO;
    NSArray *viewArray = @[introWapView ? introWapView : [NSNull null],
                           collectionWapView ? collectionWapView : [NSNull null],
                           quotesHeaderLabel ? quotesHeaderLabel : [NSNull null]];
    NSArray *reverseViewArray = [viewArray reversedArray];
    
    for (UIView *view in viewArray) {
        if (![view isEqual:[NSNull null]]) {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(authorLabel);
            }];
            
            if (!hasMakeConstraintToContentLabel) {
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(contentLabel.mas_bottom).offset(20);
                }];
                
                hasMakeConstraintToContentLabel = YES;
            } else {
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(prevView.mas_bottom).offset(15);
                }];
            }
            
            prevView = view;
        }
    }
    
    for (UIView *view in reverseViewArray) {
        if (![view isEqual:[NSNull null]]) {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                if (quotesCount > 0) {
                    make.bottom.equalTo(self);
                } else {
                    make.bottom.equalTo(self).offset(-20);
                }
            }];
            
            break;
        }
    }
    
    return self;
}

#pragma mark - Public methods

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

- (void)highlightQuote:(XCZQuote *)quote
{
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithAttributedString:self.contentLabel.attributedText];
    NSString *pattern;
    NSString *phraseSeperators = @"，。：；？！、";
    NSString *sentenceSeperators = @"。；？！";
    
    if (quote.pieces.count == 1) {
        pattern = [NSString stringWithFormat:@"%@[%@]{1}", [quote.pieces firstObject], phraseSeperators];
    } else {
        pattern = [NSString stringWithFormat:@"%@[%@\n]{1,2}?%@[%@]{0,1}", [quote.pieces firstObject], phraseSeperators, [quote.pieces lastObject], sentenceSeperators];
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionDotMatchesLineSeparators error:NULL];
    NSArray *matches = [regex matchesInString:self.work.content options:0 range:NSMakeRange(0, self.work.content.length)] ;
    NSTextCheckingResult *match = [matches firstObject];
    
    if (match != nil) {
        [contentString addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:self.contentLabel.font.pointSize]} range:match.range];
        self.contentLabel.attributedText = contentString;
    }
}

#pragma mark - View helpers

- (UIView *)createIntroWapView
{
    UIView *wapView = [UIView new];
    
    // 评析header
    UILabel *introHeaderLabel = [UILabel new];
    introHeaderLabel.text = LocalizedString(@"评析");
    introHeaderLabel.textColor = [UIColor XCZMainColor];
    [wapView addSubview:introHeaderLabel];
    
    // 评析
    XCZCopyableLabel *introLabel = [XCZCopyableLabel new];
    introLabel.numberOfLines = 0;
    introLabel.lineBreakMode = NSLineBreakByWordWrapping;
    introLabel.font = [UIFont systemFontOfSize:14];
    introLabel.textColor = [UIColor colorWithRGBA:0x333333FF];
    NSMutableParagraphStyle *introParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    introParagraphStyle.lineHeightMultiple = 1.3;
    introParagraphStyle.paragraphSpacing = 8;
    introLabel.attributedText = [[NSAttributedString alloc] initWithString:self.work.intro attributes:@{NSParagraphStyleAttributeName: introParagraphStyle}];
    [wapView addSubview:introLabel];

    [introHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(wapView);
    }];
    
    [introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(introHeaderLabel.mas_bottom).offset(5);
        make.left.right.bottom.equalTo(wapView);
    }];
    
    return wapView;
}

- (UIView *)createCollectionWapView
{
    UIView *wapView = [UIView new];
    
    UILabel *collectionsHeaderLabel = [UILabel new];
    self.collectionsHeaderLabel = collectionsHeaderLabel;
    collectionsHeaderLabel.text = LocalizedString(@"分类");
    collectionsHeaderLabel.textColor = [UIColor XCZMainColor];
    [wapView addSubview:collectionsHeaderLabel];
    
    XCZTagListView *collectionsView = [XCZTagListView new];
    collectionsView.cornerRadius = 0;
    collectionsView.borderWidth = 0;
    collectionsView.borderColor = [UIColor colorWithRGBA:0xD8D8D8FF];
    collectionsView.tagBackgroundColor = [UIColor colorWithRGBA:0xEAEAEAFF];
    collectionsView.tagSelectedBackgroundColor = [UIColor colorWithRGBA:0xD8D8D8FF];
    collectionsView.textColor = [UIColor colorWithRGBA:0x333333FF];
    collectionsView.paddingX = 8;
    collectionsView.paddingY = 5;
    collectionsView.marginX = 7;
    collectionsView.marginY = 7;
    for (XCZCollection *collection in self.work.collections) {
        [collectionsView addTag:collection.name].onTap = ^void(void) {
            UIViewController *controller = [[XCZCollectionWorksViewController alloc] initWithCollection:collection];
            if (self.delegate) {
                [self.delegate.navigationController pushViewController:controller animated:YES];
            }
        };
    }
    [wapView addSubview:collectionsView];

    [collectionsHeaderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(wapView);
    }];
    
    [collectionsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(wapView);
        make.top.equalTo(collectionsHeaderLabel.mas_bottom).offset(10);
    }];
    
    return wapView;
}

@end
