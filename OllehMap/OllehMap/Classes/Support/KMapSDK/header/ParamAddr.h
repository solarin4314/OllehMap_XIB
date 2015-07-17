//
//  ParamAddrByName.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 17..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParamBase.h"
#import "SearchTypes.h"

//! ParamAddr Class
/*!
 POI 검색 중 이름/초성/테마/전화번호와 주소코드에 대한 검색에 해당하는 파라미터를 정의한다.
 QueryAddrByName
 QueryAddrByConsonant
 QueryAddrByTheme
 QueryAddrByTelNo
 검색 메소드의 파라미터로 사용된다.
 */
@interface ParamAddr : ParamBase {
	NSString *word;                 /**<검색어 (이름/초성/테마/전화번호)*/
	NSString *addrcd;               /**<주소코드*/
	ArrangeType arrangeType;        /**<정렬조건 : Default = 명칭 (명칭 = 0, 거리 = 1)*/
	AddressCodeType addrcdtype;     /**<주소코드 타입 (0 = 법정동, 1 = 행정동)*/
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
 addrcd(주소코드) Property (Get/Set 메소드 정의)
 */
@property (nonatomic, retain) NSString *addrcd;
/**
 arrangeType(정렬조건) Property (Get/Set 메소드 정의)
 */
@property (assign) ArrangeType arrangeType;
/**
 addrcdtype(주소코드 타입) Property (Get/Set 메소드 정의)
 */
@property (assign) AddressCodeType addrcdtype;
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
