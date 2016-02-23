//
//  MainImageView.h
//  Horoscope
//
//  Created by Hai Trieu on 4/1/13.
//  Copyright (c) 2013 Adriaenssen BVBA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainImageView : UIView

@property (nonatomic, retain) NSMutableDictionary* dayInfo;

- (id)initWithDate:(NSMutableDictionary*)dayInfo;
- (id)initWithFrame:(CGRect)frame andDayInfo:(NSMutableDictionary*)dayInfo;
@end
