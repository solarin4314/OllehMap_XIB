//
//  ReverseGeocoding.h
//  KMapSDK
//
//  Created by Song Hyun Seob on 10. 07. 19.
//  Copyright 2010
//

#import <UIKit/UIKit.h>
#import "KGeometry.h"
#import "KMapTypes.h"
#import "ReverseGeocodingInfo.h"
#import "SearchManager.h"

@protocol ReverseGeocodingDelegate;

/**
 * ReverseGeocoding: ReverseGeocoding Class.
 */
@interface ReverseGeocoding : NSObject
{
    id <ReverseGeocodingDelegate> delegate;
	KLanguage language;
	KCoordType coordType;
	int rgeoType;
	Coord coord;
    
    int getMethod;
    int isLdong;
    NSString *reqMdn;
    NSString *serviceType;
    NSString *spCode;
    NSString *svcCode;
    NSString *svcPwd;

@private
    SearchManager *mgr;
}

/**
 * ReverseGeocoding delegate.
 */
@property (nonatomic, assign) id <ReverseGeocodingDelegate> delegate;

/**
 * ReverseGeocoding language.
 */
@property (nonatomic,assign) KLanguage language;

/**
 * 좌표타입
 * KAT : KATEC
 * LL_W : WGS84
 * LL_B : Bessel
 * TMW : TM_West
 * TMM : TM_Middle
 * TME : TM_East
 * UTM2 : UTM_Zone52
 * UTM1 : UTM_Zone51
 * UTMK : UTMK
 */
@property (nonatomic,assign) KCoordType coordType;

/**
 * ReverseGeocoding TYPE
 * 1: 주소
 * 2: POI
 * 3: 주소 + POI 
 * 4: 주소 + 지하철
 * 5: 상세주소 + POI
 */
@property (nonatomic,assign) int rgeoType;

/**
 * 법정동 여부
 * 0:행정동
 * 1:법정동
 * 2:법정동 + 행정동 - 법정동만 해당됨
 */
@property (nonatomic,assign) int isLdong;

/**
 * 좌표
 */
@property (nonatomic,assign) Coord coord;

/**
 * ReverseGeocoding REQ_MDN - 의미없음
 */

@property (nonatomic,assign) NSString *reqMdn;

/**
 * ReverseGeocoding serviceType - 의미없음
 */

@property (nonatomic,assign) NSString *serviceType;

/**
 * ReverseGeocoding SP Code - 의미없음
 */

@property (nonatomic,assign) NSString *spCode;

/**
 * ReverseGeocoding SVC Code - 의미없음
 */

@property (nonatomic,assign) NSString *svcCode;

/**
 * ReverseGeocoding Open Api Key
 */
@property (nonatomic,retain) NSString *svcPwd;


/**
 * 측위방식
 * 0 : Cell
 * 1 : GPS
 * 2 : Hybrid
 * 3 : AFLT 
 * 4 : MIX_SECTOR 
 * 5 : CELL_SECTOR 
 * 6 : WCDMA 
 * 7 : CELLPARAM 
 * 8 : RAD
 */
@property (nonatomic,assign) int getMethod;



/**
 * ReverseGeocoding 초기화 함수.
 */
-(id)init; 

/**
 * ReverseGeocoding coord와 함께 초기화.
 * @param coord :coord 정보
 */
-(id)initWithCoord:(Coord)coord; 

/**
 * ReverseGeocoding 검색 시작.
 */
- (void)search;

/**
 * ReverseGeocoding 검색 취소.
 */
- (void)cancel;


@end

/**
 * ReverseGeocoding: Geocoding delegate protocal.
 */
@protocol ReverseGeocodingDelegate <NSObject>
@optional

/**
 * reverseGeocoding이 성공하였을 경우 호출.
 * @param _reverseGeocoder :대상 ReverseGeocoding class
 * @param reverseGeocodingInfo :ReverseGeocodingInfo array
 */
- (void)reverseGeocoding:(ReverseGeocoding *)_reverseGeocoder didFinishReverseGeocoding:(ReverseGeocodingInfo*)reverseGeocodingInfo;

/**
 * reverseGeocoding이 실패 하였을 경우 호출.
 * @param _reverseGeocoder :대상 ReverseGeocoding class
 * @param error :error info
 */
- (void)reverseGeocoding:(ReverseGeocoding *)_reverseGeocoder didFailWithError:(NSError *)error;
@end
