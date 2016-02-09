//
//  XCZRandomQuoteViewController.m
//  xcz
//
//  Created by hustlzp on 15/10/20.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuote.h"
#import "XCZWork.h"
#import "XCZWorkViewController.h"
#import "XCZRandomQuoteViewController.h"
#import "Constants.h"
#import "UIColor+Helper.h"
#import "LocalizeHelper.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import <ionicons/IonIcons.h>
#import <Masonry.h>
#import <MBProgressHUD.h>
#import <AVOSCloud.h>

static CGFloat const SecondQuoteViewOriginalScale = 0.97;

@interface XCZRandomQuoteViewController () <XCZQuoteDraggableViewDelegate>

@property (strong, nonatomic) XCZQuoteDraggableView *firstQuoteView;
@property (strong, nonatomic) XCZQuoteDraggableView *secondQuoteView;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSMutableArray *quoteIds;

@end

@implementation XCZRandomQuoteViewController

#pragma mark - LifeCycle

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor colorWithRGBA:0xF0F0F0FF];
    
    [self createViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *buttons = [NSMutableArray new];
    
    // 刷新
    UIImage *refreshIcon = [IonIcons imageWithIcon:ion_ios_loop_strong size:24 color:[UIColor colorWithRGBA:0x8D8D8DFF]];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithImage:refreshIcon style:UIBarButtonItemStylePlain target:self action:@selector(refreshQuote)];
    [buttons addObject:refreshButton];
    
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
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.navigationItem.title = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"摘录";
}

#pragma mark - Layout

- (void)createViews
{
    [self loadQuoteView];
    [self loadQuoteView];
    self.firstQuoteView.userInteractionEnabled = YES;
}

#pragma mark - Public Interface

- (void)updateBarTitles
{
    self.tabBarItem.title = LocalizedString(@"摘录");
}

#pragma mark - User Interface

- (void)refreshQuote
{
    [AVAnalytics event:@"refresh_quote"];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.firstQuoteView dragLeft];
    
    [UIView animateWithDuration:.4 animations:^{
        self.secondQuoteView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
    }];
}

- (void)snapshot
{
    self.hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    [AVAnalytics event:@"snapshot_quote"];
    
    self.hud.labelText = LocalizedString(@"保存到相册");
    UIImageWriteToSavedPhotosAlbum([self snapshotView], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)shareQuote
{
    XCZQuote *quote = self.firstQuoteView.quote;
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
    XCZWork *work = [XCZWork getById:quote.workId];
    XCZWorkViewController *controller = [[XCZWorkViewController alloc] initWithWork:work quote:quote];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didDragLeft:(UIView *)quoteView
{
    [self loadQuoteView];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)didDragRight:(UIView *)quoteView
{
    [self loadQuoteView];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)dragging:(CGFloat)factor
{
    CGFloat scale = SecondQuoteViewOriginalScale + (1 - SecondQuoteViewOriginalScale) * factor;
    self.secondQuoteView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
}

- (void)willBackToCenter:(CGFloat)factor
{
    [UIView animateWithDuration:.3 animations:^{
        self.secondQuoteView.transform = CGAffineTransformScale(CGAffineTransformIdentity, SecondQuoteViewOriginalScale, SecondQuoteViewOriginalScale);
    }];
}

#pragma mark - Internal Helpers

- (void)loadQuoteView
{
    XCZQuote *randomQuote;
    if (self.quoteIds.count == 0) {
        randomQuote = [XCZQuote getRandomQuote];
    } else {
        randomQuote = [XCZQuote getRandomQuoteExcept:self.quoteIds];
    }
    
    XCZQuoteDraggableView *quoteView = [[XCZQuoteDraggableView alloc] initWithQuote:randomQuote];
    quoteView.delegate = self;
    
    if (self.quoteIds.count == 10) {
        [self.quoteIds removeObjectAtIndex:0];
    }
    [self.quoteIds addObject:[NSString stringWithFormat:@"%d", randomQuote.id]];
    
    if (!self.firstQuoteView) {
        self.firstQuoteView = quoteView;
        self.firstQuoteView.userInteractionEnabled = YES;
        [self.view addSubview:quoteView];
    } else {
        if (self.secondQuoteView) {
            self.firstQuoteView = self.secondQuoteView;
            self.firstQuoteView.userInteractionEnabled = YES;
            self.secondQuoteView = quoteView;
        }
            
        self.secondQuoteView = quoteView;
        quoteView.transform = CGAffineTransformScale(CGAffineTransformIdentity, SecondQuoteViewOriginalScale, SecondQuoteViewOriginalScale);
        [self.view insertSubview:quoteView belowSubview:self.firstQuoteView];
    }
    
    [quoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    [quoteView adjustSize];
}

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

- (NSMutableArray *)quoteIds
{
    if (!_quoteIds) {
        _quoteIds = [NSMutableArray new];
    }
    
    return _quoteIds;
}

@end
