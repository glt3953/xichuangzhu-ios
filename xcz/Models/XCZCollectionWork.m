//
//  XCZCollectionWork.m
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZCollectionWork.h"
#import "XCZUtils.h"

@implementation XCZCollectionWork

// 获取某集合的所有作品
+ (NSArray *)getByCollectionId:(NSInteger)collectionId
{
    int index = 0;
    NSMutableArray *collectionWorks = [NSMutableArray new];
    NSString *dbPath = [XCZUtils getDatabaseFilePath];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    
    if ([db open]) {
        FMResultSet *s = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM collection_works WHERE collection_id == %ld ORDER BY show_order ASC", (long)collectionId]];
        
        while ([s next]) {
            XCZCollectionWork *collectionWork = [XCZCollectionWork new];
            [collectionWork loadFromResultSet:s];
            collectionWorks[index] = collectionWork;
            index++;
        }
        
        [db close];
    }
    
    return collectionWorks;
}

#pragma mark - Private Methods

- (void)loadFromResultSet:(FMResultSet *)resultSet
{
    self.id = [resultSet intForColumn:@"id"];
    self.showOrder = [resultSet intForColumn:@"show_order"];
    self.workId = [resultSet intForColumn:@"work_id"];
    self.workTitle = [resultSet stringForColumn:@"work_title"];
    self.workFullTitle = [resultSet stringForColumn:@"work_full_title"];
    self.workAuthor = [resultSet stringForColumn:@"work_author"];
    self.workDynasty = [resultSet stringForColumn:@"work_dynasty"];
    self.workContent = [resultSet stringForColumn:@"work_content"];
    self.collectionId = [resultSet intForColumn:@"collection_id"];
    self.collection = [resultSet stringForColumn:@"collection"];
}

#pragma mark - Getters & Setters

- (NSString *)workFirstSentence
{
    if (!_workFirstSentence) {
        _workFirstSentence = [XCZUtils getFirstSentenceFromWorkContent:self.workContent];
    }
    
    return _workFirstSentence;
}

@end
