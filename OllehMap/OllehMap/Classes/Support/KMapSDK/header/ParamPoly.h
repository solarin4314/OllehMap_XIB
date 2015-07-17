//
//  ParamPolyByName.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 17..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParamBase.h"
#import "CoordList.h"
#import "SearchTypes.h"

//! ParamPoly Class
/*!
 POI 검색 중 이름/초성/테마/전화번호에 의한 주변 검색의 파라미터를 정의한다.
 QueryPolyByName
 QueryPolyByConsonant
 QueryPolyByTheme
 QueryPolyByTelNo
 검색 메소드의 파라미터로 사용된다.
 */
@interface ParamPoly : ParamBase {
	NSString *word;                 /**<검색어 (이름/초성/테마/전화번호)*/
	CoordList *polygon;             /**<Polygon을 정의하는 Coord List*/
	ArrangeType arrangeType;        /**<정렬조건 : Default = 명칭 (명칭 = 0, 거리 = 1)*/
	int resultCnt;                  /**<조회결과 POI개수 : Default = 10*/
	int p;                          /**<페이지번호*/
	double x;                       /**<중심좌표 X*/
	double y;                       /**<중심좌표 Y*/

}
/**
 work(검색어) Property (Get/Set 메소드 정의)
 */
@property (nonatomic, retain) NSString *word;
/**
 polygon(Polygon CoordList) Property (Get/Set 메소드 정의)
 */
@property (nonatomic, retain) CoordList *polygon;
/**
 arrangeType(정렬조건) Property (Get/Set 메소드 정의)
 */
@property (assign) ArrangeType arrangeType;
/**
 resultCnt(조회결과 POI개수) Property (Get/Set 메소드 정의)
 */
@property (assign) int resultCnt;
/**
 p(페이지번호) Property (Get/Set 메소드 정의)
 */
@property (assign) int p;
/**
 x(중심좌료 X) Property (Get/Set 메소드 정의)
 */
@property (assign) double x;
/**
 y(중심좌표 Y) Property (Get/Set 메소드 정의)
 */
@property (assign) double y;

@end
