//
//  JBBarChartViewController.m
//  JBChartViewDemo
//
//  Created by Terry Worona on 11/5/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "JBBarChartViewController.h"

// Views
#import "JBBarChartView.h"
#import "JBChartHeaderView.h"
//#import "JBBarChartFooterView.h"
//#import "JBChartInformationView.h"
#import "PGSessionFooterView.h"
#import "PGSessionInformationView.h"

// Numerics
CGFloat const kJBBarChartViewControllerChartHeight = 250.0f;
CGFloat const kJBBarChartViewControllerChartPadding = 0.0f;
CGFloat const kJBBarChartViewControllerChartHeaderHeight = 40.0f;
CGFloat const kJBBarChartViewControllerChartHeaderPadding = 10.0f;
CGFloat const kJBBarChartViewControllerChartFooterHeight = 25.0f;
CGFloat const kJBBarChartViewControllerChartFooterPadding = 5.0f;
CGFloat const kJBBarChartViewControllerBarPadding = 1;
NSInteger const kJBBarChartViewControllerNumBars = 12;
NSInteger const kJBBarChartViewControllerMaxBarHeight = 10;
NSInteger const kJBBarChartViewControllerMinBarHeight = 5;

// Strings
NSString * const kJBBarChartViewControllerNavButtonViewKey = @"view";

@interface JBBarChartViewController () <JBBarChartViewDelegate, JBBarChartViewDataSource>
{
    int currentIndex;
}

@property (nonatomic, strong) JBBarChartView *barChartView;
@property (nonatomic, strong) PGSessionInformationView *informationView;
@property (nonatomic, strong) NSArray *chartData;
@property (nonatomic, strong) NSArray *monthlySymbols;

// Buttons
- (void)chartToggleButtonPressed:(id)sender;

// Data
- (void)initFakeData;

@end

@implementation JBBarChartViewController

#pragma mark - Alloc/Init

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self initFakeData];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
 
    if (self)
    {
        [self initFakeData];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 
    if (self)
    {
        [self initFakeData];
    }
    
    return self;
}

#pragma mark - Date

- (void)initFakeData
{
    NSMutableArray *mutableChartData = [NSMutableArray array];
    currentIndex = -1;
    
    for (int i = 0; i < kJBBarChartViewControllerNumBars-1; i++)
    {
        NSInteger delta = (kJBBarChartViewControllerNumBars - abs((kJBBarChartViewControllerNumBars - i) - i)) + 2;
        [mutableChartData addObject:[NSNumber numberWithInt:0.1 * MAX((delta * kJBBarChartViewControllerMinBarHeight), arc4random() % (delta * kJBBarChartViewControllerMaxBarHeight))]];
    }

    [mutableChartData addObject:[NSNumber numberWithInt:0]];
    _chartData = [NSArray arrayWithArray:mutableChartData];
    _monthlySymbols = [[[NSDateFormatter alloc] init] shortMonthSymbols];
}

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

    self.informationView = [[PGSessionInformationView alloc] initWithFrame:CGRectMake(0,
                                                                                    self.navigationController.navigationBar.frame.size.height + 20,
                                                                                    self.view.bounds.size.width,
                                                                                    100)];

    self.informationView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.informationView];

    
    
    ////////////////////////////////////////////////////
    
    
    
    self.barChartView = [[JBBarChartView alloc] init];
    self.barChartView.frame = CGRectMake(kJBBarChartViewControllerChartPadding,
                                         CGRectGetMaxY(self.informationView.frame),
                                         self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2),
                                         self.view.bounds.size.height - CGRectGetMaxY(self.informationView.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame) + 20);

    self.barChartView.delegate = self;
    self.barChartView.dataSource = self;
//    self.barChartView.backgroundColor = [UIColor redColor];
    
    
    
    ////////////////////////////////////////////////////
    
    
    
    JBChartHeaderView *headerView = [[JBChartHeaderView alloc] initWithFrame:CGRectMake(kJBBarChartViewControllerChartPadding,
                                                                                        0,//ceil(self.view.bounds.size.height * 0.5) - ceil(kJBBarChartViewControllerChartHeaderHeight * 0.5),
                                                                                        self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2),
                                                                                        kJBBarChartViewControllerChartHeaderHeight)];

    headerView.separatorColor = [UIColor clearColor];
//    headerView.backgroundColor = [UIColor blueColor];
    
    
    self.barChartView.headerView = headerView;
    
    

    ////////////////////////////////////////////////////
    
    
    
    PGSessionFooterView *footerView = [[PGSessionFooterView alloc] initWithFrame:CGRectMake(kJBBarChartViewControllerChartPadding,
                                                                                              ceil(self.view.bounds.size.height * 0.5) - ceil(kJBBarChartViewControllerChartFooterHeight * 0.5),
                                                                                              self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2),
                                                                                              kJBBarChartViewControllerChartFooterHeight)];

    footerView.values = self.chartData;
    footerView.backgroundColor = MAIN_APP_COLOR;//[UIColor yellowColor];
    self.barChartView.footerView = footerView;
    
    [self.view addSubview:self.barChartView];
    
    [self.barChartView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.barChartView setState:JBChartViewStateExpanded];
}

#pragma mark - JBBarChartViewDelegate

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtAtIndex:(NSUInteger)index
{
    CGFloat height = [[self.chartData objectAtIndex:index] floatValue];
    
    return height;
}

#pragma mark - JBBarChartViewDataSource

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return kJBBarChartViewControllerNumBars;
}

- (NSUInteger)barPaddingForBarChartView:(JBBarChartView *)barChartView
{
    return kJBBarChartViewControllerBarPadding;
}

- (UIView *)barChartView:(JBBarChartView *)barChartView barViewAtIndex:(NSUInteger)index
{
    UIView *barView = [[UIView alloc] init];
    barView.backgroundColor = MAIN_APP_COLOR;
    
    return barView;
}

- (UIColor *)barSelectionColorForBarChartView:(JBBarChartView *)barChartView
{
    return [UIColor whiteColor];
}

- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    NSNumber *valueNumber = [self.chartData objectAtIndex:index];
 
    if (currentIndex != index)
    {
        currentIndex = index;
        
        NSMutableArray *array = [NSMutableArray new];
        
        for (int i = 0; i < valueNumber.intValue; i++)
        {
            [array addObject:[NSNumber numberWithInt:i+1]];
        }
        
        [self.informationView setPlayers:array];
    }
    
    
//    [self.informationView setValueText:[NSString stringWithFormat:kJBStringLabelDegreesFahrenheit, [valueNumber intValue], kJBStringLabelDegreeSymbol] unitText:nil];
//    [self.informationView setTitleText:kJBStringLabelWorldwideAverage];
//    [self.informationView setHidden:NO animated:YES];
    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
    [self.tooltipView setText:[[self.monthlySymbols objectAtIndex:index] uppercaseString]];
}

- (void)didUnselectBarChartView:(JBBarChartView *)barChartView
{
//    [self.informationView setPlayers:nil];
//    [self.informationView setHidden:YES animated:YES];
    [self setTooltipVisible:NO animated:YES];
}

#pragma mark - Overrides

- (JBChartView *)chartView
{
    return self.barChartView;
}

@end