//
//  XCZWorkTableViewCell.h
//  xcz
//
//  Created by hustlzp on 15/10/19.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import "XCZCollectionWork.h"
#import <UIKit/UIKit.h>

@interface XCZWorkTableViewCell : UITableViewCell

- (void)updateWithWork:(XCZWork *)work showAuthor:(BOOL)showAuthor;
- (void)updateWithCollectionWork:(XCZCollectionWork *)collectionWork;

@end
