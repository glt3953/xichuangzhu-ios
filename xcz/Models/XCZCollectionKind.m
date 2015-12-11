//
//  XCZCollectionKind.m
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZCollectionKind.h"
#import "XCZUtils.h"
#import <FMDB/FMDB.h>

@interface XCZCollectionKind ()

@property (strong, nonatomic) NSString *nameTr;

@end

@implementation XCZCollectionKind

+ (NSArray *)getAll
{
    int index = 0;
    NSMutableArray *collectionKinds = [NSMutableArray new];
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if ([db open]) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM collection_kinds ORDER BY show_order ASC"];
        while ([s next]) {
            XCZCollectionKind *collectionKind = [XCZCollectionKind new];
            [collectionKind loadFromResultSet:s];
            collectionKinds[index] = collectionKind;
            index++;
        }
        
        [db close];
    }
    
    return collectionKinds;
}

#pragma mark - Internal Helpers

- (void)loadFromResultSet:(FMResultSet *)resultSet
{
    self.id = [resultSet intForColumn:@"id"];
    self.showOrder = [resultSet intForColumn:@"show_order"];
    self.name = [resultSet stringForColumn:@"name"];
    self.nameTr = [resultSet stringForColumn:@"name_tr"];
}

#pragma mark - Getters & Setters

- (NSString *)name
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _name;
    } else {
        return _nameTr;
    }
}

@end
