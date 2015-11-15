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

- (void)loadFromResultSet:(FMResultSet *)resultSet
{
    self.id = [resultSet intForColumn:@"id"];
    self.showOrder = [resultSet intForColumn:@"show_order"];
    self.workId = [resultSet intForColumn:@"work_id"];
    self.work = [resultSet stringForColumn:@"work"];
    self.collectionId = [resultSet intForColumn:@"collection_id"];
    self.collection = [resultSet stringForColumn:@"collection"];
}

@end
