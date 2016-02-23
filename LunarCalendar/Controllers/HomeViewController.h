//
//  HomeViewController.h
//  TabbedExample
//
//  Created by Hai Trieu on 4/1/13.
//  Copyright (c) 2013 Adriaenssen BVBA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController {
    __weak IBOutlet UIView *placeHolderView;
    __weak IBOutlet UILabel *vietnameseYear;
    __weak IBOutlet UILabel *vietnameseMonth;
    __weak IBOutlet UILabel *vietnameseDay;
    __weak IBOutlet UILabel *lblClock;
    __weak IBOutlet UILabel *vietnameseHour;
    __weak IBOutlet UILabel *lunarDay;
    __weak IBOutlet UILabel *lunarMonthYear;
    __weak IBOutlet UILabel *lunarYear;
    __weak IBOutlet UILabel *horoscopeHour;
    
    NSTimer  *updateClockTimer;
    NSDateFormatter *clockFommater;
}

@property (nonatomic, strong) NSMutableDictionary *dayInfo;
@property (nonatomic, strong) NSDate *currentDate;

@end
