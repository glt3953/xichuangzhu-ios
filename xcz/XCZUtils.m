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
    NSString *firstSentence;
    NSInteger stopLocation;
    NSInteger questionLocation;
    NSInteger semicolonLocation;
    
    content = [[content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
    stopLocation = [content rangeOfString:@"。"].location;
    questionLocation = [content rangeOfString:@"？"].location;
    semicolonLocation = [content rangeOfString:@"；"].location;
    
    if (stopLocation < MIN(questionLocation, semicolonLocation)) {
        firstSentence = [NSString stringWithFormat:@"%@。", [content componentsSeparatedByString:@"。"][0]];
    } else if (questionLocation < MIN(stopLocation, semicolonLocation)) {
        firstSentence = [NSString stringWithFormat:@"%@？", [content componentsSeparatedByString:@"？"][0]];
    } else {
        firstSentence = [NSString stringWithFormat:@"%@。", [content componentsSeparatedByString:@"；"][0]];
    }
    
    return firstSentence;
}

@end
