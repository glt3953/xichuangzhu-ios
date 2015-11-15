//
//  XCZCollectionWork.h
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCZCollectionWork : NSObject

@property (nonatomic) NSInteger id;
@property (nonatomic) NSInteger showOrder;
@property (nonatomic) NSInteger workId;
@property (strong, nonatomic) NSString *work;
@property (nonatomic) NSInteger collectionId;
@property (strong, nonatomic) NSString *collection;

@end
