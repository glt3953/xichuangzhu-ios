//
//  XCZCollectionCell.m
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZCollectionCell.h"
#import "Constants.h"
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
//    self.contentView.backgroundColor = [UIColor redColor];
    
//    self.contentView.layer.borderWidth = .5;
//    self.contentView.layer.borderColor = [UIColor blackColor].CGColor;
    
    UIView *wapView = [UIView new];
    self.wapView = wapView;
    [self.contentView addSubview:wapView];
    
    UIImageView *imageView = [UIImageView new];
    self.imageView = imageView;
    imageView.layer.cornerRadius = [XCZCollectionCell getImageWidth] / 2;
    imageView.layer.masksToBounds = YES;
    [wapView addSubview:imageView];
    
    UILabel *collectionLabel = [UILabel new];
    self.collectionLabel = collectionLabel;
//    collectionLabel.numberOfLines = 0;
//    collectionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [wapView addSubview:collectionLabel];
    collectionLabel.textAlignment = NSTextAlignmentCenter;
    collectionLabel.font = [UIFont systemFontOfSize:[XCZCollectionCell getCollectionLabelFontSize]];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(wapView).offset([XCZCollectionCell getHorizonalGap]);
        make.left.right.equalTo(wapView);
        make.width.height.equalTo([NSNumber numberWithFloat:[XCZCollectionCell getImageWidth]]);
    }];
    
    [collectionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(wapView);
        make.width.lessThanOrEqualTo(imageView);
        make.top.equalTo(imageView.mas_bottom).offset(8);
        make.bottom.equalTo(wapView);
    }];
    
    return self;
}

- (void)updateWithCollection:(XCZCollection *)collection indexPath:(NSIndexPath *)indexPath
{
    self.collectionLabel.text = collection.name;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"https://placeholdit.imgix.net/~text?txtsize=33&txt=&w=120&h=120"] placeholderImage:[UIImage imageNamed:@"DefaultCollectionCover.png"]];
    
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
        return 60;
    } else if (IS_IPHONE_5) {
        return 60;
    } else if (IS_IPHONE_6) {
        return 68;
    } else {
        return 75;
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
