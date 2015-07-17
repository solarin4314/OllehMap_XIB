//
//  OMSearchResult.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 23..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//
/*
 지도 검색 결과값을 저장하는 정보 클래스
 */

#import <Foundation/Foundation.h>

#import "KGeometry.h"


@interface OMSearchResult : NSObject
{
    BOOL _used;
    BOOL _isCurrentLocation;
    Coord _coordLocationPoint;
    NSString *_strLocationName;
    NSString *_strLocationAddress;
    NSString *_strThemeCoder;
    
    NSString *_strLocationSubAddress;
    NSString *_strLocationOldOrNew;
    
    NSString *_strID;
    NSString *_strType;
    NSString *_strTel;
    NSString *_strSTheme;
    NSString *_strShape;
    NSString *_strShapeFcNm;
    NSString *_strShapeIdBgm;
    int _index;
}

-(id) init;
-(void) dealloc;
-(void) reset;

@property BOOL used;
@property BOOL isCurrentLocation;
@property Coord coordLocationPoint;
@property (retain, nonatomic) NSString *strLocationName;
@property (retain, nonatomic) NSString *strLocationAddress;
@property (retain, nonatomic) NSString *strLocationSubAddress;
@property (retain, nonatomic) NSString *strThemeCoder;
@property (retain, nonatomic) NSString *strLocationOldOrNew;
@property (retain, nonatomic) NSString *strID;
@property (retain, nonatomic) NSString *strType;
@property (retain, nonatomic) NSString *strTel;
@property (retain, nonatomic) NSString *strSTheme;
@property (retain, nonatomic) NSString *strShape;
@property (retain, nonatomic) NSString *strShapeFcNm;
@property (retain, nonatomic) NSString *strShapeIdBgm;
@property (assign, nonatomic) int index;

@end
