//
//  XCZCollectionWork.h
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

@interface XCZCollectionWork : NSObject

@property (nonatomic) NSInteger id;
@property (nonatomic) NSInteger showOrder;
@property (nonatomic) NSInteger workId;
@property (strong, nonatomic) NSString *workTitle;
@property (strong, nonatomic) NSString *workFullTitle;
@property (strong, nonatomic) NSString *workAuthor;
@property (strong, nonatomic) NSString *workDynasty;
@property (strong, nonatomic) NSString *workContent;
@property (strong, nonatomic) NSString *workFirstSentence;
@property (nonatomic) NSInteger collectionId;
@property (strong, nonatomic) NSString *collection;

+ (NSArray *)getByCollectionId:(NSInteger)collectionId;

@end
