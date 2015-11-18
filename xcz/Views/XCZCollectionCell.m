//
//  XCZCollectionCell.m
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZCollectionCell.h"
#import "Constants.h"
#import "UIColor+Helper.h"
#import <Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>

static NSInteger const ColsCount = 4;

@interface XCZCollectionCell ()

@property (strong, nonatomic) UIView *wapView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *collectionLabel;

@end

@implementation XCZCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
//    self.contentView.layer.borderWidth = .5;
//    self.contentView.layer.borderColor = [UIColor blackColor].CGColor;
    
    UIView *wapView = [UIView new];
    self.wapView = wapView;
    [self.contentView addSubview:wapView];
    
    UIView *imageWapView = [UIView new];
    [wapView addSubview:imageWapView];
    imageWapView.backgroundColor = [UIColor whiteColor];
    imageWapView.layer.cornerRadius = [XCZCollectionCell getImageWidth] / 2;
    imageWapView.layer.masksToBounds = YES;
    imageWapView.layer.borderWidth = 1;
    imageWapView.layer.borderColor = [UIColor colorWithRGBA:0xE0E0E0FF].CGColor;
    
    UIImageView *imageView = [UIImageView new];
    self.imageView = imageView;
    imageView.layer.cornerRadius = [XCZCollectionCell getImageWidth] / 2 - 4;
    imageView.layer.masksToBounds = YES;
    [imageWapView addSubview:imageView];
    
    UILabel *collectionLabel = [UILabel new];
    self.collectionLabel = collectionLabel;
//    collectionLabel.numberOfLines = 0;
//    collectionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [wapView addSubview:collectionLabel];
    collectionLabel.textAlignment = NSTextAlignmentCenter;
    collectionLabel.font = [UIFont systemFontOfSize:[XCZCollectionCell getCollectionLabelFontSize]];
    
    // 约束
    [imageWapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wapView).offset([XCZCollectionCell getHorizonalGap]);
        make.left.right.equalTo(wapView);
        make.width.height.equalTo([NSNumber numberWithFloat:[XCZCollectionCell getImageWidth]]);
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(imageWapView);
        make.width.height.equalTo([NSNumber numberWithFloat:[XCZCollectionCell getImageWidth] - 8]);
    }];
    
    [collectionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wapView);
        make.width.lessThanOrEqualTo(imageWapView);
        make.top.equalTo(imageView.mas_bottom).offset(8);
        make.bottom.equalTo(wapView);
    }];
    
    return self;
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    return layoutAttributes;
}

- (void)updateWithCollection:(XCZCollection *)collection indexPath:(NSIndexPath *)indexPath
{
    if ([collection.cover length] != 0) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:collection.cover] placeholderImage:[UIImage imageNamed:@"DefaultCollectionCover.png"]];
    } else {
        self.imageView.image = [UIImage imageNamed:@"DefaultCollectionCover.png"];
    }
    
    self.collectionLabel.text = collection.name;
    
    [self.wapView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.contentView);
        if (indexPath.item % 4 == 0) {
            make.left.equalTo(self.contentView).offset([XCZCollectionCell getHorizonalGap]);
        } else {
            make.left.equalTo(self.contentView).offset([XCZCollectionCell getHorizonalGap] * .5);
        }
    }];
}

+ (CGFloat)getImageWidth
{
    if (IS_IPHONE_4_OR_LESS) {
        return 64;
    } else if (IS_IPHONE_5) {
        return 64;
    } else if (IS_IPHONE_6) {
        return 70;
    } else {
        return 76;
    }
}

+ (CGFloat)getHorizonalGap
{
    return (SCREEN_WIDTH - ColsCount * [self getImageWidth]) / (ColsCount + 1);
}

+ (CGFloat)getCollectionLabelFontSize
{
    if (IS_IPHONE_4_OR_LESS) {
        return 12;
    } else if (IS_IPHONE_5) {
        return 12;
    } else if (IS_IPHONE_6) {
        return 13.5;
    } else {
        return 14;
    }
}

@end
