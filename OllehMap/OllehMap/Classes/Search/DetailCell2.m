//
//  DetailCell2.m
//  OllehMap
//
//  Created by 이 제민 on 12. 5. 21..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "DetailCell2.h"

@interface DetailCell2 ()

@end

@implementation DetailCell2
@synthesize poiImage;
@synthesize busNumber;
@synthesize busArea;
@synthesize startStation;
@synthesize arrow;
@synthesize returnStation;
@synthesize arrowImg;



- (void)dealloc {
    [poiImage release];
    [busNumber release];
    [busArea release];
    [startStation release];
    [returnStation release];
    [arrow release];
    [arrowImg release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
@end
