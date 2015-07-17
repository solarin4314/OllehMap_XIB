//
//  OMSearchResult.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 23..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "OMSearchResult.h"
#import "FavoriteViewController.h"

@implementation OMSearchResult

@synthesize used = _used;
@synthesize isCurrentLocation = _isCurrentLocation;
@synthesize coordLocationPoint = _coordLocationPoint;
@synthesize strLocationName = _strLocationName;
@synthesize strLocationAddress = _strLocationAddress;
@synthesize strLocationSubAddress = _strLocationSubAddress;
@synthesize strThemeCoder = _strThemeCoder;
@synthesize strLocationOldOrNew = _strLocationOldOrNew;

@synthesize strID = _strID;
@synthesize strType = _strType;
@synthesize strTel = _strTel;
@synthesize strSTheme = _strSTheme;
@synthesize strShape = _strShape;
@synthesize strShapeFcNm = _strShapeFcNm;
@synthesize strShapeIdBgm = _strShapeIdBgm;
@synthesize index = _index;

-(id) init
{
    [self resetWithInit:YES];
    
    return [super init];
}

-(void) dealloc
{
    [_strLocationName release];
    [_strLocationAddress release];
    [_strLocationSubAddress release];
    [_strThemeCoder release];
    [_strLocationOldOrNew release];
    [_strID release];
    [_strType release];
    [_strTel release];
    [_strSTheme release];
    [_strShape release];
    [_strShapeFcNm release];
    [_strShapeIdBgm release];
    
    [super dealloc];
}

-(void) reset
{
    [self resetWithInit : NO];
}
- (void) resetWithInit :(BOOL)init
{
    _used = NO;
    _isCurrentLocation = NO;
    _coordLocationPoint = CoordMake(0.0f, 0.0f);
    
    if ( init == NO )
    {
        [_strLocationName release];
        [_strLocationAddress release];
        [_strLocationSubAddress release];
        [_strThemeCoder release];
        [_strLocationOldOrNew release];
        [_strID release];
        [_strType release];
        [_strTel release];
        [_strSTheme release];
        [_strShape release];
        [_strShapeFcNm release];
        [_strShapeIdBgm release];
    }
    
    _strLocationName = [[NSString alloc] init];
    _strLocationAddress = [[NSString alloc] init];
    _strLocationSubAddress = [[NSString alloc] init];
    _strThemeCoder = [[NSString alloc] init];
    _strLocationOldOrNew = [[NSString alloc] init];
    _strID  = [[NSString alloc] init];
    _strType  = [[NSString alloc] init];
    _strTel  = [[NSString alloc] init];
    _strSTheme  = [[NSString alloc] init];
    _strShape = [[NSString alloc] init];
    _strShapeFcNm = [[NSString alloc] init];
    _strShapeIdBgm = [[NSString alloc] init];
    
    _index = -1;
}

@end
