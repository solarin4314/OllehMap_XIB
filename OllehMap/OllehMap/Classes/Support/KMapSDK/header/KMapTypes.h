//
//  KMapTypes.h
//  Created by Song Hyun Seob on 10. 07. 19.
//  Copyright 2010
//

#import <UIKit/UIKit.h>

#ifndef _MAPTYPES_DEF_H__
#define _MAPTYPES_DEF_H__


/**
 지도 타입 Enumeration
 */
typedef enum {
    KMapTypeStandard = 0,   /* 2D 지도타입 */
    KMapTypeSatellite,      /* 위성 지도타입 */
    KMapTypeHybrid,         /* Hybrid 지도타입 */
    KMapTypeTraffic,        /* 교통정보 지도타입 */
    KMapTypeCadastral,      /* 지적도정보 지도타입 */
	KMapTypeElection        /* 선거구 지도타입 */
	
}OllehMapType;

/**
 * Display Enumeration
 */
enum {
    KMapDisplayNormalBigText = 0,   /**< 일반지도(큰 글씨) */
    KMapDisplayNormalSmallText,     /**< 일반지도(작은 글씨) */
    KMapDisplayHD                   /**< HD 지도 */    
};
typedef NSUInteger KMapDisplay;

/**
 지도 내 측정타입 Enumeration
 */
typedef enum {
    KMeasureTypeNone = 0,   /**<특정 타입 없음*/
    KMeasureTypeDistance,   /**<거리 측정 타입*/
    KMeasureTypeArea        /**<면적 측정 타입*/
} KMeasureType;

/**
 지도 내 이동모드 Enumeration
 */
typedef enum {
    UserLocationNone = 0,           /**<특정 타입 없음*/
    UserLocationNorthUp,            /**<북쪽고정 모드*/
	UserLocationNorthUpTrace,       /**<북쪽고정 + 내위치 모드*/
    UserLocationCompass,            /**<나침반 모드*/
	UserLocationCompassTrace,       /**<나침반 + 내위치 모드*/
} KUserLocationType;

/**
 좌표 체계 Enumeration
 */
typedef enum {
    KCoordType_WGS84= 0,        /**<WGS84 좌표체계*/
    KCoordType_Basel1,          /**<Basel1 좌표체계*/
	KCoordType_TM_W,            /**<TM_W 좌표체계*/
	KCoordType_TM_M,            /**<TM_M 좌표체계*/
	KCoordType_TM_E,            /**<TM_E 좌표체계*/
	KCoordType_KATEC,           /**<KATEC 좌표체계*/
	KCoordType_UTM_Zone51,      /**<UTM_Zone51 좌표체계*/
	KCoordType_UTM_Zone52,      /**<UTM_Zone52 좌표체계*/
	KCoordType_UTMK,            /**<UTMK 좌표체계*/
} KCoordType;

///**
// 언어 타입 Enumeration
// */
typedef enum {
    KKorean= 0,
    KEnglish,
} KLanguage;

extern const char* codeTypeName[9];
extern const char* codeTypeNameProj[9];

#endif
