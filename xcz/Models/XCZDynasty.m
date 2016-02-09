//
//  XCZDynasty.m
//  xcz
//
//  Created by 刘志鹏 on 14-7-3.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//

#import "XCZDynasty.h"
#import "XCZUtils.h"
#import <FMDB/FMDB.h>

@interface XCZDynasty ()

@property (nonatomic, strong) NSString *nameTr;
@property (nonatomic, strong) NSString *introTr;

@end

@implementation XCZDynasty

+ (NSMutableArray *)getAll
{
    int index = 0;
    NSMutableArray *dynasties = [NSMutableArray new];
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if ([db open]) {
        FMResultSet *s = [db executeQuery:@"SELECT * FROM dynasties ORDER BY start_year ASC"];
        while ([s next]) {
            XCZDynasty *dynasty = [XCZDynasty new];
            [dynasty loadFromResultSet:s];
            dynasties[index] = dynasty;
            index++;
        }
        
        [db close];
    }
    
    return dynasties;
}

#pragma mark - Internal Helper

- (void)loadFromResultSet:(FMResultSet *)resultSet
{
    self.id = [resultSet intForColumn:@"id"];
    
    self.name = [resultSet stringForColumn:@"name"];
    self.intro = [resultSet stringForColumn:@"intro"];
    
    self.nameSim = [resultSet stringForColumn:@"name"];
    self.nameTr = [resultSet stringForColumn:@"name_tr"];
    self.introTr = [resultSet stringForColumn:@"intro_tr"];
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

- (NSString *)intro
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _intro;
    } else {
        return _introTr;
    }
}

@end
