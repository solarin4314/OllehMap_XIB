//
//  MainMapViewController.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 4..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

// 맵뷰 관련 모든 참조는 아래 헤더에서 관리한다.
#import "CommonMapViewController.h"
#import "SearchRouteDialogViewController.h"
#import "SettingViewController2.h"
#import "OMCustomView.h"
#import "ShareViewController.h"
#import "FavoriteViewController.h"
#import "AddressPOIViewController.h"
#import "ThemeViewController.h"
#import "LegendViewController.h"

// 사각형 안에 좌표가 있는지 확인? 왼쪽X,Y 오른쪽X,Y, 값X,Y
#define SquareIn(leftX, leftY, rightX, rightY, valueX, valueY) (leftX <= returnCrd.x && returnCrd.x <= rightX && leftY <= returnCrd.y && returnCrd.y <= rightY)

typedef struct
{
    double x;
    double y;
} Ppoint;
typedef struct
{
    Ppoint x1;
    Ppoint y1;
} Lline;


@interface MainMapViewController : CommonMapViewController <UIApplicationDelegate
,KMapViewDelegate, OverlayDelegate
,UIScrollViewDelegate
,UIWebViewDelegate
,UIGestureRecognizerDelegate, UIAlertViewDelegate>
{
    // ********************
    // [ Private variable - non property ]
    // ********************
    
    // 현재 뷰컨트롤러의 지도렌더링 타입
    int _nMapRenderType;
    // 지도렌더링 타입이 SinglePOI 일때 세부 타입
    int _nMapRednerSinglePOICategory;
    
    // 교통옵션 사용시 마지막으로 렌더링한 좌표값
    Coord _trafficOptionLastRenderCoordinate;
    NSTimeInterval _trafficOptionLastRequestTime;
    // 테마 사용시 마지막으로 렌더링한 좌표값
    Coord _themeLastRenderingCoordinate;
    NSTimeInterval _themeLastRequestTime;
    // 교통&테마 반경검색 관련 딜레이관리용
    NSMutableDictionary *_themesRequestInfo;
    
    NSLock *_trafficCCTVLock, *_trafficBusStationLock, *_trafficSubwayStationLock, *_themeLock;
    
    // ***********************
    // [ Information objects ]
    // ***********************
    
    // MUltiPOI 처리를 위한 배열 (4가지 상이한 데이터를 동일형식으로 변환하기위함)
    NSMutableArray *_refinedMultiPOIList;
    // MultiPOI 선택된 인덱스
    int _selectedMultiPOIIndex;
    // MultiPOI 타입
    int _multiPOIMarkingType;
    
    // 자동업데이트 정보 (추천검색어)
    NSMutableDictionary *_updateInfoAutoRecommWord;
    
    // ***************
    // [ XIB outlets ]
    // ***************
    
    // 테마 업데이트 컨테이너 뷰
    UIView *_vwThemeUpdateContainer;
    UIProgressView *_pvwThemeUpdateProgress;
    
    // 실시간 정보 뷰
    UIView *_vwRealtimeTrafficTimeTableContainer;
    // 실시간 정보 새로고침 버튼
    OMButton *_btnRealtimeRefresh;
    
    // DB 업데이트 알림용 뷰
    UIView *_vwAutoUpdateContainer;
    UILabel *_lblAutoUpdateStatus;
    
    // 팝업 공지용 뷰 컨테이너
    UIView *_vwNoticePopupContainer;
    UIImageView *_imgvwNoticePopupNoReminerCheckbox;
    
    // KMap을 채울 컨테이너 뷰
    UIView *_vwKMapContainer;
    
    // 맵뷰 상단 navigationbar outlets
    UIView *_vwNavigationbar;
    // 검색영역 그룹
    UIView *_vwSearchGroup;
    UILabel *_lblSearchKeyword;
    // "내위치" 그룹
    UIView *_vwMyLocationButtonGroup;
    UIButton *_btnMyLocation;
    // 교통량 그룹
    UIView *_vwTrafficGroup;
    // 사이드버튼 그룹
    UIView *_vwSideButtonGroup;
    UIButton *_btnSideTraffic;
    UIButton *_btnSideKMapType;
    UIButton *_btnSideFavorite;
    // 현재주소 그룹
    UIView *_vwCurrentAddressGroup;
    UILabel *_lblCurrentAddress;
    // 하단버튼 그룹
    UIView *_vwBottomButtonGroup;
    UIButton *_btnBottomTheme;
    UIButton *_btnBottomSearchRoute;
    UIButton *_btnBottomConfiguration;
    
    UIButton *_btnBottomLegend;
    // 축척 그룹
    UIView *_vwZoomLevelGroup;
    UIImageView *_imgvwZoomLevel;
    
    // **********************
    // [ KMap inner objects ]
    // **********************
    OMImageOverlayLongtap *_currentLongTapOverlay;
    
    // ******************
    // [ NonXIB outlets ]
    // ******************
    
    // MultiPOI 리스트 선택 팝업 컨테이너
    UIView *_vwMultiPOISelectorContainer;
    
}

@property (nonatomic, retain) IBOutlet UIView *vwKMapContainer;
@property (nonatomic, retain) IBOutlet UIView *vwNavigationbar;
@property (nonatomic, retain) IBOutlet UIView *vwSearchGroup;
@property (nonatomic, retain) IBOutlet UILabel *lblSearchKeyword;
@property (nonatomic, retain) IBOutlet UIView *vwMyLocationButtonGroup;
@property (nonatomic, retain) IBOutlet UIButton *btnMyLocation;
@property (nonatomic, retain) IBOutlet UIView *vwTrafficGroup;
@property (nonatomic, retain) IBOutlet UIView *vwSideButtonGroup;
@property (nonatomic, retain) IBOutlet UIButton *btnSideTraffic;
@property (nonatomic, retain) IBOutlet UIButton *btnSideKMapType;
@property (nonatomic, retain) IBOutlet UIButton *btnSideFavorite;
@property (nonatomic, retain) IBOutlet UIView *vwCurrentAddressGroup;
@property (nonatomic, retain) IBOutlet UILabel *lblCurrentAddress;
@property (nonatomic, retain) IBOutlet UIView *vwBottomButtonGroup;
@property (nonatomic, retain) IBOutlet UIButton *btnBottomTheme;
@property (nonatomic, retain) IBOutlet UIButton *btnBottomSearchRoute;
@property (nonatomic, retain) IBOutlet UIButton *btnBottomConfiguration;
@property (retain, nonatomic) IBOutlet UIButton *btnBottomLegend;

@property (nonatomic, retain) IBOutlet UIView *vwZoomLevelGroup;
@property (nonatomic, retain) IBOutlet UIImageView *imgvwZoomLevel;

@property (nonatomic, assign) Coord themeLastRenderingCoordinate;
@property (nonatomic, assign) NSTimeInterval themeLastRequestTime;
@property (atomic, readonly) NSMutableDictionary *themesRequestInfo;

// ===========================
// [ MarkingPOI 클래스 메소드 ]
// ===========================
+ (void) markingSinglePOI_RenderType:(int)type animated:(BOOL)animated;
+ (void) markingMultiPOI_RenderType:(int)type animated:(BOOL)animated;
+ (void) markingBusLineRoute_BusName:(NSString*)busname animated:(BOOL)animated;
+ (void) markingLinePolygonPOI:(NSString *)keyword animated:(BOOL)animated;
+ (void) markingThemePOI_ThemeCode:(NSString*)themeCode mainThemeCode:(NSString*)mainThemeCode maxRenderingZoomLevel:(int)maxRenderingZoomLevel   animated:(BOOL)animated;
// ***************************


// =======================================
// [ MapViewController 초기화 메소드 시작 ]
// =======================================
- (void) InitComponents;
// ***************************************


// ==============================
// [ 메인뷰 화면처리 메소드 시작 ]
// ==============================
- (void) toggleScreenMode;
- (void) toggleScreenMode :(int)mode :(BOOL)animated;
- (void) toggleMyLocationMode :(int)mode;
- (void) toggleKMapStyle;
- (void) toggleKMapStyle :(OllehMapType)type;
- (void) toggleZoomLevel;
- (void) adjustTopSideButtons;
- (void) refreshCurrentAddressLabel;
- (void) setSearchKeyword :(NSString*)keyword :(BOOL)isKeyword;
- (void) clearRealtimeTrafficTimeTableForce;
// ******************************


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


// ==============================
// [ OllehMap - KMap 연동 메소드 ]
// ==============================
- (void) pinRouteStartPOIOverlay;
- (void) pinRouteVisitPOIOverlay;
- (void) pinRouteDestPOIOverlay;

- (void) pinLongtapPOIOverlay :(BOOL)isDisplay;
- (void) pinSearchSinglePOIOverlay :(BOOL)isDisplay;
- (void) pinSearchMultiPOIOverlay :(BOOL)isDisplay;
- (void) pinRecentPOIOverlay :(BOOL)isDisplay;
- (void) pinFavoritePOIOverlay :(BOOL)isDisplay;
- (void) pinTrafficOptionCCTVPOIOverlay :(ServerRequester*)request;
- (void) pinTrafficOptionBusStationPOIOverlay :(ServerRequester*)request;
- (void) pinTrafficOptionSubwayPOIOverlay:(ServerRequester *)request;
- (void) pinThemePOIOverlay :(BOOL)isDisplay;

- (void) pinPOIMarkerOption :(BOOL)isDisplay targetInfo:(NSDictionary*)targetInfo animated:(BOOL)animated;
- (void) pinPOIMarkerOption:(BOOL)isDisplay targetInfo:(NSDictionary *)targetInfo duplicatedInfo:(NSDictionary*)duplicatedInfo animated:(BOOL)animated;
- (void) onPOIMarkerOptionStartButton :(id)sender;
- (void) onPOIMarkerOptionDestButton :(id)sender;
- (void) onPOIMarkerOptionVisitButton :(id)sender;
- (void) onPOIMarkerOptionShareButton :(id)sender;
- (void) onPOIMarkerOptionDetailButton :(id)sender;

- (void) redrawMarkerOptionOverlayOnFront;

- (void) showDuplicatedPOIList :(OMImageOverlay*)overlay;

- (void) setMapLocationWithCoordinate:(Coord)coordinate WithZoomLevel:(int)zoomLevel;
// ******************************


// ======================
// [ 검색서비스 콜백함수 ]
// ======================
- (void) didFinishRequestOneTouchPOI :(id)request;
- (void) didFinishRequestPOISimpleInfo :(id)request;
- (void) didFinishRequestAllPOIDetail :(id)request;
- (void) didFinishRequestShortURL :(id)request;
- (void) didFinishRequestSubwayDetail:(id)request;
- (void) didFinishRequestBusDetail:(id)request;
- (void) didFinishRequestThemeSearch:(id)requst;
// **********************


// ====================
// [ 네비게이션 메소드 ]
// ====================
- (void) navGoToRootView :(id)sender;
- (void) navGoToPrevView :(id)sender;
// ********************


// ======================
// [ 지도교통옵션 메소드 ]
// ======================
- (void) showMapTrafficOptionView:(BOOL)show;
- (void) onOptionViewCloseButton:(id)sender;
- (void) onOptionViewUseTrafficInfo:(id)sender;
// ======================

// ======================
// [ IBOulet 메소드 시작 ]
// ======================
- (IBAction) clickMyLocationButton:(id)sender;
- (IBAction) openThemes:(id)sender;
- (IBAction) searchRoute:(id)sender;
- (IBAction) openConfiguration:(id)sender;
// 공지사항 콜백
- (void) finishNoticeListUICallBack:(id)request;
- (IBAction) touchSearchBox :(id)sender;
// 사이드버튼
- (IBAction) onTraffic:(id)sender;
- (IBAction) onKMapStyle:(id)sender;
- (IBAction) onFavorite:(id)sender;

// 범례버튼
- (IBAction)onLegend:(id)sender;

//// 길찾기 관련 IBAction
//- (void) clickPointOverlayStartButton:(id)sender;
//- (void) clickPointOverlayDestinationButton:(id)sender;
//- (void) clickPointOverlayVisitButton:(id)sender;
//- (void) clickPointOverlayShareLocationButton:(id)sender;
//- (void) clickPointOverlayDetailButton:(id)sender;
// 중첩POI 관련 메소드
- (void) onCloseDuplicatePOIList :(id)sender;
- (void) onSelectDuplicatePOI :(id)sender;
- (void) onSelectDuplicatePOI_Down:(id)sender;
- (void) onSelectDuplicatePOI_UpOutside:(id)sender;
// **********************


// =======================================
// [ 좌표-주소 메소드 시작 ]
// =======================================
- (void) requestReversGeocodingAddress :(Coord)coord geoType:(int)geoType;
- (void) finishReversGeocodingAddress :(id)request;
- (void) requestReversGeocodingToShortAddress :(Coord)coord geoType:(int)geoType;
- (void) finishReversGeocodingToShortAddress :(id)request;
// ***************************************

// ===================
// [ 보조 메소드 시작 ]
// ===================
- (Coord) translateNSValueToCoord :(NSValue *)value;
// *******************

@end



enum MainMapViewController_ReversGeocodingTargets
{
    MainMapReversGeocodingTarget_CurrentAddress = 0,
    MainMapReversGeocodingTarget_LongTap = 1
};