//
//  XCZCollection.h
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCZCollection : NSObject

@property (nonatomic) NSInteger id;
@property (nonatomic) NSInteger showOrder;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *abbr;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *cover;
@property (strong, nonatomic) NSString *link;
@property (nonatomic) NSInteger kindId;
@property (strong, nonatomic) NSString *kind;

+ (NSArray *)getByCollectionKind:(NSInteger)collectionKindId;
+ (instancetype)getById:(NSInteger)id;
+ (NSArray *)getAll;

@end
