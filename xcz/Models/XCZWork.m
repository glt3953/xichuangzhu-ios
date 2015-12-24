//
//  XCZWork.m
//  xcz
//
//  Created by 刘志鹏 on 14-6-29.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import "XCZCollection.h"
#import "XCZCollectionWork.h"
#import "XCZUtils.h"
#import <FMDB/FMDB.h>

@interface XCZWork ()

@property (strong, nonatomic) NSString *titleTr;
@property (strong, nonatomic) NSString *fullTitleTr;
@property (strong, nonatomic) NSString *authorTr;
@property (strong, nonatomic) NSString *dynastyTr;
@property (strong, nonatomic) NSString *kindCNTr;
@property (strong, nonatomic) NSString *forewordTr;
@property (strong, nonatomic) NSString *contentTr;
@property (strong, nonatomic) NSString *introTr;
@property (strong, nonatomic) NSString *firstSentenceTr;

@end

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
        NSString *query = [[NSString alloc] initWithFormat:@"SELECT * FROM works WHERE author_id = %d AND kind = '%@'", authorId, kind];
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

- (NSArray *)getCollections
{
    int index = 0;
    NSMutableArray *collections = [NSMutableArray new];
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if ([db open]) {
        NSString *query = [[NSString alloc] initWithFormat:@"SELECT * FROM collection_works WHERE work_id = %d", self.id];
        FMResultSet *s = [db executeQuery:query];
        while ([s next]) {
            XCZCollectionWork *collectionWork = [XCZCollectionWork new];
            [collectionWork loadFromResultSet:s];
            
            XCZCollection *collection = [XCZCollection getById:collectionWork.collectionId];
            collections[index] = collection;
            index++;
        }
        
        [db close];
    }
    
    return collections;
}

#pragma mark - Internal Helper

- (void)updateWithResultSet:(FMResultSet *)resultSet
{
    self.id = [resultSet intForColumn:@"id"];
    self.authorId = [resultSet intForColumn:@"author_id"];
    self.kind = [resultSet stringForColumn:@"kind"];
    self.layout = [resultSet stringForColumn:@"layout"];
    self.baiduWiki = [resultSet stringForColumn:@"baidu_wiki"];

    self.title = [resultSet stringForColumn:@"title"];
    self.fullTitle = [resultSet stringForColumn:@"full_title"];
    self.author = [resultSet stringForColumn:@"author"];
    self.dynasty = [resultSet stringForColumn:@"dynasty"];
    self.kindCN = [resultSet stringForColumn:@"kind_cn"];
    self.foreword = [resultSet stringForColumn:@"foreword"];
    self.content = [resultSet stringForColumn:@"content"];
    self.intro = [resultSet stringForColumn:@"intro"];

    self.titleTr = [resultSet stringForColumn:@"title_tr"];
    self.fullTitleTr = [resultSet stringForColumn:@"full_title_tr"];
    self.authorTr = [resultSet stringForColumn:@"author_tr"];
    self.dynastyTr = [resultSet stringForColumn:@"dynasty_tr"];
    self.kindCNTr = [resultSet stringForColumn:@"kind_cn_tr"];
    self.forewordTr = [resultSet stringForColumn:@"foreword_tr"];
    self.contentTr = [resultSet stringForColumn:@"content_tr"];
    self.introTr = [resultSet stringForColumn:@"intro_tr"];
    
    self.firstSentence = [XCZUtils getFirstSentenceFromWorkContent:_content];
    self.firstSentenceTr = [XCZUtils getFirstSentenceFromWorkContent:_contentTr];
}

#pragma mark - Getters & Setters

- (NSString *)title
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _title;
    } else {
        return _titleTr;
    }
}

- (NSString *)fullTitle
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _fullTitle;
    } else {
        return _fullTitleTr;
    }
}

- (NSString *)author
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _author;
    } else {
        return _authorTr;
    }
}

- (NSString *)dynasty
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _dynasty;
    } else {
        return _dynastyTr;
    }
}

- (NSString *)kindCN
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _kindCN;
    } else {
        return _kindCNTr;
    }
}

- (NSString *)foreword
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _foreword;
    } else {
        return _forewordTr;
    }
}

- (NSString *)content
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _content;
    } else {
        return _contentTr;
    }
}

- (NSString *)intro
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _intro;
    } else {
        return _introTr;
    }
}

- (NSString *)firstSentence
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _firstSentence;
    } else {
        return _firstSentenceTr;
    }
}

- (NSArray *)collections{
    if (!_collections) {
        _collections = [self getCollections];
    }
    
    return _collections;
}

@end
