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

@property (strong, nonatomic) NSString *titleTr;
@property (strong, nonatomic) NSString *authorTr;
@property (strong, nonatomic) NSString *dynastyTr;
@property (strong, nonatomic) NSString *contentTr;

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
        NSString *query = [[NSString alloc] initWithFormat:@"SELECT id, title, title_tr, dynasty, dynasty_tr, author, author_tr, snippet(works_ft, '[', ']', '...', -1, 3) AS content FROM works_ft WHERE works_ft MATCH '%@'", keyword];
        
//        [db installTokenizerModule];
        FMSimpleTokenizer *simpleTok = [[FMSimpleTokenizer alloc] initWithLocale:NULL];
        
        // This installs a tokenizer module named "fmdb"
        [db installTokenizerModule];
        // This registers the delegate using the name "simple", which should be used when creating the table (below).
        [FMDatabase registerTokenizer:simpleTok withKey:@"simple"];
        
        FMResultSet *s = [db executeQuery:query];
        
        if (s == nil) {
            NSLog(@"%@", [db lastErrorMessage]);
        }
        
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
    
    self.titleTr = [resultSet stringForColumn:@"title_tr"];
    self.authorTr = [resultSet stringForColumn:@"author_tr"];
    self.dynastyTr = [resultSet stringForColumn:@"dynasty_tr"];
//    self.contentTr = [resultSet stringForColumn:@"content_tr"];
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

//- (NSString *)content
//{
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
//        return _content;
//    } else {
//        return _contentTr;
//    }
//}

@end
