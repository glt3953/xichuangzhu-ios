//
//  XCZXCZQuoteDraggableView.h
//  xcz
//
//  Created by hustlzp on 15/10/20.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuoteView.h"

@protocol XCZQuoteDraggableViewDelegate <XCZQuoteViewDelegate>

- (void)didDragLeft:(UIView *)quoteView;
- (void)didDragRight:(UIView *)quoteView;

@optional
- (void)dragging:(CGFloat)factor;
- (void)willBackToCenter:(CGFloat)factor;

@end

@interface XCZQuoteDraggableView : XCZQuoteView

@property (weak, nonatomic) id <XCZQuoteDraggableViewDelegate> delegate;

- (void)dragLeft;
- (void)dragRight;

@end
