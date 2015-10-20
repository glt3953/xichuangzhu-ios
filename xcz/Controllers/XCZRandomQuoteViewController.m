//
//  XCZRandomQuoteViewController.m
//  xcz
//
//  Created by hustlzp on 15/10/20.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZQuote.h"
#import "XCZWork.h"
#import "XCZWorkDetailViewController.h"
#import "XCZRandomQuoteViewController.h"
#import "Constants.h"
#import "UIColor+Helper.h"
#import <ionicons/IonIcons.h>
#import <Masonry.h>

@interface XCZRandomQuoteViewController ()

@property (strong, nonatomic) XCZQuote *quote;
@property (strong, nonatomic) UIImageView *logoView;
@property (strong, nonatomic) UIView *quoteWapView;
@property (strong, nonatomic) UILabel *authorLabel;
@property (strong, nonatomic) NSMutableArray *quoteLabels;

@end

@implementation XCZRandomQuoteViewController

#pragma mark - LifeCycle

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor colorWithRGBA:0xF8F8F8FF];
    
    [self createViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //添加“换一换”按钮
    UIImage *refreshIcon = [IonIcons imageWithIcon:ion_ios_loop_strong size:24 color:[UIColor grayColor]];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:refreshIcon style:UIBarButtonItemStylePlain target:self action:@selector(refreshQuote)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"摘录";
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.quoteWapView.bounds];
    self.quoteWapView.layer.masksToBounds = NO;
    self.quoteWapView.layer.shadowColor = [UIColor colorWithRGBA:0x999999FF].CGColor;
    self.quoteWapView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.quoteWapView.layer.shadowOpacity = 0.5f;
    self.quoteWapView.layer.shadowPath = shadowPath.CGPath;
    self.quoteWapView.layer.shadowRadius = 2;
}

#pragma mark - Layout

- (void)createViews
{
    UIView *quoteWapView = [UIView new];
    self.quoteWapView = quoteWapView;
    quoteWapView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:quoteWapView];
    quoteWapView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(redirectToWork)];
    [quoteWapView addGestureRecognizer:tapGesture];
    
    UIImageView *logoView = [UIImageView new];
    logoView.image = [UIImage imageNamed:@"AppIcon40x40"];
    logoView.layer.cornerRadius = 3;
    logoView.layer.masksToBounds = YES;
    self.logoView = logoView;
    [quoteWapView addSubview:logoView];
    
    [quoteWapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
        make.width.height.equalTo(self.view).multipliedBy(.8);
    }];
    
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@18);
        make.left.equalTo(self.quoteWapView).offset(15);
        make.bottom.equalTo(self.quoteWapView).offset(-20);
    }];
    
    [self refreshQuote];
}

#pragma mark - Public Interface

#pragma mark - User Interface

- (void)refreshQuote
{
    self.quote = [XCZQuote getRandomQuote];
    
    if (self.authorLabel) {
        [self.authorLabel removeFromSuperview];
    }
    
    UILabel *authorLabel = [self createVerticalLabel:[NSString stringWithFormat:@"%@", self.quote.author]];
    self.authorLabel = authorLabel;
    authorLabel.font = [UIFont fontWithName:XCZFontFangsong size:18];
    [self.quoteWapView addSubview:authorLabel];
    
    [authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.logoView);
        make.bottom.equalTo(self.logoView.mas_top).offset(-12);
    }];
    
    for (UILabel *label in self.quoteLabels) {
        [label removeFromSuperview];
    }
    
    [self updateQuoteLabels];
    
    UILabel *prevLabel;
    
    for (int i = 0; i < self.quoteLabels.count; i++) {
        UILabel *label = self.quoteLabels[i];
        
        [self.view addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.quoteWapView).offset(30);
        }];
        
        if (i == 0) {
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.quoteWapView).offset(-30);
            }];
        } else {
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(prevLabel.mas_left).offset(-10);
            }];
        }
        
        prevLabel = label;
    }
}

- (void)redirectToWork
{
    XCZWork *work = [XCZWork getById:self.quote.workId];
    XCZWorkDetailViewController *controller = [XCZWorkDetailViewController new];
    controller.work = work;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - SomeDelegate

#pragma mark - Internal Helpers

- (void)updateQuoteLabels
{
    [self.quoteLabels removeAllObjects];
    
    __block NSInteger prevLocation = 0;
    
    NSString *pattern = @"[，。；？！]";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    
    NSRange range = NSMakeRange(0,[self.quote.quote length]);
    [expression enumerateMatchesInString:self.quote.quote options:0 range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSRange range = [result rangeAtIndex:0];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2;
        
        NSString *quoteText = [self.quote.quote substringWithRange:NSMakeRange(prevLocation, range.location - prevLocation)];
        UILabel *quoteLabel = [self createVerticalLabel:quoteText attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
        quoteLabel.font = [UIFont fontWithName:XCZFontFangsong size:25];
        [self.quoteLabels addObject:quoteLabel];
        
        prevLocation = range.location + 1;
    }];
}

- (UILabel *)createVerticalLabel:(NSString *)text
{
    UILabel *label = [UILabel new];
    label.numberOfLines = text.length;
    label.text = [self createVerticalString:text];
    return label;
}

- (UILabel *)createVerticalLabel:(NSString *)text attributes:(NSDictionary *)attributes
{
    UILabel *label = [UILabel new];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:[self createVerticalString:text] attributes:attributes];
    label.numberOfLines = text.length;
    label.attributedText = attributedString;
    return label;
}

- (NSString *)createVerticalString:(NSString *)text
{
    NSMutableArray *letterArray = [NSMutableArray new];
    [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                             options:(NSStringEnumerationByComposedCharacterSequences)
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              [letterArray addObject:substring];
                          }];
    return [letterArray componentsJoinedByString:@"\n"];
}

#pragma mark - Getters & Setters

- (NSMutableArray *)quoteLabels
{
    if (!_quoteLabels) {
        _quoteLabels = [NSMutableArray new];
    }
    
    return _quoteLabels;
}

@end
