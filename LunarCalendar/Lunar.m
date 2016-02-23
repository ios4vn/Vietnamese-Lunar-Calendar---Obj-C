//
//  Lunar.m
//  ConvertLunar
//
//  Created by Hai Trieu on 3/6/13.
//  Copyright (c) 2013 Hai Trieu. All rights reserved.
//  Tính ngũ hành http://diendan.lyhocdongphuong.org.vn/bai-viet/1457-cong-thuc-tinh-nhanh-bang-lacthu-hoa-giap/
//  Tính hướng xuất hành http://hoivadap.vn/posts/view/xu_t_hanh.html#.UVvbcaXWFSU
//  Tính giờ hoàng đạo http://anhem.eu/ae/images/idoc/hoangdao.pdf
//

#import "Lunar.h"
#import "Quotations.h"

@interface Lunar ()

@end

@implementation Lunar

+ (double)UniversalToJD:(int)day :(int)month :(int)year{
    double JD;
    
    if (year > 1582 || (year == 1582 && month > 10) || (year == 1582 && month == 10 && day > 14)) {
		JD = 367*year - floor(7*(year+floor((month+9)/12))/4) - floor(3*(floor((year+(month-9)/7)/100)+1)/4) + floor(275*month/9)+day+1721028.5;
	} else {
		JD = 367*year - floor(7*(year+5001+floor((month-9)/7))/4) + floor(275*month/9)+day+1729776.5;
	}
	return JD;
    
}

+ (NSMutableArray*)UniversalFromJD:(double)JD{
    int Z, A, alpha, B, C, D, E, dd, mm, yyyy;
	double F;
	Z = floor(JD+0.5);
	F = (JD+0.5)-Z;
	if (Z < 2299161) {
        A = Z;
	} else {
        alpha = floor((Z-1867216.25)/36524.25);
        A = Z + 1 + alpha - floor(alpha/4);
	}
	B = A + 1524;
	C = floor( (B-122.1)/365.25);
	D = floor( 365.25*C );
	E = floor( (B-D)/30.6001 );
	dd = floor(B - D - floor(30.6001*E) + F);
	if (E < 14) {
        mm = E - 1;
	} else {
        mm = E - 13;
	}
	if (mm < 3) {
        yyyy = C - 4715;
	} else {
        yyyy = C - 4716;
	}
    NSMutableArray *ret =  [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%d",dd],[NSString stringWithFormat:@"%d",mm],[NSString stringWithFormat:@"%d",yyyy], nil];
	return ret;
}

+ (NSMutableArray*)LocalFromJD:(double)JD{
    return [self UniversalFromJD:JD + LOCAL_TIMEZONE/24.0];
}


+ (double)LocalToJD:(int)day :(int)month :(int)year{
    return [self UniversalToJD:day :month :year] - LOCAL_TIMEZONE/24;
}


+ (double)NewMoon:(int)k{
    double T = k/1236.85; // Time in Julian centuries from 1900 January 0.5
	double T2 = T * T;
	double T3 = T2 * T;
	double dr = PI/180;
	double Jd1 = 2415020.75933 + 29.53058868*k + 0.0001178*T2 - 0.000000155*T3;
	Jd1 = Jd1 + 0.00033*sin((166.56 + 132.87*T - 0.009173*T2)*dr); // Mean new moon
	double M = 359.2242 + 29.10535608*k - 0.0000333*T2 - 0.00000347*T3; // Sun's mean anomaly
	double Mpr = 306.0253 + 385.81691806*k + 0.0107306*T2 + 0.00001236*T3; // Moon's mean anomaly
	double F = 21.2964 + 390.67050646*k - 0.0016528*T2 - 0.00000239*T3; // Moon's argument of latitude
	double C1=(0.1734 - 0.000393*T)*sin(M*dr) + 0.0021*sin(2*dr*M);
	C1 = C1 - 0.4068*sin(Mpr*dr) + 0.0161*sin(dr*2*Mpr);
	C1 = C1 - 0.0004*sin(dr*3*Mpr);
	C1 = C1 + 0.0104*sin(dr*2*F) - 0.0051*sin(dr*(M+Mpr));
	C1 = C1 - 0.0074*sin(dr*(M-Mpr)) + 0.0004*sin(dr*(2*F+M));
	C1 = C1 - 0.0004*sin(dr*(2*F-M)) - 0.0006*sin(dr*(2*F+Mpr));
	C1 = C1 + 0.0010*sin(dr*(2*F-Mpr)) + 0.0005*sin(dr*(2*Mpr+M));
	double deltat;
	if (T < -11) {
		deltat= 0.001 + 0.000839*T + 0.0002261*T2 - 0.00000845*T3 - 0.000000081*T*T3;
	} else {
		deltat= -0.000278 + 0.000265*T + 0.000262*T2;
	};
	double JdNew = Jd1 + C1 - deltat;
	return JdNew;
}

+ (double)SunLongitude:(double)jdn{
    double T = (jdn - 2451545.0 ) / 36525; // Time in Julian centuries from 2000-01-01 12:00:00 GMT
	double T2 = T*T;
	double dr = PI/180; // degree to radian
	double M = 357.52910 + 35999.05030*T - 0.0001559*T2 - 0.00000048*T*T2; // mean anomaly, degree
	double L0 = 280.46645 + 36000.76983*T + 0.0003032*T2; // mean longitude, degree
	double DL = (1.914600 - 0.004817*T - 0.000014*T2)*sin(dr*M);
	DL = DL + (0.019993 - 0.000101*T)*sin(dr*2*M) + 0.000290*sin(dr*3*M);
	double L = L0 + DL; // true longitude, degree
	L = L*dr;
	L = L - PI*2*(floor(L/(PI*2))); // Normalize to (0, 2*PI)
	return L;
}

+ (NSMutableArray*)LunarMonth11:(int)Y{
    double off = [self LocalToJD:31 :12 :Y] - 2415021.076998695;
	int k = floor(off / 29.530588853);
	double jd = [self NewMoon:k];
    NSMutableArray *ret = [self LocalFromJD:jd];
	double sunLong = [self SunLongitude:[self LocalToJD:[[ret objectAtIndex:0] intValue] :[[ret objectAtIndex:1] intValue] :[[ret objectAtIndex:2] intValue]]];
    
	if (sunLong > 3*PI/2) {
		jd = [self NewMoon:k - 1];
	}
	return [self LocalFromJD:jd];
}
+ (NSMutableArray*)LunarYear:(int)Y{
    NSMutableArray *ret = nil;
    NSMutableArray *month11A = [self LunarMonth11:Y-1];
	double jdMonth11A = [self LocalToJD:[[month11A objectAtIndex:0] intValue] :[[month11A objectAtIndex:1] intValue]:[[month11A objectAtIndex:2] intValue]];
	int k = (int)floor(0.5 + (jdMonth11A - 2415021.076998695) / 29.530588853);
    NSMutableArray *month11B = [self LunarMonth11:Y];
    
	double off = [self LocalToJD:[[month11B objectAtIndex:0] intValue] :[[month11B objectAtIndex:1] intValue]:[[month11B objectAtIndex:2] intValue]] - jdMonth11A;
	BOOL leap = off > 365.0;
	if (!leap) {
		ret = [[NSMutableArray alloc] initWithCapacity:13];
        for (NSUInteger k = 0; k < 13; ++k) {
            [ret addObject:[NSNull null]];
        }
	} else {
		ret = [[NSMutableArray alloc] initWithCapacity:14];
        for (NSUInteger k = 0; k < 14; ++k) {
            [ret addObject:[NSNull null]];
        }
	}
    [ret replaceObjectAtIndex:0 withObject:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%d",[[month11A objectAtIndex:0] intValue]],[NSString stringWithFormat:@"%d",[[month11A objectAtIndex:1] intValue]],[NSString stringWithFormat:@"%d",[[month11A objectAtIndex:2] intValue]],@"0",@"0",nil]];
    [ret replaceObjectAtIndex:[ret count] - 1 withObject:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%d",[[month11B objectAtIndex:0] intValue]],[NSString stringWithFormat:@"%d",[[month11B objectAtIndex:1] intValue]],[NSString stringWithFormat:@"%d",[[month11B objectAtIndex:2] intValue]],@"0",@"0",nil]];
    
	for (int i = 1; i < [ret count] - 1; i++) {
		double nm = [self NewMoon:k+i];
        NSMutableArray *a = [self LocalFromJD:nm];
        [ret replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%d",[[a objectAtIndex:0] intValue]],[NSString stringWithFormat:@"%d",[[a objectAtIndex:1] intValue]],[NSString stringWithFormat:@"%d",[[a objectAtIndex:2] intValue]],@"0",@"0",nil]];
	}
	for (int i = 0; i < [ret count]; i++) {
        NSMutableArray *tmp = [ret objectAtIndex:i];
        [tmp replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%d",(i+11)%12]];
	}
	if (leap) {
        [self initLeapYear:ret];
	}
	return ret;
}

+ (void)initLeapYear:(NSMutableArray*)ret{
    NSMutableArray *sunLongitudes = [[NSMutableArray alloc] initWithCapacity:[ret count]];
    for (NSUInteger k = 0; k < [ret count]; k++) {
        [sunLongitudes addObject:[NSNull null]];
    }
    
	for (int i = 0; i < [ret count]; i++) {
		NSMutableArray *a = [ret objectAtIndex:i];
		double jdAtMonthBegin = [self LocalToJD:[[a objectAtIndex:0] intValue] :[[a objectAtIndex:1] intValue] :[[a objectAtIndex:2] intValue]];
        [sunLongitudes replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%f",[self SunLongitude:jdAtMonthBegin]]];
	}
	BOOL found = false;
	for (int i = 0; i < [ret count]; i++) {
		if (found) {
            NSMutableArray *tmp = [ret objectAtIndex:i];
            [tmp replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%d",(i+10)%12]];
			continue;
		}
        double sl1 = [[sunLongitudes objectAtIndex:i] doubleValue];
        double sl2 = [[sunLongitudes objectAtIndex:i+1] doubleValue];
		BOOL hasMajorTerm = floor(sl1/PI*6) != floor(sl2/PI*6);
		if (!hasMajorTerm) {
			found = true;
            NSMutableArray *tmp = [ret objectAtIndex:i];
            [tmp replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%d",(i+10)%12]];
            [tmp replaceObjectAtIndex:4 withObject:@"1"];
		}
	}
}

+ (NSMutableArray*)Solar2Lunar:(int)D :(int)M :(int)Y{
    int yy = Y;
	NSMutableArray *ly = [self LunarYear:Y];
    int lenght = [ly count];
	NSMutableArray *month11 = [ly objectAtIndex:lenght - 1];
	double jdToday = [self LocalToJD:D :M :Y];
    double jdMonth11 = [self LocalToJD:[[month11 objectAtIndex:0] intValue] :[[month11 objectAtIndex:1] intValue] :[[month11 objectAtIndex:2] intValue]];
	if (jdToday >= jdMonth11) {
        ly = [self LunarYear:Y + 1];
		yy = Y + 1;
	}
	int i = [ly count] - 1;
    NSMutableArray *tmp = [ly objectAtIndex:i];
	while (jdToday < [self LocalToJD:[[tmp objectAtIndex:0] intValue] :[[tmp objectAtIndex:1] intValue] :[[tmp objectAtIndex:2] intValue]] && i >=  1) {
		i--;
        tmp = [ly objectAtIndex:i];
	}
    tmp = [ly objectAtIndex:i];
	int dd = (int)(jdToday -  [self LocalToJD:[[tmp objectAtIndex:0] intValue] :[[tmp objectAtIndex:1] intValue] :[[tmp objectAtIndex:2] intValue]]) + 1;
    int mm = [[tmp objectAtIndex:3] intValue];
	if (mm >= 11) {
		yy--;
	}
    NSMutableArray *result = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%d",dd],[NSString stringWithFormat:@"%d",mm],[NSString stringWithFormat:@"%d",yy],[tmp objectAtIndex:4], nil];
	return result;
}

+(int)jdFromDate:(int)dd mm:(int)mm yy:(int)yy
{
    int a, y, m, jd;
    a = floor((14 - mm) / 12);
    y = yy+4800-a;
    m = mm+12*a-3;
    jd = dd + floor((153*m+2)/5) + 365*y + floor(y/4) - floor(y/100) + floor(y/400) - 32045;
    if (jd < 2299161) {
        jd = dd + floor((153*m+2)/5) + 365*y + floor(y/4) - 32083;
    }    return jd;
}
+(NSMutableArray*)jdToDate:(int)jd
{
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    int a, b, c, d, e, m, day, month, year;
    if (jd > 2299160) { // After 5/10/1582, Gregorian calendar
        a = jd + 32044;
        b = floor((4*a+3)/146097);
        c = a - floor((b*146097)/4);
    } else {
        b = 0;
        c = jd + 32082;
    }
    d = floor((4*c+3)/1461);
    e = c - floor((1461*d)/4);
    m = floor((5*e+2)/153);
    day = e - floor((153*m+2)/5) + 1;
    month = m + 3 - 12*floor(m/10);
    year = b*100 + d - 4800 + floor(m/10);
    [arr addObject:[NSNumber numberWithDouble:day]];
    [arr addObject:[NSNumber numberWithDouble:month]];
    [arr addObject:[NSNumber numberWithDouble:year]];
    return arr;
}

+(int)getNewMoonDay:(int)k timeZone:(int)timeZone
{
    double T, T2, T3, dr, Jd1, M, Mpr, F, C1, deltat,JdNew;
    
    T = k/1236.85; // Time in Julian centuries from 1900 January 0.5
    T2 = T * T;
    T3 = T2 * T;
    dr = PI/180;
    Jd1 = 2415020.75933 + 29.53058868*k + 0.0001178*T2 - 0.000000155*T3;
    Jd1 = Jd1 + 0.00033*sin((166.56 + 132.87*T - 0.009173*T2)*dr); // Mean new moon
    M = 359.2242 + 29.10535608*k - 0.0000333*T2 - 0.00000347*T3; // Sun's mean anomaly
    Mpr = 306.0253 + 385.81691806*k + 0.0107306*T2 + 0.00001236*T3; // Moon's mean anomaly
    F = 21.2964 + 390.67050646*k - 0.0016528*T2 - 0.00000239*T3; // Moon's argument of latitude
    C1=(0.1734 - 0.000393*T)*sin(M*dr) + 0.0021*sin(2*dr*M);
    C1 = C1 - 0.4068*sin(Mpr*dr) + 0.0161*sin(dr*2*Mpr);
    C1 = C1 - 0.0004*sin(dr*3*Mpr);
    C1 = C1 + 0.0104*sin(dr*2*F) - 0.0051*sin(dr*(M+Mpr));
    C1 = C1 - 0.0074*sin(dr*(M-Mpr)) + 0.0004*sin(dr*(2*F+M));
    C1 = C1 - 0.0004*sin(dr*(2*F-M)) - 0.0006*sin(dr*(2*F+Mpr));
    C1 = C1 + 0.0010*sin(dr*(2*F-Mpr)) + 0.0005*sin(dr*(2*Mpr+M));
    if (T < -11) {
        deltat= 0.001 + 0.000839*T + 0.0002261*T2 - 0.00000845*T3 - 0.000000081*T*T3;
    } else {
        deltat= -0.000278 + 0.000265*T + 0.000262*T2;
    };
    JdNew = Jd1 + C1 - deltat;
    return floor(JdNew + 0.5 + timeZone/24.0);
}

+(int)getSunLongitude:(int)jdn timeZone:(int)timeZone
{
    double T, T2, dr, M, L0, DL, L;
    //T = (jdn - 2451545.5 - timeZone/24) / 36525; // Time in Julian centuries from 2000-01-01 12:00:00 GMT
    T = (jdn - 2451545.0 ) / 36525;
    T2 = T*T;
    dr = PI/180; // degree to radian
    M = 357.52910 + 35999.05030*T - 0.0001559*T2 - 0.00000048*T*T2; // mean anomaly, degree
    L0 = 280.46645 + 36000.76983*T + 0.0003032*T2; // mean longitude, degree
    DL = (1.914600 - 0.004817*T - 0.000014*T2)*sin(dr*M);
    DL = DL + (0.019993 - 0.000101*T)*sin(dr*2*M) + 0.000290*sin(dr*3*M);
    L = L0 + DL; // true longitude, degree
    L = L*dr;
    L = L - PI*2*(floor(L/(PI*2))); // Normalize to (0, 2*PI)
    return floor(L / PI * 6);
}

+(int)getLeapMonthOffset:(int)a11 timeZone:(int)timeZone
{
    int k, last, arc, i;
    k = floor((a11 - 2415021.076998695) / 29.530588853 + 0.5);
    last = 0;
    i = 1; // We start with the month following lunar month 11
    arc = [self getSunLongitude:[self getNewMoonDay:k+i timeZone:timeZone ] timeZone:timeZone ];
    do {
        last = arc;
        i++;
        arc = [self getSunLongitude:[self getNewMoonDay:k+i timeZone:timeZone ] timeZone:timeZone ];
    } while (arc != last && i < 14);
    return i-1;
}

+(int)getLunarMonth11:(int)yy timeZone:(int)timeZone
{
    int k, off, nm, sunLong;
    off = [self jdFromDate:31 mm:12 yy:yy] - 2415021;
    k = floor(off / 29.530588853);
    nm = [self getNewMoonDay:k timeZone:timeZone];
    sunLong = [self getSunLongitude:nm timeZone:timeZone]; // sun longitude at local midnight
    if (sunLong >= 9) {
        nm = [self getNewMoonDay:k-1 timeZone:timeZone];
    }
    return nm;
}

+(NSMutableArray*) convertSolar2Lunar:(int)dd mm:(int)mm yy:(int)yy timeZone:(int)timeZone
{
    int k, dayNumber, monthStart, a11, b11, diff, leapMonthDiff, lunarDay, lunarMonth, lunarYear, lunarLeap;
    dayNumber = [self jdFromDate:dd mm:mm yy:yy];
    k = floor((dayNumber - 2415021.076998695) / 29.530588853);
    monthStart = [self getNewMoonDay:k+1 timeZone:timeZone];
    
    if (monthStart > dayNumber) {
        monthStart = [self getNewMoonDay:k timeZone:timeZone];
    }
    a11 = [self getLunarMonth11:yy timeZone:timeZone];
    b11 = a11;
    if (a11 >= monthStart) {
        lunarYear = yy;
        a11 = [self getLunarMonth11:yy-1 timeZone:timeZone];
    } else {
        lunarYear = yy+1;
        b11 = [self getLunarMonth11:yy+1 timeZone:timeZone];
    }
    lunarDay = dayNumber-monthStart+1;
    diff = floor((monthStart - a11)/29);
    lunarLeap = 0;
    lunarMonth = diff+11;
    if (b11 - a11 > 365) {
        leapMonthDiff = [self getLeapMonthOffset:a11 timeZone:timeZone];
        if (diff >= leapMonthDiff) {
            lunarMonth = diff + 10;
            if (diff == leapMonthDiff) {
                lunarLeap = 1;
            }
        }
    }
    if (lunarMonth > 12) {
        lunarMonth = lunarMonth - 12;
    }
    if (lunarMonth >= 11 && diff < 4) {
        lunarYear -= 1;
    }
    NSMutableArray *arr=[[NSMutableArray alloc] init];
    [arr addObject:[NSNumber numberWithDouble:lunarDay]];
    [arr addObject:[NSNumber numberWithDouble:lunarMonth]];
    [arr addObject:[NSNumber numberWithDouble:lunarYear]];
    [arr addObject:[NSNumber numberWithDouble:lunarLeap]];
    
    
    return arr;
}

+(NSMutableArray*) convertLunar2Solar:(int)lunarDay lunarMonth:(int)lunarMonth lunarYear:(int)lunarYear lunarLeap:(int)lunarLeap timeZone:(int)timeZone
{
    double k, a11, b11, off, leapOff, leapMonth, monthStart;
    int jd;
    if (lunarMonth < 11) {
        a11 = [self getLunarMonth11:lunarYear-1 timeZone:timeZone];
        b11 = [self getLunarMonth11:lunarYear timeZone:timeZone];
    } else {
        a11 = [self getLunarMonth11:lunarYear timeZone:timeZone];
        b11 = [self getLunarMonth11:lunarYear+1 timeZone:timeZone];
    }
    off = lunarMonth - 11;
    if (off < 0) {
        off = off + 12;
    }
    if (b11 - a11 > 365) {
        leapOff = [self getLeapMonthOffset:a11 timeZone:timeZone];
        leapMonth = leapOff - 2;
        if (leapMonth < 0) {
            leapMonth += 12;
        }
        if (lunarLeap != 0 && lunarMonth != leapMonth) {
        } else if (lunarLeap != 0 || off >= leapOff) {
            off += 1;
        }
    }
    k = floor(0.5 + (a11 - 2415021.076998695) / 29.530588853);
    monthStart = [self getNewMoonDay:k+off timeZone:timeZone];
    jd=monthStart+lunarDay-1;
    return [self jdToDate:jd];
}



- (NSString*)dayOfWeek:(double)jdDay{
    int X = floor(jdDay + 2.5);
    if (X%7 == 0 ) return @"Thứ bảy";
    if (X%7 == 1 ) return @"Chủ nhật";
    if (X%7 == 2 ) return @"Thứ hai";
    if (X%7 == 3 ) return @"Thứ ba";
    if (X%7 == 4 ) return @"Thứ tư";
    if (X%7 == 5 ) return @"Thứ năm";
    if (X%7 == 6 ) return @"Thứ sáu";
    return @"Chủ nhật";
}

+ (NSString*)dayOfWeek:(int)day :(int)month :(int)year{
    int X = floor([self UniversalToJD:day :month :year] + 2.5);
    if (X%7 == 0 ) return @"Thứ bảy";
    if (X%7 == 1 ) return @"Chủ nhật";
    if (X%7 == 2 ) return @"Thứ hai";
    if (X%7 == 3 ) return @"Thứ ba";
    if (X%7 == 4 ) return @"Thứ tư";
    if (X%7 == 5 ) return @"Thứ năm";
    if (X%7 == 6 ) return @"Thứ sáu";
    return @"Chủ nhật";
}

- (NSString*)dayOfVietnamese:(double)jdDay{
    int CANDay = floor(jdDay + 9.5);
    int CHIDay = floor(jdDay + 1.5);
    NSMutableString *ret = [[NSMutableString alloc] init];
    
    if (CANDay % 10 == 0) [ret appendString:@"Giáp "];
    if (CANDay % 10 == 1) [ret appendString:@"Ất "];
    if (CANDay % 10 == 2) [ret appendString:@"Bính "];
    if (CANDay % 10 == 3) [ret appendString:@"Đinh "];
    if (CANDay % 10 == 4) [ret appendString:@"Mậu "];
    if (CANDay % 10 == 5) [ret appendString:@"Kỷ "];
    if (CANDay % 10 == 6) [ret appendString:@"Canh "];
    if (CANDay % 10 == 7) [ret appendString:@"Tân "];
    if (CANDay % 10 == 8) [ret appendString:@"Nhâm "];
    if (CANDay % 10 == 9) [ret appendString:@"Quý "];
    
    if (CHIDay % 12 == 0) [ret appendString:@"Tý"];
    if (CHIDay % 12 == 1) [ret appendString:@"Sửu"];
    if (CHIDay % 12 == 2) [ret appendString:@"Dần"];
    if (CHIDay % 12 == 3) [ret appendString:@"Mão"];
    if (CHIDay % 12 == 4) [ret appendString:@"Thìn"];
    if (CHIDay % 12 == 5) [ret appendString:@"Tỵ"];
    if (CHIDay % 12 == 6) [ret appendString:@"Ngọ"];
    if (CHIDay % 12 == 7) [ret appendString:@"Mùi"];
    if (CHIDay % 12 == 8) [ret appendString:@"Thân"];
    if (CHIDay % 12 == 9) [ret appendString:@"Dậu"];
    if (CHIDay % 12 == 10) [ret appendString:@"Tuất"];
    if (CHIDay % 12 == 11) [ret appendString:@"Hợi"];
    
    return ret;
}

+ (NSString*)dayOfVietnamese:(int)day :(int)month :(int)year{
    int CANDay = floor([self UniversalToJD:day :month :year] + 9.5);
    int CHIDay = floor([self UniversalToJD:day :month :year] + 1.5);
    NSMutableString *ret = [[NSMutableString alloc] init];
    
    if (CANDay % 10 == 0) [ret appendString:@"Giáp "];
    if (CANDay % 10 == 1) [ret appendString:@"Ất "];
    if (CANDay % 10 == 2) [ret appendString:@"Bính "];
    if (CANDay % 10 == 3) [ret appendString:@"Đinh "];
    if (CANDay % 10 == 4) [ret appendString:@"Mậu "];
    if (CANDay % 10 == 5) [ret appendString:@"Kỷ "];
    if (CANDay % 10 == 6) [ret appendString:@"Canh "];
    if (CANDay % 10 == 7) [ret appendString:@"Tân "];
    if (CANDay % 10 == 8) [ret appendString:@"Nhâm "];
    if (CANDay % 10 == 9) [ret appendString:@"Quý "];
    
    if (CHIDay % 12 == 0) [ret appendString:@"Tý"];
    if (CHIDay % 12 == 1) [ret appendString:@"Sửu"];
    if (CHIDay % 12 == 2) [ret appendString:@"Dần"];
    if (CHIDay % 12 == 3) [ret appendString:@"Mão"];
    if (CHIDay % 12 == 4) [ret appendString:@"Thìn"];
    if (CHIDay % 12 == 5) [ret appendString:@"Tỵ"];
    if (CHIDay % 12 == 6) [ret appendString:@"Ngọ"];
    if (CHIDay % 12 == 7) [ret appendString:@"Mùi"];
    if (CHIDay % 12 == 8) [ret appendString:@"Thân"];
    if (CHIDay % 12 == 9) [ret appendString:@"Dậu"];
    if (CHIDay % 12 == 10) [ret appendString:@"Tuất"];
    if (CHIDay % 12 == 11) [ret appendString:@"Hợi"];
    
    return ret;
}

+ (NSString*)monthOfVietnames:(int)day :(int)month :(int)year{
    NSMutableArray *lunar = [self Solar2Lunar:day :month :year];
    
    int lMonth = [[lunar objectAtIndex:1] intValue];
    int lYear = [[lunar objectAtIndex:2] intValue];
    
    int CANDay = (lYear * 12 + lMonth + 3) % 10;
    NSMutableString *ret = [[NSMutableString alloc] init];
    
    if (CANDay % 10 == 0) [ret appendString:@"Giáp "];
    if (CANDay % 10 == 1) [ret appendString:@"Ất "];
    if (CANDay % 10 == 2) [ret appendString:@"Bính "];
    if (CANDay % 10 == 3) [ret appendString:@"Đinh "];
    if (CANDay % 10 == 4) [ret appendString:@"Mậu "];
    if (CANDay % 10 == 5) [ret appendString:@"Kỷ "];
    if (CANDay % 10 == 6) [ret appendString:@"Canh "];
    if (CANDay % 10 == 7) [ret appendString:@"Tân "];
    if (CANDay % 10 == 8) [ret appendString:@"Nhâm "];
    if (CANDay % 10 == 9) [ret appendString:@"Quý "];
    
    if (lMonth == 11) [ret appendString:@"Tý"];
    if (lMonth == 12) [ret appendString:@"Sửu"];
    if (lMonth == 1) [ret appendString:@"Dần"];
    if (lMonth == 2) [ret appendString:@"Mão"];
    if (lMonth == 3) [ret appendString:@"Thìn"];
    if (lMonth == 4) [ret appendString:@"Tỵ"];
    if (lMonth == 5) [ret appendString:@"Ngọ"];
    if (lMonth == 6) [ret appendString:@"Mùi"];
    if (lMonth == 7) [ret appendString:@"Thân"];
    if (lMonth == 8) [ret appendString:@"Dậu"];
    if (lMonth == 9) [ret appendString:@"Tuất"];
    if (lMonth == 10) [ret appendString:@"Hợi"];
    
    if ([[lunar objectAtIndex:3] intValue] == 1) {
        [ret appendString:@"(nhuận)"];
    }
    
    return ret;
}

+ (NSString*)yearOfVietnames:(int)year{
    NSMutableString *ret = [[NSMutableString alloc] init];
    
    if (year % 10 == 4) [ret appendString:@"Giáp "];
    if (year % 10 == 5) [ret appendString:@"Ất "];
    if (year % 10 == 6) [ret appendString:@"Bính "];
    if (year % 10 == 7) [ret appendString:@"Đinh "];
    if (year % 10 == 8) [ret appendString:@"Mậu "];
    if (year % 10 == 9) [ret appendString:@"Kỷ "];
    if (year % 10 == 0) [ret appendString:@"Canh "];
    if (year % 10 == 1) [ret appendString:@"Tân "];
    if (year % 10 == 2) [ret appendString:@"Nhâm "];
    if (year % 10 == 3) [ret appendString:@"Quý "];
    
    
    if (year % 12 == 4) [ret appendString:@"Tý"];
    if (year % 12 == 5) [ret appendString:@"Sửu"];
    if (year % 12 == 6) [ret appendString:@"Dần"];
    if (year % 12 == 7) [ret appendString:@"Mão"];
    if (year % 12 == 8) [ret appendString:@"Thìn"];
    if (year % 12 == 9) [ret appendString:@"Tỵ"];
    if (year % 12 == 10) [ret appendString:@"Ngọ"];
    if (year % 12 == 11) [ret appendString:@"Mùi"];
    if (year % 12 == 0) [ret appendString:@"Thân"];
    if (year % 12 == 1) [ret appendString:@"Dậu"];
    if (year % 12 == 2) [ret appendString:@"Tuất"];
    if (year % 12 == 3) [ret appendString:@"Hợi"];
    
    return ret;
}

+ (NSMutableDictionary*)getHoroscopeDayInfo:(int)D :(int)M :(int)Y{
    NSMutableDictionary *dayInfo = [[NSMutableDictionary alloc] init];
    [dayInfo setObject:[NSString stringWithFormat:@"%d",D] forKey:@"Day"];
    [dayInfo setObject:[NSString stringWithFormat:@"%d",M] forKey:@"Month"];
    [dayInfo setObject:[NSString stringWithFormat:@"%d",Y] forKey:@"Year"];
	double jdToday = [self LocalToJD:D :M :Y];
    [dayInfo setObject:[Quotations quotationAtJdDay:(int)jdToday] forKey:@"Quotation"];
    NSMutableArray *lunar = [self convertSolar2Lunar:D mm:M yy:Y timeZone:LOCAL_TIMEZONE];
//    int dd = [[lunar objectAtIndex:0] intValue];
    int mm = [[lunar objectAtIndex:1] intValue];
    int yy = [[lunar objectAtIndex:2] intValue];
    [dayInfo setObject:lunar forKey:@"Lunar"];
    
    NSString *dayOfWeek;
    int X = floor(jdToday + 2.5);
    if (X%7 == 0 ) dayOfWeek = @"Thứ bảy";
    if (X%7 == 1 ) dayOfWeek = @"Chủ nhật";
    if (X%7 == 2 ) dayOfWeek = @"Thứ hai";
    if (X%7 == 3 ) dayOfWeek = @"Thứ ba";
    if (X%7 == 4 ) dayOfWeek = @"Thứ tư";
    if (X%7 == 5 ) dayOfWeek = @"Thứ năm";
    if (X%7 == 6 ) dayOfWeek = @"Thứ sáu";
    [dayInfo setObject:dayOfWeek forKey:@"DayOfWeek"];
    
    NSMutableString *dayOfVietnamese = [[NSMutableString alloc] init];
    int CANDay = floor(jdToday + 9.5);
    int CHIDay = floor(jdToday + 1.5);
    int thienCan = 0;
    int diaChi = 0;
    int hyThan = 0;
    int taiThan = 0;
    int hacThan = 8;
    NSString *goodBadDirection;
    
/*
 0:chính bắc
 1:đông bắc
 2:chính đông
 3:đông nam
 4:chính nam
 5:tây nam
 6:chính tây
 7:tây bắc
 */
    
    int indexOfDay60 = ((int)jdToday - 10 )%60;
    if (indexOfDay60 >= 29  && indexOfDay60 <= 44) {
        hacThan = 9;
    }
     if (indexOfDay60 >=45 && indexOfDay60 <= 50){
        hacThan = 1;
    }
     if (indexOfDay60 >= 51 && indexOfDay60 <= 55 ){
        hacThan = 2;
    }
     if(indexOfDay60 >= 56 || indexOfDay60 <= 1){
        hacThan = 3;
    }
     if (indexOfDay60 >= 2 && indexOfDay60 <= 6){
        hacThan = 4;
    }
     if (indexOfDay60 >= 7 && indexOfDay60 <= 12){
        hacThan = 5;
    }
     if (indexOfDay60 >= 13 && indexOfDay60 <= 17){
        hacThan = 6;
    }
     if (indexOfDay60 >= 18 && indexOfDay60 <= 23){
        hacThan = 7;
    }
     if (indexOfDay60 >= 24 && indexOfDay60 <= 28){
        hacThan = 0;
    }
    
    if (CANDay % 10 == 0) {
        thienCan = 1;
        hyThan = 1;
        taiThan = 3;
        [dayOfVietnamese appendString:@"Giáp "];
    }
    if (CANDay % 10 == 1) {
        thienCan = 1;
        hyThan = 7;
        taiThan = 3;
        [dayOfVietnamese appendString:@"Ất "];
    }
    if (CANDay % 10 == 2) {
        thienCan = 2;
        hyThan = 5;
        taiThan = 2;
        [dayOfVietnamese appendString:@"Bính "];
    }
    if (CANDay % 10 == 3) {
        thienCan = 2;
        hyThan = 4;
        taiThan = 2;
        [dayOfVietnamese appendString:@"Đinh "];
    }
    if (CANDay % 10 == 4) {
        thienCan = 3;
        hyThan = 3;
        taiThan = 0;
        [dayOfVietnamese appendString:@"Mậu "];
    }
    if (CANDay % 10 == 5) {
        thienCan = 3;
        hyThan = 1;
        taiThan = 4;
        [dayOfVietnamese appendString:@"Kỷ "];
    }
    if (CANDay % 10 == 6) {
        thienCan = 4;
        hyThan = 7;
        taiThan = 5;
        [dayOfVietnamese appendString:@"Canh "];
    }
    if (CANDay % 10 == 7) {
        thienCan = 4;
        hyThan = 5;
        taiThan = 5;
        [dayOfVietnamese appendString:@"Tân "];
    }
    if (CANDay % 10 == 8) {
        thienCan = 5;
        hyThan = 4;
        taiThan = 6;
        [dayOfVietnamese appendString:@"Nhâm "];
    }
    if (CANDay % 10 == 9) {
        thienCan = 5;
        hyThan = 3;
        taiThan = 7;
        [dayOfVietnamese appendString:@"Quý "];
    }
    
    if (taiThan == hyThan) {
        if (hacThan > 8 || taiThan == hacThan || hyThan == hacThan) {
            goodBadDirection = @"Tài thần, hỷ thần: Đông Nam";
        }
        else{
            goodBadDirection = [NSString stringWithFormat:@"Tài thần, hỷ thần: Đông Nam. Hạc thần: %@",[self indexToDirection:hacThan]];
        }
    }
    else{
        if (hacThan > 8 || taiThan == hacThan || hyThan == hacThan) {

            goodBadDirection = [NSString stringWithFormat:@"Tài thần: %@. Hỷ thần: %@",[self indexToDirection:taiThan],[self indexToDirection:hyThan]];
        }
        else{

            goodBadDirection = [NSString stringWithFormat:@"Tài thần: %@. Hỷ thần: %@. Hạc thần: %@",[self indexToDirection:taiThan],[self indexToDirection:hyThan],[self indexToDirection:hacThan]];
        }
    }

    NSString *horoscopeHours;
    NSString *horoscopeHoursDetail;
    NSString *horoscopeDay = @"0";
    NSString *conformable;
    
    if (CHIDay % 12 == 0) {
        diaChi = 1;
        [dayOfVietnamese appendString:@"Tý"];
        horoscopeHours = @"Tý - Sửu - Mão - Ngọ - Thân - Dậu";
        horoscopeHoursDetail = @"Tý (23-1), Sửu (1-3), Mão (5-7), Ngọ (11-13), Thân (15-17), Dậu (17-19)";
        if (mm == 1 || mm == 2 || mm == 5 || mm == 7 || mm == 8 || mm == 11) {
            horoscopeDay = @"1";
        }
        else {
            horoscopeDay = @"2";
        }
        conformable = @"Sửu";
    }
    if (CHIDay % 12 == 1) {
        diaChi = 1;
        [dayOfVietnamese appendString:@"Sửu"];
        horoscopeHours = @"Dần - Mão - Tỵ - Thân - Tuất - Hợi";
        horoscopeHoursDetail = @"Dần (3-5), Mão (5-7), Tỵ (9-11), Thân (15-17), Tuất (19-21), Hợi (21-23)";
        if (mm == 1 || mm == 7 || mm == 4 || mm == 10 || mm == 5 || mm == 11) {
            horoscopeDay = @"1";
        }
        else {
            horoscopeDay = @"2";
        }
        conformable = @"Tý";
    }
    if (CHIDay % 12 == 2) {
        diaChi = 2;
        [dayOfVietnamese appendString:@"Dần"];
        horoscopeHours = @"Tý - Sửu - Thìn - Tỵ - Mùi - Tuất";
        horoscopeHoursDetail = @"Tý (23-1), Sửu (1-3), Thìn (7-9), Tỵ (9-11), Mùi (13-15), Tuất (19-21)";
        if (mm == 2 || mm == 3 || mm == 6 || mm == 8 || mm == 9 || mm == 12) {
            horoscopeDay = @"1";
        }
        else {
            horoscopeDay = @"2";
        }
        conformable = @"Hợi";
    }
    if (CHIDay % 12 == 3) {
        diaChi = 2;
        [dayOfVietnamese appendString:@"Mão"];
        horoscopeHours = @"Tý - Dần - Mão - Ngọ - Mùi - Dậu";
        horoscopeHoursDetail = @"Tý (23-1), Dần (3-5), Mão (5-7), Ngọ (11-13), Mùi (13-15), Dậu (17-19)";
        if (mm == 2 || mm == 5 || mm == 11 || mm == 8 || mm == 6 || mm == 12) {
            horoscopeDay = @"1";
        }
        else {
            horoscopeDay = @"2";
        }
        conformable = @"Tuất";
    }
    if (CHIDay % 12 == 4) {
        diaChi = 3;
        [dayOfVietnamese appendString:@"Thìn"];
        horoscopeHours = @"Dần - Thìn - Tỵ - Thân - Dậu - Hợi";
        horoscopeHoursDetail = @"Dần (3-5), Thìn (7-9), Tỵ (9-11), Thân (15-17), Dậu (17-19), Hợi (21-23)";
        if (mm == 1 || mm == 3 || mm == 4 || mm == 7 || mm == 9 || mm == 10) {
            horoscopeDay = @"1";
        }
        else {
            horoscopeDay = @"2";
        }
        conformable = @"Dậu";
    }
    if (CHIDay % 12 == 5) {
        diaChi = 3;
        [dayOfVietnamese appendString:@"Tỵ"];
        horoscopeHours = @"Sửu - Thìn - Ngọ - Mùi - Tuất - Hợi";
        horoscopeHoursDetail = @"Sửu (1-3) - Thìn (7-9)- Ngọ(11-13)- Mùi (13-15)- Tuất (19-21)- Hợi (21-23)";
        if (mm == 1 || mm == 3 || mm == 6 || mm == 7 || mm == 9 || mm == 12) {
            horoscopeDay = @"1";
        }
        else {
            horoscopeDay = @"2";
        }
        conformable = @"Thân";
    }
    if (CHIDay % 12 == 6){
        diaChi = 1;
        [dayOfVietnamese appendString:@"Ngọ"];
        horoscopeHours = @"Tý - Sửu - Mão - Ngọ - Thân - Dậu";
        horoscopeHoursDetail = @"Tý (23-1)- Sửu (1-3) - Mão (5-7)- Ngọ (11-13)- Thân (15-17)- Dậu (17-19)";
        if (mm == 2 || mm == 4 || mm == 5 || mm == 8 || mm == 10 || mm == 11) {
            horoscopeDay = @"1";
        }
        else {
            horoscopeDay = @"2";
        }
        conformable = @"Mùi";
    }
    if (CHIDay % 12 == 7){
        diaChi = 1;
        [dayOfVietnamese appendString:@"Mùi"];
        horoscopeHours = @"Dần - Mão - Tỵ - Thân - Tuất - Hợi";
        horoscopeHoursDetail = @"Dần (3-5)- Mão (5-7)- Tỵ (9-11)- Thân (15-17)- Tuất (19-21)- Hợi (21-23)";
        if (mm == 1 || mm == 2 || mm == 4 || mm == 7 || mm == 8 || mm == 10) {
            horoscopeDay = @"1";
        }
        else {
            horoscopeDay = @"2";
        }
        conformable = @"Ngọ";
    }
    if (CHIDay % 12 == 8) {
        diaChi = 2;
        [dayOfVietnamese appendString:@"Thân"];
        horoscopeHours = @"Tý - Sửu - Thìn - Tỵ - Mùi - Tuất";
        horoscopeHoursDetail = @"Tý (23-1), Sửu (1-3), Thìn (7-9), Tỵ (9-11), Mùi (13-15), Tuất(19-21)";
        if (mm == 3 || mm == 5 || mm == 6 || mm == 9 || mm == 11 || mm == 12) {
            horoscopeDay = @"1";
        }
        else {
            horoscopeDay = @"2";
        }
        conformable = @"Tỵ";
    }
    if (CHIDay % 12 == 9) {
        diaChi = 2;
        [dayOfVietnamese appendString:@"Dậu"];
        horoscopeHours = @"Tý - Dần - Mão - Ngọ - Mùi - Dậu";
        horoscopeHoursDetail = @"Tý (23-1), Dần (3-5), Mão (5-7), Ngọ (11-13), Mùi (13-15), Dậu (17-19)";
        if (mm == 5 || mm == 3 || mm == 2 || mm == 11 || mm == 9 || mm == 8) {
            horoscopeDay = @"1";
        }
        else {
            horoscopeDay = @"2";
        }
        conformable = @"Thìn";
    }
    if (CHIDay % 12 == 10) {
        diaChi = 3;
        [dayOfVietnamese appendString:@"Tuất"];
        horoscopeHours = @"Dần - Thìn - Tỵ - Thân - Dậu - Hợi";
        horoscopeHoursDetail = @"Dần (3-5), Thìn (7-9), Tỵ (9-11), Thân (15-17), Dậu (17-19), Hợi (21-23)";
        if (mm == 1 || mm == 4 || mm == 6 || mm == 7 || mm == 10 || mm == 12) {
            horoscopeDay = @"1";
        }
        else {
            horoscopeDay = @"2";
        }
        conformable = @"Mão";
    }
    if (CHIDay % 12 == 11) {
        diaChi = 3;
        [dayOfVietnamese appendString:@"Hợi"];
        
        horoscopeHours = @"Sửu - Thìn - Ngọ - Mùi - Tuất - Hợi";
        horoscopeHoursDetail = @"Sửu (1-3) - Thìn (7-9)- Ngọ(11-13)- Mùi (13-15)- Tuất (19-21)- Hợi (21-23)";

        if (mm == 6 || mm == 3 || mm == 4 || mm == 10 || mm == 9 || mm == 12) {
            horoscopeDay = @"1";
        }
        else {
            horoscopeDay = @"2";
        }
        conformable = @"Dần";
    }
    
    NSString *nguHanh;
    switch ((thienCan + diaChi)%5) {
        case 0:
            nguHanh = @"Thổ";
            break;
        case 1:
            nguHanh = @"Mộc";
            break;
        case 2:
            nguHanh = @"Kim";
            break;
        case 3:
            nguHanh = @"Thuỷ";
            break;
        case 4:
            nguHanh = @"Hoả";
            break;
    }

    [dayInfo setObject:goodBadDirection forKey:@"GoodBadDirection"];
    [dayInfo setObject:nguHanh forKey:@"NguHanh"];
    [dayInfo setObject:horoscopeDay forKey:@"HoroscopeDay"];
    [dayInfo setObject:horoscopeHours forKey:@"HoroscopeHours"];
    [dayInfo setObject:horoscopeHoursDetail forKey:@"HoroscopeHoursDetail"];
    [dayInfo setObject:dayOfVietnamese forKey:@"DayOfVietnamese"];
    int indexOfHoroscope = CHIDay %12;
    [dayInfo setObject:[NSString stringWithFormat:@"%d",indexOfHoroscope] forKey:@"IndexOfHoroscope"];
    
    
    NSMutableString *monthOfVietnamese = [[NSMutableString alloc] init];
    
    int CANMonth = (yy * 12 + mm + 3) % 10;
    
    if (CANMonth % 10 == 0) [monthOfVietnamese appendString:@"Giáp "];
    if (CANMonth % 10 == 1) [monthOfVietnamese appendString:@"Ất "];
    if (CANMonth % 10 == 2) [monthOfVietnamese appendString:@"Bính "];
    if (CANMonth % 10 == 3) [monthOfVietnamese appendString:@"Đinh "];
    if (CANMonth % 10 == 4) [monthOfVietnamese appendString:@"Mậu "];
    if (CANMonth % 10 == 5) [monthOfVietnamese appendString:@"Kỷ "];
    if (CANMonth % 10 == 6) [monthOfVietnamese appendString:@"Canh "];
    if (CANMonth % 10 == 7) [monthOfVietnamese appendString:@"Tân "];
    if (CANMonth % 10 == 8) [monthOfVietnamese appendString:@"Nhâm "];
    if (CANMonth % 10 == 9) [monthOfVietnamese appendString:@"Quý "];
    
    if (mm == 11) [monthOfVietnamese appendString:@"Tý"];
    if (mm == 12) [monthOfVietnamese appendString:@"Sửu"];
    if (mm == 1) [monthOfVietnamese appendString:@"Dần"];
    if (mm == 2) [monthOfVietnamese appendString:@"Mão"];
    if (mm == 3) [monthOfVietnamese appendString:@"Thìn"];
    if (mm == 4) [monthOfVietnamese appendString:@"Tỵ"];
    if (mm == 5) [monthOfVietnamese appendString:@"Ngọ"];
    if (mm == 6) [monthOfVietnamese appendString:@"Mùi"];
    if (mm == 7) [monthOfVietnamese appendString:@"Thân"];
    if (mm == 8) [monthOfVietnamese appendString:@"Dậu"];
    if (mm == 9) [monthOfVietnamese appendString:@"Tuất"];
    if (mm == 10) [monthOfVietnamese appendString:@"Hợi"];
    
    if ([[lunar objectAtIndex:3] intValue] == 1) {
        [monthOfVietnamese appendString:@"(nhuận)"];
    }
    
    [dayInfo setObject:monthOfVietnamese forKey:@"MonthOfVietnamese"];
    
    NSMutableString *yearOfVietnamese = [[NSMutableString alloc] init];
    
    if (yy % 10 == 4) [yearOfVietnamese appendString:@"Giáp "];
    if (yy % 10 == 5) [yearOfVietnamese appendString:@"Ất "];
    if (yy % 10 == 6) [yearOfVietnamese appendString:@"Bính "];
    if (yy % 10 == 7) [yearOfVietnamese appendString:@"Đinh "];
    if (yy % 10 == 8) [yearOfVietnamese appendString:@"Mậu "];
    if (yy % 10 == 9) [yearOfVietnamese appendString:@"Kỷ "];
    if (yy % 10 == 0) [yearOfVietnamese appendString:@"Canh "];
    if (yy % 10 == 1) [yearOfVietnamese appendString:@"Tân "];
    if (yy % 10 == 2) [yearOfVietnamese appendString:@"Nhâm "];
    if (yy % 10 == 3) [yearOfVietnamese appendString:@"Quý "];
    
    
    if (yy % 12 == 4) [yearOfVietnamese appendString:@"Tý"];
    if (yy % 12 == 5) [yearOfVietnamese appendString:@"Sửu"];
    if (yy % 12 == 6) [yearOfVietnamese appendString:@"Dần"];
    if (yy % 12 == 7) [yearOfVietnamese appendString:@"Mão"];
    if (yy % 12 == 8) [yearOfVietnamese appendString:@"Thìn"];
    if (yy % 12 == 9) [yearOfVietnamese appendString:@"Tỵ"];
    if (yy % 12 == 10) [yearOfVietnamese appendString:@"Ngọ"];
    if (yy % 12 == 11) [yearOfVietnamese appendString:@"Mùi"];
    if (yy % 12 == 0) [yearOfVietnamese appendString:@"Thân"];
    if (yy % 12 == 1) [yearOfVietnamese appendString:@"Dậu"];
    if (yy % 12 == 2) [yearOfVietnamese appendString:@"Tuất"];
    if (yy % 12 == 3) [yearOfVietnamese appendString:@"Hợi"];
    
    [dayInfo setObject:yearOfVietnamese forKey:@"YearOfVietnamese"];
    
    int twentyEightStarth = ((int)jdToday + 12) % 28;
    
    [dayInfo setObject:[NSString stringWithFormat:@"%d",twentyEightStarth] forKey:@"TwentyEightStarth"];
    
    return dayInfo;
}

+(BOOL)enoughMonthLunar:(int)lunarMonth :(int)year{
    NSMutableArray *solar = [self convertLunar2Solar:30 lunarMonth:lunarMonth lunarYear:year lunarLeap:0 timeZone:7];

    NSMutableArray *tmpLunar = [self convertSolar2Lunar:[[solar objectAtIndex:0] intValue] mm:[[solar objectAtIndex:1] intValue] yy:[[solar objectAtIndex:2] intValue] timeZone:LOCAL_TIMEZONE];
    
    int tmpLunarMonth = [[tmpLunar objectAtIndex:1] intValue];

    return lunarMonth == tmpLunarMonth;
}

+(NSString*)indexToDirection:(int)index{
    switch (index) {
        case 0:
            return @"Chính Bắc";
            break;
        case 1:
            return @"Đông Bắc";
            break;
        case 2:
            return @"Chính Đông";
            break;
        case 3:
            return @"Đông Nam";
            break;
        case 4:
            return @"Chính Nam";
            break;
        case 5:
            return @"Tây Nam";
            break;
        case 6:
            return @"Chính Tây";
            break;
        case 7:
            return @"Tây Bắc";
            break;
    }
    return @"";
}

@end

