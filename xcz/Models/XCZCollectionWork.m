//
//  XCZCollectionWork.m
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZCollectionWork.h"
#import "XCZUtils.h"

@interface XCZCollectionWork ()

@property (strong, nonatomic) NSString *workTitleTr;
@property (strong, nonatomic) NSString *workFullTitleTr;
@property (strong, nonatomic) NSString *workAuthorTr;
@property (strong, nonatomic) NSString *workDynastyTr;
@property (strong, nonatomic) NSString *workContentTr;
@property (strong, nonatomic) NSString *collectionTr;

@end

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
    self.collectionId = [resultSet intForColumn:@"collection_id"];
    
    self.workTitle = [resultSet stringForColumn:@"work_title"];
    self.workFullTitle = [resultSet stringForColumn:@"work_full_title"];
    self.workAuthor = [resultSet stringForColumn:@"work_author"];
    self.workDynasty = [resultSet stringForColumn:@"work_dynasty"];
    self.workContent = [resultSet stringForColumn:@"work_content"];
    self.collection = [resultSet stringForColumn:@"collection"];
    
    self.workTitleTr = [resultSet stringForColumn:@"work_title_tr"];
    self.workFullTitleTr = [resultSet stringForColumn:@"work_full_title_tr"];
    self.workAuthorTr = [resultSet stringForColumn:@"work_author_tr"];
    self.workDynastyTr = [resultSet stringForColumn:@"work_dynasty_tr"];
    self.workContentTr = [resultSet stringForColumn:@"work_content_tr"];
    self.collectionTr = [resultSet stringForColumn:@"collection_tr"];
}

#pragma mark - Getters & Setters

- (NSString *)workTitle
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _workTitle;
    } else {
        return _workTitleTr;
    }
}

- (NSString *)workFullTitle
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _workFullTitle;
    } else {
        return _workFullTitleTr;
    }
}

- (NSString *)workAuthor
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _workAuthor;
    } else {
        return _workAuthorTr;
    }
}

- (NSString *)workDynasty
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _workDynasty;
    } else {
        return _workDynastyTr;
    }
}

- (NSString *)workContent
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _workContent;
    } else {
        return _workContentTr;
    }
}

- (NSString *)collection
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SimplifiedChinese"]) {
        return _collection;
    } else {
        return _collectionTr;
    }
}

- (NSString *)workFirstSentence
{
    if (!_workFirstSentence) {
        _workFirstSentence = [XCZUtils getFirstSentenceFromWorkContent:self.workContent];
    }
    
    return _workFirstSentence;
}

@end
