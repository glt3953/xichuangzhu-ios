//
//  XCZBadgeView.m
//  xcz
//
//  Created by hustlzp on 15/11/2.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "UIImage+Helper.h"
#import "XCZBadgeView.h"
#import "UIColor+Helper.h"
#import <QuartzCore/QuartzCore.h>
#import <Masonry.h>

@interface XCZBadgeView ()

@property (strong, nonatomic) UILabel *numberLabel;

@end

@implementation XCZBadgeView

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.hidden = YES;
    self.layer.cornerRadius = 8.5;
    self.layer.masksToBounds = YES;
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithColor:[UIColor colorWithRGBA:0xFF3B30FF]]];
    [self addSubview:backgroundView];
    
    UILabel *numberLabel = [UILabel new];
    self.numberLabel = numberLabel;
    numberLabel.font = [UIFont systemFontOfSize:12];
    numberLabel.textColor = [UIColor whiteColor];
    [self addSubview:numberLabel];
    
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
        make.width.height.equalTo(@17);
    }];
    
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    return self;
}

#pragma mark - Getters & Setters

- (void)setNumber:(NSInteger)number
{
    _number = number;
    
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)number];
    self.hidden = number == 0;
}

@end
