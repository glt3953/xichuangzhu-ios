//
//  XCZTagView.h
//  xcz
//
//  Created by hustlzp on 15/12/24.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCZTagView : UIButton

@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat borderWidth;
@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIFont *textFont;
@property (nonatomic) CGFloat paddingX;
@property (nonatomic) CGFloat paddingY;
@property (strong, nonatomic) UIColor *tagBackgroundColor;
@property (strong, nonatomic) UIColor *tagSelectedBackgroundColor;
@property (copy, nonatomic) void (^onTap)(void);


- (instancetype)initWithTitle:(NSString *)title;

@end
