//
//  Quotations.m
//  Horoscope
//
//  Created by Hai Trieu on 4/4/13.
//  Copyright (c) 2013 Adriaenssen BVBA. All rights reserved.
//

#import "Quotations.h"

@implementation Quotations

+ (NSString*)quotationAtJdDay:(int)jdDay{
    int index = jdDay % [ShareDelegate.quotations count];
    return [[ShareDelegate.quotations objectAtIndex:index] objectAtIndex:1];
}

@end
