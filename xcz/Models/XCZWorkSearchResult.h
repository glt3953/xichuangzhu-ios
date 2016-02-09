//
//  XCZWorkSearchResult.h
//  xcz
//
//  Created by hustlzp on 16/2/9.
//  Copyright © 2016年 Zhipeng Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCZWorkSearchResult : NSObject

@property (nonatomic) int id;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *dynasty;
@property (nonatomic, strong) NSString *content;

+ (NSArray *)fullTextSearch:(NSString *)keyword;

@end
