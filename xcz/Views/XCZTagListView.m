//
//  XCZTagListView.m
//  xcz
//
//  Created by hustlzp on 15/12/24.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZTagListView.h"
#import <Masonry.h>

@interface XCZTagListView()

@property (strong, nonatomic) NSMutableArray *tagViews;

@end

@implementation XCZTagListView

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.tagViews = [NSMutableArray new];
    self.cornerRadius = 0;
    self.borderColor = [UIColor lightGrayColor];
    self.borderWidth = .5;
    self.textColor = [UIColor blackColor];
    self.paddingX = 5;
    self.paddingY = 2;
    self.tagBackgroundColor = [UIColor lightGrayColor];
    self.tagSelectedBackgroundColor = [UIColor grayColor];
    self.textFont = [UIFont systemFontOfSize:12];
    self.marginX = 5;
    self.marginY = 2;
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (XCZTagView *tagView in self.tagViews) {
        [tagView removeFromSuperview];
    }
    
    NSInteger currentRow = 0;
    NSInteger currentRowTagCount = 0;
    CGFloat currentRowWidth = 0;
    CGFloat tagViewWidth = 0.0;
    CGFloat tagViewHeight = 0.0;
    CGFloat tagViewX = 0.0;
    CGFloat tagViewY = 0.0;
    
    for (XCZTagView *tagView in self.tagViews) {
        tagViewWidth = tagView.intrinsicContentSize.width;
        tagViewHeight = tagView.intrinsicContentSize.height;
        
        if (currentRowTagCount == 0 || currentRowWidth + tagViewWidth + self.marginX > self.frame.size.width) {
            currentRow += 1;
            tagViewX = 0;
            currentRowWidth = 0;
        }
        
        tagViewX = currentRowWidth;
        tagViewY = (currentRow - 1) * (tagViewHeight + self.marginY);
        
        currentRowTagCount += 1;
        currentRowWidth += tagViewWidth + self.marginX;
        
        tagView.frame = CGRectMake(tagViewX, tagViewY, tagViewWidth, tagViewHeight);
        
        [self addSubview:tagView];
    }
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo([NSNumber numberWithFloat:tagViewY + tagViewHeight]);
    }];
}

- (XCZTagView *)addTag:(NSString *)title
{
    XCZTagView *tagView = [[XCZTagView alloc] initWithTitle:title];
    tagView.cornerRadius = self.cornerRadius;
    tagView.borderColor = self.borderColor;
    tagView.borderWidth = self.borderWidth;
    tagView.textColor = self.textColor;
    tagView.paddingX = self.paddingX;
    tagView.paddingY = self.paddingY;
    tagView.tagBackgroundColor = self.tagBackgroundColor;
    tagView.tagSelectedBackgroundColor = self.tagSelectedBackgroundColor;
    tagView.textFont = self.textFont;
    
    [self.tagViews addObject:tagView];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    return tagView;
}

- (void)removeAllTags
{
    for (XCZTagView *tagView in self.tagViews) {
        [tagView removeFromSuperview];
    }
    
    [self.tagViews removeAllObjects];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
