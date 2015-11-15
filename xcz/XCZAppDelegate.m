//
//  XCZAppDelegate.m
//  xcz
//
//  Created by 刘志鹏 on 14-6-28.
//  Copyright (c) 2014年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import "XCZQuote.h"
#import "XCZAppDelegate.h"
#import "XCZOtherViewController.h"
#import "XCZRandomQuoteViewController.h"
#import "XCZLibraryViewController.h"
#import "XCZWorkViewController.h"
#import "XCZCollectionsViewController.h"
#import "XCZLikesViewController.h"
#import "XCZUtils.h"
#import "Constants.h"
#import "UIColor+Helper.h"
#import "Constants.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import <AVOSCloud/AVOSCloud.h>
#import <ionicons/IonIcons.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <FMDB/FMDB.h>
#import <LeanCloudFeedback/LeanCloudFeedback.h>

@implementation XCZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [Fabric with:@[[Crashlytics class]]];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // AVOSCloud
    [AVOSCloud setApplicationId:AVOSCloudAppID clientKey:AVOSCloudAppKey];
    
    // 友盟
    [UMSocialData setAppKey:UmengAppKey];
    [UMSocialWechatHandler setWXAppId:WechatAppId appSecret:WechatAppSecret url:nil];
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToWechatSession, UMShareToWechatTimeline]];
    
    // 执行数据库拷贝
    [self copyPublicDatabase];
    [self copyUserDatabase];
    
    // 延迟0.5s
    usleep(500 * 1000);
    
    // 摘录
    XCZRandomQuoteViewController *quoteController = [XCZRandomQuoteViewController new];
    UINavigationController *quoteNavController = [[UINavigationController alloc] initWithRootViewController:quoteController];
    quoteController.tabBarItem.title = @"摘录";
    UIImage *quotesImg = [UIImage imageNamed:@"quotes.png"];
    quoteController.tabBarItem.image = quotesImg;
    
    // 分类
    XCZCollectionsViewController *collectionsController = [XCZCollectionsViewController new];
    UINavigationController *meetNavController = [[UINavigationController alloc] initWithRootViewController:collectionsController];
    collectionsController.tabBarItem.title = @"分类";
    UIImage *meetImg = [UIImage imageNamed:@"authors.png"];
    collectionsController.tabBarItem.image = meetImg;
    
    // 文库
    XCZLibraryViewController *libraryController = [XCZLibraryViewController new];
    UINavigationController *libraryNavController = [[UINavigationController alloc] initWithRootViewController:libraryController];
    libraryController.tabBarItem.title = @"文库";
    UIImage *libraryImg = [UIImage imageNamed:@"works.png"];
    libraryController.tabBarItem.image = libraryImg;
    
    // 其他
    XCZOtherViewController *otherController = [[XCZOtherViewController alloc] init];
    UINavigationController *meNavController = [[UINavigationController alloc] initWithRootViewController:otherController];
    UIImage *infoIcon = [IonIcons imageWithIcon:ion_ios_more size:34 color:[UIColor XCZSystemGrayColor]];
    UIImage *selectedInfoIcon = [IonIcons imageWithIcon:ion_ios_more size:34 color:[UIColor XCZSystemTintColor]];
    otherController.tabBarItem.title = @"其他";
    otherController.tabBarItem.image = infoIcon;
    otherController.tabBarItem.selectedImage = selectedInfoIcon;
    
    [[LCUserFeedbackAgent sharedInstance] countUnreadFeedbackThreadsWithBlock:^(NSInteger number, NSError *error) {
        if (!error && number != 0) {
            otherController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)number];
        } else {
            otherController.tabBarItem.badgeValue = nil;
        }
    }];
    
    // TabBar Controller
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[quoteNavController, meetNavController, libraryNavController, meNavController];
    
    // Root Controller
    [self.window setRootViewController:tabBarController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [UMSocialSnsService handleOpenURL:url];
}

- (void)copyUserDatabase
{
    NSString *storePath = [XCZUtils getUserDatabaseFilePath];
    NSString *bundleStore = [[NSBundle mainBundle] pathForResource:@"xcz_user" ofType:@"db"];
    
    // 若Documents文件夹下不存在数据库文件，则执行拷贝
    if (![[NSFileManager defaultManager] fileExistsAtPath:storePath]) {
        NSLog(@"User database not found... copy from bundle.");
        [[NSFileManager defaultManager] copyItemAtPath:bundleStore toPath:storePath error:nil];
    } else {
        NSLog(@"User database found.");
    }
}

- (void)copyPublicDatabase
{
    NSString *storePath = [XCZUtils getDatabaseFilePath];
    NSString *bundleStore = [[NSBundle mainBundle] pathForResource:@"xcz" ofType:@"db"];
    //NSLog(@"%@", storePath);
    
    // 若Documents文件夹下不存在数据库文件，则执行拷贝
    if (![[NSFileManager defaultManager] fileExistsAtPath:storePath]) {
        NSLog(@"Public database not found... copy from bundle.");
        [[NSFileManager defaultManager] copyItemAtPath:bundleStore toPath:storePath error:nil];
    } else {
        NSLog(@"Public database found.");
        
        NSString *latestVersion;
        NSString *currentVersion;
        
        // 获取latestVersion
        @try {
            FMDatabase *db = [FMDatabase databaseWithPath:bundleStore];
            [db open];
            FMResultSet *s = [db executeQuery:@"SELECT * FROM version"];
            [s next];
            latestVersion = [s stringForColumn:@"version"];
            [db close];
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
        
        // 获取currentVersion
        @try {
            FMDatabase *db = [FMDatabase databaseWithPath:storePath];
            [db open];
            FMResultSet *s = [db executeQuery:@"SELECT * FROM version"];
            [s next];
            currentVersion = [s stringForColumn:@"version"];
            [db close];
        }
        @catch (NSException * e) {
            NSLog(@"Exception: %@", e);
        }
        
        // 若 version 不匹配，则删除原有db，将新db复制过来
        if(![latestVersion isEqualToString:currentVersion]) {
            NSLog(@"Version not match...delete old one and copy new one from bundle.");
            [[NSFileManager defaultManager] removeItemAtPath:storePath error:NULL];
            [[NSFileManager defaultManager] removeItemAtPath:storePath error:NULL];[[NSFileManager defaultManager] copyItemAtPath:bundleStore toPath:storePath error:nil];
        } else {
            NSLog(@"Version match.");
        }
    }
}

@end
