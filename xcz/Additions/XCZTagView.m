//
//  XCZTagView.m
//  xcz
//
//  Created by hustlzp on 15/12/24.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZTagView.h"

@implementation XCZTagView

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.cornerRadius = 0;
    self.borderColor = [UIColor lightGrayColor];
    self.borderWidth = .5;
    self.textColor = [UIColor blackColor];
    self.paddingX = 5;
    self.paddingY = 2;
    self.tagBackgroundColor = [UIColor lightGrayColor];
    self.tagSelectedBackgroundColor = [UIColor grayColor];
    self.textFont = [UIFont systemFontOfSize:12];
    
    [self setTitle:title forState:UIControlStateNormal];
    [self addTarget:self action:@selector(tagPressed) forControlEvents:UIControlEventTouchUpInside];
    
    return self;
}

- (void)tagPressed {
    self.backgroundColor = self.tagSelectedBackgroundColor;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.backgroundColor = self.tagBackgroundColor;
        if (self.onTap) {
            self.onTap();
        }
    });
}

#pragma mark - Getters & Setters

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self setTitleColor:textColor forState:UIControlStateNormal];
}

- (void)setPaddingX:(CGFloat)paddingX
{
    _paddingX = paddingX;
    UIEdgeInsets contentEdgeInsets = self.contentEdgeInsets;
    contentEdgeInsets.left = paddingX;
    contentEdgeInsets.right = paddingX;
    self.contentEdgeInsets = contentEdgeInsets;
}

- (void)setPaddingY:(CGFloat)paddingY
{
    _paddingY = paddingY;
    UIEdgeInsets contentEdgeInsets = self.contentEdgeInsets;
    contentEdgeInsets.top = paddingY;
    contentEdgeInsets.bottom = paddingY;
    self.contentEdgeInsets = contentEdgeInsets;
}

- (void)setTagBackgroundColor:(UIColor *)tagBackgroundColor
{
    _tagBackgroundColor = tagBackgroundColor;
    self.backgroundColor = tagBackgroundColor;
}

- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    self.titleLabel.font = textFont;
}

@end
