//
//  XCZCollectionCell.h
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZCollection.h"
#import <UIKit/UIKit.h>

@interface XCZCollectionCell : UICollectionViewCell

+ (CGFloat)getImageWidth;
+ (CGFloat)getHorizonalGap;
- (void)updateWithCollection:(XCZCollection *)collection indexPath:(NSIndexPath *)indexPath;

@end
