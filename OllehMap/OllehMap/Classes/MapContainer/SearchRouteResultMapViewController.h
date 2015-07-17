//
//  SearchRouteResultMapViewController.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 6. 11..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

// 맵뷰 관련 모든 참조는 아래 헤더에서 관리한다.
#import "CommonMapViewController.h"
#import "ServerConnector.h"
#import "OMCustomView.h"
#import "DbHelper.h"
#import "FavoriteViewController.h"

// 뷰 컨트롤러 렌더링 상태 열거형
typedef enum
{
    OM_SRRMV_ViewRenderType_NONE = 0,
    OM_SRRMV_ViewRenderType_CAR_MAP = 1,
    OM_SRRMV_ViewRenderType_CAR_LIST = 2,
    OM_SRRMV_ViewRenderType_PUBLIC_SELECT = 3,
    OM_SRRMV_ViewRenderType_PUBLIC_MAP = 4,
    OM_SRRMV_ViewRenderType_PUBLIC_LIST = 5
} OM_SRRMV_ViewRenderType;

// 대중교통 종류
typedef enum
{
    OM_SRRMV_PublicMethodType_Recommend = 0,
    OM_SRRMV_PublicMethodType_Bus = 1,
    OM_SRRMV_PublicMethodType_Subway = 2,
    OM_SRRMV_PublicMethodType_Both = 3
} OM_SRRMV_PublicMethodType;
@interface CarScrollView : UIScrollView
@end
@interface PublicScrollView : UIScrollView
@end

@interface SearchRouteResultMapViewController : CommonMapViewController <UIApplicationDelegate,
UIScrollViewDelegate,
KMapViewDelegate, OverlayDelegate, ReverseGeocodingDelegate>
{
    
    // ***********************
    // [ 뷰 컨트롤러 상태변수 ]
    // ***********************
    
    // 대중교통 먼저 시작 상태
    BOOL _isPublicFirst;
    
    // 현재 뷰 컨트롤러 렌더링 타입
    OM_SRRMV_ViewRenderType _currentViewRenderType;
    
    // 길찾기 세부경로 (-1:전체)
    int _currentRouteDetailPathIndex;
    
    // 내위치 모드 (일반/내위치/나침판) **OMS에서 관리하는 메인맵의 내위치 모드와는 독립적이어야 함
    int _currentMyLocationMode;
    
    // 자동차 길찾기 경로선택 옵션
    int _currentRouteCarSelector;
    
    // 최근 줌레벨
    int _lastKMapZoomLevel;
    
    // ****************************
    // [ 뷰 컨트롤러 공통 오브젝트 ]
    // ****************************
    
    // 상단 네비게이션 그룹 뷰
    UIView *_vwNavigationGroup;
    // 네비게이션 좌우측 버튼
    UIButton *_btnNavigationLeftButton;
    UIButton *_btnNavigationRightButton;
    // 네비게이선 중앙 버튼
    UIButton *_btnNavigationCarButton;
    UIButton *_btnNavigationPublicButton;
    
    // 경로 지도 & 목록 뷰
    UIView *_vwRoutePathMapContainer;
    UIView *_vwRoutePathListContainer;
    
    // 내위치 토글 버튼
    UIButton *_btnMyLocation;
    
    // 지도타입 토글 버튼 (일반/하이브리드)
    UIButton *_btnMapRenderStyle;
    // 지도 교통량 토글 버튼
    UIButton *_btnMapTrafficInfo;
    // 지도 교통량 안내 이미지뷰
    UIImageView *_imgvwMapTrafficInfo;
    
    // 하단 버튼 그룹 뷰 (실제 버튼은 상황별로 각각 렌더링하도록 한다)
    UIView *_vwBottomButtonGroup;
    
    // 경로탐색 다이얼로그
    UIView *_vwRouteSelectorDialog;
    
    // 지도모드 폴리곤라인
    PolylineOverlay *_plovrPath;
    PolylineOverlay *_plovrWalk1;
    PolylineOverlay *_plovrWalk2;
    PolylineOverlay *_plovrWalk3;
    
    // 내위치 이미지뷰
    UIImageView  *_imgvwMyArea;
    UIImageView *_imgvwMyDirection;
    
    // 경로 상세포인트 관리를 위한 리스트
    NSMutableArray *_detailPointOverlays;
    
    
    // *********************
    // [ 자동차 + 지도 모드 ]
    // *********************
    
    // 하단 길찾기 경로정보 ( 시간거리 || 포인트정보)
    UIView *_vwCarRouteDetailPathInfoGroup;
    // 하단 길찾기 요약정보 - 전체경로 & 옵션 -
    UIView *_vwCarRouteSummaryInfoGroup;
    // 경로옵션 뷰 (딤드팝업)
    UIView *_vwCarRouteSelectorPopup;
    
    // *********************
    // [ 자동차 + 목록 모드 ]
    // *********************
    
    // ***************************
    // [ 대중교통 + 경로선택 모드 ]
    // ***************************
    
    // 경로선택 뷰
    UIView *_vwPublicRouteSelector;
    // 현재 선택된 대중교통 종류
    OM_SRRMV_PublicMethodType _currentPublicMethod;
    // 현재 선택된 대중교통 인덱스
    int _currentPublicMethodListIndex;
    
    // ************************
    // [ 대중교통 + 지도 모드 ]
    // ************************
    
    // 하단 길찾기 경로정보 ( 시간거리 || 포인트정보)
    UIView *_vwPublicRouteDetailPathInfoGroup;
    // 하단 길찾기 요약정보 - 전체경로 & 옵션 -
    UIView *_vwPublicRouteSummaryInfoGroup;
    
    
    // ************************
    // [ 대중교통 + 목록 모드 ]
    // ************************
    
    ////
    CarScrollView *_scrollView;
    UIPageControl *_pageControl;
    
    PublicScrollView *_scrollViewPub;
    UIPageControl *_pageControlPub;
    //
    // 실시간 정보 뷰
    UIView *_vwRealtimeTrafficTimeTableContainer;
    // 실시간 정보 새로고침 버튼
    OMButton *_btnRealtimeRefresh;

    
    // 교통옵션 사용시 마지막으로 렌더링한 좌표값
    Coord _trafficOptionLastRenderCoordinate;
    NSTimeInterval _trafficOptionLastRequestTime;
    // 테마 사용시 마지막으로 렌더링한 좌표값
    // 교통&테마 반경검색 관련 딜레이관리용
    NSMutableDictionary *_themesRequestInfo;
}

// ==========================================
// [  ]
// ==========================================
// ******************************************
@property (nonatomic, assign) Coord themeLastRenderingCoordinate;
@property (atomic, readonly) NSMutableDictionary *themesRequestInfo;

// =========================
// [ 화면공통 렌더링 메소드 ]
// =========================
- (void) initComponents;
- (void) renderCommonNavigationBar;
- (void) renderCommonBottomButtonsWithOllehNavi :(BOOL) useOllehNavi;
- (void) addFavorite :(id)sender;
- (void) linkOllehNavi :(id)sender;
- (void) showPublicSelectList :(id)sender;
- (void) showCarMap :(id)sender;
- (void) onMyLocation :(id)sender;
- (void) onTraffic :(id)sender;
- (void) onMapRenderType :(id)sender;
- (void) onNavigationLeftButton :(id)sender;
- (void) onNavigationRightButton :(id)sender;
- (void) adjustMyArea;
- (void) adjustMyAreaRadius;
- (void) showRouteRouteImageOverlay :(BOOL)show;
// *************************


// ================================
// [ 자동차 - 공통 - 렌더링 메소드 ]
// ================================
- (void) showCarRouteSelector :(id)sender;
- (void) closeCarRouteSelector :(id)sender;
- (void) onCarRouteSelectorCell_Down :(id)sender;
- (void) onCarRouteSelectorCell_Up :(id)sender;
- (void) searchRouteCarRealTime :(id)sender;
- (void) searchRouteCarFreePass :(id)sender;
- (void) searchRouteCarShortDistance :(id)sender;
- (void) searchRouteCarHighWay :(id)sender;
- (void) requestCarSearchRouteSelector;
- (void) onCarListSelectDetailPathCell :(id)sender;
- (void) onCarListSelectDetailPathCell_Down :(id)sender;
- (void) onCarListSelectDetailPathCell_UpOutside :(id)sender;
// ********************************

// ================================
// [ 자동차 - 지도 - 렌더링 메소드 ]
// ================================
- (void) renderCarMap;
- (void) renderCarMapPathPolygon;
- (void) renderCarMapRouteDetailPathInfoMiddle:(int)pathIndex :(int)viewSight;
- (void) renderCarMapRouteDetailPathInfo :(int)pathIndex;
- (void) renderCarMapRouteSummaryInfo;
- (void) onCarRoutePathPrev :(id)sender;
- (void) onCarRoutePathNext :(id)sender;
// ********************************

// ================================
// [ 자동차 - 목록 - 렌더링 메소드 ]
// ================================
- (void) renderCarList;
- (void) renderCarListRouteSummaryInfo;
- (void) renderCarListRouteDetailPathTable;
// ********************************

// ==================================
// [ 대중교통 - 공통 - 렌더링 메소드 ]
// ==================================
- (void) requestPublicSearchRoute;
- (NSDictionary *) getCurrentPublicRouteData;
- (int) getPublicMethodIconNumber :(int)methodtype :(int)subnumber;
// **********************************

// ==================================
// [ 대중교통 - 선택 - 렌더링 메소드 ]
// ==================================
- (void) renderPublicSelector;
- (void) renderPublicSelectorCategoryTab;
- (void) renderPublicSelectorRouteMethodListTable;
- (void) onPublicCategoryRecommend :(id)sender;
- (void) onPublicCategoryBus :(id)sender;
- (void) onPublicCategorySubway :(id)sender;
- (void) onPublicCategoryBoth :(id)sender;
- (void) onPublicMethod :(id)sender;
- (void) onPublicMethod_Down:(id)sender;
- (void) onPublicMethod_UpOutside:(id)sender;
// **********************************

// ==================================
// [ 대중교통 - 목록 - 렌더링 메소드 ]
// ==================================
- (void) renderPublicList;
- (void) renderPublicListRouteSummaryInfo;
- (void) renderPublicListRouteDetailPathTable;
- (void) onPublicListRouteDetailPathTableToMap :(id)sender;
- (void) onPublicListRouteDetailPath_Down :(id)sender;
- (void) onPublicListRouteDetailPath_UpOutside :(id)sender;
// **********************************


// ==================================
// [ 대중교통 - 지도 - 렌더링 메소드 ]
// ==================================
- (void) renderPublicMap;
- (void) renderPublicMapPathPolygon;
- (void) renderPublicMapRouteDetailPathInfoMiddle:(int)pathIndex :(int)viewSight;
- (void) renderPublicMapRouteDetailPathInfo :(int)pathIndex;
- (void) renderPublicMapRouteSummaryInfo;
- (void) onPublicRoutePathPrev :(id)sender;
- (void) onPublicRoutePathNext :(id)sender;
// **********************************


// ==============================
// [ KMap 터치 이벤트 메소드 시작 ]
// ==============================
- (void) mapTouchBegan:(KMapView*)mapView Events:(UIEvent*)event;
- (void) mapTouched:(KMapView*)mapView Events:(UIEvent*)event;
- (void) mapLongTouched:(NSValue *)coord;
- (void) mapDoubleTouched:(KMapView*)mapView Events:(UIEvent*)event;
- (void) mapTouchMoved:(KMapView*)mapView Events:(UIEvent*)event;
- (void) mapMultiTouched:(KMapView *)mapView Events:(UIEvent *)event;
- (void) mapTouchEnded:(KMapView*)mapView Events:(UIEvent*)event;
- (void) overlayTouched:(Overlay *)overlay;
- (void) mapBoundsChanged:(KMapView *)mapView Bounds:(KBounds)bounds;
- (void) mapStatusChanged:(NSNumber *)mapLoad isZoom:(NSNumber *)isZoom;
// ******************************

// ==============
// [ 지도교통옵션 메소드 ]
// ==============
- (void) showMapTrafficOptionView:(BOOL)show;
// ==============

// ==============
// [ 보조 메소드 ]
// ==============
- (NSString*) getSearchRouteCarRGType :(int) type;
- (NSString*) getDistanceRefined :(double) distance;
- (NSString*) getTimeRefined :(double) time;
- (NSString*) getTaxiFareRefined :(double) distance localCode :(int)localCode;
- (NSString*) getAfterFareRefined :(double) fare;
// **************



@end
