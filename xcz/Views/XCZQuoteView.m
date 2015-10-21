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

@property (strong, nonatomic) XCZQuote *quote;
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
    
    UILabel *authorLabel = [self createVerticalLabel:[NSString stringWithFormat:@"%@", self.quote.author]];
    self.authorLabel = authorLabel;
    authorLabel.font = [UIFont fontWithName:XCZFontFangsong size:18];
    [self addSubview:authorLabel];
    
    [self createQuoteLabels];
    
    UILabel *prevLabel;
    
    for (int i = 0; i < self.quoteLabels.count; i++) {
        UILabel *label = self.quoteLabels[i];
        
        [self addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(30);
        }];
        
        if (i == 0) {
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self).offset(-30);
            }];
        } else {
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(prevLabel.mas_left).offset(-10);
            }];
        }
        
        prevLabel = label;
    }
    
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@18);
        make.left.equalTo(self).offset(15);
        make.bottom.equalTo(self).offset(-20);
    }];
    
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.logoView);
        make.bottom.equalTo(self.logoView.mas_top).offset(-10);
    }];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor colorWithRGBA:0x999999FF].CGColor;
    self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.layer.shadowOpacity = .25;
    self.layer.shadowPath = shadowPath.CGPath;
    self.layer.shadowRadius = 2;
}

#pragma mark - User Interaction

- (void)quoteViewPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(quoteViewPressed:)]) {
        [self.delegate quoteViewPressed:self.quote];
    }
}

#pragma mark - Internal Helpers

- (void)createQuoteLabels
{
    [self.quoteLabels removeAllObjects];
    
    __block NSInteger prevLocation = 0;
    
    NSString *pattern = @"[，。：？！]、";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    
    NSRange range = NSMakeRange(0,[self.quote.quote length]);
    [expression enumerateMatchesInString:self.quote.quote options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange range = [result rangeAtIndex:0];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2;
        
        NSString *quoteText = [self.quote.quote substringWithRange:NSMakeRange(prevLocation, range.location - prevLocation)];
        UILabel *quoteLabel = [self createVerticalLabel:quoteText attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
        quoteLabel.font = [UIFont fontWithName:XCZFontFangsong size:25];
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

#pragma mark - Getters & Setters

- (NSMutableArray *)quoteLabels
{
    if (!_quoteLabels) {
        _quoteLabels = [NSMutableArray new];
    }
    
    return _quoteLabels;
}

@end
