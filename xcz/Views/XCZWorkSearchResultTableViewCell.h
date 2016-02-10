//
//  XCZWorkSearchResultTableViewCell.h
//  xcz
//
//  Created by hustlzp on 16/2/10.
//  Copyright © 2016年 Zhipeng Liu. All rights reserved.
//

#import "XCZWorkSearchResult.h"
#import <UIKit/UIKit.h>

@interface XCZWorkSearchResultTableViewCell : UITableViewCell

- (void)updateWithWorkSearchResult:(XCZWorkSearchResult *)workSearchResult;

@end
