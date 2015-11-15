//
//  XCZCollectionWorksViewController.m
//  xcz
//
//  Created by hustlzp on 15/11/14.
//  Copyright © 2015年 Zhipeng Liu. All rights reserved.
//

#import "XCZWork.h"
#import "XCZCollection.h"
#import "XCZCollectionWorksViewController.h"

@interface XCZCollectionWorksViewController ()

@property (nonatomic) NSInteger collectionId;
@property (strong, nonatomic) XCZCollection *collection;
@property (strong, nonatomic) NSArray *works;

@end

@implementation XCZCollectionWorksViewController

#pragma mark - LifeCycle

- (instancetype)initWithCollectionId:(NSInteger)collectionId
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.collectionId = collectionId;
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - View Helpers

- (void)createViews
{
    
}

#pragma mark - Public Interface

#pragma mark - User Interface

#pragma mark - SomeDelegate

#pragma mark - Internal Helpers

#pragma mark - Getters & Setters

- (XCZCollection *)collection
{
    if (!_collection) {
        _collection = [XCZCollection getById:self.collectionId];
    }
    
    return _collection;
}

- (NSArray *)works
{
    if (!_works) {
        _works = [XCZWork getByCollectionId:self.collectionId];
    }
    
    return _works;
}

@end
