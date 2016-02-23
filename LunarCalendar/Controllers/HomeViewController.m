//
//  HomeViewController.m
//  TabbedExample
//
//  Created by Hai Trieu on 4/1/13.
//  Copyright (c) 2013 Adriaenssen BVBA. All rights reserved.
//
#import "Lunar.h"
#import "HomeViewController.h"
#import "MainImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface HomeViewController ()
-(NSDateComponents*)extractCurrentDate;
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (_currentDate == nil) {
        self.currentDate = [NSDate date];
    }

//    self.navigationItem.title = @"Trang chủ";
//    headerTitle.text = @"Trang chủ";
    
//    headerTitle.font = [UIFont boldSystemFontOfSize:24];
    self.navigationController.navigationBarHidden = YES;
    
    clockFommater = [[NSDateFormatter alloc] init];
    [clockFommater setTimeZone:[NSTimeZone systemTimeZone]];
    [clockFommater setDateFormat:@"HH:mm"];
    updateClockTimer =  [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(countUpH) userInfo:nil repeats: YES];
    
    
    UIImage *logo = [UIImage imageNamed:@"logo_top"];
    UIImageView *logoApp = [[UIImageView alloc] initWithFrame:CGRectMake(7, 9, logo.size.width, logo.size.height)];
    logoApp.image = logo;
    
    UIImage *todayBg = [UIImage imageNamed:@"btn_today"];
    UIButton *today = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - todayBg.size.width - 7, 7, todayBg.size.width, todayBg.size.height)];
    [today setBackgroundImage:todayBg forState:UIControlStateNormal];
    [today setTitle:@"Hôm nay" forState:UIControlStateNormal];
    today.titleLabel.font = [UIFont systemFontOfSize:13];
    [today addTarget:self action:@selector(viewToday) forControlEvents:UIControlEventTouchUpInside];
    [self extractCurrentDate];

    [self.navigationController.navigationBar addSubview:today];
    [self.navigationController.navigationBar addSubview:logoApp];

    
	// -----------------------------
    // One finger, swipe right
	// -----------------------------
    UISwipeGestureRecognizer *oneFingerSwipeRight =
  	[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeRight:)];
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [placeHolderView addGestureRecognizer:oneFingerSwipeRight];
    
	// -----------------------------
	// One finger, swipe left
	// -----------------------------
    UISwipeGestureRecognizer *oneFingerSwipeLeft =
  	[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeLeft:)];
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [placeHolderView addGestureRecognizer:oneFingerSwipeLeft];
}

- (void)oneFingerSwipeRight:(UISwipeGestureRecognizer *)recognizer
{
    for (UIView *i in self.view.subviews){
        if ([i isKindOfClass:[MainImageView class]]) {
            [i removeFromSuperview];
        }
    }
    CATransition *transition = [CATransition animation];
    transition.duration = 0.15;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    transition.delegate = self;
    
    [placeHolderView.layer addAnimation:transition forKey:nil];
    self.currentDate = [self.currentDate dateByAddingTimeInterval:(-1)*60*60*24];
    [self extractCurrentDate];
    
}

/*--------------------------------------------------------------
 * One finger, swipe left
 *-------------------------------------------------------------*/
- (void)oneFingerSwipeLeft:(UISwipeGestureRecognizer *)recognizer
{
    for (UIView *i in self.view.subviews){
        if ([i isKindOfClass:[MainImageView class]]) {
            [i removeFromSuperview];
        }
    }
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.15;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    transition.delegate = self;
    [placeHolderView.layer addAnimation:transition forKey:nil];
    self.currentDate = [self.currentDate dateByAddingTimeInterval:60*60*24];
    [self extractCurrentDate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSDateComponents*)extractCurrentDate{
    unsigned units = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:units fromDate:_currentDate];
    _dayInfo = [Lunar getHoroscopeDayInfo:[components day] :[components month] :[components year]];
    if ([components weekday] == 1) {
        [_dayInfo setObject:@"Chủ nhật" forKey:@"WeekDay"];
    }
    else{
        [_dayInfo setObject:[NSString stringWithFormat:@"Thứ %ld",(long)[components weekday]] forKey:@"WeekDay"];
    }
    vietnameseDay.text = [_dayInfo objectForKey:@"DayOfVietnamese"];
    vietnameseMonth.text = [_dayInfo objectForKey:@"MonthOfVietnamese"];
    vietnameseYear.text = [_dayInfo objectForKey:@"YearOfVietnamese"];
    horoscopeHour.text = [[NSMutableString stringWithFormat:@"%@",[_dayInfo objectForKey:@"HoroscopeHours"]] stringByReplacingOccurrencesOfString:@" - " withString:@", "];
    NSArray *lunarCalendar = [_dayInfo objectForKey:@"Lunar"];
    lunarDay.text = [[lunarCalendar objectAtIndex:0] stringValue];
    lunarMonthYear.text = [NSString stringWithFormat:@"%@",[lunarCalendar objectAtIndex:1]];
    lunarYear.text = [NSString stringWithFormat:@"%@",[lunarCalendar objectAtIndex:2]];
    
//    [placeHolderView addSubview:[[MainImageView alloc] initWithDate:_dayInfo]];
    [placeHolderView addSubview:[[MainImageView alloc] initWithFrame:placeHolderView.frame andDayInfo:_dayInfo]];
    return components;
}

-(void)countUpH{
    unsigned units = NSHourCalendarUnit;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [gregorian components:units fromDate:now];
    lblClock.text = [clockFommater stringFromDate:now];
    switch ([components hour]) {
        case 0:
            vietnameseHour.text = @"Giờ Tý";
            break;
        case 1:
            vietnameseHour.text = @"Giờ Sửu";
            break;
        case 2:
            vietnameseHour.text = @"Giờ Sửu";
            break;
        case 3:
            vietnameseHour.text = @"Giờ Dần";
            break;
        case 4:
            vietnameseHour.text = @"Giờ Dần";
            break;
        case 5:
            vietnameseHour.text = @"Giờ Mão";
            break;
        case 6:
            vietnameseHour.text = @"Giờ Mão";
            break;
        case 7:
            vietnameseHour.text = @"Giờ Thìn";
            break;
        case 8:
            vietnameseHour.text = @"Giờ Thìn";
            break;
        case 9:
            vietnameseHour.text = @"Giờ Tỵ";
            break;
        case 10:
            vietnameseHour.text = @"Giờ Tỵ";
            break;
        case 11:
            vietnameseHour.text = @"Giờ Ngọ";
            break;
        case 12:
            vietnameseHour.text = @"Giờ Ngọ";
            break;
        case 13:
            vietnameseHour.text = @"Giờ Mùi";
            break;
        case 14:
            vietnameseHour.text = @"Giờ Mùi";
            break;
        case 15:
            vietnameseHour.text = @"Giờ Thân";
            break;
        case 16:
            vietnameseHour.text = @"Giờ Thân";
            break;
        case 17:
            vietnameseHour.text = @"Giờ Dậu";
            break;
        case 18:
            vietnameseHour.text = @"Giờ Dậu";
            break;
        case 19:
            vietnameseHour.text = @"Giờ Tuất";
            break;
        case 20:
            vietnameseHour.text = @"Giờ Tuất";
            break;
        case 21:
            vietnameseHour.text = @"Giờ Hợi";
            break;
        case 22:
            vietnameseHour.text = @"Giờ Hợi";
            break;
        case 23:
            vietnameseHour.text = @"Giờ Tý";
            break;
        default:
            break;
    }
}

-(void)viewToday{
    NSDate *today = [NSDate date];
    if ([self.currentDate compare:today] == NSOrderedSame) {
        return;
        
    } else {
        for (UIView *i in self.view.subviews){
            if ([i isKindOfClass:[MainImageView class]]) {
                [i removeFromSuperview];
            }
        }
        if ([self.currentDate compare:today] == NSOrderedAscending) {
            CATransition *transition = [CATransition animation];
            transition.duration = 0.15;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionPush;
            transition.subtype =kCATransitionFromRight;
            transition.delegate = self;
            [placeHolderView.layer addAnimation:transition forKey:nil];
        } else {
            CATransition *transition = [CATransition animation];
            transition.duration = 0.15;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionPush;
            transition.subtype =kCATransitionFromLeft;
            transition.delegate = self;
            
            [placeHolderView.layer addAnimation:transition forKey:nil];
        }
        self.currentDate = today;
        [self extractCurrentDate];
    }
}
@end
