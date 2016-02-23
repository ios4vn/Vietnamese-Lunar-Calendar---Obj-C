//
//  Lunar.h
//  ConvertLunar
//
//  Created by Hai Trieu on 3/6/13.
//  Copyright (c) 2013 Hai Trieu. All rights reserved.
//

#import <Foundation/Foundation.h>
#define LOCAL_TIMEZONE 7
#define PI M_PI
@interface Lunar : NSObject {

}

+ (double)UniversalToJD:(int)day :(int)month :(int)year;
+ (NSMutableArray*)UniversalFromJD:(double)JD;
+ (NSMutableArray*)LocalFromJD:(double)JD;
+ (double)LocalToJD:(int)day :(int)month :(int)year;
+ (double)NewMoon:(int)k;
+ (double)SunLongitude:(double)jdn;
+ (NSMutableArray*)LunarMonth11:(int)Y;
+ (NSMutableArray*)LunarYear:(int)Y;

+ (void)initLeapYear:(NSMutableArray*)ret;
+ (NSMutableArray*)Solar2Lunar:(int)D :(int)M :(int)Y;
+(NSMutableArray*) convertLunar2Solar:(int)lunarDay lunarMonth:(int)lunarMonth lunarYear:(int)lunarYear lunarLeap:(int)lunarLeap timeZone:(int)timeZone;
+(NSMutableArray*) convertSolar2Lunar:(int)dd mm:(int)mm yy:(int)yy timeZone:(int)timeZone;
+(int)jdFromDate:(int)dd mm:(int)mm yy:(int)yy;
+(NSMutableArray*)jdToDate:(int)jd;
+(int)getNewMoonDay:(int)k timeZone:(int)timeZone;
+(int)getSunLongitude:(int)jdn timeZone:(int)timeZone;
+(int)getLeapMonthOffset:(int)a11 timeZone:(int)timeZone;
+(int)getLunarMonth11:(int)yy timeZone:(int)timeZone;

+ (NSString*)dayOfWeek:(int)day :(int)month :(int)year;
+ (NSString*)dayOfVietnamese:(int)day :(int)month :(int)year;
+ (NSString*)monthOfVietnames:(int)day :(int)month :(int)year;
+ (NSString*)yearOfVietnames:(int)year;
+ (NSMutableDictionary*)getHoroscopeDayInfo:(int)D :(int)M :(int)Y;
+(BOOL)enoughMonthLunar:(int)lunarMonth :(int)year;
+(NSString*)indexToDirection:(int)index;

@end
