//
//  XCZWorkSearchResult.m
//  xcz
//
//  Created by hustlzp on 16/2/9.
//  Copyright © 2016年 Zhipeng Liu. All rights reserved.
//

#import "XCZWorkSearchResult.h"
#import "XCZUtils.h"
#import <FMDB/FMDB.h>
#import <FMDB/FMDatabase+FTS3.h>
#import <FMDB/FMTokenizers.h>

@interface XCZWorkSearchResult ()

@property (strong, nonatomic) NSString *authorTr;
@property (strong, nonatomic) NSString *dynastyTr;

@end

@implementation XCZWorkSearchResult

/**
 *  全文检索
 *
 *  @param keyword <#keyword description#>
 *
 *  @return <#return value description#>
 */
+ (NSArray *)fullTextSearch:(NSString *)keyword
{
    NSMutableArray *works = [NSMutableArray new];
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if ([db open]) {
        int titleIndex = [[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"] ? 1 : 2;
        int contentIndex = [[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"] ? 3 : 4;
        NSString *query = [[NSString alloc] initWithFormat:@"SELECT id, snippet(works_ft, '[', ']', '...', %d, 10) AS title, dynasty, dynasty_tr, author, author_tr, snippet(works_ft, '[', ']', '...', %d, 8) AS content FROM works_ft WHERE works_ft MATCH '%@'", titleIndex, contentIndex, keyword];
        
        FMSimpleTokenizer *simpleTok = [[FMSimpleTokenizer alloc] initWithLocale:NULL];
        [db installTokenizerModule];
        [FMDatabase registerTokenizer:simpleTok withKey:@"simple"];
        FMResultSet *s = [db executeQuery:query];
        
        while ([s next]) {
            XCZWorkSearchResult *work = [XCZWorkSearchResult new];
            [work updateWithResultSet:s];
            [works addObject:work];
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
    self.author = [resultSet stringForColumn:@"author"];
    self.dynasty = [resultSet stringForColumn:@"dynasty"];
    self.content = [resultSet stringForColumn:@"content"];
    
    self.authorTr = [resultSet stringForColumn:@"author_tr"];
    self.dynastyTr = [resultSet stringForColumn:@"dynasty_tr"];
}

#pragma mark - Getters & Setters

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

@end
