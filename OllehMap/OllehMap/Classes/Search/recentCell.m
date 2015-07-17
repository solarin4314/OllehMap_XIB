//
//  recentCell.m
//  OllehMap
//
//  Created by 이 제민 on 12. 5. 15..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "recentCell.h"

@interface recentCell ()

@end

@implementation recentCell
@synthesize startLbl = _startLbl;
@synthesize destLbl = _destLbl;
@synthesize visitLbl = _visitLbl;
@synthesize startContent = _startContent;
@synthesize visitContent = _visitContent;
@synthesize destContent = _destContent;

@synthesize poiImage = _poiImage;
@synthesize placeName = _placeName;
@synthesize classification = _classification;
@synthesize radioBtn = _radioBtn;

@synthesize imgvwCheckBox = _imgvwCheckBox;
@synthesize vwCellBackground = _vwCellBackground;

- (void) dealloc
{
    [_placeName release];
    _placeName = nil;
    [_poiImage release];
    _poiImage = nil;
    [_classification release];
    _classification = nil;

    [_startLbl release];
    _startLbl = nil;
    [_destLbl release];
    _destLbl = nil;
    [_visitLbl release];
    _visitLbl = nil;
    [_startContent release];
    _startContent = nil;
    [_visitContent release];
    _visitContent = nil;
    [_destContent release];
    _destContent = nil;    
    
    [_imgvwCheckBox release];
    _imgvwCheckBox = nil;
    [_vwCellBackground release];
    _vwCellBackground = nil;
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Initialization code
        
        _vwCellBackground = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 116/2)];
        [_vwCellBackground setHidden:YES];
        [self insertSubview:_vwCellBackground atIndex:0];        
        _imgvwCheckBox = [[UIImageView alloc] initWithFrame:CGRectMake(10, 17, 25, 25)];
        [_imgvwCheckBox setHidden:YES];
        [self addSubview:_imgvwCheckBox];
    }
    return self;
}

@end
