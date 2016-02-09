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
        NSString *query = [[NSString alloc] initWithFormat:@"SELECT * FROM works_ft WHERE works_ft MATCH '%@'", keyword];
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
    
    self.titleTr = [resultSet stringForColumn:@"title_tr"];
    self.authorTr = [resultSet stringForColumn:@"author_tr"];
    self.dynastyTr = [resultSet stringForColumn:@"dynasty_tr"];
    self.contentTr = [resultSet stringForColumn:@"content_tr"];
}

@end
