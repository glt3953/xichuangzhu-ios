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

@end

@interface XCZQuoteView : UIView

@property (weak, nonatomic) id <XCZQuoteViewDelegate> delegate;
@property (strong, nonatomic) XCZQuote *quote;

- (instancetype)initWithQuote:(XCZQuote *)quote;
- (void)adjustSize;

@end
