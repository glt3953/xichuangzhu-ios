//
//  XCZAuthorTableViewCell.h
//  xcz
//
//  Created by hustlzp on 15/10/19.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZAuthor.h"
#import <UIKit/UIKit.h>

@interface XCZAuthorTableViewCell : UITableViewCell

- (void)updateWithAuthor:(XCZAuthor *)author;

@end
