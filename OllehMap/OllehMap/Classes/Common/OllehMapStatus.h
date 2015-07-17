//
//  OllehMapStatus.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 17..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "OMClassCategory.h"

#import "OMSearchResult.h"
#import "OMSearchRouteResult.h"
#import "CommonGW.h"
#import "GANTracker.h"

#define SearchResult_Page_MaxRow 15
#define RecentSearch_MaxCount 25

#define OM_RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
double convertHexToDecimal (NSString *hex);
UIColor* convertHexToDecimalRGBA (NSString *r, NSString *g, NSString *b, float a);

NSString* stringValueOfDictionary (NSDictionary *dic, NSString *key);
NSString* tryStringValueOfDictionary (NSDictionary *dic, NSString *key, NSString *defaultValue);
NSNumber* numberValueOfDiction (NSDictionary *dic, NSString *key);
id objectForKey ( id coll, NSString *key);
id objectForKeyWithDefault ( id coll, NSString *key, NSObject *defaultValue);
id objectAtIndex ( id coll, NSInteger index);
id objectAtIndexWithDefault ( id coll, NSInteger index, NSObject *defaultValue);

// 위치정보 받아오지 못할 경우 기본값 "서울시청"으로 매크로처리
#ifdef DEBUG
// KTH본사
//#define OM_DefaultCoord CoordMake(949053.521651,1943896.028507)
// MIKSYSTEM 946392 1943191
#define OM_DefaultCoord CoordMake(946392,1943191)
#else
// 서울시청
#define OM_DefaultCoord CoordMake(953925,1952026)
#endif

enum OMStatus_MapRenderType
{
    MapRenderType_Normal = 0,
    MapRenderType_SearchResult_SinglePOI = 1, MapRenderType_SearchResult_MultiPOI = 2,
    MapRenderType_SearchResult_Route = 3,
    MapRenderType_SearchResult_BusLineRoute = 4,
    MapRenderType_SearchResult_LinePolyGon = 5
};
typedef enum
{
    MainMap_SinglePOI_Type_Normal = 0,
    MainMap_SinglePOI_Type_Favorite = 1,
    MainMap_SinglePOI_Type_Recent = 2
}MainMap_SinglePOI_Type;

enum OMStatus_ActionType
{
    ActionType_MAP = 0, ActionType_SEARCH = 1, ActionType_SEARCHROUTE = 2, ActionType_THEME = 3, ActionType_CONFIG = 4
};
enum OMStatus_TouchesType
{
    TouchesType_NOT = 0, TouchesType_TAP = 1, TouchesType_DBLTAP = 2,  TouchesType_LONGTAP = 3,  TouchesType_MOVE = 4
};
enum OMStatus_MapScreenMode
{
    MapScreenMode_NORMAL = 0, MapScreenMode_FULL = 1
};
enum SearchTargetType
{
    SearchTargetType_NONE = 0, SearchTargetType_START = 1, SearchTargetType_DEST = 2, SearchTargetType_VISIT = 3, SearchTargetType_VOICENONE = 4, SearchTargetType_VOICESTART = 5, SearchTargetType_VOICEVISIT = 6, SearchTargetType_VOICEDEST = 7
};

enum OMStatus_MapLocationMode
{
    MapLocationMode_None = 0, MapLocationMode_NorthUp = 1, MapLocationMode_Commpass = 2
};

// 경로탐색(자동차) 탐색종류
enum SearchRoute_Car_SearchType
{
    SearchRoute_Car_SearchType_ShortDistance = 0,
    SearchRoute_Car_SearchType_HighWay = 1,
    SearchRoute_Car_SearchType_FreePass = 2,
    SearchRoute_Car_SearchType_Optimal = 3,
    SearchRoute_Car_SearchType_RealTime = 5
};

// 경로탐색(대중교통) 정류장
typedef struct
{
    NSString *strID;
    NSString *strName;
    int nStationType;
    Coord crd;
}X_SearchRoute_Public_Station;
// 경로탐색(대중교통) 환승정보
typedef struct
{
    int nDistanceType;
    int nDistance;
    int nEndID;
    int nStartID;
    NSString *strStartName;
    NSString *strEndName;
    NSString *strLaneName;
    int nMethodType;
    int nRgType;
    Coord crd;
}X_SearchRoute_Public_Gate;

// View 또는 Overlay 관련 태그(tag) 정의
enum OMTags
{
    // 기본 :: 값 없음
    OMTags_None = 0
    // UIView 타입 10,000 번대 (10,000 ~ 19,999)
    ,OMTags_View_None = 10000
    ,OMTags_View_PopupMenuOnPOI = 11000
    // UIButton 타입 20,000 번대 (20,000 ~ 29,999)
    ,OMTags_Button_None = 20000
    ,OMTags_Button_StartButtonOnPOI = 20010
    ,OMTags_Button_DestButtonOnPOI = 20020
    ,OMTags_Button_VisitButtonOnPOI = 20030
    ,OMTags_Button_ShareButtonOnPOI = 20040
    // KMap Overlay 타입 30,000 번대 (30,000 ~ 39,999)
    ,OMTags_Overlay_None = 30000
    ,OMTags_Overlay_PointOnPOI = 30010
    ,OMTags_Overlay_SearchResult_SinglePointONPOI = 30020
    ,OMTags_Overlay_SearchResult_MultiPointONPOI = 30030
    ,OMTags_Overlay_SearchResult_MultiPointONPOI_Alphabet = 30031
    ,OMTags_Overlay_MyArea = 30100
};

// KMap 관련 정의
#define KMap_ZoomLevel_Maximun  12
#define KMap_ZoomLevel_MaximunHybrid 13
#define KMap_ZoomLevel_Minimum  0


// 네트워크 연결상태
typedef enum
{
    OMReachabilityStatus_disconnected = 0,
    OMReachabilityStatus_connected_3G,
    OMReachabilityStatus_connected_WiFi
} OMReachabilityStatus;




@interface OllehMapStatus : NSObject
{

    // **************
    // [ 앱 상태변수 ]
    // **************
    
    // 동작 : 지도,테마,길찾기,설정 분류
    int _currentActionType;
    // 터치 : 최근에 입력된 터치이벤트 종류
    int _currentTouchesType;
    // 맵 스크린 모드, 일반/풀스크린
    int _currentMapScreenMode;
    
    // 검색대상 : 현재 검색창의 대상 시작,도착,경유지 분류
    int _currentSearchTargetType;
    
    // 지도 현재위치 타입 : 복쪽고정, 나침반 타입분류
    int _currentMapLocationMode;
    
    // 디버깅용 변수
    NSMutableString *_debuggingString;
    
    // 검색결과 전달변수
    OMSearchResult *_searchResult;
    OMSearchResult *_searchResultRouteStart;
    OMSearchResult *_searchResultRouteDest;
    OMSearchResult *_searchResultRouteVisit;
    OMSearchResult *_searchResultOneTouchPOI;
    
    // 첫화면 렌더링여부
    BOOL _isMainViewDidApper;
    // openURL 여부
    BOOL _calledOpenURL;
    
    // 백그라운드 뮤직 플레이어 상태 (1이면 아이팟 / 2이면 어플플레이어 실행중)
    int _soundState;

    
    // 위치공유
    BOOL _fbNewContact;
    BOOL _isPhotosCheck;
    UIImage *_photoimg;
    
    // 버스노선 정보보관
    NSMutableArray *_pushDataBusNumberArray;
    // 버스정류장 정보보관
    NSMutableArray *_pushDataBusStationArray;
    
    // 최근검색어 관리용 배열
    NSMutableArray *_recentSearch;
    // 즐겨찾기
    NSMutableArray *_favoriteList;
        
    // 음성검색 배열
    NSMutableArray *_voiceSearchArray;
    // 추천검색어 결과
	NSMutableArray		*_searchAutoMakeArray;
    
    // 추천검색어 변수
    char **_recommandWordTable;
    int _recommandWordTableRowCount;
    
    // 주소/장소/대중교통 검색결과 저장
    NSMutableDictionary	*_searchLocalDictionary;
	// searchLocalDictionary 데이터중 선택된 인덱스값
    int					_searchIndex;
    // 검색키워드
    NSString            *_keyword;
    
    // 길찾기 검색결과
    OMSearchRouteResult     *_searchRouteData;
    // 롱탭 POI검색결과
    NSMutableDictionary *_oneTouchPOIDictionary;
    // 라인폴리곤 정보
    NSMutableDictionary *_linePolygonDictionary;
    // 단말기 정보
    NSString *_deviceDisplayID;
    
    //==========//
    // POI 상세 //
    //==========//
    // 주소 딕
    NSMutableDictionary *_addressPOIDictionary;
    
    // poi상세정보 결과
    NSMutableDictionary *_poiDetailDictionary;
    // 기름상세정보 결과
    NSMutableDictionary *_oilDetailDictionary;
    // 영화관 주요정보 결과
    NSMutableDictionary *_movieDetailDictionary;
    // 영화관 리스트 결과
    NSMutableDictionary *_movieListDictionary;
    
    //=============//
    // 지하철 상세 //
    //=============//
    
    // 지하철 상세정보 결과
    NSMutableDictionary *_subwayDetailDictionary;
    // 지하철 시간정보 결과
    NSMutableDictionary *_subwayTimeDictionary;
    // 지하철 출구정보 결과
    NSMutableDictionary *_subwayExitDictionary;
    // 지하철 출구결과(2)
    NSMutableDictionary *_subwayRefinedExitDictionary;
    // 환승역 호선 저장
    NSMutableArray *_subwayExistArr;
    
    //============//
    // 버정 상세  //
    //============//
    NSMutableDictionary *_busStationNewDictionary;
    //============//
    // 노선  상세 //
    //============//
    
    // 새로운 버스노선 dic
    NSMutableDictionary *_busNumberNewDictionary;

    // laneId -> BIS ID(BIS)
    NSMutableDictionary *_laneIdToBisIdDictionary;

    // 버스노선 그리기 리스트(BIS)
    NSMutableDictionary *_busLineDrawingDictionary;
    
    
    // 위치공유시 정보
    NSMutableDictionary *_shareDictionary;
    
    //============//
    // 설      정 //
    //============//
    
    // 공지사항 리스트
    NSMutableDictionary *_noticeListDictionary;
    // 공지사항 상세
    NSMutableDictionary *_noticeDetailDictionary;
    // 공지사항 읽기 체크
    NSMutableArray *_noticeCheckArray;
    // 앱버전
    NSMutableDictionary *_appVersionDictionary;

    //==========//
    // 테    마 //
    //============
    NSMutableArray *_themeInfoList;
    NSMutableArray *_themeSearchResultList;
}
@property int soundState;
@property BOOL isPhotosCheck;
@property BOOL fbNewContact;
@property (nonatomic, retain) UIImage *photoimg;

@property (nonatomic, retain) NSMutableArray *pushDataBusNumberArray;
@property (nonatomic, retain) NSMutableArray *pushDataBusStationArray;

@property int currentActionType;
@property int currentTouchesType;
@property int currentMapScreenMode;
@property int currentSearchTargetType;
@property int currentMapLocationMode;
@property (retain, nonatomic) NSMutableString *debuggingString;

@property (retain, nonatomic) OMSearchResult *searchResult;
@property (retain, nonatomic) OMSearchResult *searchResultRouteStart;
@property (retain, nonatomic) OMSearchResult *searchResultRouteDest;
@property (retain, nonatomic) OMSearchResult *searchResultRouteVisit;
@property (retain, nonatomic) OMSearchResult *searchResultOneTouchPOI;

@property (nonatomic, assign) BOOL isMainViewDidApear;
@property (nonatomic, assign) BOOL calledOpenURL;

@property (nonatomic, retain) NSMutableArray *voiceSearchArray;
@property (nonatomic, retain) NSMutableArray *searchAutoMakeArray;
@property (nonatomic, retain) NSMutableDictionary *searchLocalDictionary;
@property (nonatomic, assign) int searchIndex;
@property (nonatomic, retain) NSString *keyword;

@property (nonatomic, retain) NSMutableArray *favoriteList;
@property (nonatomic, retain) NSMutableDictionary *addressPOIDictionary;
@property (nonatomic, retain) NSString *deviceDisplayID;

@property (nonatomic, retain) NSMutableDictionary *linePolygonDictionary;
@property (nonatomic, retain) OMSearchRouteResult *searchRouteData;
@property (nonatomic, retain) NSMutableDictionary *oneTouchPOIDictionary;
@property (nonatomic, retain) NSMutableDictionary *poiDetailDictionary;
@property (nonatomic, retain) NSMutableDictionary *oilDetailDictionary;
@property (nonatomic, retain) NSMutableDictionary *subwayDetailDictionary;
@property (nonatomic, retain) NSMutableDictionary *subwayTimeDictionary;
@property (nonatomic, retain) NSMutableDictionary *subwayExitDictionary;
@property (nonatomic, retain) NSMutableDictionary *subwayRefinedExitDictionary;
@property (nonatomic, retain) NSMutableDictionary *movieDetailDictionary;
@property (nonatomic, retain) NSMutableDictionary *movieListDictionary;
@property (nonatomic, retain) NSMutableArray *subwayExistArr;
@property (nonatomic, retain) NSMutableDictionary *busStationNewDictionary;

@property (nonatomic, retain) NSMutableDictionary *busNumberNewDictionary;
@property (nonatomic, retain) NSMutableDictionary *laneIdToBisIdDictionary;
@property (nonatomic, retain) NSMutableDictionary *busLineDrawingDictionary;
@property (nonatomic, retain) NSMutableDictionary *shareDictionary;

@property (nonatomic, retain) NSMutableDictionary *noticeListDictionary;
@property (nonatomic, retain) NSMutableDictionary *noticeDetailDictionary;
@property (nonatomic, retain) NSMutableArray *noticeCheckArray;
@property (nonatomic, retain) NSMutableDictionary *appVersionDictionary;

@property (atomic, retain) NSMutableArray *themeInfoList;
@property (atomic, retain) NSMutableArray *themeSearchResultList;

// ================
// [ 생성자 메소드 ]
// ================
+ (OllehMapStatus *) sharedOllehMapStatus;
+ (void) closeOllehMapStatus;
-(void) initStatus;
-(id) init;
-(void) dealloc;
// ****************

// 공지관리
- (void) addNoticeCheck :(int)sequenceNo;
- (int) getNoticeCheckCount;
- (NSMutableArray *) getNoticeCheckList;
- (void) removeNoticeCheckList:(int)key;

// =========================
// [ 최근검색어 관리 메소드 ]
// =========================
- (void) addRecentSearch :(NSMutableDictionary *)dicSearch;
- (int) getRecentSearchCount;
- (NSMutableArray *) getRecentSearchList;
- (void) removeRecentSearchOnCheckDelete;
- (void) completeRecenSearchEdting :(BOOL)isSave;
// *************************

// 추천검색어 관리 메소드
- (void) setRecommWord :(char**)table :(int)count;
- (int) getRecommWordRowCount;
- (NSString*) getRecommWord :(int)index;

// ==============
// [ 보조 메소드 ]
// ==============
- (void) resetLocalSearchDictionary:(NSString *)s;
// **************

// ==============
// [ 상태 메소드 ]
// ==============
- (BOOL) isNetworkConnected;
- (OMReachabilityStatus) getNetworkStatus;
// 맥어드레스 사용 중지
- (NSString *)getMACAddress:(NSString *)separator;
- (void) trackPageView :(NSString *)page;
- (void) setDisplayMapResolution :(int)resolution;
- (int) getDisplayMapResolution;
- (BOOL) isRetinaDisplay;
- (BOOL) isLongDisplay;
- (NSString*) getDeviceModel;
- (NSString *)generateUuidString;


// ==============
// [ 유효성 체크]
// ==============
- (BOOL) emailVaildCheck:(NSString *)emailId;
- (BOOL) number5VaildCheck:(NSString *)keyword;
- (BOOL) uniqueVaildCheck:(NSString *)keyword;
// LANEID -> 이미지스트링
- (NSString *) getLaneIdToImgString :(NSString *)laneId;

// 캡쳐이미지 리턴
- (UIImage *) returnCaptureImg :(UIView *)selfView;
// **************

// 업종분류 상위 2개만 표시
- (NSString *) ujNameSegment :(NSString *)omsUjString;

// cityCode -> cityName
-(NSString *) cityCodeToCityName : (int)Bl_CityCode;

// url로 이미지 보이기
- (UIImage*)urlGetImage:(NSString*)Url;

// URL 유효성 체크
- (NSString *) urlValidCheck:(NSString *)rawUrl;

// 버스타입으로 이미지숫자
- (int) getBusClassNumber:(int)busClass;
@end
