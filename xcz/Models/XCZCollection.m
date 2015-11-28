//
//  XCZCollection.m
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZCollection.h"
#import "XCZUtils.h"
#import <FMDB/FMDB.h>

@implementation XCZCollection

+ (instancetype)getById:(NSInteger)id
{
    XCZCollection *collection = [XCZCollection new];
    
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM collections WHERE id == %ld", (long)id]];
        [s next];
        [collection loadFromResultSet:s];
        [db close];
    }
    
    return collection;
}

+ (NSArray *)getByCollectionKind:(NSInteger)collectionKindId
{
    int index = 0;
    NSMutableArray *collections = [NSMutableArray new];
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if ([db open]) {
        FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM collections WHERE kind_id == %ld ORDER BY show_order ASC", (long)collectionKindId]];
        while ([s next]) {
            XCZCollection *collection = [XCZCollection new];
            [collection loadFromResultSet:s];
            collections[index] = collection;
            index++;
        }
        
        [db close];
    }
    
    return collections;
}

+ (NSArray *)getAll
{
    int index = 0;
    NSMutableArray *collections = [NSMutableArray new];
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if ([db open]) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM collections ORDER BY show_order ASC"];
        while ([s next]) {
            XCZCollection *collection = [XCZCollection new];
            [collection loadFromResultSet:s];
            collections[index] = collection;
            index++;
        }
        
        [db close];
    }
    
    return collections;
}

#pragma mark - Internal Helpers

- (void)loadFromResultSet:(FMResultSet *)resultSet
{
    self.id = [resultSet intForColumn:@"id"];
    self.name = [resultSet stringForColumn:@"name"];
    self.showOrder = [resultSet intForColumn:@"show_order"];
    self.abbr = [resultSet stringForColumn:@"abbr"];
    self.desc = [resultSet stringForColumn:@"desc"];
    self.cover = [resultSet stringForColumn:@"cover"];
    self.link = [resultSet stringForColumn:@"link"];
    self.kindId = [resultSet intForColumn:@"kind_id"];
    self.kind = [resultSet stringForColumn:@"kind"];
}

@end
