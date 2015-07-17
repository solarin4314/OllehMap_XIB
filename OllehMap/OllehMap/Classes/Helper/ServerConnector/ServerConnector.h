//
//  ServerConnector.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 15..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerRequester.h"
#import "NetDataFindRoad.h"
#import "OMSearchRouteDataParser.h"

@class SearchViewController;

#define _TB_SERVER

#ifdef _TB_SERVER
// 테스트 서버 디파인
// mmv 테스트서버 변경

#define COMMON_MMV_SERVER           @"m2.ktgis.com:4555"
#define COMMON_SERVER_IP            @"ollehmap.miksystem.com:4555"
#define COMMON_SERVER_GW            @"ollehmap.miksystem.com:4555/Router/GW"
#define COMMON_SERVER_BIS           @"ollehmap.miksystem.com:4555/Router/BIS"
#define COMMON_SERVER_DJT           @"ollehmap.miksystem.com:4555/Router/DJT"

#define CCTV_SERVER                 @"ollehmap.miksystem.com:4555/tr/service.do?transType=CCTV&returnType=xml&targetUrl="
#define WIFIZONE_INFO_SERVER        @"ollehmap.miksystem.com:4555/tr/service.do?transType=WIFI&returnType=nop&targetUrl="

// 메일주소 추가
#define ollehEmail                  @"jmlee@miksystem.com"
#define COMMON_URL_SHARE            @"http://map.olleh.com/olleh/hub?"
#else
// 상용 서버 디파인
#define COMMON_MMV_SERVER           @"m2.ktgis.com:4555"
#define COMMON_SERVER_IP            @"m2.ktgis.com:4555"
#define COMMON_SERVER_GW            @"m2.ktgis.com:4555/Router/GW"
#define COMMON_SERVER_BIS           @"m2.ktgis.com:4555/Router/BIS"
#define COMMON_SERVER_DJT           @"m2.ktgis.com:4555/Router/DJT"
#define CCTV_SERVER                 @"m2.ktgis.com:4555/tr/service.do?transType=CCTV&returnType=xml&targetUrl="
#define WIFIZONE_INFO_SERVER        @"m2.ktgis.com:4555/tr/service.do?transType=WIFI&returnType=nop&targetUrl="

// 메일주소 추가
#define ollehEmail                  @"ollehmap.help@kt.com"
#define COMMON_URL_SHARE            @"http://ollehmap.miksystem.com:4556/Mapin/Scheme.html?"

#endif

//#define APPSTORE_URL @"http://211.62.40.100:4555/deploy/iphone.do"
#define APPSTORE_URL @"http://itunes.apple.com/kr/app/olle-map/id464187687?mt=8"
// VOC AppId
#define appId @"AP20120828001"

// 타임아웃 인터벌
#define DEFAULT_TIMEOUT_INTERVAL	5.0f

@interface ServerConnector : NSObject
{
	NSString *_sessionString1;            ///< 세션 코드
    
}

@property (nonatomic, retain) NSString *sessionString;

// ==============================
// [ ServerConnector 싱글턴 처리 ]
// ==============================
+ (ServerConnector *) sharedServerConnection;
+ (void) releaseSharedServerConnection;
// ******************************


// =============================
// [ ServerConnector 보조메소드 ]
// =============================
- (NSString *) getPlatform;
- (void) addHeaderForApplicationServer:(NSMutableURLRequest *)request;
- (NSString *) convertToJsonStringFromReceiveData :(ServerRequester *)request :(BOOL)isXml;
// *****************************


// ====================
// [ 근접거리 POI 검색 ]
// ====================
- (ServerRequester *) requestOneTouchPOI:(id)target action:(SEL)action PX:(int)PX PY:(int)PY Level:(int)Level;
- (void) finishOneTouchPOI:(id)request;
// ********************

// =======================
// [ 길찾기 - 자동차 검색 ]
// =======================
- (ServerRequester *) requestRouteSearch:(id)target action:(SEL)action SX:(float)SX SY:(float)SY EX:(float)EX EY:(float)EY RPType:(int)RPType CoordType:(int)CoordType VX1:(float)VX1 VY1:(float)VY1 Priority:(int)Priority;
- (void)finishRouteSearch:(id)request;
// ***********************


// ========
// [ 검색 ]
// ========
- (ServerRequester *) requestSearchPlaceAndAddress :(id)target action:(SEL)action key:(NSString *)key mapX:(int)mapX mapY:(int)mapY s:(NSString *)s sr:(NSString *)sr p_startPage:(int)p_startPage a_startPage:(int)a_startPage n_startPage:(int)n_startPage indexCount:(int)indexCount option:(int)option;
- (void) finishSearchPlaceAndAddress :(id)request;
- (ServerRequester *) requestSearchPublicBusStation :(id)target action:(SEL)action Name:(NSString *)Name ViewCnt:(int)ViewCnt Page:(int)Page;
- (ServerRequester *) requestSearchPublicBusNumber :(id)target action:(SEL)action key:(NSString *)key startPage:(int)startPage indexCount:(int)indexCount;
- (ServerRequester *) requestSearchPublicSubwayStation :(id)target action:(SEL)action Name:(NSString *)Name;

- (ServerRequester *)requestSearchPublicBusStationUnique:(id)target action:(SEL)action UniqueId:(NSString *)UniqueId;
- (void) finishSearchPublic :(id)request;
// ********

// =================
// [ 좌표-주소 변환 ]
// =================
- (ServerRequester *) requestGeocodingCoordToAddress :(id)target action:(SEL)action x:(double)x y:(double)y radius:(int)radius type:(int)type;
- (void) finishGeocodingCoordToAddress :(id)request;
- (ServerRequester *) requestGeocodingCoordToShortAddress :(id)target action:(SEL)action type:(int)type x:(double)x y:(double)y dong:(int)dong;
- (void) finishGeocodingCoordToShortAddress :(id)request;
- (ServerRequester *) requestGeocodingCoordForSearchRoute :(id)target action:(SEL)action type:(int)type x:(double)x y:(double)y dong:(int)dong searchType:(int)searchType;
- (void) finishGeocodingCoordForSearchRoute :(id)request;
// *****************


// =================
// [ POI상세 method ]
// =================
- (ServerRequester *)requestPoiDetailAtPoiId:(id)target action:(SEL)action poiId:(NSString *)poiId isSimple:(int)isSimple;
- (ServerRequester *)requestPoiDetailAtPoiId:(id)target action:(SEL)action poiId:(NSString *)poiId;
- (void)finishPoiDetailAtPoiId:(id)request;
// *****************

// =====================
// [ 버스정류장 method ]
// =====================

- (ServerRequester *) requestBusStationInfoUniqueId:(id)target action:(SEL)action uniqueId:(NSString *)uniqueId cityCode:(NSString *)cityCode;
- (ServerRequester *) requestBusStationInfoStid:(id)target action:(SEL)action stId:(NSString *)stationId;

// ====================
// [ 버스노선  method ]
// ====================
- (ServerRequester *) requestBusNumberInfo:(id)target action:(SEL)action laneId:(NSString *)laneId;
// =========================
// [ BIS버스아이디  method ]
// =========================
- (ServerRequester *)requestBusRouteId:(id)target action:(SEL)action arsId:(NSString *)laneId;
- (void)finishBusRouteId:(id)request;
// ==========================
// [ 버스노선 그리기 method ]
// ==========================
- (ServerRequester *)requestBusLineDraw:(id)target action:(SEL)action busRouteId:(NSString *)RouteId;
- (void) finishBusLineDraw:(id)request;
- (ServerRequester *)requestBusLineDraw_G:(id)target action:(SEL)action busRouteId:(NSString *)RouteId;

// ======================
// [ 지하철 상세 method ]
// ======================
- (ServerRequester *)requestSubStation:(id)target action:(SEL)action stationId:(NSString *)stationId;
- (void)finishSubStation:(id)request;
- (ServerRequester *)requestTransSubStation:(id)target action:(SEL)action stationId:(NSString *)stationId counter:(int)counter max:(int)max;

// ======================
// [ 지하철 시간 method ]
// ======================
- (ServerRequester *)requestTrafficSubwayTime:(id)target action:(SEL)action STId:(NSString *)stationId DayType:(int)DayType;
- (void)finishTrafficSubwayTime:(id)request;

// ======================
// [ 지하철 추루 method ]
// ======================
- (ServerRequester *)requestTrafficSubwayExit:(id)target action:(SEL)action STId:(NSString *)stationId;
- (void)finishTrafficSubwayExit:(id)request;


// ====================
// [ 영화 상세 method ]
// ====================
- (ServerRequester *)requestMovieInfo:(id)target action:(SEL)action mId:(NSString *)mId;
- (void)finishMovieDetail:(id)request;

// ====================
// [ 상영 정보 method ]
// ====================
- (ServerRequester *)requestMovieList:(id)target action:(SEL)action mId:(NSString *)mId;
- (void)finishMovieListDetail:(id)request;

// ====================
// [ 유가 상세 method ]
// ====================
- (ServerRequester *)requestOilDetail:(id)target action:(SEL)action uId:(NSString *)uId;
- (void)finishOilDetail:(id)request;

// =================
// [ 콜링크 method ]
// =================
- (ServerRequester *)requestCallLink:(id)target action:(SEL)action mid:(NSString*)mid caller:(NSString*)caller called:(NSString*)called;
- (void)finishCallLink:(id)request;

// ==================
// [ 단축URL method ]
// ==================
/**
 @brief 단축 URL 정보 요청 함수 (정보를 단축 URL 로 바꾸어 준다.)
 @param target 콜백 타겟 클래스
 @param action 타겟 클래스 콜백함수
 @param PX : x 좌표
 @param PY : y 좌표
 @param Level : 맵 레벨
 @param Maptype : 맵 타입
 @param Name : 이름
 @param PID : ID 값
 @param ADDRESS : 주소
 @param TELEPHONE : 전화번호
 @param sendNum : 보낼타입
 @return ServerRequest 정보를 리턴
 */
//- (ServerRequester *)requestShortenURL:(id)target action:(SEL)action PX:(int)PX PY:(int)PY Level:(int)Level MapType:(int)MapType Name:(NSString *)Name PID:(NSString *)PID Addr:(NSString *)addr Tel:(NSString *)tel Type:(NSString *)type ID:(NSString *)Id;
//- (ServerRequester *)requestShortenURL:(id)target action:(SEL)action PX:(int)PX PY:(int)PY Level:(int)Level MapType:(int)MapType Name:(NSString *)Name PID:(NSString *)PID Addr:(NSString *)addr Tel:(NSString *)tel Type:(NSString *)type ID:(NSString *)Id poiButton:(UIButton*)poiButton;

// 새로운 url공유
// 지도페이지
- (ServerRequester *)requestMapURL:(id)target action:(SEL)action PX:(int)PX PY:(int)PY PID:(NSString *)PID Name:(NSString *)Name Addr:(NSString *)addr Tel:(NSString *)tel poiButton:(UIButton *)poiButton detailType:(int)type mapType:(int)mapType;
// 검색결과페이지
- (ServerRequester *)requestSearchURL:(id)target action:(SEL)action PX:(int)PX PY:(int)PY Query:(NSString *)query SearchType:(NSString *)searchType order:(NSString *)order;
// 상세페이지
- (ServerRequester *)requestDetailURL:(id)target action:(SEL)action PID:(NSString *)poi_id DetailType:(int)detailType Addr:(NSString *)addr StId:(NSString *)stId;

// ===================
// [ 예외처리 method ]
// ===================
- (ServerRequester *)requestExceptionLogging:(id)target action:(SEL)action exceptionMessage:(NSString*)exceptionMessage;
- (void)finishExceptionLogging:(id)request;
// *******************

// 설정관련

// =========================
// [ 공지사항리스트 method ]
// =========================
- (ServerRequester *)requestNoticeList:(id)target action:(SEL)action;
- (void) finishNoticeList:(id)request;
// ========================
// [ 공지사항 상세 method ]
// ========================
- (ServerRequester *)requestNoticeDetail:(id)target action:(SEL)action SeqNo:(int)SeqNo :(int)number;
- (void) finishNoticeDetail:(id)request;


// ===================
// [ 앱버전 method ]
// ===================
- (ServerRequester *)requestAppVersion:(id)target action:(SEL)action;
- (void) finishVersion:(id)request;

// ===================
// [ 테마버전 method ]
// ===================
- (ServerRequester *)requestThemeVersion:(id)target action:(SEL)action;
- (void) finishThemeVersion:(id)request;

// ===================
// [ 테마호출 method ]
// ===================
- (ServerRequester *)requestThemeInfoList:(id)target action:(SEL)action version:(NSString *)ver;
- (void) finishThemeInfoList:(id)request;
- (ServerRequester *) requestThemeInfoImageDownload :(id)target action:(SEL)action downloadList:(NSArray*)downloadList downloadIndex:(NSInteger)downloadIndex;
- (void) finishThemeInfoImageDownload :(id)request;

// ===================
// [ 테마상세 method ]
// ===================
- (ServerRequester *)requestThemeDetail:(id)target action:(SEL)action themeCode:(NSString *)themeCode pX:(int)px pY:(int)py radius:(int)rad;
- (void) finishThemeDetail:(id)request;

// ===================
// [ 추천검색어 method ]
// ===================
- (ServerRequester *) requestRecommendWordVersion :(id)target action:(SEL)action;
- (void) finishRecommendWordVersion :(id)request;
- (ServerRequester *) requestRecommendWordDownload :(id)target action:(SEL)action version:(int)version hash:(NSString*)hash;
- (void) finishRecommendWordDownload :(id)request;

// ===================
// [디바이스 정보 method ]
// ===================
- (ServerRequester *) requestDeviceDisplay :(id)target action:(SEL)action;
- (void) finishDeviceDisplay :(id)request;

// ===================
// [메인공지사항 method ]
// ===================
- (ServerRequester *) requestNoticePopup :(id)target  action:(SEL)action;
- (void) finishNoticePopup :(id)request;

// ===================
// [KHUB method ]
// ===================
- (ServerRequester *) requestJoinInfo:(id)target action:(SEL)action phoneNum:(NSString *)phoneNumber;
- (void) finishJoinInfo:(id)request;

// ===========================
// [ 교통옵션 method ]
// ===========================
- (ServerRequester*) requestTrafficOptionCCTVList :(id)target action:(SEL)action minX:(float)minX minY:(float)minY maxX:(float)maxX maxY:(float)maxY;
- (ServerRequester*) requestTrafficOptionBusStationList :(id)target action:(SEL)action coordidate:(Coord)coordinate radius:(int)radius;
- (ServerRequester*) requestTrafficOptionSubwayStationList :(id)target action:(SEL)action coordidate:(Coord)coordinate radius:(int)radius;
- (ServerRequester*) requestTrafficOptionCCTVInfo :(id)target action:(SEL)action cctvid:(NSString*)cctvid cctvCoordinate:(Coord)cctvCoordinate;
- (ServerRequester *)requestTrafficRealtimeBusTimeTable :(id)target action:(SEL)action busid:(NSString*)busid;
- (ServerRequester *)requestTrafficRealtimeSubwayTimeTable :(id)target action:(SEL)action subwayid:(NSString*)subwayid;

// =================
// [ 폴리곤 method ]
// =================
- (ServerRequester *) requestPolygonSearch :(id)target action:(SEL)action table:(NSString *)fcNm loadKey:(NSString *)idBgm;
@end

