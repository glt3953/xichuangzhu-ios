//
//  XCZCollectionsViewController.m
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZCollectionSectionHeaderView.h"
#import "XCZCollectionSectionFooterView.h"
#import "XCZCollectionKind.h"
#import "XCZCollection.h"
#import "XCZCollectionCell.h"
#import "XCZCollectionWorksViewController.h"
#import "XCZCollectionsViewController.h"
#import "UIColor+Helper.h"
#import "Constants.h"
#import "XCZUtils.h"
#import <Masonry.h>

static NSString * const CellReuseIdentifier = @"CellIdentifier";
static NSString * const HeaderViewReuseIdentifier = @"HeaderView";
static NSString * const FooterViewReuseIdentifier = @"FooterView";

@interface XCZCollectionsViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *collectionKinds;
@property (strong, nonatomic) NSArray *collections;

@end

@implementation XCZCollectionsViewController

#pragma mark - LifeCycle

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self view];
    
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createViews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"分类";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - View Helpers


- (void)createViews
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 30);
    layout.footerReferenceSize = CGSizeMake(SCREEN_WIDTH, [XCZCollectionCell getHorizonalGap]);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor colorWithRGBA:0xFFFFFFFF];
    [collectionView registerClass:[XCZCollectionCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
    [collectionView registerClass:[XCZCollectionSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderViewReuseIdentifier];
    [collectionView registerClass:[XCZCollectionSectionFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:FooterViewReuseIdentifier];
    self.collectionView = collectionView;
    [self.view addSubview:collectionView];
    
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Public Interface

#pragma mark - User Interface

#pragma mark - SomeDelegate

#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    XCZCollection *collection = self.collections[indexPath.section][indexPath.item];
    XCZCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    [cell updateWithCollection:collection indexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.collectionKinds.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.collections[section] count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width;
    static CGFloat height;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        XCZCollection *collection = self.collections[indexPath.section][indexPath.item];
        XCZCollectionCell *cell = [[XCZCollectionCell alloc] initWithFrame:CGRectZero];
        [cell updateWithCollection:collection indexPath:indexPath];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        height = size.height;
    });
    
    if (indexPath.item % 4 == 0 || indexPath.item % 4 == 3) {
        width = [XCZCollectionCell getImageWidth] + [XCZCollectionCell getHorizonalGap] * 1.5;
    } else {
        width = [XCZCollectionCell getImageWidth] + [XCZCollectionCell getHorizonalGap] * 1;
    }
    
    return CGSizeMake(width, height);
}

// Section header
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        XCZCollectionKind *collectionKind = self.collectionKinds[indexPath.section];
        XCZCollectionSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderViewReuseIdentifier forIndexPath:indexPath];
        [headerView updateWithTitle:collectionKind.name];
        reusableView = headerView;
    } else if (kind == UICollectionElementKindSectionFooter) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:FooterViewReuseIdentifier forIndexPath:indexPath];
    }
    
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    XCZCollection *collection = self.collections[indexPath.section][indexPath.item];
    UIViewController *controller = [[XCZCollectionWorksViewController alloc] initWithCollection:collection];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Internal Helpers

#pragma mark - Getters & Setters

- (NSArray *)collectionKinds
{
    if (!_collectionKinds) {
        _collectionKinds = [XCZCollectionKind getAll];
    }
    
    return _collectionKinds;
}

- (NSArray *)collections
{
    if (!_collections) {
        NSMutableArray *tempCollections = [NSMutableArray new];
        for (XCZCollectionKind *collectionKind in self.collectionKinds) {
            [tempCollections addObject:[XCZCollection getByCollectionKind:collectionKind.id]];
        }
        _collections = tempCollections;
    }
    
    return _collections;
}

@end
