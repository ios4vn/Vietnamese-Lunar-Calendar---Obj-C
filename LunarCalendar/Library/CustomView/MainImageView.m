//
//  MainImageView.m
//  Horoscope
//
//  Created by Hai Trieu on 4/1/13.
//  Copyright (c) 2013 Adriaenssen BVBA. All rights reserved.
//

#import "MainImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MainImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithDate:(NSMutableDictionary*)dayInfo
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 267)];
    if (self) {
        _dayInfo = dayInfo;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andDayInfo:(NSMutableDictionary*)dayInfo{
    self = [super initWithFrame:frame];
    if (self) {
        _dayInfo = dayInfo;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/

 - (void)drawRect:(CGRect)rect
{

    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"pic%d", arc4random()%13]]];
//    bg.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    bg.frame = rect;
    [self addSubview:bg];
    UIImageView *firstNumber = [[UIImageView alloc] init];
    UIImageView *secondNumber = [[UIImageView alloc] init];
    int _solarDay = [[_dayInfo objectForKey:@"Day"] intValue];
    firstNumber.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",_solarDay%10]];
    UILabel *solarMonthYear = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 45)];
    solarMonthYear.text = [NSString stringWithFormat:@"Tháng %@ năm %@",[_dayInfo objectForKey:@"Month"],[_dayInfo objectForKey:@"Year"]];
    solarMonthYear.textAlignment = UITextAlignmentCenter;
    solarMonthYear.font = [UIFont systemFontOfSize:23];
    solarMonthYear.textColor = [UIColor whiteColor];
    solarMonthYear.backgroundColor = [UIColor clearColor];
    solarMonthYear.layer.shadowColor = [[UIColor blackColor] CGColor];
    solarMonthYear.layer.shadowRadius = 4.0f;
    solarMonthYear.layer.shadowOpacity = .9;
    solarMonthYear.layer.shadowOffset = CGSizeZero;
    solarMonthYear.layer.masksToBounds = NO;
    [self addSubview:solarMonthYear];
    
    UILabel *weekday = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, self.frame.size.width, 45)];
    weekday.text = [_dayInfo objectForKey:@"WeekDay"];
    weekday.textAlignment = UITextAlignmentCenter;
    weekday.font = [UIFont boldSystemFontOfSize:28];
    weekday.textColor = [UIColor whiteColor];
    weekday.backgroundColor = [UIColor clearColor];
    weekday.layer.shadowColor = [[UIColor blackColor] CGColor];
    weekday.layer.shadowRadius = 4.0f;
    weekday.layer.shadowOpacity = .9;
    weekday.layer.shadowOffset = CGSizeZero;
    weekday.layer.masksToBounds = NO;
    [self addSubview:weekday];
    weekday.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    UIImageView *bgComment = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 50, self.frame.size.width, 50)];
    bgComment.image = [UIImage imageNamed:@"eclip.png"];
    [self addSubview:bgComment];
    UILabel *comment = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 50, self.frame.size.width, 50)];
    comment.textAlignment = UITextAlignmentCenter;
    comment.font = [UIFont boldSystemFontOfSize:11];
    comment.numberOfLines = 0;
    comment.lineBreakMode = UILineBreakModeWordWrap;
    comment.textColor = [UIColor whiteColor];
    comment.backgroundColor = [UIColor clearColor];
    comment.text = [_dayInfo objectForKey:@"Quotation"];
    [self addSubview:comment];
    if (_solarDay < 10) {
        firstNumber.frame = CGRectMake(105, 50, 110, 110);
        [self addSubview:firstNumber];
    }
    else{
        secondNumber.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",(int)_solarDay/10]];
        firstNumber.frame = CGRectMake(146, 50, 110, 110);
        secondNumber.frame = CGRectMake(65, 50, 110, 110);
        [self addSubview:firstNumber];
        [self addSubview:secondNumber];
    }
}


@end
