//
//  XCZXCZQuoteDraggableView.h
//  xcz
//
//  Created by hustlzp on 15/10/20.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuoteView.h"

@protocol XCZQuoteDraggableViewDelegate <XCZQuoteViewDelegate>

- (void)quoteViewSwipedLeft:(UIView *)quoteView;
- (void)quoteViewSwipedRight:(UIView *)quoteView;

@end

@interface XCZQuoteDraggableView : XCZQuoteView

@property (weak, nonatomic) id <XCZQuoteDraggableViewDelegate> delegate;

- (void)leftClickAction;
- (void)rightClickAction;

@end
