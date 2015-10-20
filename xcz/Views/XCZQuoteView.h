//
//  XCZQuoteView.h
//  xcz
//
//  Created by hustlzp on 15/10/20.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuote.h"
#import <UIKit/UIKit.h>

@protocol XCZQuoteViewDelegate <NSObject>

- (void)quoteViewPressed:(XCZQuote *)quote;

@optional
- (void)quoteViewSwipedLeft:(UIView *)quoteView;
- (void)quoteViewSwipedRight:(UIView *)quoteView;

@end

@interface XCZQuoteView : UIView

@property (weak, nonatomic) id <XCZQuoteViewDelegate> delegate;

- (instancetype)initWithQuote:(XCZQuote *)quote;
- (void)leftClickAction;
- (void)rightClickAction;

@end
