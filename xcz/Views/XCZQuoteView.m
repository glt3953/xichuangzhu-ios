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
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = [self lineSpacing];
    UILabel *authorLabel = [self createVerticalLabel:self.quote.author attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
    self.authorLabel = authorLabel;
    authorLabel.font = [UIFont fontWithName:[self fontName] size:[self authorFontSize]];
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
        [UIView animateWithDuration:.01 animations:^{
            self.transform = CGAffineTransformScale(CGAffineTransformIdentity, .985, .985);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.1 animations:^{
                self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.delegate quoteViewPressed:self.quote];
                });
            }];
        }];
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
        paragraphStyle.lineSpacing = [self lineSpacing];
        
        NSString *quoteText = [self.quote.quote substringWithRange:NSMakeRange(prevLocation, range.location - prevLocation)];
        UILabel *quoteLabel = [self createVerticalLabel:quoteText attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
        
        quoteLabel.font = [UIFont fontWithName:[self fontName] size:[self quoteFontSize]];

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

- (NSString *)fontName
{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"QuoteFont"] isEqualToString:@"STFangsong"]) {
        return XCZFontHWFangsong;
    } else {
        return XCZFontWYFangsong;
    }
}

- (CGFloat)quoteFontSize
{
    // 华文仿宋
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"QuoteFont"] isEqualToString:@"STFangsong"]) {
        if (IS_IPHONE_4_OR_LESS) {
            return 23;
        } else if (IS_IPHONE_5) {
            return 25;
        } else if (IS_IPHONE_6) {
            return 28;
        } else {
            return 31;
        }
    } else {
        // 文悦仿宋
        if (IS_IPHONE_4_OR_LESS) {
            return 19;
        } else if (IS_IPHONE_5) {
            return 21;
        } else if (IS_IPHONE_6) {
            return 24;
        } else {
            return 27;
        }
    }
}

// 水平间距
- (CGFloat)quoteHorizonalGap
{
    // 华文仿宋
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"QuoteFont"] isEqualToString:@"STFangsong"]) {
        if (IS_IPHONE_4_OR_LESS) {
            return 9;
        } else if (IS_IPHONE_5) {
            return 10;
        } else if (IS_IPHONE_6) {
            return 11;
        } else {
            return 12;
        }
    } else {
        // 文悦仿宋
        if (IS_IPHONE_4_OR_LESS) {
            return 11;
        } else if (IS_IPHONE_5) {
            return 12;
        } else if (IS_IPHONE_6) {
            return 13;
        } else {
            return 14;
        }
    }
}

/**
 *  右边距
 *
 *  @return
 */
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

/**
 *  上边距
 *
 *  @return
 */
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

// 行间距
- (CGFloat)lineSpacing
{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"QuoteFont"] isEqualToString:@"STFangsong"]) {
        return 2;
    } else {
        return 0.6;
    }
}

// 作者字体
- (CGFloat)authorFontSize
{
    // 华文仿宋
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"QuoteFont"] isEqualToString:@"STFangsong"]) {
        if (IS_IPHONE_4_OR_LESS) {
            return 17;
        } else if (IS_IPHONE_5) {
            return 18;
        } else if (IS_IPHONE_6) {
            return 20;
        } else {
            return 22;
        }
    } else {
        // 文悦仿宋
        if (IS_IPHONE_4_OR_LESS) {
            return 13;
        } else if (IS_IPHONE_5) {
            return 14;
        } else if (IS_IPHONE_6) {
            return 16;
        } else {
            return 18;
        }
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
