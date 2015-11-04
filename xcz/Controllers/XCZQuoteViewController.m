//
//  XCZQuoteViewController.m
//  xcz
//
//  Created by hustlzp on 15/10/20.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuoteView.h"
#import "XCZWorkDetailViewController.h"
#import "XCZMeetViewController.h"
#import "XCZQuoteViewController.h"
#import "UIColor+Helper.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import <Masonry.h>
#import <MBProgressHUD.h>
#import <IonIcons.h>
#import <AVOSCloud.h>

@interface XCZQuoteViewController () <XCZQuoteViewDelegate>

@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) XCZQuote *quote;

@end

@implementation XCZQuoteViewController

#pragma mark - LifeCycle

- (instancetype)initWithQuote:(XCZQuote *)quote
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.quote = quote;
    
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor colorWithRGBA:0xF0F0F0FF];
    
    [self createViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSMutableArray *buttons = [NSMutableArray new];
    
    // 分享
    UIImage *shareIcon = [IonIcons imageWithIcon:ion_ios_paperplane_outline iconColor:[UIColor colorWithRGBA:0x8D8D8DFF] iconSize:35 imageSize:CGSizeMake(27, 35)];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithImage:shareIcon style:UIBarButtonItemStylePlain target:self action:@selector(shareQuote)];
    [buttons addObject:shareButton];
    
    // 保存到相册
    UIImage *snapshotIcon = [IonIcons imageWithIcon:ion_ios_albums_outline size:23 color:[UIColor grayColor]];
    UIBarButtonItem *snapshotButton = [[UIBarButtonItem alloc] initWithImage:snapshotIcon style:UIBarButtonItemStylePlain target:self action:@selector(snapshot)];
    [buttons addObject:snapshotButton];
    
    self.navigationItem.rightBarButtonItems = buttons;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Layout

- (void)createViews
{
    XCZQuoteView *quoteView = [[XCZQuoteView alloc] initWithQuote:self.quote];
    quoteView.delegate = self;
    [self.view addSubview:quoteView];
    
    [quoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.equalTo(self.view).multipliedBy(.8);
    }];
}

#pragma mark - Public Interface

#pragma mark - User Interface

- (void)snapshot
{
    [AVAnalytics event:@"snapshot_quote"];
    
    self.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.hud.labelText = @"保存到相册";
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)shareQuote
{
    XCZQuote *quote = self.quote;
    NSString *shareText = [NSString stringWithFormat:@"%@——%@《%@》", quote.quote, quote.author, quote.work];
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:nil
                                      shareText:shareText
                                     shareImage:[self snapshotView]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatTimeline, UMShareToWechatSession, UMShareToSina, UMShareToDouban, nil]
                                       delegate:nil];
}

#pragma mark - XCZQuoteViewDelegate

- (void)quoteViewPressed:(XCZQuote *)quote
{
    UIViewController *secondLastViewController = (UIViewController *)self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
    
    if ([secondLastViewController isKindOfClass:[XCZWorkDetailViewController class]] || [secondLastViewController isKindOfClass:[XCZMeetViewController class]]) {
        return;
    }
    
    XCZWorkDetailViewController *controller = [[XCZWorkDetailViewController alloc] initWithWorkId:quote.workId];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Internal Helpers

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.hud.labelText = @"已保存成功";
        self.hud.customView = [[UIImageView alloc] initWithImage:[IonIcons imageWithIcon:ion_checkmark size:37 color:[UIColor whiteColor]]];
        self.hud.mode = MBProgressHUDModeCustomView;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        });
    });
}

- (UIImage *)snapshotView
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Getters & Setters

@end
