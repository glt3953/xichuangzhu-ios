//
//  XCZWork.m
//  xcz
//
//  Created by 刘志鹏 on 14-6-29.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import "XCZCollectionWork.h"
#import "XCZUtils.h"
#import <FMDB/FMDB.h>

@implementation XCZWork

// 根据id获取作品
+ (XCZWork *)getById:(int)workId
{
    XCZWork *work = [[XCZWork alloc] init];
    
    // 从SQLite中加载work
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        FMResultSet *s = [db executeQuery:[[NSString alloc] initWithFormat:@"SELECT * FROM works where id == %d", workId]];
        [s next];
        [work updateWithResultSet:s];
        [db close];
    }
    
    return work;
}

// 获取所有作品
+ (NSMutableArray *)getAll
{
    int index = 0;
    NSMutableArray *works = [[NSMutableArray alloc] init];

    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM works ORDER BY show_order ASC"];
        while ([s next]) {
            XCZWork *work = [XCZWork new];
            [work updateWithResultSet:s];
            works[index] = work;
            index++;
        }
        
        [db close];
    }
    
    return works;
}

// 获取重新排序后的作品
+ (NSMutableArray *)reorderWorks
{
    int index = 0;
    int showOrder = 0;
    NSMutableArray *works = [[NSMutableArray alloc] init];
    
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM works ORDER BY RANDOM()"];
        
        [db beginTransaction];
        
        while ([s next]) {
            XCZWork *work = [XCZWork new];
            [work updateWithResultSet:s];
            works[index] = work;
            index++;
            
            // 更新show_order
            NSString *query = [[NSString alloc] initWithFormat:@"UPDATE works SET show_order = %d WHERE id = %d", showOrder, work.id];
            [db executeUpdate:query];
            showOrder++;
        }
        
        [db commit];
        
        [db close];
    }
    
    return works;
}

// 获取某文学家的某类文学作品
+ (NSMutableArray *)getWorksByAuthorId:(int)authorId kind:(NSString *)kind
{
    int index = 0;
    NSMutableArray *works = [[NSMutableArray alloc] init];
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];

    if ([db open]) {
        NSString *query = [[NSString alloc] initWithFormat:@"SELECT * FROM works WHERE author_id = %d AND kind_cn = '%@'", authorId, kind];
        FMResultSet *s = [db executeQuery:query];
        while ([s next]) {
            XCZWork *work = [XCZWork new];
            [work updateWithResultSet:s];
            works[index] = work;
            index++;
        }
        
        [db close];
    }
    
    return works;
}

+ (XCZWork *)getRandomWork
{
    XCZWork *work = [[XCZWork alloc] init];
    
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM works ORDER BY RANDOM() LIMIT 1"];
        [s next];
        [work updateWithResultSet:s];
        [db close];
    }
    
    return work;
}

// 获取某集合的所有作品
+ (NSArray *)getByCollectionId:(NSInteger)collectionId
{
    int index = 0;
    NSMutableArray *works = [NSMutableArray new];
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if ([db open]) {
        FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM collection_works WHERE collection_id == %d ORDER BY show_order ASC", collectionId]];
        while ([s next]) {
            XCZCollectionWork *collectionWork = [XCZCollectionWork new];
            [collectionWork loadFromResultSet:s];
            XCZWork *work = [XCZWork getById:collectionWork.workId];
            works[index] = work;
            index++;
        }
        
        [db close];
    }
    
    return works;
}

#pragma mark - Internal Helper

- (void)updateWithResultSet:(FMResultSet *)resultSet
{
    self.id = [resultSet intForColumn:@"id"];
    self.title = [resultSet stringForColumn:@"title"];
    self.fullTitle = [resultSet stringForColumn:@"full_title"];
    self.authorId = [resultSet intForColumn:@"author_id"];
    self.author = [resultSet stringForColumn:@"author"];
    self.dynasty = [resultSet stringForColumn:@"dynasty"];
    self.kind = [resultSet stringForColumn:@"kind"];
    self.kindCN = [resultSet stringForColumn:@"kind_cn"];
    self.foreword = [resultSet stringForColumn:@"foreword"];
    self.content = [resultSet stringForColumn:@"content"];
    self.intro = [resultSet stringForColumn:@"intro"];
    self.layout = [resultSet stringForColumn:@"layout"];
    self.baiduWiki = [resultSet stringForColumn:@"baidu_wiki"];
}

#pragma mark - Getters & Setters

- (NSString *)firstSentence
{
    if (!_firstSentence) {
        NSString *content = [[self.content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
        
        NSInteger stopLocation = [content rangeOfString:@"。"].location;
        NSInteger questionLocation = [content rangeOfString:@"？"].location;
        NSInteger semicolonLocation = [content rangeOfString:@"；"].location;

        if (stopLocation < MIN(questionLocation, semicolonLocation)) {
            _firstSentence = [NSString stringWithFormat:@"%@。", [content componentsSeparatedByString:@"。"][0]];
        } else if (questionLocation < MIN(stopLocation, semicolonLocation)) {
            _firstSentence = [NSString stringWithFormat:@"%@？", [content componentsSeparatedByString:@"？"][0]];
        } else {
            _firstSentence = [NSString stringWithFormat:@"%@。", [content componentsSeparatedByString:@"；"][0]];
        }
    }
    
    return _firstSentence;
}

@end
