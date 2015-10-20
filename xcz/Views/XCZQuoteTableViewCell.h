//
//  XCZQuoteTableViewCell.h
//  xcz
//
//  Created by hustlzp on 15/10/20.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuote.h"
#import <UIKit/UIKit.h>

@interface XCZQuoteTableViewCell : UITableViewCell

- (void)updateWithQuote:(XCZQuote *)quote;

@end
