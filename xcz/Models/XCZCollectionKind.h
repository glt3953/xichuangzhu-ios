//
//  XCZCollectionKind.h
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCZCollectionKind : NSObject

@property (nonatomic) NSInteger id;
@property (nonatomic) NSInteger showOrder;
@property (strong, nonatomic) NSString *name;

+ (NSArray *)getAll;

@end
