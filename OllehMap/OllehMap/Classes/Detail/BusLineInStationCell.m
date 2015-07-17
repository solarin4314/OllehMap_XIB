//
//  BusLineInStationCell.m
//  OllehMap
//
//  Created by 이 제민 on 12. 6. 26..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "BusLineInStationCell.h"

@interface BusLineInStationCell ()

@end

@implementation BusLineInStationCell
@synthesize stationId;
@synthesize stationName;
@synthesize busLineImg;
@synthesize cellBg;


- (void)dealloc
{
    [stationId release];
    [stationName release];
    [busLineImg release];
    [cellBg release];
    [super dealloc];
}
@end
