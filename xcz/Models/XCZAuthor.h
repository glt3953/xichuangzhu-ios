//
//  XCZAuthor.h
//  xcz
//
//  Created by 刘志鹏 on 14-7-3.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuote.h"
#import <Foundation/Foundation.h>

@interface XCZAuthor : NSObject

@property (nonatomic) int id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *firstChar;
@property (nonatomic, strong) NSString *intro;
@property (nonatomic, strong) NSString *dynasty;
@property (nonatomic, strong) NSString *dynastySim;
@property (nonatomic, strong) NSString *birthYear;
@property (nonatomic, strong) NSString *deathYear;
@property (nonatomic, strong) NSString *baiduWiki;
@property (nonatomic, strong) XCZQuote *randomQuote;
@property (nonatomic) NSInteger worksCount;

+ (XCZAuthor *)getById:(int)authorId;
+ (int)getWorksCount:(int)authorId;
+ (NSMutableArray *)getAuthorsByDynasty:(NSString *)dynasty;
+ (NSMutableArray *)getAllAuthors;

@end
