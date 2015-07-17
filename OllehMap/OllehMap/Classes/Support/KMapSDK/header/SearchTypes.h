//
//  SearchTypes.h
//  KTMapSDK
//
//  Created by 종석 정 on 11. 6. 9..
//  Copyright 2011 네이버시스템(주). All rights reserved.
//

#import <Foundation/Foundation.h>

//! CoordType Enumeration
/*!
 조회 서비스에서 사용되는 좌표체계 정의
 UTMK = 0
 TM_WEST = 1
 TM_MID = 2
 TM_EAST = 3
 KATEC = 4
 UTM52 = 5
 UTM51 = 6
 WGS84 = 7
 BESSEL = 8
 */
enum {
    kCoordType_UTMK = 0,
    kCoordType_TM_WEST,
    kCoordType_TM_MID,
	kCoordType_TM_EAST,
	kCoordType_KATEC,
	kCoordType_UTM52,
	kCoordType_UTM51,
	kCoordType_WGS84, 
	kCoordType_BESSEL,
	kCoordType_NONE
};
typedef NSUInteger CoordType;

//! SearchType Enumeration
/*!
 조회 서비스 타입
 명칭검색 = 0
 초성검색 = 1
 테마검색 = 2
 전화번호 검색 = 3
 테마코드검색 = 4
 Reverse Geocode 검색 = 5
 */
enum {
    kSearchType_NAME = 0,
    kSearchType_CNST,
    kSearchType_THEM,
	kSearchType_TEL,
	kSearchType_THEM_CODE,
	kSearchType_RGEO_POI,
	kSearchType_NONE
};
typedef NSUInteger SearchType;

//! SearchKind Enumeration
/*!
 경로검색 서비스 타입
 자동자경로검색 = 0
 대중교통경로검색 = 1
 */
enum {
    kSearchKind_Car = 0,
    kSearchKind_Pub,
	kSearchKind_NONE
};
typedef NSUInteger SearchKind;

//! RoutePriority Enumeration
/*!
 자동차경로검색 우선순위
 최단경로 = 0
 고속도로우선 = 1
 무료도로우선 = 2
 최적경로 = 3
 실시간도로우선 = 4
 */
enum {
    kRoutePriority_SHT = 0,
    kRoutePriority_EXP,
	kRoutePriority_FRE,
	kRoutePriority_OPT,
	kRoutePriority_REL,
	kROutePriority_NONE	
};
typedef NSUInteger RoutePriority;

//! PublicRoutePriority Enumeration
/*!
 대중교통경로검색 우선순위
 추천 = 0
 버스 = 1
 지하철 = 2
 버스+지하철 = 3
 */
enum {
    kPublicRoutePriority_RCD = 0,
    kPublicRoutePriority_BUS,
	kPublicRoutePriority_SUB,
	kPublicRoutePriority_CFS,
	kPublicRoutePriority_NONE
};
typedef NSUInteger PublicRoutePriority;

//! AddressCodeType Enumeration
/*!
 주소코드 타입
 법정동 = 0
 행정동 = 1
 */
enum {
    kAddressCodeType_BJD = 0,
    kAddressCodeType_HJD,
	kAddressCodeType_NONE
};
typedef NSUInteger AddressCodeType;

//! ArrangeType Enumeration
/*!
 POI정렬 방식
 명칭 = 0
 거리 = 1
 */
enum {
    kArrangeType_NAME = 0,
    kArrangeType_DIST,
    kArrangeType_NONE
};
typedef NSUInteger ArrangeType;

//! SearchSide Enumeration
/*!
 검색면 타입
 오른쪽 = 0
 왼쪽 = 1
 모두 = 2
 */
enum {
    kSearchSide_RGT = 0,
    kSearchSide_LFT,
	kSearchSide_ALL,
	kSearchSide_NONE
};
typedef NSUInteger SearchSide;

//! AddressType Enumeration
/*!
 주소 타입
 새주소 = 0
 구주소 = 1
 */
enum {
    kAddressType_NADDR = 0,
    kAddressType_OADDR,
	kAddressType_NONE
};
typedef NSUInteger AddressType;

//! AddressJibunType Enumeration
/*!
 주소 지번 타입
 행정동 = 0
 Full address = 1
 */
enum {
    kAddressJibunType_HJD = 0,
    kAddressJibunType_FULL,
	kAddressJibunType_NONE
};
typedef NSUInteger AddressJibunType;

//! ReturnPOIType Enumeration
/*!
 POI반환여부 
 반환하지않음 = 0
 반환 = 1
 */
enum {
    kReturnPOIType_FALE = 0,
    kReturnPOIType_TRUE,
	kReturnPOIType_NONE
};
typedef NSUInteger ReturnPOIType;
