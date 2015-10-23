#ifndef Constants_h
#define Constants_h

#if TARGET_IPHONE_SIMULATOR
#define RunOnSimulator 1
#else
#define RunOnSimulator 0
#endif

#define AVOSCloudAppID  @"9pq709je4y36ubi10xphdpovula77enqrz27idozgry7x644"
#define AVOSCloudAppKey @"364g5iu6q1f3hhwz8wruvmayu3vsap995wh4ws7tszor43np"
#define UmengAppKey @"5408794dfd98c533af00180a"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define XCZFontFangsong @"STFangsong"

#define XCZTabBarHeight 49
#define XCZNavBarHeight 64
#define XCZStatusBarHeight 20

#endif