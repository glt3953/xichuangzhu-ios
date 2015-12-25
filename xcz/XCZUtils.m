//
//  XCZUtils.m
//  xcz
//
//  Created by 刘志鹏 on 14-7-7.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//

#import "Constants.h"
#import "XCZUtils.h"

@implementation XCZUtils

+ (NSString *)getDatabaseFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *storePath = [documentsDirectory stringByAppendingPathComponent:@"xcz.db"];
    return storePath;
}

+ (NSString *)getUserDatabaseFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *storePath = [documentsDirectory stringByAppendingPathComponent: @"xcz_user.db"];
    return storePath;
}

+ (CGFloat)getCellHorizonalGap
{
    if (IS_IPHONE_6P) {
        return 20;
    } else {
        return 15;
    }
}

+ (NSString *)getFirstSentenceFromWorkContent:(NSString *)content
{    
    content = [[content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] firstObject];
    NSArray *seperators = @[@"。", @"？", @"；", @"！"];
    
    NSInteger minLocation = -1;
    NSString *minSeperator;
    
    for (NSString *seperator in seperators) {
        NSInteger location = [content rangeOfString:seperator].location;
        if (location == NSNotFound) {
            continue;
        }
        
        if (minLocation == -1) {
            minLocation = location;
            minSeperator = seperator;
        } else if (location < minLocation){
            minLocation = location;
            minSeperator = seperator;
        }
    }
    
    if (minLocation == -1) {
        return content;
    } else {
        return [NSString stringWithFormat:@"%@%@", [[content componentsSeparatedByString:minSeperator] firstObject], minSeperator];
    }
}

@end
