//
//  XCZQuoteView.m
//  xcz
//
//  Created by hustlzp on 15/10/20.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuoteView.h"
#import "Constants.h"
#import "UIColor+Helper.h"
#import <Masonry.h>
#import <QuartzCore/QuartzCore.h>

@interface XCZQuoteView ()

@property (strong, nonatomic) UIImageView *logoView;
@property (strong, nonatomic) UILabel *authorLabel;
@property (strong, nonatomic) NSMutableArray *quoteLabels;

@end

@implementation XCZQuoteView

- (instancetype)initWithQuote:(XCZQuote *)quote
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.quote = quote;
    
    self.backgroundColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quoteViewPressed)];
    [self addGestureRecognizer:tapGesture];
    
    UIImageView *logoView = [UIImageView new];
    logoView.image = [UIImage imageNamed:@"AppIcon40x40"];
    logoView.layer.cornerRadius = 3;
    logoView.layer.masksToBounds = YES;
    self.logoView = logoView;
    [self addSubview:logoView];
    
    UILabel *authorLabel = [self createVerticalLabel:self.quote.author];
    self.authorLabel = authorLabel;
    authorLabel.font = [UIFont fontWithName:XCZFontFangsong size:[self authorFontSize]];
    [self addSubview:authorLabel];
    
    [self createQuoteLabels];
    
    UILabel *prevLabel;
    
    for (int i = 0; i < self.quoteLabels.count; i++) {
        UILabel *label = self.quoteLabels[i];
        
        [self addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset([self quoteTopMargin]);
        }];
        
        if (i == 0) {
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-[self quoteRightMargin]);
            }];
        } else {
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(prevLabel.mas_left).offset(-[self quoteHorizonalGap]);
            }];
        }
        
        prevLabel = label;
    }
    
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo([NSNumber numberWithFloat:[self logoWidth]]);
        make.left.equalTo(self).offset([self logoHorizonalGap]);
        make.bottom.equalTo(self).offset(-[self logoVerticalGap]);
    }];
    
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(logoView.mas_top).offset(-10);
        make.centerX.equalTo(logoView);
    }];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor colorWithRGBA:0x666666FF].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.layer.shadowOpacity = .25;
    self.layer.shadowPath = shadowPath.CGPath;
    self.layer.shadowRadius = 2;
    
    [self.authorLabel sizeToFit];
}

#pragma mark - User Interaction

- (void)quoteViewPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(quoteViewPressed:)]) {
        [self.delegate quoteViewPressed:self.quote];
    }
}

#pragma mark - Public Helpers

- (void)adjustSize
{
    if (!self.superview) {
        return;
    }
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        if (IS_IPHONE_4_OR_LESS) {
            make.height.equalTo(self.superview).multipliedBy(.85);
            make.width.equalTo(self.mas_height).multipliedBy(.75);
        } else {
            make.height.equalTo(self.superview).multipliedBy(.8);
            make.width.equalTo(self.superview).multipliedBy(.8);
        }
    }];
}

#pragma mark - Internal Helpers

- (void)createQuoteLabels
{
    [self.quoteLabels removeAllObjects];
    
    __block NSInteger prevLocation = 0;
    
    NSString *pattern = @"[，。：；？！、]";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    
    NSRange range = NSMakeRange(0,[self.quote.quote length]);
    [expression enumerateMatchesInString:self.quote.quote options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange range = [result rangeAtIndex:0];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2;
        
        NSString *quoteText = [self.quote.quote substringWithRange:NSMakeRange(prevLocation, range.location - prevLocation)];
        UILabel *quoteLabel = [self createVerticalLabel:quoteText attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
        
        quoteLabel.font = [UIFont fontWithName:XCZFontFangsong size:[self quoteFontSize]];

        [self.quoteLabels addObject:quoteLabel];
        
        prevLocation = range.location + 1;
    }];
}

- (UILabel *)createVerticalLabel:(NSString *)text
{
    UILabel *label = [UILabel new];
    label.numberOfLines = text.length;
    label.text = [self createVerticalString:text];
    return label;
}

- (UILabel *)createVerticalLabel:(NSString *)text attributes:(NSDictionary *)attributes
{
    UILabel *label = [UILabel new];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[self createVerticalString:text] attributes:attributes];
    label.numberOfLines = text.length;
    label.attributedText = attributedString;
    return label;
}

- (NSString *)createVerticalString:(NSString *)text
{
    NSMutableArray *letterArray = [NSMutableArray new];
    [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                             options:(NSStringEnumerationByComposedCharacterSequences)
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              [letterArray addObject:substring];
                          }];
    return [letterArray componentsJoinedByString:@"\n"];
}

- (CGFloat)quoteFontSize
{
    if (IS_IPHONE_4_OR_LESS) {
        return 23;
    } else if (IS_IPHONE_5) {
        return 25;
    } else if (IS_IPHONE_6) {
        return 28;
    } else {
        return 31;
    }
}

- (CGFloat)quoteHorizonalGap
{
    if (IS_IPHONE_4_OR_LESS) {
        return 9;
    } else if (IS_IPHONE_5) {
        return 10;
    } else if (IS_IPHONE_6) {
        return 11;
    } else {
        return 12;
    }
}

- (CGFloat)quoteRightMargin
{
    if (IS_IPHONE_4_OR_LESS) {
        return 26;
    } else if (IS_IPHONE_5) {
        return 28;
    } else if (IS_IPHONE_6) {
        return 33;
    } else {
        return 36;
    }
}

- (CGFloat)quoteTopMargin
{
    if (IS_IPHONE_4_OR_LESS) {
        return 26;
    } else if (IS_IPHONE_5) {
        return 28;
    } else if (IS_IPHONE_6) {
        return 33;
    } else {
        return 36;
    }
}

- (CGFloat)authorFontSize
{
    if (IS_IPHONE_4_OR_LESS) {
        return 17;
    } else if (IS_IPHONE_5) {
        return 18;
    } else if (IS_IPHONE_6) {
        return 20;
    } else {
        return 22;
    }
}

- (CGFloat)logoWidth
{
    if (IS_IPHONE_4_OR_LESS) {
        return 17;
    } else if (IS_IPHONE_5) {
        return 18;
    } else if (IS_IPHONE_6) {
        return 20;
    } else {
        return 22;
    }
}

- (CGFloat)logoVerticalGap
{
    if (IS_IPHONE_4_OR_LESS) {
        return 20;
    } else if (IS_IPHONE_5) {
        return 20;
    } else if (IS_IPHONE_6) {
        return 23;
    } else {
        return 26;
    }
}

- (CGFloat)logoHorizonalGap
{
    if (IS_IPHONE_4_OR_LESS) {
        return 15;
    } else if (IS_IPHONE_5) {
        return 15;
    } else if (IS_IPHONE_6) {
        return 17;
    } else {
        return 19;
    }
}

#pragma mark - Getters & Setters

- (NSMutableArray *)quoteLabels
{
    if (!_quoteLabels) {
        _quoteLabels = [NSMutableArray new];
    }
    
    return _quoteLabels;
}

@end
