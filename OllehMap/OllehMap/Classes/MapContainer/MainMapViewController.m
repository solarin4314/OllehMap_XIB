//
//  MainMapViewController.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 4..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "MainMapViewController.h"

#import "CommonPOIDetailViewController.h"
#import "GeneralPOIDetailViewController.h"
#import "SubwayPOIDetailViewController.h"
#import "OilPOIDetailViewController.h"
#import "MoviePOIDetailViewController.h"
#import "ContactViewController.h"
#import "MyImage.h"
#import "OMToast.h"

#import "VoiceSearchViewController.h"
#import "CCTVViewController.h"

#import "OMReachability.h"

@interface MainMapViewController ()

// =======================
// [ 검색결과 처리 메소드 ]
// =======================
- (void) markingSinglePOI;
- (void) setMultiPOIType :(int)type;
- (void) markingMultiPOI;
- (BOOL) isDuplicatePOI :(Coord)crd1 :(Coord)crd2;
- (BOOL) isDuplicatePOI :(Coord)crd1 :(Coord)crd2 :(BOOL)wide;
- (void) markingBusLineRoute;
- (OMSearchResult *)getCurrentSearchResult;
- (OMSearchResult *)getCurrentSearchResultFromMultiPOI :(NSDictionary*)poiDic;
- (void) renderRealtimeTrafficBusTimeTable :(NSDictionary*)timetable :(NSString*)busid;
- (void) renderRealtimeTrafficSubwayTimeTable :(NSArray*)timetable :(NSString*)subwayid;
- (void) clearRealtimeTrafficTimeTable;
- (void) clearRealtimeTrafficTimeTable :(BOOL)withCheck;
// ******************************
@end

@implementation MainMapViewController

@synthesize vwKMapContainer = _vwKMapContainer;

@synthesize vwNavigationbar = _vwNavigationbar;
@synthesize vwSearchGroup = _vwSearchGroup;
@synthesize lblSearchKeyword = _lblSearchKeyword;
@synthesize vwMyLocationButtonGroup = _vwMyLocationButtonGroup;
@synthesize btnMyLocation = _btnMyLocation;
@synthesize vwTrafficGroup = _vwTrafficGroup;
@synthesize vwSideButtonGroup = _vwSideButtonGroup;
@synthesize btnSideTraffic = _btnSideTraffic;
@synthesize btnSideKMapType = _btnSideKMapType;
@synthesize btnSideFavorite = _btnSideFavorite;
@synthesize vwCurrentAddressGroup = _vwCurrentAddressGroup;
@synthesize lblCurrentAddress = _lblCurrentAddress;
@synthesize vwBottomButtonGroup = _vwBottomButtonGroup;
@synthesize btnBottomTheme = _btnBottomTheme;
@synthesize btnBottomSearchRoute = _btnBottomSearchRoute;
@synthesize btnBottomConfiguration = _btnBottomConfiguration;
@synthesize vwZoomLevelGroup = _vwZoomLevelGroup;
@synthesize imgvwZoomLevel = _imgvwZoomLevel;

@synthesize themeLastRequestTime = _themeLastRequestTime;
@synthesize themesRequestInfo = _themesRequestInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    // *************************
    // [ 커스텀 뷰컨트롤러 생성 ]
    // *************************
    
    // 뷰컨트롤러 NIB가 기본값이 아닐때...
    if ( ![nibNameOrNil isEqualToString:@"MainMapViewController"] )
    {
        // 싱글 POI 처리
        if ( [nibNameOrNil isEqualToString:@"MainMapViewController_SearchResult_SinglePOI"] )
        {
            _nMapRenderType = MapRenderType_SearchResult_SinglePOI;
            _nMapRednerSinglePOICategory = MainMap_SinglePOI_Type_Normal;
        }
        // 싱글 POI 처리 - Favorite
        else if ( [nibNameOrNil isEqualToString:@"MainMapViewController_SearchResult_SinglePOI_Favorite"] )
        {
            _nMapRenderType = MapRenderType_SearchResult_SinglePOI;
            _nMapRednerSinglePOICategory = MainMap_SinglePOI_Type_Favorite;
        }
        // 싱글 POI 처리 - Recent
        else if ( [nibNameOrNil isEqualToString:@"MainMapViewController_SearchResult_SinglePOI_Recent"] )
        {
            _nMapRenderType = MapRenderType_SearchResult_SinglePOI;
            _nMapRednerSinglePOICategory = MainMap_SinglePOI_Type_Recent;
        }
        // 멀티 POI 처리
        else if ( [nibNameOrNil isEqualToString:@"MainMapViewController_SearchResult_MultiPOI"] )
        {
            _nMapRenderType = MapRenderType_SearchResult_MultiPOI;
        }
        // 버스노선도 처리
        else if ( [nibNameOrNil isEqualToString:@"MainMapViewController_SearchResult_BusLineRoute"] )
        {
            _nMapRenderType = MapRenderType_SearchResult_BusLineRoute;
        }
        // 라인폴리곤 처리
        else if ([nibNameOrNil isEqualToString:@"MainMapViewController_SearchResult_LinePolyGon"])
        {
            _nMapRenderType = MapRenderType_SearchResult_LinePolyGon;
        }
        
        nibNameOrNil = @"MainMapViewController";
    }
    // 기본 뷰컨트롤러 생성이면 그대로 진행
    else
    {
        _nMapRenderType = MapRenderType_Normal;
    }
    
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self InitComponents];
    
    // POI 지도화면 처리를 위해서.. (딱 첫진입시에만 한번 실행하면됨)
    if ( _nMapRenderType == MapRenderType_SearchResult_SinglePOI )
        [self markingSinglePOI];
    else if ( _nMapRenderType == MapRenderType_SearchResult_MultiPOI )
        [self markingMultiPOI];
    else if ( _nMapRenderType == MapRenderType_SearchResult_BusLineRoute )
        [self markingBusLineRoute];
    else if ( _nMapRenderType == MapRenderType_SearchResult_LinePolyGon)
        [self markingLinePolyGon];
    
    [_vwKMapContainer setFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height - 20)];
}

- (BOOL) canBecomeFirstResponder
{
    if ( [MapContainer sharedMapContainer_Main].kmap.theme ) return YES;
        else return [super canBecomeFirstResponder];
}
- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ( event && event.type == UIEventTypeMotion && motion == UIEventSubtypeMotionShake )
    {
        //[OMMessageBox showAlertMessageTwoButtonsWithTitle:@"" message:@"테마검색을 종료 하시겠습니까?" target:self firstAction:nil secondAction:@selector(cancelTheme:) firstButtonLabel:@"아니오" secondButtonLabel:@"예"];
        // MIK.geun :: 20121019 // 물어보지않고 바로 테마 제거
        [self cancelTheme:nil];
    }
    
    [super motionEnded:motion withEvent:event];
}
- (void) cancelTheme :(id)sender
{
    // 테마상태에서 흔들렸다면..
    [[ThemeCommon sharedThemeCommon] clearThemeSearchResult];
    [[MapContainer sharedMapContainer_Main].kmap removeAllThemeOverlay];
    self.btnBottomTheme.selected = NO;
}

- (void) dealloc
{
    // ******************
    // [ non properties ]
    // ******************
    
    [_refinedMultiPOIList release];
    
    // **************
    // [ properties ]
    // **************
    [_vwMyLocationButtonGroup release]; _vwMyLocationButtonGroup = nil;
    
    [_vwZoomLevelGroup release]; _vwZoomLevelGroup = nil;
    [_vwBottomButtonGroup release]; _vwBottomButtonGroup = nil;
    [_lblCurrentAddress release]; _lblCurrentAddress = nil;
    [_vwCurrentAddressGroup release]; _vwCurrentAddressGroup = nil;
    [_vwMyLocationButtonGroup release]; _vwMyLocationButtonGroup = nil;
    [_vwSearchGroup retain]; _vwSearchGroup = nil;
    [_vwNavigationbar release]; _vwNavigationbar = nil;
    [_vwKMapContainer release]; _vwKMapContainer = nil;
    
    [_themesRequestInfo release]; _themesRequestInfo = nil;
    
    // ******************
    // [ NonXIB outlets ]
    // ******************
    
    [_vwMultiPOISelectorContainer release]; _vwMultiPOISelectorContainer = nil;
    [_vwAutoUpdateContainer release]; _vwAutoUpdateContainer = nil;
    [_lblAutoUpdateStatus release]; _lblAutoUpdateStatus = nil;
    [_vwNoticePopupContainer release]; _vwNoticePopupContainer = nil;
    [_imgvwNoticePopupNoReminerCheckbox release]; _imgvwNoticePopupNoReminerCheckbox = nil;
    [_vwRealtimeTrafficTimeTableContainer release]; _vwRealtimeTrafficTimeTableContainer = nil;
    [_btnRealtimeRefresh release]; _btnRealtimeRefresh = nil;
    [_vwThemeUpdateContainer release]; _vwThemeUpdateContainer = nil;
    [_pvwThemeUpdateProgress release]; _pvwThemeUpdateProgress = nil;
    
    
    
    [_btnBottomLegend release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setBtnBottomLegend:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
    // ******************
    // [ non properties ]
    // ******************
    
    [_refinedMultiPOIList release]; _refinedMultiPOIList = nil;
    
    // **************
    // [ properties ]
    // **************
    [_vwMyLocationButtonGroup release]; _vwMyLocationButtonGroup = nil;
    
    [_vwZoomLevelGroup release]; _vwZoomLevelGroup = nil;
    [_vwBottomButtonGroup release]; _vwBottomButtonGroup = nil;
    [_lblCurrentAddress release]; _lblCurrentAddress = nil;
    [_vwCurrentAddressGroup release]; _vwCurrentAddressGroup = nil;
    [_vwMyLocationButtonGroup release]; _vwMyLocationButtonGroup = nil;
    [_vwSearchGroup retain]; _vwSearchGroup = nil;
    [_vwNavigationbar release]; _vwNavigationbar = nil;
    [_vwKMapContainer release]; _vwKMapContainer = nil;
    
    [_themesRequestInfo release]; _themesRequestInfo = nil;
    
    // ******************
    // [ NonXIB outlets ]
    // ******************
    
    [_vwMultiPOISelectorContainer release]; _vwMultiPOISelectorContainer = nil;
    [_vwAutoUpdateContainer release]; _vwAutoUpdateContainer = nil;
    [_lblAutoUpdateStatus release]; _lblAutoUpdateStatus = nil;
    [_vwNoticePopupContainer release]; _vwNoticePopupContainer = nil;
    [_imgvwNoticePopupNoReminerCheckbox release]; _imgvwNoticePopupNoReminerCheckbox = nil;
    [_vwRealtimeTrafficTimeTableContainer release]; _vwRealtimeTrafficTimeTableContainer = nil;
    [_btnRealtimeRefresh release]; _btnRealtimeRefresh = nil;
    [_vwThemeUpdateContainer release]; _vwThemeUpdateContainer = nil;
    [_pvwThemeUpdateProgress release]; _pvwThemeUpdateProgress = nil;
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 항상 지도가 앞으로 나오도록 설정
    [[MapContainer sharedMapContainer_Main] showMapContainer:_vwKMapContainer :self];
    
    // sdk수정필요
    NSLog(@"== %d", [MapContainer sharedMapContainer_Main].kmap.mapDisplay);
    
    // 이벤트 트래킹 - 메인 지도화면 노출
    if (_nMapRenderType == MapRenderType_Normal) [oms trackPageView:@"/main_map"];
}

- (void) viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    // 쉐이크 이벤트를 얻기위한 등록
    [self becomeFirstResponder];
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    // 지도화면 전환되어 나타날때 줌레벨 체크
    [self toggleZoomLevel];
    
    // 하이브리드 or 평면지도 상태반영
    [_btnSideKMapType setSelected:[MapContainer sharedMapContainer_Main].kmap.mapType == KMapTypeHybrid];
    
    // 범례버튼 상태
    [_btnBottomLegend setHidden:!mc.kmap.CadastralInfo];
    
    
    // 교통량 상태 반영
    // MIK.geun :: 20121004 // 교통옵션 반영 이후 체크할 사항이 늘어남..
    BOOL trafficSelected = mc.kmap.trafficInfo || mc.kmap.trafficCCTV || mc.kmap.trafficBusStation || mc.kmap.trafficSubwayStation || mc.kmap.CadastralInfo;
    
    [_btnSideTraffic setSelected:trafficSelected];
    // 교통량 표시 상태
    [_vwTrafficGroup setHidden: !mc.kmap.trafficInfo];
    
    // 테마 사용여부에 따라 테마버튼 활성화
    _btnBottomTheme.selected = mc.kmap.theme;
    
    // 화면에 나타날때 지도 위치서비스도 다시 시작하도록 설정
    [mc.kmap restartUserLocationTracing];
    mc.kmap.delegate = self;
    
    // 지도 나타날때 현재 로케이션 설정대로 맞춰준다.
    // 최초 지도 로드시에는 0 (준비중) 인 상태로 지도 좌표가 (제주도 0,0)으로 나오게 되니까 피하도록 하자.
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        @autoreleasepool
        {
            NSInteger maxCount = 50;
            while ([MapContainer sharedMapContainer_Main].kmap.checkStartMapService != 3)
            {
                [NSThread sleepForTimeInterval:0.1];
                if ( maxCount-- <= 0) break;
            }
        }
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_release(group);
    if ( [[MapContainer sharedMapContainer_Main].kmap checkStartMapService] == 3 )
    {
        [self toggleMyLocationMode:[OllehMapStatus sharedOllehMapStatus].currentMapLocationMode];
    }
    
    // MIK.geun :: 20121011 // 메인지도가 아닌곳에서 교통 오버레이를 추가한경우 delegate 가 self 로 되어있어서 나중에 relase 되버린 self 를 찾아서 문제가됨.
    //MainMapViewController *rootMapView = (MainMapViewController*)[[OMNavigationController sharedNavigationController].viewControllers objectAtIndexGC:0];
    if ( mc.kmap.trafficCCTV || mc.kmap.trafficBusStation || mc.kmap.trafficSubwayStation )
        for (Overlay *overlay in [MapContainer sharedMapContainer_Main].kmap.getOverlays)
        {
            if ( overlay.delegate != self )
                overlay.delegate = self;
        }
    
    // 줌레벨 변경에 상관없이 주소는 항상 체크
    [self refreshCurrentAddressLabel];
    
    // MIK.geun :: 20121008
    // 화면 진입시... 실시간정보 여부 판단 (마지막 안전장치)
    [self clearRealtimeTrafficTimeTable:YES];
    
    
    if ( _nMapRenderType == MapRenderType_Normal && [OllehMapStatus sharedOllehMapStatus].isMainViewDidApear == NO )
    {
        [OllehMapStatus sharedOllehMapStatus].isMainViewDidApear = YES;
    }

}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void) viewWillDisappear:(BOOL)animated
{
    // 화면이 사라질때 지도 위치서비스도 중단
    [[MapContainer sharedMapContainer_Main].kmap stopUserLocationTracing];
    [MapContainer sharedMapContainer_Main].kmap.delegate = nil;
    
    [super viewWillDisappear:animated];
}



// ===========================
// [ MarkingPOI 클래스 메소드 ]
// ===========================

+ (void) markingSinglePOI_RenderType:(int)type animated:(BOOL)animated
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 테마 존재할 경우 클리어
    [[ThemeCommon sharedThemeCommon] clearThemeSearchResult];
    
    // 해당지역으로 이동시켜준다
    [[MapContainer sharedMapContainer_Main].kmap setCenterCoordinate:oms.searchResult.coordLocationPoint];
    
    // 최근-즐겨찾기-연락처검색 이면서 출발-경유-도착 대상검색인 경우 바로 길찾기 화면으로 처리
    if ( type == MainMap_SinglePOI_Type_Recent || type == MainMap_SinglePOI_Type_Favorite
        || [[[OMNavigationController sharedNavigationController].viewControllers lastObject] isKindOfClass:[ContactViewController class]] )
    {
        switch (oms.currentSearchTargetType)
        {
            case SearchTargetType_START:
            case SearchTargetType_VOICESTART:
            {
                [oms.searchResultRouteStart reset];
                [oms.searchResultRouteStart setUsed:YES];
                [oms.searchResultRouteStart setIsCurrentLocation:NO];
                [oms.searchResultRouteStart setStrLocationName:oms.searchResult.strLocationName];
                [oms.searchResultRouteStart setStrLocationAddress:oms.searchResult.strLocationAddress];
                [oms.searchResultRouteStart setCoordLocationPoint:oms.searchResult.coordLocationPoint];
                
                [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
                return;
            }
            case SearchTargetType_VISIT:
            case SearchTargetType_VOICEVISIT:
            {
                [oms.searchResultRouteVisit reset];
                [oms.searchResultRouteVisit setUsed:YES];
                [oms.searchResultRouteVisit setIsCurrentLocation:NO];
                [oms.searchResultRouteVisit setStrLocationName:oms.searchResult.strLocationName];
                [oms.searchResultRouteVisit setStrLocationAddress:oms.searchResult.strLocationAddress];
                [oms.searchResultRouteVisit setCoordLocationPoint:oms.searchResult.coordLocationPoint];
                [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
                return;
            }
            case SearchTargetType_DEST:
            case SearchTargetType_VOICEDEST:
            {
                [oms.searchResultRouteDest reset];
                [oms.searchResultRouteDest setUsed:YES];
                [oms.searchResultRouteDest setIsCurrentLocation:NO];
                [oms.searchResultRouteDest setStrLocationName:oms.searchResult.strLocationName];
                [oms.searchResultRouteDest setStrLocationAddress:oms.searchResult.strLocationAddress];
                [oms.searchResultRouteDest setCoordLocationPoint:oms.searchResult.coordLocationPoint];
                [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
                return;
            }
                
            default:
                break;
        }
    }
    
    // 뷰 컨트롤러 생성
    MainMapViewController *mmvc = nil;
    if ( type == MainMap_SinglePOI_Type_Favorite )
    {
        mmvc = [[MainMapViewController alloc] initWithNibName:@"MainMapViewController_SearchResult_SinglePOI_Favorite" bundle:nil];
    }
    else if ( type == MainMap_SinglePOI_Type_Recent )
    {
        mmvc = [[MainMapViewController alloc] initWithNibName:@"MainMapViewController_SearchResult_SinglePOI_Recent" bundle:nil];
    }
    else
    {
        mmvc = [[MainMapViewController alloc] initWithNibName:@"MainMapViewController_SearchResult_SinglePOI" bundle:nil];
    }
    
    
    // 애니메이션 초기화
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[OMNavigationController sharedNavigationController].view cache:NO];
    }
    
    // 현재 뷰컨트롤러를 네비게이션컨트롤러에 추가
    [[OMNavigationController sharedNavigationController] pushViewController:mmvc animated:NO];
    
    // 애니메이션 적용
    if (animated)
    {
        [UIView commitAnimations];
    }
    
    [mmvc release];
}

+ (void) markingMultiPOI_RenderType:(int)type animated:(BOOL)animated
{
    // 뷰 컨트롤러 생성
    MainMapViewController *mmvc = [[MainMapViewController alloc] initWithNibName:@"MainMapViewController_SearchResult_MultiPOI" bundle:nil];
    [mmvc setMultiPOIType:type];
    
    // 테마 클리어
    [[ThemeCommon sharedThemeCommon] clearThemeSearchResult];
    
    // 애니메이션 초기화
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[OMNavigationController sharedNavigationController].view cache:NO];
    }
    
    // 현재 뷰컨트롤러를 네비게이션컨트롤러에 추가
    [[OMNavigationController sharedNavigationController] pushViewController:mmvc animated:NO];
    
    // 애니메이션 적용
    if (animated)
    {
        [UIView commitAnimations];
    }
    
    [mmvc release];
}
+ (void) markingLinePolygonPOI:(NSString *)keyword animated:(BOOL)animated
{
    // 뷰 컨트롤러 생성
    MainMapViewController *mmvc = [[MainMapViewController alloc] initWithNibName:@"MainMapViewController_SearchResult_LinePolyGon" bundle:nil];
    
    
    // 애니메이션 초기화
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[OMNavigationController sharedNavigationController].view cache:NO];
    }
    
    // 현재 뷰컨트롤러를 네비게이션컨트롤러에 추가
    [[OMNavigationController sharedNavigationController] pushViewController:mmvc animated:NO];
    
    // 애니메이션 적용
    if (animated)
    {
        [UIView commitAnimations];
    }
    
    [mmvc release];

}
+ (void) markingBusLineRoute_BusName:(NSString *)busname animated:(BOOL)animated
{
    [[OllehMapStatus sharedOllehMapStatus].busLineDrawingDictionary setObject:busname forKey:@"BusName"];
    
    // 테마클리어
    [[ThemeCommon sharedThemeCommon] clearThemeSearchResult];
    
    // 뷰 컨트롤러 생성
    MainMapViewController *mmvc = [[MainMapViewController alloc] initWithNibName:@"MainMapViewController_SearchResult_BusLineRoute" bundle:nil];
    
    
    // 애니메이션 초기화
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[OMNavigationController sharedNavigationController].view cache:NO];
    }
    
    // 현재 뷰컨트롤러를 네비게이션컨트롤러에 추가
    [[OMNavigationController sharedNavigationController] pushViewController:mmvc animated:NO];
    
    // 애니메이션 적용
    if (animated)
    {
        [UIView commitAnimations];
    }
    
    [mmvc release];
}

+ (void) markingThemePOI_ThemeCode:(NSString*)themeCode mainThemeCode:(NSString*)mainThemeCode maxRenderingZoomLevel:(int)maxRenderingZoomLevel   animated:(BOOL)animated
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 통계
    [oms trackPageView:[NSString stringWithFormat:@"/theme/%@", themeCode]];
    
    // 무조건 루트로 빠져나간다.
    [[OMNavigationController sharedNavigationController] popToRootViewControllerAnimated:animated];
    
    // 교통옵션 제외하고 전부삭제
    [mc.kmap removeAllOverlaysWithoutTraffic];
    
    // 최대 렌더링 축척을 보정한다.
    if (maxRenderingZoomLevel < 0) maxRenderingZoomLevel = 9; // 200m 기본값으로 사용하자.
    
    // 테마 활성화 시킨다.
    [MapContainer sharedMapContainer_Main].kmap.theme = YES;
    [[ThemeCommon sharedThemeCommon].additionalInfo setObject:[NSNumber numberWithInt:maxRenderingZoomLevel] forKey:@"MaxRenderingZoomLevel"];
    [[ThemeCommon sharedThemeCommon].additionalInfo  setObject:themeCode forKey:@"ThemeCode"];
    [[ThemeCommon sharedThemeCommon].additionalInfo  setObject:mainThemeCode forKey:@"MainThemeCode"];
    
    
    
    
    // 메인지도를 불러온다.
    MainMapViewController *mmvc = (MainMapViewController*)[[OMNavigationController sharedNavigationController].viewControllers objectAtIndexGC:0];
    
    // 현재 줌레벨이 렌더링최대줌레벨보다 낮을 경우 (m..거리단위가 커질경우..) 보정한다.
    if ( mc.kmap.adjustZoomLevel < maxRenderingZoomLevel )
    {
        //[mc.kmap setZoomLevel:maxRenderingZoomLevel];
        [mc.kmap setAdjustZoomLevel:maxRenderingZoomLevel];
        //  강제로 맵 이동 호출  (**지도 축척이 변경됐는데 교통옵션 렌더링도 다시해야해서.. )
        [mmvc mapStatusChanged:[NSNumber numberWithInt:2] isZoom:[NSNumber numberWithBool:YES]];
    }
    
    // 위에서 불러온 메인지도 하단 테마버튼을 ON처리한다.
    [mmvc.btnBottomTheme setSelected:YES];
    
    // 그리고 테마검색 검증데이터 입력
    mmvc.themeLastRenderingCoordinate = mc.kmap.centerCoordinate;
    mmvc.themeLastRequestTime = [NSDate timeIntervalSinceReferenceDate];
    NSMutableDictionary *theme = [[NSMutableDictionary alloc] init];
    [theme setObject:[NSNumber numberWithBool:YES] forKey:@"IsZoom"];
    //[theme setObject:[NSNumber numberWithBool:YES] forKey:@"IsThemeSearchStartUp"];
    [theme setObject:[NSNumber numberWithDouble:mmvc.themeLastRequestTime] forKey:@"Time"];
    [mmvc.themesRequestInfo setObject:theme forKey:@"Theme"];
    [theme release];
    
    // 위에서 불러온 메인지도 테마 검색시도
    //[[ServerConnector sharedServerConnection] requestThemeDetail:mmvc action:@selector(didFinishRequestThemeSearch:) themeCode:themeCode pX:mc.kmap.centerCoordinate.x pY:mc.kmap.centerCoordinate.y radius:[mc getSpecialMapZoomLevelMeterWithScreen:mc.kmap.adjustZoomLevel]];
    [[ServerConnector sharedServerConnection] requestThemeDetail:mmvc action:@selector(didFinishRequestThemeSearch:) themeCode:themeCode pX:mc.kmap.centerCoordinate.x pY:mc.kmap.centerCoordinate.y radius:mc.getCurrentMapZoomLevelMeterWithScreen/2];
}

// ***************************


// =======================================
// [ MapViewController 초기화 메소드 시작 ]
// =======================================

- (void) InitComponents
{
    
    //    // 네트워크 연결 상태 체크
    //    if ([[OllehMapStatus sharedOllehMapStatus] getNetworkStatus] == OMReachabilityStatus_disconnected )
    //    {
    //        [OMMessageBox showAlertMessage:@"네트워크" :@"네트워크에 접속할수없습니다. 3G 또는 WiFi 상태를 확인바랍니다."];
    //
    //    }
    
    // *************************
    // [ 올레맵 상태변수 초기화 ]
    // *************************
    if (_nMapRenderType == MapRenderType_Normal)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        [oms setCurrentActionType:ActionType_MAP];
        [oms setCurrentSearchTargetType:SearchTargetType_NONE];
        [oms setCurrentMapLocationMode:MapLocationMode_NorthUp];
        [oms setCurrentMapScreenMode:MapScreenMode_NORMAL];
        [oms setCurrentTouchesType:TouchesType_NOT];
    }
    
    
    // POI 선택 인덱스 초기화 ( -2 : Onetouch / -1 : SinglePOI / 0~00 : MultiPOI )
    _selectedMultiPOIIndex = -100;
    
    // 교통옵션 사용시 마지막으로 렌더링한 좌표값
    _trafficOptionLastRenderCoordinate = CoordMake(0, 0);
    _trafficOptionLastRequestTime = 0;
    // 테마 사용시 마지막으로 렌더링한 좌표값
    _themeLastRenderingCoordinate = CoordMake(0, 0);
    _themeLastRequestTime = 0;
    // 교통&테마 반경검색 관련 딜레이관리용
    _themesRequestInfo = [[NSMutableDictionary alloc] init];
    
    // DB업데이트 알림
    _vwAutoUpdateContainer = [[UIView alloc]
                              initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,
                                                       [[UIScreen mainScreen] bounds].size.height)];
    [_vwAutoUpdateContainer setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
    [_vwAutoUpdateContainer setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.3]];
    _lblAutoUpdateStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 276, 69)];
    [_lblAutoUpdateStatus setFont:[UIFont boldSystemFontOfSize:15]];
    [_lblAutoUpdateStatus setTextColor:[UIColor whiteColor]];
    [_lblAutoUpdateStatus setBackgroundColor:[UIColor clearColor]];
    [_lblAutoUpdateStatus setTextAlignment:NSTextAlignmentCenter];
    
    // 팝업공지
    _vwNoticePopupContainer = [[UIView alloc]
                               initWithFrame:CGRectMake(0, 0,
                                                        [[UIScreen mainScreen] bounds].size.width,
                                                        [[UIScreen mainScreen] bounds].size.height
                                                        - 20
                                                        - ([[UIApplication sharedApplication] statusBarFrame].size.height-20) )];
    [_vwNoticePopupContainer setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight];
    [_vwNoticePopupContainer setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
    _imgvwNoticePopupNoReminerCheckbox = [[UIImageView alloc] initWithFrame:CGRectMake(18/2, 0, 56/2, 68/2)];
    
    
    // **********************************
    // [ 맵전용 네비게이션바 커스터마이징 ]
    // **********************************
    
    // 네비게이션바 배경설정
    UIImageView *imgvwBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_bg.png"]];
    [imgvwBackground setFrame:CGRectMake(0, 0, 320, 37)];
    [_vwNavigationbar addSubview:imgvwBackground];
    [imgvwBackground release];
    
    // 네비게이션바 타이틀 설정
    if (_nMapRenderType == MapRenderType_Normal)
    {
        UIImageView *imgvwTitle =  [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_title_text.png"]];
        [imgvwTitle setFrame:CGRectMake(246/2, 0, 148/2, 74/2)];
        [_vwNavigationbar addSubview:imgvwTitle];
        [imgvwTitle release];
    }
    // 검색결과 지도보기 화면일 경우
    else if (_nMapRenderType == MapRenderType_SearchResult_SinglePOI
             || _nMapRenderType == MapRenderType_SearchResult_MultiPOI
             || _nMapRenderType == MapRenderType_SearchResult_BusLineRoute
             || _nMapRenderType == MapRenderType_SearchResult_LinePolyGon)
    {
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(61.0f, 8.5f, 198.0f, 20.0f)];
        [lblTitle setTextAlignment:NSTextAlignmentCenter];
        [lblTitle setFont:[UIFont systemFontOfSize:20]];
        [lblTitle setTextColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [lblTitle setText:NSLocalizedString(@"Title_OllehMap_SearchResultMap", @"")];
        
        UILabel *lblTitleShadow = [[UILabel alloc] initWithFrame:CGRectMake(61.0f, 9.5f, 198.0f, 20.0f)];
        [lblTitleShadow setTextAlignment:NSTextAlignmentCenter];
        [lblTitleShadow setFont:[UIFont systemFontOfSize:20]];
        [lblTitleShadow setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75]];
        [lblTitleShadow setBackgroundColor:[UIColor clearColor]];
        [lblTitleShadow setText:NSLocalizedString(@"Title_OllehMap_SearchResultMap", @"")];
        
        [_vwNavigationbar addSubview:lblTitleShadow];
        [_vwNavigationbar addSubview:lblTitle];
        
        [lblTitle release];
        [lblTitleShadow release];
    }
    
    
    // 검색결과 지도화면일때는 네비게이션 버튼 설정
    if (_nMapRenderType == MapRenderType_SearchResult_SinglePOI
        || _nMapRenderType == MapRenderType_SearchResult_MultiPOI
        || _nMapRenderType == MapRenderType_SearchResult_BusLineRoute
        || _nMapRenderType == MapRenderType_SearchResult_LinePolyGon)
    {
        UIButton *btnPrev = [[UIButton alloc] initWithFrame:CGRectMake(7, 4, 94.0/2, 56.0/2)];
        [btnPrev setImage:[UIImage imageNamed:@"title_bt_before.png"] forState:UIControlStateNormal];
        [btnPrev addTarget:self action:@selector(navGoToPrevView:) forControlEvents:UIControlEventTouchUpInside];
        [_vwNavigationbar addSubview:btnPrev];
        [btnPrev release];
    }
    
    // 교통정보 새로고침 버튼
    _btnRealtimeRefresh = [[OMButton alloc] initWithFrame:CGRectMake(234+42, 4, 32, 28)];
    //    if ( _nMapRenderType == MapRenderType_SearchResult_SinglePOI)
    //    {
    //        [_btnRealtimeRefresh setFrame:CGRectMake(234+42, 4, 32, 28)];
    //    }
    
    [_btnRealtimeRefresh setImage:[UIImage imageNamed:@"title_btn_reset.png"] forState:UIControlStateNormal];
    [_btnRealtimeRefresh addTarget:self action:@selector(refreshTrafficRealtimeTimetable:) forControlEvents:UIControlEventTouchUpInside];
    [_vwNavigationbar addSubview:_btnRealtimeRefresh];
    [_btnRealtimeRefresh setHidden:YES];
    
    // *************
    // [ KMap 호출 ]
    // *************
    //MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    // 일반지도 처음 시작할 경우 위치정보 관련 설정이 필요하다.
    if ( _nMapRenderType == MapRenderType_Normal )
    {
        // 내위치 모드 설정
        if ( [MapContainer CheckLocationService] && ![OllehMapStatus sharedOllehMapStatus].calledOpenURL )
        {
            [self toggleMyLocationMode:MapLocationMode_NorthUp];
        }
        else
        {
            [self toggleMyLocationMode:MapLocationMode_None];
        }
        
        [OllehMapStatus sharedOllehMapStatus].calledOpenURL = NO;
        
        /*
         // 초기 위치 좌표 설정
         if ( CoordDistance(_deviceInitLocation, CoordMake(0, 0)) > 0 )
         [mc.kmap setCenterCoordinate: [mc.kmap convertCoordinate:_deviceInitLocation inCoordType:KCoordType_WGS84 outCoordType:KCoordType_UTMK]];
         else
         [mc.kmap setCenterCoordinate:OM_DefaultCoord];
         */
    }
    
    // **************************
    // [ OllehMap IBOutlet 설정 ]
    // **************************
    
    // 검색 - 배경
    UIImageView *imgvwSearchBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_search_bar.png"]];
    [imgvwSearchBackground setFrame:CGRectMake(0, 0, 299, 37)];
    [_vwSearchGroup insertSubview:imgvwSearchBackground atIndex:0];
    [imgvwSearchBackground release];
    // 검색 - 아이콘
    UIImageView *imgvwSearchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_search_icon.png"]];
    [imgvwSearchIcon setFrame:CGRectMake(10, 7, 21, 21)];
    [_vwSearchGroup insertSubview:imgvwSearchIcon atIndex:1];
    [imgvwSearchIcon release];
    // 검색 - 검색어
    if (_nMapRenderType == MapRenderType_Normal)
    {
        [self setSearchKeyword:NSLocalizedString(@"Body_InitSearchText", @"") :NO];
    }
    else if (_nMapRenderType == MapRenderType_SearchResult_SinglePOI
             || _nMapRenderType == MapRenderType_SearchResult_MultiPOI)
    {
        [self setSearchKeyword:[OllehMapStatus sharedOllehMapStatus].keyword :YES];
    }
    
    // 교통량 게이지
    for (UIView *subview in _vwTrafficGroup.subviews)
    {
        if ( [subview isKindOfClass:[UIImageView class]] )
        {
            [((UIImageView *)subview) setImage:[UIImage imageNamed:@"traffic_pop.png"]];
            break;
        }
    }
    
    // 사이드버튼 그룹
    [_btnSideTraffic setImage:[UIImage imageNamed:@"map_btn_traffic.png"] forState:UIControlStateNormal];
    [_btnSideTraffic setImage:[UIImage imageNamed:@"map_btn_traffic_pressed.png"] forState:UIControlStateSelected];
    [_btnSideTraffic setImage:[UIImage imageNamed:@"map_btn_traffic_pressed.png"] forState:UIControlStateHighlighted];
    [_btnSideKMapType setImage:[UIImage imageNamed:@"map_btn_aviation.png"] forState:UIControlStateNormal];
    [_btnSideKMapType setImage:[UIImage imageNamed:@"map_btn_aviation_pressed.png"] forState:UIControlStateSelected];
    [_btnSideKMapType setImage:[UIImage imageNamed:@"map_btn_aviation_pressed.png"] forState:UIControlStateHighlighted];
    [_btnSideFavorite setImage:[UIImage imageNamed:@"map_btn_hotlist.png"] forState:UIControlStateNormal];
    [_btnSideFavorite setImage:[UIImage imageNamed:@"map_btn_hotlist_pressed.png"] forState:UIControlStateSelected];
    [_btnSideFavorite setImage:[UIImage imageNamed:@"map_btn_hotlist_pressed.png"] forState:UIControlStateHighlighted];
    
    // 현재주소 - 배경
    UIImageView *imgvwCurrentAddressBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_address_bg.png"]];
    [imgvwCurrentAddressBackground setFrame:CGRectMake(0, 0, 201, 22)];
    [_vwCurrentAddressGroup insertSubview:imgvwCurrentAddressBackground atIndex:0];
    [imgvwCurrentAddressBackground release];
    
    // 하단버튼 - 배경
    for (UIView *subview in _vwBottomButtonGroup.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            [((UIImageView *) subview) setImage:[UIImage imageNamed:@"map_btn_bg.png"]];
            break;
        }
    }
    // 하단버튼 - 테마];
    /* MIK.geun :: 20120627 // 1차오픈시에는 테마대신 검색버튼으로 대체한다.
     [_btnBottomTheme setBackgroundImage:[UIImage imageNamed:@"map_btn_theme.png"] forState:UIControlStateNormal];
     [_btnBottomTheme setBackgroundImage:[UIImage imageNamed:@"map_btn_theme_pressed.png"] forState:UIControlStateSelected];
     */
    [_btnBottomTheme setBackgroundImage:[UIImage imageNamed:@"map_btn_theme.png"] forState:UIControlStateNormal];
    [_btnBottomTheme setBackgroundImage:[UIImage imageNamed:@"map_btn_theme_pressed.png"] forState:UIControlStateSelected];
    [_btnBottomTheme setBackgroundImage:[UIImage imageNamed:@"map_btn_theme_pressed.png"] forState:UIControlStateHighlighted];
    // 하단버튼 - 길찾기
    [_btnBottomSearchRoute setBackgroundImage:[UIImage imageNamed:@"map_btn_street.png"] forState:UIControlStateNormal];
    [_btnBottomSearchRoute setBackgroundImage:[UIImage imageNamed:@"map_btn_street_pressed.png"] forState:UIControlStateSelected];
    [_btnBottomSearchRoute setBackgroundImage:[UIImage imageNamed:@"map_btn_street_pressed.png"] forState:UIControlStateHighlighted];
    // 하단버튼 - 설정
    [_btnBottomConfiguration setBackgroundImage:[UIImage imageNamed:@"map_btn_setting.png"] forState:UIControlStateNormal];
    [_btnBottomConfiguration setBackgroundImage:[UIImage imageNamed:@"map_btn_setting_pressed.png"] forState:UIControlStateSelected];
    [_btnBottomConfiguration setBackgroundImage:[UIImage imageNamed:@"map_btn_setting_pressed.png"] forState:UIControlStateHighlighted];
    
    // 범례버튼 상태
    //[_btnBottomLegend setHidden:![MapContainer sharedMapContainer_Main].kmap.CadastralInfo];
    
    // 축척레벨
    [_vwZoomLevelGroup setFrame:CGRectMake(5, 422, 50, 26)];
    [self toggleZoomLevel];
    
    
    // outlet 위치조정
    [self toggleScreenMode:MapScreenMode_NORMAL :NO];
    
    
    // ******************
    // [ NonXIB outlets ]
    // ******************
    _vwMultiPOISelectorContainer = [[UIView alloc]
                                    initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,
                                                             [[UIScreen mainScreen] bounds].size.height - 20)];
    [_vwMultiPOISelectorContainer setBackgroundColor:convertHexToDecimalRGBA(@"00", @"00", @"00", 0.7f)];
    
    // 실시간 교통정보 컨테이너 뷰 초기화
    _vwRealtimeTrafficTimeTableContainer = [[UIView alloc] initWithFrame:CGRectMake(20/2, 79+65, 1, 1)];  //79+65 ==> 검색창하단좌표~실시간상단좌표간격
    [_vwRealtimeTrafficTimeTableContainer setBackgroundColor:[UIColor clearColor]];
    [_vwRealtimeTrafficTimeTableContainer setBackgroundColor:[UIColor redColor]];
    
    // 테마 업데이트 컨테이너 뷰 초기화
    _vwThemeUpdateContainer = [[UIView alloc]
                               initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,
                                                        [[UIScreen mainScreen] bounds].size.height - 20)];
    [_vwThemeUpdateContainer setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.7]];
    _pvwThemeUpdateProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(30, 205, 260, 30)];
    [_pvwThemeUpdateProgress setProgressViewStyle:UIProgressViewStyleBar];
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] > 5.0 )
        [_pvwThemeUpdateProgress setProgressTintColor:[UIColor redColor]];
    [_vwThemeUpdateContainer addSubview:_pvwThemeUpdateProgress];
    UILabel *themeUpdateMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 320, 15)];
    [themeUpdateMessageLabel setFont:[UIFont systemFontOfSize:15]];
    [themeUpdateMessageLabel setTextColor:[UIColor whiteColor]];
    [themeUpdateMessageLabel setBackgroundColor:[UIColor clearColor]];
    [themeUpdateMessageLabel setTextAlignment:NSTextAlignmentCenter];
    [themeUpdateMessageLabel setText:@"테마 정보를 업데이트 중입니다."];
    [_vwThemeUpdateContainer addSubview:themeUpdateMessageLabel];
    [themeUpdateMessageLabel release];
    
    _updateInfoAutoRecommWord = nil;
    // 최초 일반 지도 생성시에만 실행됨
    if (_nMapRenderType == MapRenderType_Normal && [[[NSUserDefaults standardUserDefaults] objectForKeyGC:@"IsStartup"] boolValue] == NO)
    {
        // 앱이 최초 실행됐음을 기록 ... 앱 초기화 (AppDelegate)에서 NO 항상 픽스해서 들어옴.
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"IsStartup"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 네트워크 연결만 되어 있으면 업데이트 정보체크
        if ( [[OllehMapStatus sharedOllehMapStatus] getNetworkStatus] != OMReachabilityStatus_disconnected )
        {
            [[ServerConnector sharedServerConnection] requestAppVersion:self action:@selector(finishAppVersionCallBack:)];
        }
    }
}
// ******************************

// ==============================
// [ 메인뷰 화면처리 메소드 시작 ]
// ==============================

- (void) toggleScreenMode
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    int mode = (oms.currentMapScreenMode + 1) %2;
    [self toggleScreenMode:mode :YES];
}
- (void) toggleScreenMode :(int)mode :(BOOL)animated
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    [oms setCurrentMapScreenMode:mode];
    
    // 애니메이션 설정
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }
    
    
    // 상단 네비게이션바(메인뷰전용) 위치 조정
    {
        CGRect rect = CGRectZero;
        rect.size.width = 320.0f;
        rect.size.height = 37.0f;
        rect.origin.x = 0.0f;
        switch (oms.currentMapScreenMode)
        {
            case MapScreenMode_FULL:
                rect.origin.y = -rect.size.height - _vwSearchGroup.frame.size.height - 20.0f; // -20.0f 추가된 이유는 최상단 스테이터스바 위로 올라가도록..
                break;
            case MapScreenMode_NORMAL:
                rect.origin.y = 0.0f;
                break;
        }
        [_vwNavigationbar setFrame:rect];
    }
    
    // 상단 검색바 위치 조정
    {
        CGRect rect = CGRectZero;
        rect.size.width = 299.0f;
        rect.size.height = 37.0f;
        rect.origin.x = 10.0f;
        switch (oms.currentMapScreenMode)
        {
            case MapScreenMode_FULL:
                rect.origin.y = -rect.size.height -20.0f; // -20.0f 추가된 이유는 최상단 스테이터스바 위로 올라가도록..
                break;
            case MapScreenMode_NORMAL:
                rect.origin.y =  42.0f; // _vwNavigationbar.frame.origin.y + _vwNavigationbar.frame.size.height + 5.0f; //네비게이션바 하단 5.0 좌표
                break;
        }
        [_vwSearchGroup setFrame:rect];
    }
    
    // 내위치 버튼 위치 조정
    {
        CGRect rect = CGRectZero;
        rect.size.width = 37.0f;
        rect.size.height = 37.0f;
        rect.origin.x = 12.0f;
        
        switch (oms.currentMapScreenMode)
        {
            case MapScreenMode_FULL:
                rect.origin.y = 15.0f;
                break;
            case MapScreenMode_NORMAL:
                rect.origin.y = 91.0f;
                break;
        }
        [_vwMyLocationButtonGroup setFrame:rect];
    }
    
    // 하단버튼 위치 조정
    {
        CGRect rect = CGRectZero;
        rect.size.width = 164.0f;
        rect.size.height = 63.0f;
        rect.origin.x = 78.0f;
        
        switch (oms.currentMapScreenMode)
        {
            case MapScreenMode_FULL:
                rect.origin.y = [[UIScreen mainScreen] bounds].size.height - 20 + rect.size.height;
                break;
            case MapScreenMode_NORMAL:
                rect.origin.y = self.view.frame.size.height - 66;
                break;
        }
        [_vwBottomButtonGroup setFrame:rect];
    }
    
    // 현재 위치 주소창 위치조정
    {
        CGRect rect = CGRectZero;
        rect.size.width = 201.0f;
        rect.size.height = 22.0f;
        rect.origin.x = 59.0;
        
        switch (oms.currentMapScreenMode)
        {
            case MapScreenMode_FULL:
                rect.origin.y =  self.view.frame.size.height - 34; //426.0f  -  ( [UIApplication sharedApplication].statusBarFrame.size.height-20 );
                break;
            case MapScreenMode_NORMAL:
                rect.origin.y = self.view.frame.size.height - 91; //369.0f -  ( [UIApplication sharedApplication].statusBarFrame.size.height-20 );
                break;
        }
        [_vwCurrentAddressGroup setFrame:rect];
    }
    
    // 교통량&사이드버튼 위치 조정
    [self adjustTopSideButtons];
    
    // 애니메이션 적용
    if (animated) [UIView commitAnimations];
}

- (void) toggleMyLocationMode:(int)mode
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    [oms setCurrentMapLocationMode:mode];
    
    switch (mode) {
        case MapLocationMode_NorthUp:
            [_btnMyLocation setImage:[UIImage imageNamed:@"map_btn_location_pressed_1.png"] forState:UIControlStateNormal];
            // 북쪽고정 + 트래킹 모드
            [mc.kmap setShowUserLocation:UserLocationNorthUpTrace];
            // 현재 맵중앙을 내위치로 바로 가져오도록 설정
            [mc.kmap setCenterCoordinate: mc.kmap.getUserLocation];
            break;
        case MapLocationMode_Commpass:
            [_btnMyLocation setImage:[UIImage imageNamed:@"map_btn_location_pressed_2.png"] forState:UIControlStateNormal];
            // 나침반 + 트래킹 모드
            [mc.kmap setShowUserLocation:UserLocationCompassTrace];
            // 현재 맵중앙을 내위치로 바로 가져오도록 설정
            [mc.kmap setCenterCoordinate: mc.kmap.getUserLocation];
            break;
        case MapLocationMode_None:
        default:
            [_btnMyLocation setImage:[UIImage imageNamed:@"map_btn_location.png"] forState:UIControlStateNormal];
            // 북쪽고정 모드
            [mc.kmap setShowUserLocation:UserLocationNorthUp];
            break;
    }
}
- (void) toggleKMapStyle
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    int currentMapZoomLevel = mc.kmap.zoomLevel;
    
    // Maptype ==> Standard : 평면지도, Satelite : 위성지도, Hybrid : 위성+마킹, Traffice : 교통(?)
    if (mc.kmap.mapType == KMapTypeStandard)
    {
        [mc.kmap setMapType:KMapTypeHybrid];
        if (currentMapZoomLevel > KMap_ZoomLevel_MaximunHybrid) currentMapZoomLevel = mc.kmap.maxZoomLevel;
        
        // 이벤트 트래킹 - 위성 지도
        [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/main_map/hybrid_mode"];
    }
    else
    {
        [mc.kmap setMapType:KMapTypeStandard];
        if (currentMapZoomLevel > KMap_ZoomLevel_Maximun) currentMapZoomLevel = mc.kmap.maxZoomLevel;
        
        // 이벤트 트래킹 - vywns 지도
        [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/main_map/2D_mode"];
    }
    
    // 기존 맵 줌레벨대로 맞춰준다. (상단 분기문에서 최대 레벨 계산해서 어긋나지 않도록 고려했음)
    [mc.kmap setZoomLevel:currentMapZoomLevel];
}
- (void) toggleKMapStyle:(OllehMapType)type
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    int currentMapZoomLevel = mc.kmap.zoomLevel;
    
    if ( mc.kmap.mapType != type )
        [mc.kmap setMapType:type];
    
    // UI 업데이트
    if ( type == KMapTypeHybrid )
        _btnSideKMapType.selected = YES;
    else if ( mc.kmap.mapType == KMapTypeStandard )
        _btnSideKMapType.selected = NO;
    else
        _btnSideKMapType.selected = NO;
    
    
    // 기존 맵 줌레벨대로 맞춰준다. (상단 분기문에서 최대 레벨 계산해서 어긋나지 않도록 고려했음)
    [mc.kmap setZoomLevel:currentMapZoomLevel];
}

- (void) toggleZoomLevel
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    //NSLog(@"축척 이미지 변경 %d / %d level", mc.kmap.zoomLevel, mc.kmap.maxZoomLevel);
    
    // 맵 축척레벨
    int zoomLevel = mc.kmap.zoomLevel;
    
    //  일반지도-작은글씨 지도일 경우 줌레벨을 한단계 내려준다.
    if (mc.kmap.mapDisplay == KMapDisplayNormalSmallText) zoomLevel--;
    
    switch (zoomLevel)
    {
        case -1: // 일반지도-작은글씨 일 경우에만 해당됨
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_204km.png"]];
            break;
        case 0:
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_102km.png"]];
            break;
        case 1:
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_51km.png"]];
            break;
        case 2:
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_26km.png"]];
            break;
        case 3:
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_13km.png"]];
            break;
        case 4:
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_6km.png"]];
            break;
        case 5:
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_3km.png"]];
            break;
        case 6:
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_1600m.png"]];
            break;
        case 7:
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_800m.png"]];
            break;
        case 8:
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_400m.png"]];
            break;
        case 9:
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_200m.png"]];
            break;
        case 10:
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_100m.png"]];
            break;
        case 11:
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_50m.png"]];
            break;
        case 12:
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_25m.png"]];
            break;
        case 13:
            [_imgvwZoomLevel setImage:[UIImage imageNamed:@"scale_12m.png"]];
            break;
        default:
            break;
    }
}

- (void) adjustTopSideButtons
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // *********************
    // [ 교통량 게이지 위치 ]
    // *********************
    {
        CGRect rect = CGRectMake(0, 0, 0, 0);
        rect.size.width = 166.0f;
        rect.size.height = 21.0f;
        rect.origin.x = 77.0f;
        
        // 화면모드에 따라 위치조정
        if (oms.currentMapScreenMode == MapScreenMode_FULL)
            rect.origin.y = 15.0f;
        else
            rect.origin.y = 91.0f;
        
        [_vwTrafficGroup setFrame:rect];
        
        // 교통량 선택여부에 따라 숨김처리
        [_vwTrafficGroup setHidden: ![MapContainer sharedMapContainer_Main].kmap.trafficInfo ];
    }
    
    
    // ***********************
    // [ 사이드버튼 그룹 위치 ]
    // ***********************
    {
        CGRect rect = CGRectMake(0, 0, 0, 0);
        rect.size.width = 37.0f;
        rect.origin.x = 271.0f;
        
        // 즐겨찾기 디스플레이 여부에 따라 높이 변경
        if (true) // 숨김
            rect.size.height = 80.0f;
        else // 즐겨찾기 사용
            rect.size.height = 117.0f;
        
        // 스크린모드에 따라 위치 변경
        if (oms.currentMapScreenMode == MapScreenMode_FULL)
            rect.origin.y = 15.0f;
        else
            rect.origin.y = 91.0f;
        
        [_vwSideButtonGroup setFrame:rect];
        
        if (true) // 즐겨찾기 숨김처리된 상태
            [_btnSideFavorite setHidden:YES];
        else // 즐겨찾기 보여야 할 상황
            [_btnSideFavorite setHidden:NO];
    }
    
}


- (void) refreshCurrentAddressLabel
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    if (mc.kmap.zoomLevel >= 3)
        //[self requestReversGeocodingToShortAddress:mc.kmap.centerCoordinate geoType:0];
        [self requestReversGeocodingAddress:mc.kmap.centerCoordinate geoType:0];
    else
        //[self requestReversGeocodingToShortAddress:mc.kmap.centerCoordinate geoType:10];
        [self requestReversGeocodingAddress:mc.kmap.centerCoordinate geoType:10];
}

- (void) setSearchKeyword :(NSString*)keyword :(BOOL)isKeyword
{
    @try
    {
        if ( self.lblSearchKeyword )
        {
            [self.lblSearchKeyword setText:keyword];
            
            if (isKeyword)
                [self.lblSearchKeyword setTextColor:[UIColor blackColor]];
            else
                [self.lblSearchKeyword setTextColor:convertHexToDecimalRGBA(@"95", @"95", @"95", 1.0f)];
        }
    }
    @catch (NSException *exception)
    {
        [OMMessageBox showAlertMessage:@"검색어 라벨 오류" :[NSString stringWithFormat:@"%@", exception]];
    }
}

// ******************************


// =======================
// [ 검색결과 처리 메소드 ]
// =======================

- (void) markingSinglePOI
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    // SinglePOI 렌더링으로 들어올때는 미리 인덱스 값 설정한다.
    _selectedMultiPOIIndex = -1;
    
    // 위치 정보 해제해야한다.
    [self toggleMyLocationMode:MapLocationMode_None];
    
    // ************
    // [ POI 설정 ]
    // ************
    
    // SearchResult 값 체크
    if (!oms.searchResult.used)
    {
        [OMMessageBox showAlertMessage:@"" :@"검색결과가 올바르지 않습니다."];
        [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
        return;
    }
    
    // 교통옵션 오버레이를제외한 모든 오버레이 제거
    [mc.kmap removeAllOverlaysWithoutTraffic];
    
    // 일반적인 SinglePOI 인 경우
    if ( _nMapRednerSinglePOICategory == MainMap_SinglePOI_Type_Normal)
    {
        // 검색결과 대상 SinglePOI 렌더링 **searchResult.used 는 위에서 체크했음
        [self pinSearchSinglePOIOverlay:YES];
    }
    // 즐겨찾기나 최근검색일 경우
    else if (_nMapRednerSinglePOICategory == MainMap_SinglePOI_Type_Favorite
             || _nMapRednerSinglePOICategory == MainMap_SinglePOI_Type_Recent )
    {
        if ( _nMapRednerSinglePOICategory == MainMap_SinglePOI_Type_Recent )
            [self pinRecentPOIOverlay:YES];
        else if (_nMapRednerSinglePOICategory == MainMap_SinglePOI_Type_Favorite )
            [self pinFavoritePOIOverlay:YES];
        
        // 검색 키워드 텍스트 설정
        OMSearchResult *omsr = [self getCurrentSearchResult];
        [[OllehMapStatus sharedOllehMapStatus] setKeyword:omsr.strLocationName];
        [self setSearchKeyword:omsr.strLocationName :YES];
    }
    //  강제로 맵 이동 호출
    [self mapStatusChanged:[NSNumber numberWithInt:2] isZoom:[NSNumber numberWithBool:YES]];
}


- (void) setMultiPOIType:(int)type
{
    _multiPOIMarkingType = type;
}
- (void) markingMultiPOI
{
    //OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    // MultiPOI 렌더링을 어떤 타입을 할지 결정
    int type = _multiPOIMarkingType;
    
    // 내위치 상태 변경
    [self toggleMyLocationMode:MapLocationMode_None];
    
    // ************
    // [ POI 설정 ]
    // ************
    
    // 기존 생성된 오버레이 제거, 교통옵션 오버레이는 제외
    [mc.kmap removeAllOverlaysWithoutTraffic];
    
    // 검색결과 대상 MultiPOI 렌더링
    NSArray *arr = nil;
    if (type == 0)
        arr = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataPlace"];
    else if (type == 1)
        arr = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"];
    else if (type == 2)
        arr = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataPublicBusStation"];
    else if (type == 3)
        arr = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataPublicSubwayStation"];
    else if (type== 4)
        arr = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataNewAddress"];
    
    // SearchResult 값 체크
    if (arr == nil || arr.count <= 0)
    {
        [OMMessageBox showAlertMessage:@"" :@"검색결과가 올바르지 않습니다."];
        [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
        return;
    }
    
    
    // MUltiPOI 처리를 위한 배열 클리어 (4가지 상이한 데이터를 동일형식으로 변환하기위함)
    _refinedMultiPOIList = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < SearchResult_Page_MaxRow && i < arr.count; i++)
    {
        NSMutableDictionary *poiDic = [arr objectAtIndexGC:i];
        NSString *strName = nil;
        NSString *strAddr = nil;
        NSString *strID = nil;
        NSString *strType = nil;
        NSString *strSTheme = nil;
        NSString *strTel = nil;
        Coord crd = CoordMake(0, 0);
        
        switch (type)
        {
            case 0:   // 장소
                strName = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"NAME"]];
                strAddr = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ADDR"]];
                strType = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ORG_DB_TYPE"]];
                if ([strType isEqualToString:@"TR"])
                {
                    strType = @"TR_RAW";
                    strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"DOCID"]];
                }
                else if ([strType isEqualToString:@"OL"])
                {
                    strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"DOCID"]];
                }
                else if ([strType isEqualToString:@"MV"])
                {
                    strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"DOCID"]];
                }
                else
                {
                    strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ORG_DB_ID"]];
                }
                if ([[poiDic allKeys] containsObject:@"STHEME_CODE"] && [[poiDic objectForKeyGC:@"STHEME_CODE"] isEqualToString:@"PG1201000000008"] )
                    strSTheme = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"STHEME_CODE"]];
                else
                    strSTheme = @"";
                crd = CoordMake([[poiDic objectForKeyGC:@"X"] doubleValue], [[poiDic objectForKeyGC:@"Y"] doubleValue]);
                strTel = @"";
                break;
            case 1:  // 주소
                strName = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ADDRESS"]];
                strAddr = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ADDRESS"]];
                strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@""]];
                strType = [NSString stringWithFormat:@"ADDR"];
                crd = CoordMake([[poiDic objectForKeyGC:@"X"] doubleValue], [[poiDic objectForKeyGC:@"Y"] doubleValue]);
                strSTheme = @"";
                strTel = @"";
                break;
            case 4:  // 새 주소
                strName = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"NEW_ADDR"]];
                strAddr = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"NEW_ADDR"]];
                strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@""]];
                strType = [NSString stringWithFormat:@"ADDR"];
                crd = CoordMake([[poiDic objectForKeyGC:@"X"] doubleValue], [[poiDic objectForKeyGC:@"Y"] doubleValue]);
                strSTheme = @"";
                strTel = @"";
                break;
            case 2:  // 버스정류장
                strName = [poiDic objectForKeyGC:@"ST_UNIQUEID"];
                if([strName isEqualToString:@"0"])
                    strName = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"BST_NAME"]];
                else
                    strName = [NSString stringWithFormat:@"%@[%@-%@]", [poiDic objectForKeyGC:@"BST_NAME"], [strName substringToIndex:2], [strName substringFromIndex:2]];
                strAddr = [NSString stringWithFormat:@"%@ %@ %@", [poiDic objectForKeyGC:@"BST_DO"], [poiDic objectForKeyGC:@"BST_GU"], [poiDic objectForKeyGC:@"BST_DONG"]];
                strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"STID"]];
                strType = @"TR_BUS";
                crd = CoordMake([[poiDic objectForKeyGC:@"BST_X"] doubleValue], [[poiDic objectForKeyGC:@"BST_Y"] doubleValue]);
                strSTheme = @"";
                strTel = @"";
                break;
            case 3: // 지하철역
                strName = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"SST_NAME"]];
                strAddr = [NSString stringWithFormat:@"%@ %@ %@", [poiDic objectForKeyGC:@"DO"], [poiDic objectForKeyGC:@"U"], [poiDic objectForKeyGC:@"DONG"]];
                strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"STID"]];
                strType = @"TR";
                crd = CoordMake([[poiDic objectForKeyGC:@"SST_X"] doubleValue], [[poiDic objectForKeyGC:@"SST_Y"] doubleValue]);
                strSTheme = @"";
                strTel = @"";
                break;
            default:
                break;
        }
        
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        [tempDic setObject:strName forKey:@"Name"];
        [tempDic setObject:strAddr forKey:@"Address"];
        [tempDic setObject:[NSNumber numberWithInt:i] forKey:@"Index"];
        [tempDic setObject:[NSNumber numberWithDouble:crd.x] forKey:@"X"];
        [tempDic setObject:[NSNumber numberWithDouble:crd.y] forKey:@"Y"];
        // MP(일반) 대신 실제 값을 넣어줘야 한다.
        [tempDic setObject:strType forKey:@"Type"];
        [tempDic setObject:strTel forKey:@"Tel"];
        [tempDic setObject:strID forKey:@"ID"];
        
        [tempDic setObject:strSTheme forKey:@"STHEME_CODE"];
        [_refinedMultiPOIList addObject:tempDic];
    }
    
    // 맵 중앙 정렬
    KBounds mapBound = BoundsMake(0, 0, 0, 0);
    for (NSDictionary *dic in _refinedMultiPOIList)
    {
        double x = [[dic objectForKeyGC:@"X"] doubleValue];
        double y = [[dic objectForKeyGC:@"Y"] doubleValue];
        
        if (mapBound.maxX == 0 && mapBound.minX == 0) mapBound = BoundsMake(x, y, x, y);
        
        if (mapBound.maxX < x) mapBound.maxX = x;
        if (mapBound.maxY < y) mapBound.maxY = y;
        if (mapBound.minX > x) mapBound.minX = x;
        if (mapBound.minY > y) mapBound.minY = y;
    }
    [mc.kmap zoomToExtent:mapBound];
    NSLog(@"%d", mc.kmap.zoomLevel);
    //  강제로 맵 이동 호출
    [self mapStatusChanged:[NSNumber numberWithInt:2] isZoom:[NSNumber numberWithBool:YES]];
    
    // POI 렌더링
    //[self markingMultiPOIRenderCore];
    [self pinSearchMultiPOIOverlay:YES];
    
}

- (BOOL) isDuplicatePOI:(Coord)crd1 :(Coord)crd2 { return [self isDuplicatePOI:crd1 :crd2 :NO]; }
- (BOOL) isDuplicatePOI :(Coord)crd1 :(Coord)crd2 :(BOOL)wide
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    CGPoint p1 = [mc.kmap convertCoordinate:crd1];
    CGPoint p2 = [mc.kmap convertCoordinate:crd2];
    
    //NSLog(@" 좌표 %f %f / %f %f", p1.x, p1.y, p2.x, p2.y);
    
    /* MIK.geun :: 20121016 // 반경을 조금 더 늘려잡음
     CGRect r1 = CGRectMake(p1.x-11, p1.y-34, 23, 34);
     CGRect r2 = CGRectMake(p2.x-11, p2.y-34, 23, 34);
     */
    CGRect r1 = CGRectMake(p1.x-14, p1.y-37, 29, 40);
    CGRect r2 = CGRectMake(p2.x-14, p2.y-37, 29, 40);
    
    if ( wide)
    {
        //r1 = CGRectMake(p1.x-16, p1.y-39, 33, 44);
        //r2 = CGRectMake(p2.x-16, p2.y-39, 33, 44);
        r1 = CGRectMake(p1.x-21, p1.y-44, 43, 54);
        r2 = CGRectMake(p2.x-21, p2.y-44, 43, 54);
        
    }
    
    
    return CGRectIntersectsRect(r1, r2);
    
}
- (void) markingLinePolyGon
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    // 싱글POI키워드
    _selectedMultiPOIIndex = -1;
    
    // 위치 정보 해제해야한다.
    [self toggleMyLocationMode:MapLocationMode_None];
    
    // 기존 생성된 오버레이 제거
    [mc.kmap removeAllOverlays];
    
    
    int vertexCnt = [[[[oms.linePolygonDictionary objectForKeyGC:@"LinePolygon"] objectAtIndexGC:0] objectForKeyGC:@"part"] count];
    
    if ( [oms.linePolygonDictionary count] <= 0 )
    {
        [OMMessageBox showAlertMessage:@"" :@"폴리곤 정보가 존재하지 않습니다."];
        [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
        return;
    }
    
    // 키워드 설정
    OMSearchResult *omsr = [self getCurrentSearchResult];
    [self setSearchKeyword:omsr.strLocationName :YES];
    
    NSLog(@"%@", omsr.strLocationName);
    
    [self pinSearchSinglePOIOverlay:YES];
    
    // 지도영역
    KBounds mapBound = BoundsMake(0, 0, 0, 0);
    
    int i = 0;
    while (i < vertexCnt)
    {
        NSArray *vertexArr = [[[[[oms.linePolygonDictionary objectForKeyGC:@"LinePolygon"] objectAtIndexGC:0] objectForKeyGC:@"part"] objectAtIndexGC:i] objectForKeyGC:@"vertex"];
    
    // 노선 렌더링
    CoordList *vertexList = [[CoordList alloc] init];
    for (NSDictionary *dic in vertexArr)
    {
        double x = [[dic objectForKeyGC:@"x"] doubleValue];
        double y = [[dic objectForKeyGC:@"y"] doubleValue];
        //Coord vertex = [mc.kmap convertCoordinate:CoordMake(x, y) inCoordType:KCoordType_WGS84 outCoordType:KCoordType_UTMK] ;
        Coord vertex = CoordMake(x, y);
        [vertexList addCoord: vertex ];
        
        if ( mapBound.maxX == 0 && mapBound.minX == 0 )
        {
            mapBound.maxX = mapBound.minX = vertex.x;
            mapBound.maxY = mapBound.minY = vertex.y;
        }
        
        if ( vertex.x > mapBound.maxX ) mapBound.maxX = vertex.x;
        if ( vertex.y > mapBound.maxY ) mapBound.maxY = vertex.y;
        if ( vertex.x < mapBound.minX ) mapBound.minX = vertex.x;
        if ( vertex.y < mapBound.minY ) mapBound.minY = vertex.y;
    }
    
    // 라인POI 렌더링
    OMPolylineOverlay *plOverlay = [[OMPolylineOverlay alloc] initWithCoordList:vertexList];
    
    // 경로 색상
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGColorRef stroke = CGColorCreate(rgb, (CGFloat[]){convertHexToDecimal(@"1A") ,convertHexToDecimal(@"68") ,convertHexToDecimal(@"C9") ,1.0f});
    plOverlay.strokeColor = stroke;
    CGColorSpaceRelease(rgb);
    CFRelease(stroke);
    // 경로 나머지 설정
    plOverlay.lineWidth = 5;
    plOverlay.delegate = self;
    plOverlay.canShowBalloon = NO;
    // 오버레이 삽입
    [mc.kmap addOverlay:plOverlay];
    // 오버레이 해제
    [plOverlay release];
    
    // 노선 정보 해제
    [vertexList release];
        
        i++;
        
    }
    
    // 맵 중앙/줌 처리(테스트용 끝난 뒤 주석해제)
    [mc.kmap zoomToExtent:mapBound];
    



}

- (void) markingBusLineRoute
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    _selectedMultiPOIIndex = -100;
    
    // 위치 정보 해제해야한다.
    [self toggleMyLocationMode:MapLocationMode_None];
    
    // 기존 생성된 오버레이 제거
    [mc.kmap removeAllOverlays];
    
    // 버스 노선명
    NSString *busName = [oms.busLineDrawingDictionary objectForKeyGC:@"BusName"];
    
    // 버스 노선정보
    NSArray *busLineVertexs = [oms.busLineDrawingDictionary objectForKeyGC:@"BUSLINE"];
    
    // 노선정보 카운트 확인
    if ( [busLineVertexs count] <= 0 )
    {
        [OMMessageBox showAlertMessage:@"" :@"노선정보가 존재하지 않습니다."];
        [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
        return;
    }
    
    // 키워드 설정
    [self setSearchKeyword:busName :YES];
    
    // 지도영역
    KBounds mapBound = BoundsMake(0, 0, 0, 0);
    
    // 노선 렌더링
    CoordList *vertexList = [[CoordList alloc] init];
    for (NSDictionary *dic in busLineVertexs)
    {
        double x = [[dic objectForKeyGC:@"GPSX"] doubleValue];
        double y = [[dic objectForKeyGC:@"GPSY"] doubleValue];
        Coord vertex = [mc.kmap convertCoordinate:CoordMake(x, y) inCoordType:KCoordType_WGS84 outCoordType:KCoordType_UTMK] ;
        [vertexList addCoord: vertex ];
        
        if ( mapBound.maxX == 0 && mapBound.minX == 0 )
        {
            mapBound.maxX = mapBound.minX = vertex.x;
            mapBound.maxY = mapBound.minY = vertex.y;
        }
        
        if ( vertex.x > mapBound.maxX ) mapBound.maxX = vertex.x;
        if ( vertex.y > mapBound.maxY ) mapBound.maxY = vertex.y;
        if ( vertex.x < mapBound.minX ) mapBound.minX = vertex.x;
        if ( vertex.y < mapBound.minY ) mapBound.minY = vertex.y;
    }
    
    // 버스 노선 경로렌더링
    PolylineOverlay *plOverlay = [[PolylineOverlay alloc] initWithCoordList:vertexList];
    
    // 경로 색상
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGColorRef stroke = CGColorCreate(rgb, (CGFloat[]){convertHexToDecimal(@"1A") ,convertHexToDecimal(@"68") ,convertHexToDecimal(@"C9") ,1.0f});
    plOverlay.strokeColor = stroke;
    CGColorSpaceRelease(rgb);
    CFRelease(stroke);
    // 경로 나머지 설정
    plOverlay.lineWidth = 5;
    plOverlay.delegate = self;
    plOverlay.canShowBalloon = NO;
    // 오버레이 삽입
    [mc.kmap addOverlay:plOverlay];
    // 오버레이 해제
    [plOverlay release];
    
    // 노선 정보 해제
    [vertexList release];
    
    // 맵 중앙/줌 처리
    [mc.kmap zoomToExtent:mapBound];
    
}

- (OMSearchResult *)_X_getCurrentSearchResult
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    OMSearchResult *omsr;
    // Normal
    if (_nMapRenderType == MapRenderType_Normal) omsr = oms.searchResultOneTouchPOI;
    // SInglePOI
    else if (_nMapRenderType == MapRenderType_SearchResult_SinglePOI) omsr = oms.searchResult;
    // MultiPOI
    else if (_nMapRenderType == MapRenderType_SearchResult_MultiPOI && index >= 0)
    {
        NSDictionary *poiDic = [_refinedMultiPOIList objectAtIndexGC:_selectedMultiPOIIndex];
        omsr = [self getCurrentSearchResultFromMultiPOI:poiDic];
    }
    else omsr = nil;
    
    return omsr;
}

- (OMSearchResult *)getCurrentSearchResult
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    OMSearchResult *omsr;
    // Normal
    if (_selectedMultiPOIIndex == -2) omsr = oms.searchResultOneTouchPOI;
    // SInglePOI
    else if (_selectedMultiPOIIndex == -1) omsr = oms.searchResult;
    // MultiPOI
    else if (_selectedMultiPOIIndex >= 0)
    {
        NSDictionary *poiDic = [_refinedMultiPOIList objectAtIndexGC:_selectedMultiPOIIndex];
        omsr = [self getCurrentSearchResultFromMultiPOI:poiDic];
    }
    else omsr = nil;
    
    return omsr;
}

- (OMSearchResult *)getCurrentSearchResultFromMultiPOI :(NSDictionary*)poiDic
{
    OMSearchResult *omsr = [OllehMapStatus sharedOllehMapStatus].searchResult;
    omsr.used = YES;
    omsr.isCurrentLocation = NO;
    omsr.index = [[poiDic objectForKeyGC:@"Index"] intValue];
    omsr.strID = [NSString stringWithFormat:@"%@",[poiDic objectForKeyGC:@"ID"]];
    omsr.strType =  [NSString stringWithFormat:@"%@",[poiDic objectForKeyGC:@"Type"]];
    omsr.strLocationName = [NSString stringWithFormat:@"%@",[poiDic objectForKeyGC:@"Name"]];
    omsr.strLocationAddress = [NSString stringWithFormat:@"%@",[poiDic objectForKeyGC:@"Address"]];
    omsr.coordLocationPoint = CoordMake([[poiDic objectForKeyGC:@"X"] doubleValue], [[poiDic objectForKeyGC:@"Y"]  doubleValue]);
    
    return omsr;
}

- (void) renderRealtimeTrafficBusTimeTable :(NSDictionary*)timetable :(NSString*)busid
{
    // 뷰 클리어
    [self clearRealtimeTrafficTimeTable];
    
    if ( timetable == nil || busid == nil ) return;
    
    // 리프레시 버튼 나타내기
    [_btnRealtimeRefresh setHidden:NO];
    [_btnRealtimeRefresh.additionalInfo setObject:[NSNumber numberWithBool:YES] forKey:@"IsBus"];
    [_btnRealtimeRefresh.additionalInfo setObject:timetable forKey:@"TimeTable"];
    [_btnRealtimeRefresh.additionalInfo setObject:busid forKey:@"BusID"];
    
    // 실시간 최대 카운트
    NSInteger maxCount = [numberValueOfDiction(timetable, @"total_count") integerValue];
    
    // 실시간 정보가 한개도 없을 경우  컨테이너만 남겨두고 전부 클리어한다.
    if ( maxCount <= 0 )
    {
        for (UIView *subview in _vwRealtimeTrafficTimeTableContainer.subviews)
        {
            [subview removeFromSuperview];
        }
        return;
    }
    
    NSArray *busTimeList = [timetable objectForKeyGC:@"traffic"];
    // 카운트만큼 렌더링
    for (int cnt=0, maxcnt=5; cnt < maxcnt; cnt++)
    {
        int height = 41 * cnt;
        
        UIView *cell = nil;
        UIImage *cellBackgroundImage = nil;
        
        if ( cnt == 0 )
        {
            cell = [[UIView alloc] initWithFrame:CGRectMake(0, height, 64, 41)];
            cellBackgroundImage = [UIImage imageNamed:@"poi_layer_top.png"];
        }
        else if ( cnt == maxcnt-1 )
        {
            cell = [[UIView alloc] initWithFrame:CGRectMake(0, height, 64, 44)];
            cellBackgroundImage = [UIImage imageNamed:@"poi_layer_bottom.png"];
        }
        else
        {
            cell = [[UIView alloc] initWithFrame:CGRectMake(0, height, 64, 41)];
            cellBackgroundImage = [UIImage imageNamed:@"poi_layer_center.png"];
        }
        
        UIImageView *cellBackgroundImageView = [[UIImageView alloc] initWithImage:cellBackgroundImage];
        [cell addSubview:cellBackgroundImageView];
        [cellBackgroundImageView release];
        
        if ( cnt < maxCount )
        {
            NSDictionary *busData = [busTimeList objectAtIndexGC:cnt];
            
            UILabel *busNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 6, 46, 14)];
            [busNumberLabel setFont:[UIFont boldSystemFontOfSize:14]];
            [busNumberLabel setTextAlignment:NSTextAlignmentCenter];
            [busNumberLabel setTextColor:convertHexToDecimalRGBA(@"2F", @"C9", @"EB", 1.0)];
            [busNumberLabel setBackgroundColor:[UIColor clearColor]];
            [busNumberLabel setText:stringValueOfDictionary(busData, @"lane")];
            [cell addSubview:busNumberLabel];
            [busNumberLabel release];
            
            UILabel *busArriveTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 25, 60, 10)];
            [busArriveTimeLabel setFont:[UIFont systemFontOfSize:10]];
            [busArriveTimeLabel setTextAlignment:NSTextAlignmentCenter];
            [busArriveTimeLabel setTextColor:[UIColor whiteColor]];
            [busArriveTimeLabel setBackgroundColor:[UIColor clearColor]];
            int busarrivetime = [numberValueOfDiction(busData, @"time") intValue];
            if ( busarrivetime > 1 )
                [busArriveTimeLabel setText:[NSString stringWithFormat:@"약 %d분 후", busarrivetime]];
            else
                [busArriveTimeLabel setText:[NSString stringWithFormat:@"약 %d분 이내", busarrivetime]];
            [cell addSubview:busArriveTimeLabel];
            [busArriveTimeLabel release];
        }
        
        [_vwRealtimeTrafficTimeTableContainer addSubview:cell];
        [cell release];
    }
    
    
    // 컨테이너 삽입
    [_vwKMapContainer addSubview:_vwRealtimeTrafficTimeTableContainer];
}
- (void) renderRealtimeTrafficSubwayTimeTable :(NSArray*)timetable :(NSString*)subwayid
{
    // 뷰 클리어
    [self clearRealtimeTrafficTimeTable];
    
    if ( timetable == nil || subwayid == nil ) return;
    
    // 리프레시 버튼 나타내기
    [_btnRealtimeRefresh setHidden:NO];
    [_btnRealtimeRefresh.additionalInfo setObject:[NSNumber numberWithBool:NO] forKey:@"IsBus"];
    [_btnRealtimeRefresh.additionalInfo setObject:timetable forKey:@"TimeTable"];
    [_btnRealtimeRefresh.additionalInfo setObject:subwayid forKey:@"SubwayID"];
    
    NSDictionary *upLineData = nil;
    NSDictionary *downLineData = nil;
    for (NSDictionary *data in timetable)
    {
        if ( [numberValueOfDiction(data, @"direction") intValue] == 0)
            upLineData = data;
        else if ( [numberValueOfDiction(data, @"direction") intValue] == 1 )
            downLineData = data;
    }
    
    // 실시간 정보가 한개도 없을 경우  컨테이너만 남겨두고 전부 클리어한다.
    if ( upLineData.count + downLineData.count <= 0 )
    {
        for (UIView *subview in _vwRealtimeTrafficTimeTableContainer.subviews)
        {
            [subview removeFromSuperview];
        }
        return;
    }
    
    
    // 상행
    {
        UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 105)];
        
        UIImageView *cellBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"poi_layer_bg.png"]];
        [cell addSubview:cellBackgroundImageView];
        [cellBackgroundImageView release];
        
        UILabel *directionLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 5, 50, 11)];
        [directionLabel setFont:[UIFont boldSystemFontOfSize:11]];
        [directionLabel setTextAlignment:NSTextAlignmentCenter];
        [directionLabel setTextColor:convertHexToDecimalRGBA(@"F2", @"34", @"71", 1.0)];
        [directionLabel setBackgroundColor:[UIColor clearColor]];
        [directionLabel setText:@"상행"];
        [cell addSubview:directionLabel];
        [directionLabel release];
        
        NSArray *upLineDataTimes = nil;
        NSDictionary *firstData = nil;
        NSDictionary *secondData = nil;
        
        // 상행선 데이터 존재하면서 시간표도 존재할경우 시간표 배열 작성
        if ( upLineData ) upLineDataTimes = [upLineData objectForKeyGC:@"times"];
        
        // 상행성 데이터 및 시간표 존재할 경우 실시간표 정제..
        if ( upLineDataTimes )
        {
            // 시간표가 2개 이상 존재할경우 첫/두번째 시간정제
            if ( upLineDataTimes.count > 1 )
            {
                firstData = [upLineDataTimes objectAtIndexGC:0];
                secondData = [upLineDataTimes objectAtIndexGC:1];
            }
            // 시간표가 1개만 존재할경우 첫번째 시간정제..
            else if ( upLineDataTimes.count > 0 )
            {
                firstData = [upLineDataTimes objectAtIndexGC:0];
            }
            // 이도저도 아니다?? 그럼 모두 nil 처리..
        }
        
        if ( firstData)
        {
            UILabel *goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 24, 50, 11)];
            [goalLabel setFont:[UIFont boldSystemFontOfSize:11]];
            [goalLabel setTextAlignment:NSTextAlignmentCenter];
            [goalLabel setTextColor:[UIColor whiteColor]];
            [goalLabel setBackgroundColor:[UIColor clearColor]];
            [goalLabel setText:[NSString stringWithFormat:@"%@", stringValueOfDictionary(firstData, @"lane")]];
            [cell addSubview:goalLabel];
            [goalLabel release];
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 42, 50, 11)];
            [timeLabel setFont:[UIFont boldSystemFontOfSize:11]];
            [timeLabel setTextAlignment:NSTextAlignmentCenter];
            [timeLabel setTextColor:convertHexToDecimalRGBA(@"2F", @"C9", @"EB", 1.0)];
            [timeLabel setBackgroundColor:[UIColor clearColor]];
            [timeLabel setText:[NSString stringWithFormat:@"%@", stringValueOfDictionary(firstData, @"time")]];
            [cell addSubview:timeLabel];
            [timeLabel release];
        }
        if ( secondData)
        {
            UILabel *goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 65, 50, 11)];
            [goalLabel setFont:[UIFont boldSystemFontOfSize:11]];
            [goalLabel setTextAlignment:NSTextAlignmentCenter];
            [goalLabel setTextColor:[UIColor whiteColor]];
            [goalLabel setBackgroundColor:[UIColor clearColor]];
            [goalLabel setText:[NSString stringWithFormat:@"%@", stringValueOfDictionary(secondData, @"lane")]];
            [cell addSubview:goalLabel];
            [goalLabel release];
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 83, 50, 11)];
            [timeLabel setFont:[UIFont boldSystemFontOfSize:11]];
            [timeLabel setTextAlignment:NSTextAlignmentCenter];
            [timeLabel setTextColor:convertHexToDecimalRGBA(@"2F", @"C9", @"EB", 1.0)];
            [timeLabel setBackgroundColor:[UIColor clearColor]];
            [timeLabel setText:[NSString stringWithFormat:@"%@", stringValueOfDictionary(secondData, @"time")]];
            [cell addSubview:timeLabel];
            [timeLabel release];
        }
        
        [_vwRealtimeTrafficTimeTableContainer addSubview:cell];
        [cell release];
    }
    
    // 하행
    {
        UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(0, 106, 50, 105)];
        
        UIImageView *cellBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"poi_layer_bg.png"]];
        [cell addSubview:cellBackgroundImageView];
        [cellBackgroundImageView release];
        
        UILabel *directionLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 5, 50, 11)];
        [directionLabel setFont:[UIFont boldSystemFontOfSize:11]];
        [directionLabel setTextAlignment:NSTextAlignmentCenter];
        [directionLabel setTextColor:convertHexToDecimalRGBA(@"F2", @"34", @"71", 1.0)];
        [directionLabel setBackgroundColor:[UIColor clearColor]];
        [directionLabel setText:@"하행"];
        [cell addSubview:directionLabel];
        [directionLabel release];
        
        NSArray *downLineDataTimes = nil;
        NSDictionary *firstData = nil;
        NSDictionary *secondData = nil;
        
        // 하행선 데이터가 존재할 경우 시간표 작성
        if (downLineData ) downLineDataTimes = [downLineData objectForKeyGC:@"times"];
        
        // 하행선 데이터 및 시간표가 존재할 경우 실시간표 정제..
        if ( downLineDataTimes )
        {
            // 시간정보가 2개 이상인 경우 첫/두번재 시간 정제
            if ( downLineDataTimes.count > 1 )
            {
                firstData = [downLineDataTimes objectAtIndexGC:0];
                secondData = [downLineDataTimes objectAtIndexGC:1];
            }
            // 시간정보가 1개인 경우 첫번째 시간만 정제
            else if ( downLineDataTimes.count > 0 )
            {
                firstData = [downLineDataTimes objectAtIndexGC:0];
            }
            // 이도저도 아닌 경우 모두 nil 처리
        }
        
        if ( firstData)
        {
            UILabel *goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 24, 50, 11)];
            [goalLabel setFont:[UIFont boldSystemFontOfSize:11]];
            [goalLabel setTextAlignment:NSTextAlignmentCenter];
            [goalLabel setTextColor:[UIColor whiteColor]];
            [goalLabel setBackgroundColor:[UIColor clearColor]];
            [goalLabel setText:[NSString stringWithFormat:@"%@", stringValueOfDictionary(firstData, @"lane")]];
            [cell addSubview:goalLabel];
            [goalLabel release];
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 42, 50, 11)];
            [timeLabel setFont:[UIFont boldSystemFontOfSize:11]];
            [timeLabel setTextAlignment:NSTextAlignmentCenter];
            [timeLabel setTextColor:convertHexToDecimalRGBA(@"2F", @"C9", @"EB", 1.0)];
            [timeLabel setBackgroundColor:[UIColor clearColor]];
            [timeLabel setText:[NSString stringWithFormat:@"%@", stringValueOfDictionary(firstData, @"time")]];
            [cell addSubview:timeLabel];
            [timeLabel release];
        }
        if ( secondData)
        {
            UILabel *goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 65, 50, 11)];
            [goalLabel setFont:[UIFont boldSystemFontOfSize:11]];
            [goalLabel setTextAlignment:NSTextAlignmentCenter];
            [goalLabel setTextColor:[UIColor whiteColor]];
            [goalLabel setBackgroundColor:[UIColor clearColor]];
            [goalLabel setText:[NSString stringWithFormat:@"%@", stringValueOfDictionary(secondData, @"lane")]];
            [cell addSubview:goalLabel];
            [goalLabel release];
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 83, 50, 11)];
            [timeLabel setFont:[UIFont boldSystemFontOfSize:11]];
            [timeLabel setTextAlignment:NSTextAlignmentCenter];
            [timeLabel setTextColor:convertHexToDecimalRGBA(@"2F", @"C9", @"EB", 1.0)];
            [timeLabel setBackgroundColor:[UIColor clearColor]];
            [timeLabel setText:[NSString stringWithFormat:@"%@", stringValueOfDictionary(secondData, @"time")]];
            [cell addSubview:timeLabel];
            [timeLabel release];
        }
        
        [_vwRealtimeTrafficTimeTableContainer addSubview:cell];
        [cell release];
    }
    
    // 컨테이너 삽입
    [_vwKMapContainer addSubview:_vwRealtimeTrafficTimeTableContainer];
}
- (void) clearRealtimeTrafficTimeTable { [self clearRealtimeTrafficTimeTable :NO]; }
- (void) clearRealtimeTrafficTimeTable :(BOOL)withCheck
{
    
    // MIK.geun :: 20121008
    // 오버레이를 체크해서 현재 실시간정보창이 활성화되어 있으면서, 실제 선택된 오버레이도 존재하는 경우
    // 클리어하지 않도록 한다.
    if (withCheck)
    {
        if ( !_vwRealtimeTrafficTimeTableContainer.hidden )
            for (Overlay *overlay in [MapContainer sharedMapContainer_Main].kmap.getOverlays)
                if ( [overlay isKindOfClass:[OMImageOverlay class]] && ((OMImageOverlay*)overlay).selected ) return;
    }
    
    // 리프레시 버튼 숨김
    [_btnRealtimeRefresh setHidden:YES];
    // 서브뷰 클리어
    for (UIView *subview in _vwRealtimeTrafficTimeTableContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    // 뷰 제거
    [_vwRealtimeTrafficTimeTableContainer removeFromSuperview];
}

- (void) clearRealtimeTrafficTimeTableForce
{
    [self clearRealtimeTrafficTimeTable:NO];
}

// ******************************


// ==============================
// [ KMap 터치 이벤트 메소드 시작 ]
// ==============================

- (void) mapTouchBegan:(KMapView*)mapView Events:(UIEvent*)event
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 터치이벤트 감지 // 기존 터치 이벤트 정리
    [oms setCurrentTouchesType:TouchesType_NOT];
}
- (void) mapTouched:(KMapView*)mapView Events:(UIEvent*)event
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 터치이벤트 감지 // 터치됨 처리
    [oms setCurrentTouchesType:TouchesType_TAP];
}
- (void) mapLongTouched:(NSValue *)coord
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 터치이벤트 감지 // 터치됐음
    [oms setCurrentTouchesType:TouchesType_LONGTAP];
    
    // 일반지도 모드에서 롱탭됐을 경우 POI 표시
    // 단, 버스노선도 모드에서는 지원하지 않는다.
    if ( _nMapRenderType != MapRenderType_SearchResult_BusLineRoute)
    {
        // 이벤트 트래킹 - 롱탭
        [oms trackPageView:@"/main_map/long_tab"];
        
        Coord transCrd = [self translateNSValueToCoord:coord];
        
        // 마지막 롱탭 좌표를 남겨준다.
        [[MapContainer sharedMapContainer_Main].kmap setLastLongTapCoordinate:transCrd];
        
        // 해당좌표로 POI검색
        [[ServerConnector sharedServerConnection] requestOneTouchPOI:self action:@selector(didFinishRequestOneTouchPOI:)PX:transCrd.x PY:transCrd.y Level:[MapContainer sharedMapContainer_Main].kmap.zoomLevel];
    }
    
}
- (void) mapDoubleTouched:(KMapView*)mapView Events:(UIEvent*)event
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    //터치이벤트 감지 // 더블탭
    [oms setCurrentTouchesType:TouchesType_DBLTAP];
    
    // 기존 싱글탭 메소드 실행 중지
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // 더블탭시 해당 영역을 확대처리한다. (최대 줌 레벨은 지도별로 다름)
    /*
     if (
     // 평면 지도의 경우 최대 줌레벨은 12
     (mapView.mapType == KMapTypeStandard && mapView.zoomLevel < KMap_ZoomLevel_Maximun)
     ||
     // 하이브리드 지도의 경우 최대 줌레벨은 13
     (mapView.mapType == KMapTypeHybrid && mapView.zoomLevel < KMap_ZoomLevel_MaximunHybrid)
     )
     */
    if ( mapView.zoomLevel < mapView.maxZoomLevel )
    {
        NSSet *touches = [event allTouches];
        CGPoint point = [[touches anyObject] locationInView:mapView];
        // 맵을 줌인하기 전에 미리 화면-지도 좌표변환을 해둬야 정확한 Coord값이 나온다.
        Coord crd = [mapView convertPoint:point];
        
        // 더블탭 좌표로 확대이동 시켜준다.
        [mapView setCenterCoordinate:crd];
        [mapView setZoomLevel:mapView.zoomLevel+1];
        
        // 최근 지도좌표/줌레벨값을 업데이트 해준다.
        [[MapContainer sharedMapContainer_Main].kmap setLastMapCenterCoordinate:mapView.centerCoordinate];
        [[MapContainer sharedMapContainer_Main].kmap setLastMapZoomLevel:mapView.zoomLevel];
    }
    
    [self toggleMyLocationMode:MapLocationMode_None];
    
}
- (void) mapTouchMoved:(KMapView*)mapView Events:(UIEvent*)event
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    if (oms.currentTouchesType != TouchesType_MOVE)
    {
        // '내위치' 관련 기능 초기화
        [self toggleMyLocationMode:MapLocationMode_None];
        // 터치타입을 MOVE로 수정
        [oms setCurrentTouchesType:TouchesType_MOVE];
    }
}
- (void) mapMultiTouched:(KMapView *)mapView Events:(UIEvent *)event
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    [oms setCurrentTouchesType:TouchesType_NOT];
}
- (void) mapTouchEnded:(KMapView*)mapView Events:(UIEvent*)event
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    switch ((enum OMStatus_TouchesType)oms.currentTouchesType)
    {
        case TouchesType_TAP:
            // 기존에 선택된 오버레이 삭제
            if (_currentLongTapOverlay)
            {
                MapContainer *mc = [MapContainer sharedMapContainer_Main];
                
                //ver4 원터치시 오버레이 제거
                
                [mc.kmap removeSpecialOverlaysKindOfClass:[OMImageOverlayLongtap class]];
                [mc.kmap removeSpecialOverlaysKindOfClass:[OMUserOverlayMarkerOption class]];
                // 롱탭관련 POI 제거후 실시간 정보가 살아 있을 경우 실시간정보도 해제..
                [self clearRealtimeTrafficTimeTable:YES];
                
                
                //[mc.kmap removeOverlay:_currentLongTapOverlay];
                // ver4 끝
                
                [self pinPOIMarkerOption:NO targetInfo:_currentLongTapOverlay.additionalInfo animated:YES];
                
                [self currentOverlayNoSelected];
                
                break;
            }
            
            // 바로 더블탭이 들어올수 있으므로 0.3초의 딜레이를 걸어준다.
            [self performSelector:@selector(toggleScreenMode) withObject:nil afterDelay:0.3];
            break;
        case TouchesType_DBLTAP:
            break;
        case TouchesType_LONGTAP:
            break;
        case TouchesType_MOVE:
            break;
        case TouchesType_NOT:
        default:
            break;
    }
    
    // 터치 이벤트 처리후 원상태로 초기화
    [oms setCurrentTouchesType:TouchesType_NOT];
    
    //[OMMessageBox showAlertMessage:@"" :@"터치종료"];
}
- (void) overlayTouched:(Overlay *)overlay
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    // 오버레이 터치됐을 경우 터치이벤트 정리
    [oms setCurrentTouchesType:TouchesType_NOT];
    
    if ( [overlay isKindOfClass:[OMImageOverlay class]] )
    {
        // 원터치(롱탭) POI
        if ( [overlay isMemberOfClass:[OMImageOverlayLongtap class]] )
        {
            // 롱탭 POI가 클릭된 경우는 전부 제거하도록 한다.
            [mc.kmap removeSpecialOverlaysKindOfClass:[OMImageOverlayLongtap class]];
            [mc.kmap removeSpecialOverlaysKindOfClass:[OMUserOverlayMarkerOption class]];
            // 롱탭관련 POI 제거후 실시간 정보가 살아 있을 경우 실시간정보도 해제..
            [self clearRealtimeTrafficTimeTable:YES];
            
            // ver4 오버레이 제거시에도 nil 추가
            [self currentOverlayNoSelected];
            
        }
        // 검색결과 단일 POI
        else if ( [overlay isMemberOfClass:[OMImageOverlaySearchSingle class]] )
        {
            // 검색결과 단일POI가 클린된 경우
            OMImageOverlaySearchSingle *searchSingleOverlay = (OMImageOverlaySearchSingle*)overlay;
            // 선택되어 있는 경우 선택해제하도록 한다.
            if (searchSingleOverlay.selected)
            {
                [self pinPOIMarkerOption:NO targetInfo:Nil animated:YES];
                [mc.kmap selectPOIOverlay:nil];
            }
            // 해제되어 있는 경우 선택하도록 하자.
            else
            {
                [self pinPOIMarkerOption:YES targetInfo:searchSingleOverlay.additionalInfo animated:YES];
                [mc.kmap selectPOIOverlay:searchSingleOverlay];
            }
        }
        // 검색결과 다중 POI
        else if ( [overlay isMemberOfClass:[OMImageOverlaySearchMulti class]] )
        {
            OMImageOverlaySearchMulti *searchMultiOverlay = (OMImageOverlaySearchMulti*)overlay;
            // 선택되어 있는 경우 선택해제하도록 한다.
            if ( searchMultiOverlay.selected)
            {
                [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
                [mc.kmap selectPOIOverlay:nil];
            }
            // 해제되어 잇는 경우 선택하는 과정이 필요하다.
            else
            {
                // 중첩된 POI 선택한경우
                if ( searchMultiOverlay.duplicated )
                {
                    //[self showDuplicatePOIList:searchMultiOverlay];
                    [self showDuplicatedPOIList:searchMultiOverlay];
                }
                // 단일 POI 선택한 경우
                else
                {
                    [self pinPOIMarkerOption:YES targetInfo:searchMultiOverlay.additionalInfo animated:YES];
                    [mc.kmap selectPOIOverlay:searchMultiOverlay];
                    _selectedMultiPOIIndex = [[searchMultiOverlay.additionalInfo objectForKeyGC:@"Index"] intValue];
                }
            }
        }
        // 최근검색 POI
        else if ( [overlay isMemberOfClass:[OMImageOverlayRecent class]] )
        {
            OMImageOverlayRecent *recentOverlay = (OMImageOverlayRecent*)overlay;
            
            // 설정-최근검색에서 생성된 경우 터치시 무조건 삭제하도록 한다.
            if ( [numberValueOfDiction(recentOverlay.additionalInfo, @"LongtapClose") boolValue] )
            {
                [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
                [mc.kmap selectPOIOverlay:nil];
                [mc.kmap removeOverlay:overlay];
            }
            // 선택되어 있는 경우 선택해제하도록 한다.
            else if ( recentOverlay.selected)
            {
                [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
                [mc.kmap selectPOIOverlay:nil];
            }
            // 해제되어 있는 경우 선택하다로고 한다.
            else
            {
                [self pinPOIMarkerOption:YES targetInfo:recentOverlay.additionalInfo animated:YES];
                [mc.kmap selectPOIOverlay:recentOverlay];
            }
        }
        // 즐겨찾기 POI
        else if ( [overlay isMemberOfClass:[OMImageOverlayFavorite class]] )
        {
            OMImageOverlayFavorite *favoriteOverlay = (OMImageOverlayFavorite*)overlay;
            
            // 설정-즐겨찾기에서 생성된 경우 터치시 무조건 삭제하도록 한다.
            if ( [numberValueOfDiction(favoriteOverlay.additionalInfo, @"LongtapClose") boolValue] )
            {
                [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
                [mc.kmap selectPOIOverlay:nil];
                [mc.kmap removeOverlay:overlay];
            }
            // 선택되어 있는 경우 선택해제하도록 한다.
            else if ( favoriteOverlay.selected)
            {
                [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
                [mc.kmap selectPOIOverlay:nil];
            }
            // 해제되어 있는 경우 선택하도록  한다.
            else
            {
                [self pinPOIMarkerOption:YES targetInfo:favoriteOverlay.additionalInfo animated:YES];
                [mc.kmap selectPOIOverlay:favoriteOverlay];
            }
        }
        // 교통옵션 CCTV POI
        else if ( [overlay isMemberOfClass:[OMImageOverlayTrafficCCTV class]] )
        {
            OMImageOverlayTrafficCCTV *cctvOverlay = (OMImageOverlayTrafficCCTV*)overlay;
            
            // 선택되어 있는 경우 선택해제하도록 한다.
            if ( cctvOverlay.selected )
            {
                [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
                [mc.kmap selectPOIOverlay:nil];
            }
            // 해제되어 있는 경우선택하도록 한다.
            else
            {
                [mc.kmap selectPOIOverlay:nil];
                // 중복 POI
                if ( [numberValueOfDiction(cctvOverlay.additionalInfo, @"Duplicated") boolValue] )
                {
                    [self showDuplicatedPOIList:cctvOverlay];
                }
                // 단일 POI
                else
                {
                    [self pinPOIMarkerOption:YES targetInfo:cctvOverlay.additionalInfo animated:YES];
                    [mc.kmap selectPOIOverlay:cctvOverlay];
                    _selectedMultiPOIIndex = -3;
                }
            }
        }
        // 교통옵션 버스정류장 POI
        else if ( [overlay isMemberOfClass:[OMImageOverlayTrafficBusStation class]] )
        {
            OMImageOverlayTrafficBusStation *busStationOverlay = (OMImageOverlayTrafficBusStation*)overlay;
            // 선택되어 있는 경우 선택해제하도록 한다.
            if ( busStationOverlay.selected)
            {
                [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
                [mc.kmap selectPOIOverlay:nil];
            }
            // 해제되어 있는 경우 선택하도록 한다.
            else
            {
                // 중첩된 POI 선택한경우
                if ( busStationOverlay.duplicated )
                {
                    [self showDuplicatedPOIList:busStationOverlay];
                }
                // 단일 POI 선택한 경우
                else
                {
                    [self pinPOIMarkerOption:YES targetInfo:busStationOverlay.additionalInfo animated:YES];
                    [mc.kmap selectPOIOverlay:busStationOverlay];
                    _selectedMultiPOIIndex = [[busStationOverlay.additionalInfo objectForKeyGC:@"Index"] intValue];
                }
            }
        }
        // 교통옵션 지하철 POI
        else if ( [overlay isMemberOfClass:[OMImageOverlayTrafficSubwayStation class]] )
        {
            OMImageOverlayTrafficSubwayStation *subwayOverlay = (OMImageOverlayTrafficSubwayStation*)overlay;
            // 선택되어 있는 경우 선택해제하도록 한다.
            if ( subwayOverlay.selected )
            {
                [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
                [mc.kmap selectPOIOverlay:nil];
            }
            // 해제되어 있는 경우 선택하도록 한다.
            else
            {
                // 중첩된 POI 선택한 경우
                if ( subwayOverlay.duplicated )
                {
                    [self showDuplicatedPOIList:subwayOverlay];
                }
                // 단일 POI 선택한 경우
                else
                {
                    [self pinPOIMarkerOption:YES targetInfo:subwayOverlay.additionalInfo animated:YES];
                    [mc.kmap selectPOIOverlay:subwayOverlay];
                    _selectedMultiPOIIndex = [numberValueOfDiction(subwayOverlay.additionalInfo, @"Index") intValue];
                }
            }
        }
        // 테마 오버레이
        else if ( [overlay isMemberOfClass:[OMImageOverlayTheme class]] )
        {
            OMImageOverlayTheme *themeOverlay = (OMImageOverlayTheme*)overlay;
            // 선택되어 있는 경우 선택해제하도록 한다.
            if ( themeOverlay.selected )
            {
                [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
                [mc.kmap selectPOIOverlay:nil];
            }
            // 해제되어 있는 경우 선택하도록 한다.
            else
            {
                // 중첩된 POI 선택한 경우
                if ( themeOverlay.duplicated )
                {
                    [self showDuplicatedPOIList:themeOverlay];
                }
                // 단일 POI 선택한 경우
                else
                {
                    [self pinPOIMarkerOption:YES targetInfo:themeOverlay.additionalInfo animated:YES];
                    [mc.kmap selectPOIOverlay:themeOverlay];
                    _selectedMultiPOIIndex = [numberValueOfDiction(themeOverlay.additionalInfo, @"Index") intValue];
                }
            }
            
        }
        // 교통옵션
        else if ( ( [overlay isMemberOfClass:[OMImageOverlaySearchRouteStart class]] )
                 || ( [overlay isMemberOfClass:[OMImageOverlaySearchRouteDest class]] )
                 || ( [overlay isMemberOfClass:[OMImageOverlaySearchRouteVisit class]] ))
        {
            [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
        }
        // 그외 이상한 오버레이??
        else
        {
#ifdef DEBUG
            [OMMessageBox showAlertMessage:@"디버깅 모드 전용 메세지" :@"정의되지 않은 오버레이가 선택됐네요?? 뭘하신거죠??"];
#endif
        }
        
    }
    
}


/* =======================================================================================
 * 현재 화면 중심좌표에 대한 리버스지오코딩은 mapBoundsChanged 에서 처리한다.
 * 화면 줌인아웃에 따른 줌레벨 이미지 처리는 mapStatusChanged 와 더블탭 메소드에서 처리한다.
 *
 *=======================================================================================
 */

- (void) mapBoundsChanged:(KMapView *)mapView Bounds:(KBounds)bounds
{
}

- (void) mapStatusChanged:(NSNumber *)mapLoad isZoom:(NSNumber *)isZoom
{
    // mapLoad :map이동상태 (0:이동시작, 1:이동중 2:이동완료)
    // isZoom :map의 이동상태 변경이 Zoom In/Out에 의한 것이라면 True, 아니라면 False
    
    if ( [mapLoad intValue] == 2 )
    {
        
        //OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        MapContainer *mc = [MapContainer sharedMapContainer_Main];
        
        // 이전 좌표나 줌레벨이 변경됐을 경우 현재 주소 업데이트
        if ( CoordDistance(mc.kmap.centerCoordinate, mc.kmap.lastMapCenterCoordinate) > 0 || mc.kmap.zoomLevel != mc.kmap.lastMapZoomLevel )
            [self refreshCurrentAddressLabel];
        
        if ( [isZoom boolValue] )
        {
            // 변경된 레벨에 맞춰서 축척이미지 변경
            [self toggleZoomLevel];
            // 줌레벨 변경으로 인해 지도상태가 변경됏으면서 MultiPOI 지도화면일때 POI(중첩처리)를 다시 렌더링한다.
            if (_nMapRenderType == MapRenderType_SearchResult_MultiPOI)
            {
                BOOL isLongTaped = _selectedMultiPOIIndex == -2; //multi poi 그려지기 전에 현재 선택된 인덱스값을 가져와서 판단해야한다.
                
                // 마커 렌더링
                //[self markingMultiPOIRenderCore];
                [self pinSearchMultiPOIOverlay:YES];
                
                // 롱탭 POI 가 마지막으로 선택된 경우 롱탭 그림
                if ( isLongTaped )
                {
                    //[self pinLongtapPOIOverlay:YES :NO];
                }
                if(_currentLongTapOverlay != nil)
                    [self pinLongtapPOIOverlay:isLongTaped :NO];
                
            }
        }
        else
        {
        }
        
        
        // 교통옵션 아무것이나 활성화 된상태에서 공통적으로 처리할 메소드 일정거리 이상 이동한 경우 공통적으로처리할 메소드
        if ( ( mc.kmap.trafficCCTV || mc.kmap.trafficBusStation || mc.kmap.trafficSubwayStation ) )
        {
            // MIK.geun :: 20120928
            // 교통옵션 활성화상태에서 실시간정보 창 닫는 케이스를 수정함
            // ==> 현재 선택된 POI  없거나, 현재 화면에서 사라졌을때 제거
            if ( _vwRealtimeTrafficTimeTableContainer.hidden == NO )
            {
                BOOL anyOverlaySelected = NO;
                OMImageOverlay *trafficOverlay = nil;
                // 전체 오버레이를 탐색하며 교통옵션 오버레이면서 선택된 상태인지 판단하자.
                
                for (Overlay *currentOverlay in mc.kmap.getOverlays)
                {
                    // 선택된 오버레이 검색
                    if ( [currentOverlay isKindOfClass:[OMImageOverlay class]] && ((OMImageOverlay*)currentOverlay).selected)
                    {
                        // 교통옵션(지하철역_버스정류장) 관련 오버레이면
                        if ( [currentOverlay isKindOfClass:[OMImageOverlayTrafficBusStation class]]
                            || [currentOverlay isKindOfClass:[OMImageOverlayTrafficSubwayStation class]] )
                        {
                            trafficOverlay  = (OMImageOverlay*)currentOverlay;
                            [trafficOverlay retain];
                        }
                        // 다른종류 오버레이면 이쯤해서 털고나가자..
                        else
                        {
                        }
                        // 일단 선택된 오버레이 찾기는 했으니까~
                        anyOverlaySelected = YES;
                        break;
                    }
                }
                
                // 선택된 교통옵션 오버레이가 존재하면..
                if (trafficOverlay)
                {
                    CGPoint trafficOverlayPointOnView = [mc.kmap convertCoordinate:trafficOverlay.coord];
                    // 오버레이가 현재 맵뷰컨테이너 밖으로 나간상태면...
                    if ( trafficOverlayPointOnView.x < -10 || trafficOverlayPointOnView.y < -10
                        || trafficOverlayPointOnView.x > mc.kmap.frame.size.width + 10
                        || trafficOverlayPointOnView.y > mc.kmap.frame.size.height + 10 )
                    {
                        // 해당 오버레이 선택해제 (**실시간정보도 연계되서 해제됨.)
                        [mc.kmap selectPOIOverlay:nil]; // 어짜피 교통옵션선택된 상태니 무조건 선택해제하면된다.
                        [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
                        //[self clearRealtimeTrafficTimeTable];
                    }
                    // 아무튼 교통옵션 활성화 된상태에서 줌인/아웃된경우
                    else if ( [isZoom boolValue] )
                    {
                        [mc.kmap selectPOIOverlay:nil];
                        [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
                    }
                    
                    // 오버레이 해제 (retain에 대한 해제)
                    [trafficOverlay release];
                    trafficOverlay = nil;
                }
                else
                {
                    // 교통옵션은 활성화되어 있다. 그런데 선택된 교통옵션은 없다.
                    // 하지만 추가정보.. 그어떤 오버레이도 선택되지 않았다. 그건.... 실시간창을 그냥 닫어버려도 된다.???
                    if ( anyOverlaySelected == NO )
                    {
                        //[OMMessageBox showAlertMessage:@"" :@"교통옵션활성화, 하지만 선택된 오버레이는 없음."];
                        [mc.kmap selectPOIOverlay:nil];
                        [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
                    }
                }
                
                
            }
            
        }
        
        // ===========================
        // 교통옵션 (CCTV/버스/지하철) 렌더링
        // MIK.geun :: 20121010 // 바로 검색/렌더링하면 KMapSDK가 성능이 떨어져서,, 딜레이를 건뒤 1초뒤에 검색/렌더링 하도록 수정
        // ===========================
        if ( mc.kmap.trafficBusStation && mc.kmap.adjustZoomLevel >= 9 )
        {
            double distance = CoordDistance(_trafficOptionLastRenderCoordinate, mc.kmap.centerCoordinate);
            double radius = mc.getCurrentMapZoomLevelMeterWithScreen/2.5;
            BOOL isValidZoom = [isZoom boolValue] ? mc.kmap.lastMapZoomLevel != mc.kmap.zoomLevel : NO;
            
            if ( distance > radius  || isValidZoom )
            {
                _trafficOptionLastRequestTime = [NSDate timeIntervalSinceReferenceDate];
                NSMutableDictionary *traffic = [[NSMutableDictionary alloc] init];
                [traffic setObject:[NSNumber numberWithInt:1] forKey:@"Type"];
                [traffic setObject:isZoom forKey:@"IsZoom"];
                [traffic setObject:[NSNumber numberWithDouble:_trafficOptionLastRequestTime] forKey:@"Time"];
                [_themesRequestInfo setObject:traffic forKey:@"Traffic"];
                [traffic release];
                
                // 줌 인/아웃 모드일때는 미리 오버레이를 지워놓고 타이머를 태우자.
                if ( [isZoom boolValue] )
                    [mc.kmap removeAllTrafficOverlay];
                
                // 타이머 콜백함수 체크를 위한 UserInfo 객체 생성
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                [userInfo setObject:[NSNumber numberWithInt:0] forKey:@"Type"];
                [userInfo setObject:[NSNumber numberWithDouble:_trafficOptionLastRequestTime] forKey:@"Time"];
                NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(callbackThemesRequest:) userInfo:userInfo repeats:NO];
                [userInfo release];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            }
        }
        else if ( mc.kmap.trafficBusStation && mc.kmap.adjustZoomLevel < 9 )
        {
            // 교통옵션 검색요청 시간 초기화
            _trafficOptionLastRequestTime = [NSDate timeIntervalSinceReferenceDate];
            // 오버레이 삭제
            [mc.kmap removeAllTrafficOverlay];
        }
        else if ( mc.kmap.trafficSubwayStation && mc.kmap.adjustZoomLevel >= 7 )
        {
            double distance = CoordDistance(_trafficOptionLastRenderCoordinate, mc.kmap.centerCoordinate);
            double radius = mc.getCurrentMapZoomLevelMeterWithScreen/2.5;
            BOOL isValidZoom = [isZoom boolValue] ? mc.kmap.lastMapZoomLevel != mc.kmap.zoomLevel : NO;
            
            if ( distance > radius  || isValidZoom )
            {
                _trafficOptionLastRequestTime = [NSDate timeIntervalSinceReferenceDate];
                NSMutableDictionary *traffic = [[NSMutableDictionary alloc] init];
                [traffic setObject:[NSNumber numberWithInt:2] forKey:@"Type"];
                [traffic setObject:isZoom forKey:@"IsZoom"];
                [traffic setObject:[NSNumber numberWithDouble:_trafficOptionLastRequestTime] forKey:@"Time"];
                [_themesRequestInfo setObject:traffic forKey:@"Traffic"];
                [traffic release];
                
                // 줌 인/아웃 모드일때는 미리 오버레이를 지워놓고 타이머를 태우자.
                if ( [isZoom boolValue] )
                    [mc.kmap removeAllTrafficOverlay];
                
                // 타이머 콜백함수 체크를 위한 UserInfo 객체 생성
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                [userInfo setObject:[NSNumber numberWithInt:0] forKey:@"Type"];
                [userInfo setObject:[NSNumber numberWithDouble:_trafficOptionLastRequestTime] forKey:@"Time"];
                NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(callbackThemesRequest:) userInfo:userInfo repeats:NO];
                [userInfo release];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            }
        }
        else if ( mc.kmap.trafficSubwayStation && mc.kmap.adjustZoomLevel < 7 )
        {
            // 교통옵션 검색요청 시간 초기화
            _trafficOptionLastRequestTime = [NSDate timeIntervalSinceReferenceDate];
            // 오버레이 삭제
            [mc.kmap removeAllTrafficOverlay];
        }
        else if ( mc.kmap.trafficCCTV && mc.kmap.adjustZoomLevel >= 4 )
        {
            double distance = CoordDistance(_trafficOptionLastRenderCoordinate, mc.kmap.centerCoordinate);
            double radius = mc.getCurrentMapZoomLevelMeterWithScreen/2.5;
            BOOL isValidZoom = [isZoom boolValue] ? mc.kmap.lastMapZoomLevel != mc.kmap.zoomLevel : NO;
            
            if ( distance > radius  || isValidZoom )
            {
                _trafficOptionLastRequestTime = [NSDate timeIntervalSinceReferenceDate];
                NSMutableDictionary *traffic = [[NSMutableDictionary alloc] init];
                [traffic setObject:[NSNumber numberWithInt:0] forKey:@"Type"];
                [traffic setObject:isZoom forKey:@"IsZoom"];
                [traffic setObject:[NSNumber numberWithDouble:_trafficOptionLastRequestTime] forKey:@"Time"];
                [_themesRequestInfo setObject:traffic forKey:@"Traffic"];
                [traffic release];
                
                // 줌 인/아웃 모드일때는 미리 오버레이를 지워놓고 타이머를 태우자.
                if ( [isZoom boolValue] )
                    [mc.kmap removeAllTrafficOverlayWithoutLinePoly];
                
                // 타이머 콜백함수 체크를 위한 UserInfo 객체 생성
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                [userInfo setObject:[NSNumber numberWithInt:0] forKey:@"Type"];
                [userInfo setObject:[NSNumber numberWithDouble:_trafficOptionLastRequestTime] forKey:@"Time"];
                NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(callbackThemesRequest:) userInfo:userInfo repeats:NO];
                [userInfo release];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            }
        }
        else if ( mc.kmap.trafficCCTV && mc.kmap.adjustZoomLevel < 4 )
        {
            // 교통옵션 검색요청 시간 초기화
            _trafficOptionLastRequestTime = [NSDate timeIntervalSinceReferenceDate];
            // 오버레이 삭제
            [mc.kmap removeAllTrafficOverlayWithoutLinePoly];
        }
        
        // ==========
        // 테마 렌더링
        // ==========
        NSInteger themeMaxRenderingZoomLevel = [numberValueOfDiction([ThemeCommon sharedThemeCommon].additionalInfo, @"MaxRenderingZoomLevel") integerValue];
        NSLog(@"%d  %d", mc.kmap.adjustZoomLevel, themeMaxRenderingZoomLevel);
        if ( mc.kmap.theme && mc.kmap.adjustZoomLevel >= themeMaxRenderingZoomLevel )
        {
            double distance = CoordDistance(_themeLastRenderingCoordinate, mc.kmap.centerCoordinate);
            double radius = mc.getCurrentMapZoomLevelMeterWithScreen/2.5;
            BOOL isValidZoom = [isZoom boolValue] ? mc.kmap.lastMapZoomLevel != mc.kmap.zoomLevel : NO;
            
            if ( distance > radius  || isValidZoom )
            {
                _themeLastRequestTime = [NSDate timeIntervalSinceReferenceDate];
                NSMutableDictionary *theme = [[NSMutableDictionary alloc] init];
                [theme setObject:isZoom forKey:@"IsZoom"];
                [theme setObject:[NSNumber numberWithDouble:_themeLastRequestTime] forKey:@"Time"];
                [_themesRequestInfo setObject:theme forKey:@"Theme"];
                [theme release];
                
                // 줌 인/아웃 모드일때는 미리 오버레이를 지워놓고 타이머를 태우자.
                if ( [isZoom boolValue] )
                    [mc.kmap removeAllThemeOverlay];
                
                // 타이머 콜백함수 체크를 위한 UserInfo 객체 생성
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                [userInfo setObject:[NSNumber numberWithInt:1] forKey:@"Type"];
                [userInfo setObject:[NSNumber numberWithDouble:_themeLastRequestTime] forKey:@"Time"];
                NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(callbackThemesRequest:) userInfo:userInfo repeats:NO];
                [userInfo release];
                [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            }
        }
        // 테마가 최대 렌더링 줌레벨을 벗어난 경우 렌더링하지 않는다.
        else if (  mc.kmap.theme && mc.kmap.adjustZoomLevel < themeMaxRenderingZoomLevel )
        {
            // 테마 검색 요청시간 초기화
            _themeLastRequestTime = [NSDate timeIntervalSinceReferenceDate];
            // 테마 지우기
            [mc.kmap removeAllThemeOverlay];
            
            // 이전 줌레벨 수치 보정 (작은글씨지도일때..)
            NSInteger adjustLastZoomLevel = mc.kmap.mapDisplay == KMapDisplayNormalSmallText ? mc.kmap.lastMapZoomLevel-1 : mc.kmap.lastMapZoomLevel;
            // 처음으로 최대 렌더링 줌레벨을 넘어간 경우에만 토스트 띄우기
            if ( [isZoom boolValue] && adjustLastZoomLevel >= themeMaxRenderingZoomLevel )
            {
                // 메세지 조합하기
                NSString *message = [NSString stringWithFormat:@"선택하신 테마는 %@ 이하에서만 제공됩니다.", [self convertToMeterStringFromZoomLevel:themeMaxRenderingZoomLevel checkMapDisplay:NO]];
                // 토스트 띄우기
                [[OMToast sharedToast] showToastMessagePopup:message superView:self.view maxBottomPoint:self.vwCurrentAddressGroup.frame.origin.y-10 autoClose:YES];
            }
            
        }
        else if (_nMapRenderType == MapRenderType_SearchResult_LinePolyGon)
        {
            NSLog(@"라인폴리곤");
            _currentLongTapOverlay = nil;
            
            int vertextCnt = [[[[[OllehMapStatus sharedOllehMapStatus].linePolygonDictionary objectForKeyGC:@"LinePolygon"] objectAtIndexGC:0] objectForKeyGC:@"part"] count];
            
            int i=0;
            
            
            //NSMutableArray *vertexShortX = [NSArray array];
            //NSMutableArray *vertexShortY = [NSArray array];
            
            double rawDistance = DBL_MAX;
            double shortX = 1.0;
            double shortY = 1.0;
            
            while (i < vertextCnt)
            {
            
            NSArray *vertexArr = [[[[[[OllehMapStatus sharedOllehMapStatus].linePolygonDictionary objectForKeyGC:@"LinePolygon"] objectAtIndexGC:0] objectForKeyGC:@"part"] objectAtIndexGC:i] objectForKeyGC:@"vertex"];

            Coord myCrd = [[MapContainer sharedMapContainer_Main].kmap centerCoordinate];
            
            

            
            for (int i = 0;i<vertexArr.count - 1;i++)
            {
                NSDictionary *dic = [vertexArr objectAtIndex:i];
                Coord compareDist1 = CoordMake([[dic objectForKeyGC:@"x"] doubleValue], [[dic objectForKeyGC:@"y"] doubleValue]);
                
                NSDictionary *dic2 = [vertexArr objectAtIndex:i+1];
                Coord compareDist2 = CoordMake([[dic2 objectForKeyGC:@"x"] doubleValue], [[dic2 objectForKeyGC:@"y"] doubleValue]);
                
                Coord shortestCoord = [self tester:myCrd pointA:compareDist1 pointB:compareDist2];
                
                double shortDist = CoordDistance(myCrd, shortestCoord);
                
                if(shortDist < rawDistance)
                {
                    rawDistance = shortDist;
                    
                    shortX = shortestCoord.x;
                    shortY = shortestCoord.y;
      
                }
            }
                
                
            
                i++;
            }
            
            
                
            [self pinSearchSinglePOIOverlayWithLinePolygon:YES modiX:shortX modiY:shortY];
        }
        
        NSLog(@"현재 줌레벨 : %d", mc.kmap.adjustZoomLevel);
        

        // 작은글씨지도는 26km 축척에서도 지적도가 보인다
        int cadastralMaxLevel = mc.kmap.mapDisplay == KMapDisplayNormalSmallText ? 2 : 3;
        
        // 지적도 토스트 팝업
        if (mc.kmap.CadastralInfo && mc.kmap.adjustZoomLevel < cadastralMaxLevel)
        {
            // 이전 줌레벨 수치 보정 (작은글씨지도일때..)
            NSInteger adjustLastZoomLevel = mc.kmap.mapDisplay == KMapDisplayNormalSmallText ? mc.kmap.lastMapZoomLevel-1 : mc.kmap.lastMapZoomLevel;
            
            NSLog(@"이전 줌레벨 : %d", adjustLastZoomLevel);
            
            // 이전 줌 레벨이 max레벨보다 작거나 같으면(팝업을 띄운다)
            // 축소(=줌 레벨이 작아짐 = 이전줌 > 현재줌 => 이전줌 > 맥스레벨)
            if([isZoom boolValue] && adjustLastZoomLevel >= cadastralMaxLevel)
            {
                // 메세지 조합하기
                //NSString *message = @"지적편집도는 26km 이하에서만 제공됩니다.";
                // 메세지 조합하기
                NSString *message = [NSString stringWithFormat:@"지적편집도는 %@ 이상에서 제공되지 않습니다.", [self convertToMeterStringFromZoomLevel:mc.kmap.adjustZoomLevel checkMapDisplay:NO]];
                
                
                // 토스트 띄우기
                [[OMToast sharedToast] showToastCadaStralPopup:message superView:self.view maxBottomPoint:self.vwCurrentAddressGroup.frame.origin.y-10 autoClose:YES];
                
                //[[OMToast sharedToast] showToastMessagePopup:message superView:self.view maxBottomPoint:self.vwCurrentAddressGroup.frame.origin.y-10 autoClose:YES];
            }
            
        }

        
        if([OllehMapStatus sharedOllehMapStatus].searchResultRouteStart.used && [isZoom boolValue])
        {
            
        }
        
#ifdef DEBUG
        [self setSearchKeyword:[NSString stringWithFormat:@"* 좌표:%.0f,%.0f / 줌:%d of %d", mc.kmap.centerCoordinate.x, mc.kmap.centerCoordinate.y,mc.kmap.zoomLevel,mc.kmap.maxZoomLevel] :NO];
#endif
        
        
        // 최근 지도좌표를 업데이트 해준다.
        [mc.kmap setLastMapCenterCoordinate:mc.kmap.centerCoordinate];
        // 최근 지도 줌레벨을 업데이트 해준다.
        [mc.kmap setLastMapZoomLevel:mc.kmap.zoomLevel];
    }
}

// 교통옵션/테마 검색용 타이머 콜백함수
- (void) callbackThemesRequest :(NSTimer*)timer
{
    // 타이머 validcheck, 타이머 정보, 테마검색요청 정보 확인.
    if ( !timer || !timer.isValid |!timer.userInfo || !_themesRequestInfo ) return;
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    // 타이머 콜백함수 검증... 마지막에 요청된 시간을 비교.
    NSDictionary *requestInfo = (NSDictionary*)timer.userInfo;
    NSInteger requestType = [numberValueOfDiction(requestInfo, @"Type") integerValue] ;
    NSTimeInterval requestTime = [numberValueOfDiction(requestInfo, @"Time") doubleValue];
    
    // 교통옵션 요청인 경우...
    if ( requestType == 0  && requestTime == _trafficOptionLastRequestTime )
    {
        NSDictionary *traffic = [_themesRequestInfo objectForKeyGC:@"Traffic"];
        if ( !traffic )  return;
        
        NSInteger trafficType = [numberValueOfDiction(traffic, @"Type") integerValue];
        BOOL isZoom = [numberValueOfDiction(traffic, @"IsZoom") boolValue];
        
        if ( trafficType == 0 )
        {
            // MIK.geun :: 20121009 // 테마와 동일한작업을 위한 코드추가
            // 줌레벨이 변경된 경우에만 기존 교통옵션 오버레이가 삭제되도록한다.
            if ( isZoom ) [mc.kmap removeAllTrafficOverlayWithoutLinePoly];
            // 검색반경 계산
            Coord utmkMinCoord = [mc.kmap convertPoint:CGPointMake(-50, -50)];
            Coord utmkMaxCoord = [mc.kmap convertPoint:CGPointMake(self.view.frame.size.width+50, self.view.frame.size.height+50)];
            Coord wgsMinCoord = [mc.kmap convertCoordinate:utmkMinCoord inCoordType:KCoordType_UTMK outCoordType:KCoordType_WGS84];
            Coord wgsMaxCoord = [mc.kmap convertCoordinate:utmkMaxCoord inCoordType:KCoordType_UTMK outCoordType:KCoordType_WGS84];
            // 검색요청
            [[ServerConnector sharedServerConnection] requestTrafficOptionCCTVList:self action:@selector(finishTrafficOptionCCTVList:) minX:wgsMinCoord.x minY:wgsMinCoord.y maxX:wgsMaxCoord.x maxY:wgsMaxCoord.y];
        }
        else if ( trafficType == 1 ) // 버스정류장
        {
            // MIK.geun :: 20121009 // 테마와 동일한작업을 위한 코드추가
            // 줌레벨이 변경된 경우에만 기존 교통옵션 오버레이가 삭제되도록한다.
            if ( isZoom ) [mc.kmap removeAllTrafficOverlay];
            // 검색요청
            [[ServerConnector sharedServerConnection] requestTrafficOptionBusStationList:self action:@selector(finishTrafficOptionBusStationList:) coordidate:mc.kmap.centerCoordinate radius:mc.getCurrentMapZoomLevelMeterWithScreen/2];
        }
        else if ( trafficType == 2 )
        {
            // MIK.geun :: 20121009 // 테마와 동일한작업을 위한 코드추가
            // 줌레벨이 변경된 경우에만 기존 교통옵션 오버레이가 삭제되도록한다.
            if ( isZoom ) [mc.kmap removeAllTrafficOverlay];
            // 검색요청
            [[ServerConnector sharedServerConnection] requestTrafficOptionSubwayStationList:self action:@selector(finishTrafficOptionSubwayStationList:) coordidate:mc.kmap.centerCoordinate radius:mc.getCurrentMapZoomLevelMeterWithScreen/2];
        }
    }
    // 테마 요청인 경우...
    else if ( requestType == 1 && requestTime == _themeLastRequestTime )
    {
        NSDictionary *theme = [_themesRequestInfo objectForKeyGC:@"Theme"];
        if ( !theme )  return;
        
        // 테마코드 가져오기
        NSString *themeCode = stringValueOfDictionary([ThemeCommon sharedThemeCommon].additionalInfo, @"ThemeCode");
        
        // 검색요청
        [[ServerConnector sharedServerConnection] requestThemeDetail:self action:@selector(didFinishRequestThemeSearch:) themeCode:themeCode pX:mc.kmap.centerCoordinate.x pY:mc.kmap.centerCoordinate.y radius:[mc getCurrentMapZoomLevelMeterWithScreen]/2];
    }
    
    // 타이머 해제
    [timer invalidate];
}

// ******************************



// ==============================
// [ OllehMap - KMap 연동 메소드 ]
// ==============================

- (void) pinRouteStartPOIOverlay
{
    // ver4 오버레이 제거시에도 nil 추가
    [self currentOverlayNoSelected];
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    OMImageOverlaySearchRouteStart *overlay = [[OMImageOverlaySearchRouteStart alloc] initWithImage:[UIImage imageNamed:@"map_marker_start.png"]];
    
    //[overlay setSelected:YES];
    [overlay setCoord:oms.searchResultRouteStart.coordLocationPoint];
    [overlay setDelegate:self];
    //[mc.kmap setCenterCoordinate:oms.searchResult.coordLocationPoint];
    
    //NSLog(@"%f %f", oms.searchResult.coordLocationPoint.x, oms.searchResult.coordLocationPoint.y);
    
    [mc.kmap addOverlay:overlay];
    
    //NSLog(@"%d", mc.kmap.getOverlays.count);
    
    [overlay release];
}
- (void) pinRouteVisitPOIOverlay
{
    // ver4 오버레이 제거시에도 nil 추가
    [self currentOverlayNoSelected];
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    OMImageOverlaySearchRouteVisit *overlay = [[OMImageOverlaySearchRouteVisit alloc] initWithImage:[UIImage imageNamed:@"map_marker_via.png"]];
    
    //[overlay setSelected:YES];
    [overlay setCoord:oms.searchResultRouteVisit.coordLocationPoint];
    [overlay setDelegate:self];
    [mc.kmap addOverlay:overlay];
    
    [overlay release];
}
- (void) pinRouteDestPOIOverlay
{
    // ver4 오버레이 제거시에도 nil 추가
    [self currentOverlayNoSelected];
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    OMImageOverlaySearchRouteDest *overlay = [[OMImageOverlaySearchRouteDest alloc] initWithImage:[UIImage imageNamed:@"map_marker_stop.png"]];
    
    //[overlay setSelected:YES];
    [overlay setCoord:oms.searchResultRouteDest.coordLocationPoint];
    [overlay setDelegate:self];
    [mc.kmap addOverlay:overlay];
    
    [overlay release];
}

- (void) pinLongtapPOIOverlay:(BOOL)isDisplay
{
    [self pinLongtapPOIOverlay:isDisplay :YES];
}
- (void) pinLongtapPOIOverlay:(BOOL)isDisplay :(BOOL)animatedMarkerOption
{
    // 롱탭POI 의 경우 재선택시 관련 오버레이를 전부 삭제해야한다.
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    if ( isDisplay )
    {
        // 기존 롱탭 및 마커옵션 전부 제거
        [mc.kmap removeSpecialOverlaysKindOfClass:[OMImageOverlayLongtap class]];
        [mc.kmap removeSpecialOverlaysKindOfClass:[OMUserOverlayMarkerOption class]];
        
        _selectedMultiPOIIndex = -2;
        
        // 기존 선택되어있을지도모르는 모든 이미지오버레이 해제
        [mc.kmap selectPOIOverlay:nil];
        
        // 롱탭 POI 생성
        OMImageOverlayLongtap *overlay = [[OMImageOverlayLongtap alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_poi_pressed.png"]];
        [overlay setSelected:YES]; // 롱탭의 경우 항상 선택된 상태로 나타나야 하기에 처음부터 YES
        [overlay setCoord:oms.searchResultOneTouchPOI.coordLocationPoint];
        [overlay setDelegate:self];
        
        _currentLongTapOverlay = overlay;
        
        [mc.kmap addOverlay:overlay];
        
        // 롱탭 추가정보 입력
        [overlay.additionalInfo setObject:oms.searchResultOneTouchPOI.strLocationName forKey:@"Name"];
        [overlay.additionalInfo setObject:oms.searchResultOneTouchPOI.strLocationAddress forKey:@"Address"];
        [overlay.additionalInfo setObject:oms.searchResultOneTouchPOI.strID forKey:@"ID"];
        [overlay.additionalInfo setObject:oms.searchResultOneTouchPOI.strType forKey:@"Type"];
        [overlay.additionalInfo setObject:oms.searchResultOneTouchPOI.strTel forKey:@"Tel"];
        [overlay.additionalInfo setObject:[NSNumber numberWithFloat:oms.searchResultOneTouchPOI.coordLocationPoint.x] forKey:@"X"];
        [overlay.additionalInfo setObject:[NSNumber numberWithFloat:oms.searchResultOneTouchPOI.coordLocationPoint.y] forKey:@"Y"];
        
        // 마커옵션 자동으로 펼치기
        [self pinPOIMarkerOption:YES targetInfo:overlay.additionalInfo animated:animatedMarkerOption];
        
        [overlay release];
    }
    // 롱탭 관련 오버레이 전부 제거
    else
    {
        // 롱탭POI 클래스 인스턴스 전부 제거
        [mc.kmap removeSpecialOverlaysKindOfClass:[OMImageOverlayLongtap class]];
        // 마커옵션 오버레이 제거
        [self pinPOIMarkerOption:NO targetInfo:nil animated:animatedMarkerOption];
    }
}
- (void) pinSearchSinglePOIOverlayWithLinePolygon:(BOOL)isDisplay modiX:(float)x modiY:(float)y
{
    // 검색결과 단일 POI 처리
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    if (isDisplay)
    {
        // 새로그리기전 기존 오버레이 제거 (단, 교통, 라인폴리곤 옵션 오버레이는 건들지 않는다.)
        [mc.kmap removeAllOverlaysWithoutTrafficWithoutLinePoly];
        
        _selectedMultiPOIIndex = -1;
        
        // 현재 인덱스가 0보다 클경우에는 알파벳 처리, 아닌경우..
        
        // 오버레이 생성
        OMImageOverlaySearchSingle *overlay = nil;
        if ( oms.searchResult.index > 0 )
        {
            overlay = [[OMImageOverlaySearchSingle alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_pressed.png"]];
            overlay.usePOIIcon = NO;
        }
        else
        {
            overlay = [[OMImageOverlaySearchSingle alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_poi_pressed.png"]];
            overlay.usePOIIcon = YES;
        }
        
        // 알파벳 이미지 추가
        UIImageView *searchIndexImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"marker_%d.png", oms.searchResult.index]]];
        [searchIndexImageView setFrame:
         CGRectMake((int)11, (int)9, 20, searchIndexImageView.image.size.height)];
        [overlay.getOverlayView addSubview:searchIndexImageView];
        [searchIndexImageView release];
        
        
        [overlay setSelected:YES];
        [overlay setCoord:CoordMake(x, y)];
        [overlay setDelegate:self];
        [mc.kmap addOverlay:overlay];
        
        
        
        // 추가정보 입력
        [overlay.additionalInfo setObject:oms.searchResult.strLocationName forKey:@"Name"];
        [overlay.additionalInfo setObject:oms.searchResult.strLocationAddress forKey:@"Address"];
        [overlay.additionalInfo setObject:oms.searchResult.strID forKey:@"ID"];
        [overlay.additionalInfo setObject:oms.searchResult.strType forKey:@"Type"];
        [overlay.additionalInfo setObject:oms.searchResult.strTel forKey:@"Tel"];
        [overlay.additionalInfo setObject:[NSNumber numberWithInt:oms.searchResult.index] forKey:@"Index"];
        [overlay.additionalInfo setObject:[NSNumber numberWithFloat:x] forKey:@"X"];
        [overlay.additionalInfo setObject:[NSNumber numberWithFloat:y] forKey:@"Y"];
        
        // 테스트용이니 삭제
//        NSArray *vertexArr = [[[[[[OllehMapStatus sharedOllehMapStatus].linePolygonDictionary objectForKeyGC:@"LinePolygon"] objectAtIndexGC:0] objectForKeyGC:@"part"] objectAtIndexGC:0] objectForKeyGC:@"vertex"];
//
//        int index=0;
//        for (NSDictionary *dic in vertexArr)
//        {
//            
//            Coord lineCrd = CoordMake([[dic objectForKeyGC:@"x"] doubleValue], [[dic objectForKeyGC:@"y"] doubleValue]);
//            
//            OMImageOverlaySearchSingle *ov = [[OMImageOverlaySearchSingle alloc] initWithImage:[UIImage imageNamed:@"radio_btn_on.png"]];
//            ov.usePOIIcon = NO;
//            [ov setSelected:YES];
//            [ov setCoord:lineCrd];
//            [ov setDelegate:self];
//            [mc.kmap addOverlay:ov];
//            
//            UIView *view = [[UIView alloc] init];
//            [view setFrame:CGRectMake((int)((overlay.imageSize.width + 1.5 - searchIndexImageView.image.size.width)/2) - 10,(int)((overlay.imageSize.height - 5 - 7 -searchIndexImageView.image.size.height)/2) - 5, 10, 10)];
//            [view setBackgroundColor:[UIColor clearColor]];
//            UILabel *lbl = [[UILabel alloc] init];
//            [lbl setFrame:CGRectMake(0, 0, 20, 10)];
//            [lbl setFont:[UIFont systemFontOfSize:8]];
//            [lbl setText:[NSString stringWithFormat:@"%d", index]];
//            [lbl setTextAlignment:NSTextAlignmentCenter];
//            [lbl setBackgroundColor:[UIColor clearColor]];
//            [view addSubview:lbl];
//            [lbl release];
//            
//            [ov.getOverlayView addSubview:view];
//            [view release];
//            
//            [ov release];
//            index++;
//        }
//        
//        OMImageOverlaySearchSingle *ov = [[OMImageOverlaySearchSingle alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_poi_pressed.png"]];
//        ov.usePOIIcon = NO;
//        [ov setSelected:YES];
//        [ov setCoord:mc.kmap.centerCoordinate];
//        [ov setDelegate:self];
//        [mc.kmap addOverlay:ov];
//        [ov release];
        
        // 테스트용이니 삭제
//        NSArray *vertexArr = [[[[[[OllehMapStatus sharedOllehMapStatus].linePolygonDictionary objectForKeyGC:@"LinePolygon"] objectAtIndexGC:0] objectForKeyGC:@"part"] objectAtIndexGC:0] objectForKeyGC:@"vertex"];
//        
//        Coord myCrd = [[MapContainer sharedMapContainer_Main].kmap centerCoordinate];
//        
//        
//        for (int i = 0;i<vertexArr.count - 1;i++)
//        {
//            NSDictionary *dic = [vertexArr objectAtIndex:i];
//            Coord compareDist1 = CoordMake([[dic objectForKeyGC:@"x"] doubleValue], [[dic objectForKeyGC:@"y"] doubleValue]);
//            
//            NSDictionary *dic2 = [vertexArr objectAtIndex:i+1];
//            Coord compareDist2 = CoordMake([[dic2 objectForKeyGC:@"x"] doubleValue], [[dic2 objectForKeyGC:@"y"] doubleValue]);
//            
//            Coord shortest = [self tester:myCrd pointA:compareDist1 pointB:compareDist2];
//
//
//        
//        OMImageOverlaySearchSingle *ov = [[OMImageOverlaySearchSingle alloc] initWithImage:[UIImage imageNamed:@"radio_btn_on.png"]];
//        ov.usePOIIcon = NO;
//        [ov setSelected:YES];
//        [ov setCoord:shortest];
//        [ov setDelegate:self];
//        [mc.kmap addOverlay:ov];
//            
//            UIView *view = [[UIView alloc] init];
//            [view setFrame:CGRectMake((int)((overlay.imageSize.width + 1.5 - searchIndexImageView.image.size.width)/2) - 10,(int)((overlay.imageSize.height - 5 - 7 -searchIndexImageView.image.size.height)/2) - 5, 10, 10)];
//            [view setBackgroundColor:[UIColor clearColor]];
//                     UILabel *lbl = [[UILabel alloc] init];
//                    [lbl setFrame:CGRectMake(0, 0, 20, 10)];
//                   [lbl setFont:[UIFont systemFontOfSize:8]];
//                    [lbl setText:[NSString stringWithFormat:@"%d", i]];
//                        [lbl setTextAlignment:NSTextAlignmentCenter];
//                        [lbl setBackgroundColor:[UIColor clearColor]];
//                        [view addSubview:lbl];
//                        [lbl release];
//            
//                        [ov.getOverlayView addSubview:view];
//                        [view release];
//        [ov release];
//        }
        
        
        
        
//        OMImageOverlaySearchSingle *ov = [[OMImageOverlaySearchSingle alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_poi_pressed.png"]];
//        ov.usePOIIcon = NO;
//        [ov setSelected:YES];
//        [ov setCoord:mc.kmap.centerCoordinate];
//        [ov setDelegate:self];
//        [mc.kmap addOverlay:ov];
//        [ov release];
        // 테스트용이니 삭제
        
        // 마커옵션 자동으로 펼치기
        [self pinPOIMarkerOption:YES targetInfo:overlay.additionalInfo animated:NO];
        
        
    }
    else
    {
        // 검색결과 단일POI 골라서 삭제하기
        [mc.kmap removeSpecialOverlaysKindOfClass:[OMImageOverlaySearchSingle class]];
        // 마커옵션 오버레이 제거
        [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
    }

}
- (void) pinSearchSinglePOIOverlay:(BOOL)isDisplay
{
    // 검색결과 단일 POI 처리
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    if (isDisplay)
    {
        // 새로그리기전 기존 모든 오버레이 제거 (단, 교통옵션 오버레이는 건들지 않는다.)
        [mc.kmap removeAllOverlaysWithoutTraffic];
        
        _selectedMultiPOIIndex = -1;
        
        // 현재 인덱스가 0보다 클경우에는 알파벳 처리, 아닌경우..
        
        // 오버레이 생성
        OMImageOverlaySearchSingle *overlay = nil;
        if ( oms.searchResult.index > 0 )
        {
            overlay = [[OMImageOverlaySearchSingle alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_pressed.png"]];
            overlay.usePOIIcon = NO;
        }
        else
        {
            overlay = [[OMImageOverlaySearchSingle alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_poi_pressed.png"]];
            overlay.usePOIIcon = YES;
        }
        // 알파벳 이미지 추가
        UIImageView *searchIndexImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"marker_%d.png", oms.searchResult.index]]];
        
        [searchIndexImageView setFrame:
         CGRectMake((int)11, (int)9, 20, searchIndexImageView.image.size.height)];
        
        NSLog(@"싱글 : %@", NSStringFromCGRect(searchIndexImageView.frame));
        
        [overlay.getOverlayView addSubview:searchIndexImageView];
        [searchIndexImageView release];

        
        [overlay setSelected:YES];
        [overlay setCoord:oms.searchResult.coordLocationPoint];
        [overlay setDelegate:self];
        [mc.kmap addOverlay:overlay];
        
        
        
        
                
        // 추가정보 입력
        [overlay.additionalInfo setObject:oms.searchResult.strLocationName forKey:@"Name"];
        [overlay.additionalInfo setObject:oms.searchResult.strLocationAddress forKey:@"Address"];
        [overlay.additionalInfo setObject:oms.searchResult.strID forKey:@"ID"];
        [overlay.additionalInfo setObject:oms.searchResult.strType forKey:@"Type"];
        [overlay.additionalInfo setObject:oms.searchResult.strTel forKey:@"Tel"];
        [overlay.additionalInfo setObject:[NSNumber numberWithInt:oms.searchResult.index] forKey:@"Index"];
        [overlay.additionalInfo setObject:[NSNumber numberWithFloat:oms.searchResult.coordLocationPoint.x] forKey:@"X"];
        [overlay.additionalInfo setObject:[NSNumber numberWithFloat:oms.searchResult.coordLocationPoint.y] forKey:@"Y"];
        
        // 마커옵션 자동으로 펼치기
        [self pinPOIMarkerOption:YES targetInfo:overlay.additionalInfo animated:YES];
        
        // 맵 중앙으로 이동
        [mc.kmap setCenterCoordinate:oms.searchResult.coordLocationPoint];
        
    }
    else
    {
        // 검색결과 단일POI 골라서 삭제하기
        [mc.kmap removeSpecialOverlaysKindOfClass:[OMImageOverlaySearchSingle class]];
        // 마커옵션 오버레이 제거
        [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
    }
}

- (void) pinSearchMultiPOIOverlay:(BOOL)isDisplay
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    //OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 선택된 MultiPOI 인덱스 초기화
    _selectedMultiPOIIndex = -100;
    
    if (isDisplay)
    {
        // 기존 모든 오버레이 제거하기, 단 교통옵션 오버레이는 존재시킨다.
        [mc.kmap removeAllOverlaysWithoutTraffic];
        
        // 중첩되는 POI 분류하기
        NSMutableArray *duplicatedPOIList = [[NSMutableArray alloc] init];
        for (NSDictionary *poiDic in _refinedMultiPOIList)
        {
            Coord poiCrd = CoordMake([[poiDic objectForKeyGC:@"X"] doubleValue], [[poiDic objectForKeyGC:@"Y"] doubleValue]);
            
            // 중복처리된 리스트에 중첩되는 POI 존재하는지 체크
            BOOL isDuplicate = NO;
            for (NSMutableDictionary *duplicatedPOI in duplicatedPOIList)
            {
                Coord preCrd = CoordMake([[duplicatedPOI objectForKeyGC:@"X"] doubleValue], [[duplicatedPOI objectForKeyGC:@"Y"] doubleValue]);
                
                // 두POI가 중첩되는 경우
                if ( [self isDuplicatePOI:poiCrd :preCrd] )
                {
                    isDuplicate = YES;
                    [[duplicatedPOI objectForKeyGC:@"POIs"] addObject:poiDic];
                    break;
                }
            }
            
            // 중첩된 POI 없을 경우 신규 등록
            if (isDuplicate == NO)
            {
                NSMutableDictionary *dupDic = [NSMutableDictionary dictionary];
                [dupDic setObject:[NSString stringWithFormat:@"%f", poiCrd.x] forKey:@"X"];
                [dupDic setObject:[NSString stringWithFormat:@"%f", poiCrd.y] forKey:@"Y"];
                [dupDic setObject:[NSMutableArray array] forKey:@"POIs"];
                [[dupDic objectForKeyGC:@"POIs"] addObject:poiDic];
                [duplicatedPOIList addObject:dupDic];
            }
        }
        
        // 중첩처리된 POI 렌더링 한다.
        for (NSDictionary *duplicatedPOI in duplicatedPOIList)
        {
            Coord crd = CoordMake([[duplicatedPOI objectForKeyGC:@"X"] doubleValue], [[duplicatedPOI objectForKeyGC:@"Y"] doubleValue]);
            int dupCount = [[duplicatedPOI objectForKeyGC:@"POIs"] count];
            
            // 해당 POI가 중첩된 상태가 아닌경우 알파벳 표시
            if (dupCount <= 1)
            {
                int index = [[[[duplicatedPOI objectForKeyGC:@"POIs"] objectAtIndexGC:0] objectForKeyGC:@"Index"] intValue];
                OMImageOverlaySearchMulti *imgovrPOI = [[OMImageOverlaySearchMulti alloc] initWithImage:[UIImage imageNamed:@"map_b_marker.png"]];
                [imgovrPOI setCoord:crd];
                [imgovrPOI setCenterOffset:CGPointMake( (int)(imgovrPOI.imageSize.width/2), (int)(imgovrPOI.imageSize.height) )];
                [imgovrPOI setDelegate:self];
                [imgovrPOI setDuplicated:NO];
                [imgovrPOI setSelected:NO];
                [imgovrPOI.additionalInfo setObject:[NSNumber numberWithInt:index] forKey:@"Index"];
                [mc.kmap addOverlay:imgovrPOI];
                // 알파벳 이미지 추가
                UIImageView *searchIndexImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"marker_%d.png", index+1]]];
                [searchIndexImageView setFrame:
                 CGRectMake((int)11, (int)9, (int)20, searchIndexImageView.image.size.height)];
                
                [imgovrPOI.getOverlayView addSubview:searchIndexImageView];
                [searchIndexImageView release];
                // 롱탭 추가정보 입력
                NSDictionary *currentInfoInPOIs = [[duplicatedPOI objectForKeyGC:@"POIs"] objectAtIndexGC:0];
                [imgovrPOI.additionalInfo setObject:[currentInfoInPOIs objectForKeyGC:@"Name"] forKey:@"Name"];
                [imgovrPOI.additionalInfo setObject:[currentInfoInPOIs objectForKeyGC:@"Address"] forKey:@"Address"];
                [imgovrPOI.additionalInfo setObject:[currentInfoInPOIs objectForKeyGC:@"ID"] forKey:@"ID"];
                [imgovrPOI.additionalInfo setObject:[currentInfoInPOIs objectForKeyGC:@"Type"] forKey:@"Type"];
                [imgovrPOI.additionalInfo setObject:[currentInfoInPOIs objectForKeyGC:@"Tel"] forKey:@"Tel"];
                [imgovrPOI.additionalInfo setObject:[currentInfoInPOIs objectForKeyGC:@"X"] forKey:@"X"];
                [imgovrPOI.additionalInfo setObject:[currentInfoInPOIs objectForKeyGC:@"Y"] forKey:@"Y"];
                // 오버레이 해제
                [imgovrPOI release];
                
            }
            // 2이상의 카운트를 가진경우 중첩 플러스마크 사용
            else
            {
                OMImageOverlaySearchMulti *imgovrPOI = [[OMImageOverlaySearchMulti alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_overlap.png"]];
                [imgovrPOI setCoord:crd];
                [imgovrPOI setCenterOffset:CGPointMake( (int)(imgovrPOI.imageSize.width/2), (int)(imgovrPOI.imageSize.height) )];
                [imgovrPOI setDelegate:self];
                [imgovrPOI setDuplicated:YES];
                [imgovrPOI setSelected:NO];
                [imgovrPOI.additionalInfo setObject:[NSNumber numberWithInt:-1] forKey:@"Index"];
                [imgovrPOI.additionalInfo setObject:[duplicatedPOI objectForKeyGC:@"POIs"] forKey:@"POIs"];
                [imgovrPOI.additionalInfo setObject:[duplicatedPOI objectForKeyGC:@"X"] forKey:@"X"];
                [imgovrPOI.additionalInfo setObject:[duplicatedPOI objectForKeyGC:@"Y"] forKey:@"Y"];
                [mc.kmap addOverlay:imgovrPOI];
                [imgovrPOI release];
            }
        }
        
        [duplicatedPOIList removeAllObjects];
        [duplicatedPOIList release];
        
    }
    else
    {
        // 검색결과 다중POI 골라서 삭제하기
        [mc.kmap removeSpecialOverlaysKindOfClass:[OMImageOverlaySearchMulti class]];
        // 마커옵션 오버레이 제거
        [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
    }
}

- (void) pinRecentPOIOverlay:(BOOL)isDisplay
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    if (isDisplay)
    {
        // 기존 모든 오버레이 제거하기, 단 교통옵션 오버레이는 존재시킨다.
        [mc.kmap removeAllOverlaysWithoutTraffic];
        
        // 오버레이 생성
        OMImageOverlayRecent *overlay = nil;
        // CCTV
        if ( [oms.searchResult.strType isEqualToString:@"CCTV"] )
        {
            overlay = [[OMImageOverlayRecent alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_cctv_pressed.png"]];
            overlay.specialNormalIconImage = @"map_b_marker_cctv.png";
            overlay.specialSelectedIconImage = @"map_b_marker_cctv_pressed.png";
        }
        // 버스
        else if ( [oms.searchResult.strType isEqualToString:@"TR_BUS"] )
        {
            overlay = [[OMImageOverlayRecent alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_busstop_pressed.png"]];
            overlay.specialNormalIconImage = @"map_b_marker_busstop.png";
            overlay.specialSelectedIconImage = @"map_b_marker_busstop_pressed.png";
        }
        // 지하철
        else if ( [oms.searchResult.strType isEqualToString:@"TR"] )
        {
            overlay = [[OMImageOverlayRecent alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_subway_pressed.png"]];
            overlay.specialNormalIconImage = @"map_b_marker_subway.png";
            overlay.specialSelectedIconImage = @"map_b_marker_subway_pressed.png";
        }
        else
        {
            overlay = [[OMImageOverlayRecent alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_poi_pressed.png"]];
        }
        [overlay setSelected:YES];
        [overlay setCoord:oms.searchResult.coordLocationPoint];
        [overlay setDelegate:self];
        [mc.kmap addOverlay:overlay];
        
        // 롱탭 추가정보 입력
        [overlay.additionalInfo setObject:oms.searchResult.strLocationName forKey:@"Name"];
        [overlay.additionalInfo setObject:oms.searchResult.strLocationAddress forKey:@"Address"];
        [overlay.additionalInfo setObject:oms.searchResult.strID forKey:@"ID"];
        [overlay.additionalInfo setObject:oms.searchResult.strType forKey:@"Type"];
        [overlay.additionalInfo setObject:oms.searchResult.strTel forKey:@"Tel"];
        [overlay.additionalInfo setObject:[NSNumber numberWithFloat:oms.searchResult.coordLocationPoint.x] forKey:@"X"];
        [overlay.additionalInfo setObject:[NSNumber numberWithFloat:oms.searchResult.coordLocationPoint.y] forKey:@"Y"];
        
        // 새주소 추가
        [overlay.additionalInfo setObject:oms.searchResult.strLocationSubAddress forKey:@"SubAddress"];
        [overlay.additionalInfo setObject:oms.searchResult.strLocationOldOrNew forKey:@"OldOrNew"];
        
        // 마커옵션 자동으로 펼치기
        [self pinPOIMarkerOption:YES targetInfo:overlay.additionalInfo animated:YES];
        
        // 맵 중앙으로 이동
        [mc.kmap setCenterCoordinate:oms.searchResult.coordLocationPoint];
        
        [overlay release];
    }
    else
    {
        // 최근검색 POI 골라서 삭제하기
        [mc.kmap removeSpecialOverlaysKindOfClass:[OMImageOverlayRecent class]];
        // 마커옵션 오버레이 제거
        [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
    }
}
- (void) pinFavoritePOIOverlay:(BOOL)isDisplay
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    if (isDisplay)
    {
        // 기존 모든 오버레이 제거하기, 단 교통옵션 오버레이는 존재시킨다.
        [mc.kmap removeAllOverlaysWithoutTraffic];
        
        // 오버레이 생성
        OMImageOverlayFavorite *overlay = nil;
        // CCTV
        if ( [oms.searchResult.strType isEqualToString:@"CCTV"] )
        {
            overlay = [[OMImageOverlayFavorite alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_cctv_pressed.png"]];
            overlay.specialNormalIconImage = @"map_b_marker_cctv.png";
            overlay.specialSelectedIconImage = @"map_b_marker_cctv_pressed.png";
        }
        // 버스
        else if ( [oms.searchResult.strType isEqualToString:@"TR_BUS"] )
        {
            overlay = [[OMImageOverlayFavorite alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_busstop_pressed.png"]];
            overlay.specialNormalIconImage = @"map_b_marker_busstop.png";
            overlay.specialSelectedIconImage = @"map_b_marker_busstop_pressed.png";
        }
        // 지하철
        else if ( [oms.searchResult.strType isEqualToString:@"TR"] )
        {
            overlay = [[OMImageOverlayFavorite alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_subway_pressed.png"]];
            overlay.specialNormalIconImage = @"map_b_marker_subway.png";
            overlay.specialSelectedIconImage = @"map_b_marker_subway_pressed.png";
        }
        else
        {
            overlay = [[OMImageOverlayFavorite alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_poi_pressed.png"]];
        }
        [overlay setSelected:YES];
        [overlay setCoord:oms.searchResult.coordLocationPoint];
        [overlay setDelegate:self];
        [mc.kmap addOverlay:overlay];
        
        // 롱탭 추가정보 입력
        [overlay.additionalInfo setObject:oms.searchResult.strLocationName forKey:@"Name"];
        [overlay.additionalInfo setObject:oms.searchResult.strLocationAddress forKey:@"Address"];
        [overlay.additionalInfo setObject:oms.searchResult.strID forKey:@"ID"];
        [overlay.additionalInfo setObject:oms.searchResult.strType forKey:@"Type"];
        [overlay.additionalInfo setObject:oms.searchResult.strTel forKey:@"Tel"];
        [overlay.additionalInfo setObject:[NSNumber numberWithFloat:oms.searchResult.coordLocationPoint.x] forKey:@"X"];
        [overlay.additionalInfo setObject:[NSNumber numberWithFloat:oms.searchResult.coordLocationPoint.y] forKey:@"Y"];
        
        // 새주소추가
        [overlay.additionalInfo setObject:oms.searchResult.strLocationSubAddress forKey:@"SubAddress"];
        [overlay.additionalInfo setObject:oms.searchResult.strLocationOldOrNew forKey:@"OldOrNew"];
        
        // 마커옵션 자동으로 펼치기
        [self pinPOIMarkerOption:YES targetInfo:overlay.additionalInfo animated:YES];
        
        // 맵 중앙으로 이동
        [mc.kmap setCenterCoordinate:oms.searchResult.coordLocationPoint];
        
    }
    else
    {
        // 즐겨찾기 POI 골라서 삭제하기
        [mc.kmap removeSpecialOverlaysKindOfClass:[OMImageOverlayFavorite class]];
        // 마커옵션 오버레이 제거
        [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
    }
}

- (void) pinTrafficOptionCCTVPOIOverlay:(ServerRequester *)request
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    // MIK.geun :: 20121009 // 교통옵션오버레이는 무조건제거하지 않고, 맵이벤트 발생시 줌인/아웃여부에 따라 처리하도록 수정
    //[mc.kmap removeAllTrafficOverlay];
    
    _trafficOptionLastRenderCoordinate = mc.kmap.centerCoordinate;
    
    if ( [request userObject] )
    {
        NSArray *cctvList = (NSArray*)[request userObject];
        [NSThread detachNewThreadSelector:@selector(doWork_PinTrafficOptionCCTVPOIOverlay:) toTarget:self withObject:cctvList];
    }
    
}
- (void) doWork_PinTrafficOptionCCTVPOIOverlay :(id)object
{
    @autoreleasepool
    {
        @try
        {
            
            
            MapContainer *mc = [MapContainer sharedMapContainer_Main];
            NSArray *cctvList = (NSArray*)object;
            
            // 카운트가 존재하면 리스트 정렬 시작
            NSMutableArray *refinedCCTVList = [[NSMutableArray alloc] init];
            
            // 기존 CCTV 오버레이와 신규 CCTV 검색결과 비교후 유지/삭제 대상 정제한다.
            NSMutableArray *previousRenderedCCTVOverlayList = [[NSMutableArray alloc] init];
            NSMutableArray *deleteTargetRenderedCCTVOverlayList = [[NSMutableArray alloc] init];
            for (Overlay *overlay in mc.kmap.getOverlays)
            {
                if ( [overlay isKindOfClass:[OMImageOverlayTrafficCCTV  class]] )
                {
                    // 오버레이가 현재 좌표기준으로 일정거리내에 있는지 체크 ==> 유지/삭제 결정
                    // 검색시에는 1/2값을 사용하지만, 삭제할때는 1/1.8 값을 사용하기로함.. 외곽라인에 대해 좀더 중첩체크를 보정하기위해서..
                    if ( CoordDistance(overlay.coord, _trafficOptionLastRenderCoordinate) > mc.getCurrentMapZoomLevelMeterWithScreen/2.5 )
                        [deleteTargetRenderedCCTVOverlayList addObject:overlay];
                    else
                        [previousRenderedCCTVOverlayList addObject:overlay];
                }
            }
            
            // 삭제대상 오버레이 제거
            for (OMImageOverlayTrafficCCTV *overlay in deleteTargetRenderedCCTVOverlayList)
            {
                [mc.kmap removeOverlay:overlay];
            }
            // 삭제대상 오버레이 목록 클리어
            [deleteTargetRenderedCCTVOverlayList removeAllObjects];
            [deleteTargetRenderedCCTVOverlayList release];
            
            // CCTV 목록
            for (NSDictionary *cctv in cctvList)
            {
                
                Coord currentWgsCoordinate = CoordMake( [numberValueOfDiction(cctv, @"x") doubleValue], [numberValueOfDiction(cctv, @"y") doubleValue]);
                Coord currentCoordinate = [mc.kmap convertCoordinate:currentWgsCoordinate inCoordType:KCoordType_WGS84 outCoordType:KCoordType_UTMK];
                
                NSString *currentID = stringValueOfDictionary(cctv, @"id");
                NSString *currentType = @"CCTV";
                NSString *currentName = stringValueOfDictionary(cctv, @"name");
                
                NSMutableDictionary *currentTotalInfo = [[NSMutableDictionary alloc] init];
                [currentTotalInfo setObject:currentID forKey:@"ID"];
                [currentTotalInfo setObject:currentType forKey:@"Type"];
                [currentTotalInfo setObject:currentName forKey:@"Name"];
                [currentTotalInfo setObject:[NSNumber numberWithDouble:currentCoordinate.x] forKey:@"X"];
                [currentTotalInfo setObject:[NSNumber numberWithDouble:currentCoordinate.y] forKey:@"Y"];
                
                // 기존 렌더링된 오버레이 해당 정보가 포함되어 있는지 체크
                BOOL previousDuplicated = NO;
                for (OMImageOverlayTrafficCCTV *overlay in previousRenderedCCTVOverlayList)
                {
                    // 기존 오버레이에 포함된 CCTV 정보와 현재 CCTV 정보가 중복되는지 확인한다. (싱글/중첩별로 구조가 다르다)
                    if ( overlay.duplicated )
                    {
                        
                        for (NSDictionary *info in [overlay.additionalInfo objectForKeyGC:@"POIs"] )
                        {
                            if ( [stringValueOfDictionary(info, @"Type") isEqualToString:currentType]
                                && [stringValueOfDictionary(info, @"ID") isEqualToString:currentID]  )
                            {
                                previousDuplicated = YES;
                                break;
                            }
                        }
                    }
                    else
                    {
                        if ( [stringValueOfDictionary(overlay.additionalInfo, @"Type") isEqualToString:currentType]
                            && [stringValueOfDictionary(overlay.additionalInfo, @"ID") isEqualToString:currentID]  )
                        {
                            previousDuplicated = YES;
                        }
                    }
                    // 동일한 CCTV 확인되면 현재 오버레이 체크 빠져나감.
                    if ( previousDuplicated ) break;
                }
                // 기존 오버레이와 중복된 경우 해당 CCTV는 건너뛰어야 한다.
                if ( previousDuplicated ) continue;
                
                
                // 기존 데이터와 중첩되는지 체크
                BOOL duplicated = NO;
                for (NSMutableDictionary *preCCTV in refinedCCTVList)
                {
                    Coord preCoordinate = CoordMake( [numberValueOfDiction(preCCTV, @"X") doubleValue] , [numberValueOfDiction(preCCTV, @"Y") doubleValue]);
                    
                    // 위치 중첩되는 경우 중첩데이터로 처리
                    if ( [self isDuplicatePOI:preCoordinate :currentCoordinate :YES] )
                    {
                        duplicated = YES;
                        [preCCTV setObject:[NSNumber numberWithBool:duplicated] forKey:@"Duplicated"];
                        [[preCCTV objectForKeyGC:@"POIs"] addObject:currentTotalInfo];
                        break;
                    }
                }
                // 기존 데이터와 위치 중첩되지 않을 경우 신규 POI 저장
                if ( duplicated == NO )
                {
                    NSMutableDictionary *newCCTV = [[NSMutableDictionary alloc] init];
                    
                    [newCCTV setObject:[NSNumber numberWithDouble:currentCoordinate.x] forKey:@"X"];
                    [newCCTV setObject:[NSNumber numberWithDouble:currentCoordinate.y] forKey:@"Y"];
                    [newCCTV setObject:[NSMutableArray array] forKey:@"POIs"];
                    [[newCCTV objectForKeyGC:@"POIs"] addObject:currentTotalInfo];
                    [newCCTV setObject:[NSNumber numberWithBool:NO] forKey:@"Duplicated"];
                    [refinedCCTVList addObject:newCCTV];
                    [newCCTV release];
                }
                
                // 제거
                [currentTotalInfo release];
                
            }
            
            // 렌더링하자~~
            for (NSDictionary *poi in refinedCCTVList)
            {
                BOOL duplicated = [[poi objectForKeyGC:@"Duplicated"] boolValue];
                Coord coordinate = CoordMake([numberValueOfDiction(poi, @"X") doubleValue] , [numberValueOfDiction(poi, @"Y") doubleValue]);
                OMImageOverlayTrafficCCTV *overlay = nil;
                if (duplicated)
                {
                    overlay = [[OMImageOverlayTrafficCCTV alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_poi_cctv.png"]];
                    for (NSString *key in [poi allKeys])
                    {
                        [overlay.additionalInfo setObject:[poi objectForKeyGC:key] forKey:key];
                    }
                }
                else
                {
                    overlay =  [[OMImageOverlayTrafficCCTV alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_cctv.png"]];
                    NSDictionary *single = [[poi objectForKeyGC:@"POIs"] objectAtIndexGC:0];
                    for (NSString *key in [single allKeys] )
                    {
                        [overlay.additionalInfo setObject:[single objectForKeyGC:key] forKey:key];
                    }
                }
                [overlay setDuplicated:duplicated];
                [overlay setSelected:NO];
                [overlay setCoord:coordinate];
                [overlay setDelegate:self];
                [mc.kmap addOverlay:overlay];
                
                [overlay release];
            }
            
            [refinedCCTVList removeAllObjects];
            [refinedCCTVList release];
            
        }
        @catch (NSException *exception)
        {
            
            NSMutableDictionary *toast = [[NSMutableDictionary alloc] init];
#ifdef DEBUG
            [toast setObject:[NSString stringWithString:exception.reason] forKey:@"Message"];
#else
            [toast setObject:@"CCTV POI 를 그리는데 실패햇습니다." forKey:@"Message"];
#endif
            [toast setObject:self.view forKey:@"SuperView"];
            [toast setObject:[NSNumber numberWithFloat:self.vwCurrentAddressGroup.frame.origin.y-10] forKey:@"MaxBottomPoint"];
            [toast setObject:[NSNumber numberWithBool:YES] forKey:@"AutoClose"];
            [self performSelectorOnMainThread:@selector(doWork_ToastMessage:) withObject:toast waitUntilDone:YES];
            [toast release];
            
        }
        @finally
        {
        }
    }
}

- (void) pinTrafficOptionBusStationPOIOverlay:(ServerRequester *)request
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    // MIK.geun :: 20121009 // 무조건 교통오버레이 제거하지 않도록 수정, 삭제작업은 교통검색 이전단계에서 상황별로 처리한다.
    //[mc.kmap removeAllTrafficOverlay];
    
    _trafficOptionLastRenderCoordinate = mc.kmap.centerCoordinate;
    
    if ( [request userObject] )
    {
        NSDictionary *busStationListContainer = (NSDictionary*)[request userObject];
        [NSThread detachNewThreadSelector:@selector(doWork_PinTrafficOptionBusStationPOIOverlay:) toTarget:self withObject:busStationListContainer];
    }
    
}
- (void) doWork_PinTrafficOptionBusStationPOIOverlay :(id)object
{
    @autoreleasepool
    {
        @try
        {
            MapContainer *mc = [MapContainer sharedMapContainer_Main];
            
            NSDictionary *busStationListContainer = (NSDictionary*)object;
            
            // 카운트가 존재하면 리스트 정렬 시작
            if ( [numberValueOfDiction(busStationListContainer, @"total_count") intValue] > 0 )
            {
                NSMutableArray *refinedBusStationList = [[NSMutableArray alloc] init];
                
                // 기존 버스정류장 오버레이와 신규 버스정류장 검색결과 비교후 유지/삭제 대상 정제한다.
                NSMutableArray *previousRenderedBusStationOverlayList = [[NSMutableArray alloc] init];
                NSMutableArray *deleteTargetRenderedBusStationOverlayList = [[NSMutableArray alloc] init];
                
                for (Overlay *overlay in mc.kmap.getOverlays)
                {
                    if ( [overlay isKindOfClass:[OMImageOverlayTrafficBusStation  class]] )
                    {
                        // 오버레이가 현재 좌표기준으로 일정거리내에 있는지 체크 ==> 유지/삭제 결정
                        // 검색시에는 1/2값을 사용하지만, 삭제할때는 1/1.8 값을 사용하기로함.. 외곽라인에 대해 좀더 중첩체크를 보정하기위해서..
                        if ( CoordDistance(overlay.coord, _trafficOptionLastRenderCoordinate) > mc.getCurrentMapZoomLevelMeterWithScreen/2.5 )
                            [deleteTargetRenderedBusStationOverlayList addObject:overlay];
                        else
                            [previousRenderedBusStationOverlayList addObject:overlay];
                    }
                }
                
                // 삭제대상 오버레이 제거
                for (OMImageOverlayTrafficBusStation *overlay in deleteTargetRenderedBusStationOverlayList)
                {
                    [mc.kmap removeOverlay:overlay];
                }
                // 삭제대상 오버레이 목록 클리어
                [deleteTargetRenderedBusStationOverlayList removeAllObjects];
                [deleteTargetRenderedBusStationOverlayList release];
                
                // 신규 버스정류장 검색결과 정제하기..
                for (NSDictionary *poi in [busStationListContainer objectForKeyGC:@"poi"])
                {
                    Coord currentCoordinate = CoordMake( [numberValueOfDiction(poi, @"x") doubleValue], [numberValueOfDiction(poi, @"y") doubleValue]);
                    //NSString *currentID = stringValueOfDictionary(poi, @"id");
                    NSString *currentStationID = stringValueOfDictionary(poi, @"st_id");
                    NSString *currentType = @"TR_BUS";
                    NSString *currentName = stringValueOfDictionary(poi, @"name");
                    
                    NSMutableDictionary *currentTotalInfo = [[NSMutableDictionary alloc] init];
                    //[currentTotalInfo setObject:currentID forKey:@"ID"];
                    // 버스정류장인걸 알고 있으니 type은 TR_BUS 고정, ID값도 STID 를 바로 사용.
                    [currentTotalInfo setObject:currentStationID forKey:@"ID"];
                    [currentTotalInfo setObject:currentStationID forKey:@"STID"];
                    [currentTotalInfo setObject:currentType forKey:@"Type"];
                    [currentTotalInfo setObject:currentName forKey:@"Name"];
                    [currentTotalInfo setObject:[NSNumber numberWithDouble:currentCoordinate.x] forKey:@"X"];
                    [currentTotalInfo setObject:[NSNumber numberWithDouble:currentCoordinate.y] forKey:@"Y"];
                    
                    // 기존 렌더링된 오버레이 해당 정보가 포함되어 있는지 체크
                    BOOL previousDuplicated = NO;
                    for (OMImageOverlayTrafficBusStation *overlay in previousRenderedBusStationOverlayList)
                    {
                        // 기존 오버레이에 포함된 버스정류장 정보와 현재 버스정류장 정보가 중복되는지 확인한다. (싱글/중첩별로 구조가 다르다)
                        if ( overlay.duplicated )
                        {
                            
                            for (NSDictionary *info in [overlay.additionalInfo objectForKeyGC:@"POIs"] )
                            {
                                if ( [stringValueOfDictionary(info, @"Type") isEqualToString:currentType]
                                    && [stringValueOfDictionary(info, @"ID") isEqualToString:currentStationID]  )
                                {
                                    previousDuplicated = YES;
                                    break;
                                }
                            }
                        }
                        else
                        {
                            if ( [stringValueOfDictionary(overlay.additionalInfo, @"Type") isEqualToString:currentType]
                                && [stringValueOfDictionary(overlay.additionalInfo, @"ID") isEqualToString:currentStationID]  )
                            {
                                previousDuplicated = YES;
                            }
                        }
                        // 동일한 버스정류장 확인되면 현재 오버레이 체크 빠져나감.
                        if ( previousDuplicated ) break;
                    }
                    // 기존 오버레이와 중복된 경우 해당 버스정류장은 건너뛰어야 한다.
                    if ( previousDuplicated ) continue;
                    
                    // 기존 데이터와 중첩되는지 체크
                    BOOL duplicated = NO;
                    for (NSMutableDictionary *preBusStation in refinedBusStationList)
                    {
                        Coord preCoordinate = CoordMake( [numberValueOfDiction(preBusStation, @"X") doubleValue] , [numberValueOfDiction(preBusStation, @"Y") doubleValue]);
                        
                        // 위치 중첩되는 경우 중첩데이터로 처리
                        if ( [self isDuplicatePOI:preCoordinate :currentCoordinate] )
                        {
                            duplicated = YES;
                            [preBusStation setObject:[NSNumber numberWithBool:duplicated] forKey:@"Duplicated"];
                            [[preBusStation objectForKeyGC:@"POIs"] addObject:currentTotalInfo];
                            break;
                        }
                    }
                    // 기존 데이터와 위치 중첩되지 않을 경우 신규 POI 저장
                    if ( duplicated == NO )
                    {
                        NSMutableDictionary *busStationInfo = [[NSMutableDictionary alloc] init];
                        
                        [busStationInfo setObject:[NSNumber numberWithDouble:currentCoordinate.x] forKey:@"X"];
                        [busStationInfo setObject:[NSNumber numberWithDouble:currentCoordinate.y] forKey:@"Y"];
                        [busStationInfo setObject:[NSMutableArray array] forKey:@"POIs"];
                        [[busStationInfo objectForKeyGC:@"POIs"] addObject:currentTotalInfo];
                        [busStationInfo setObject:[NSNumber numberWithBool:NO] forKey:@"Duplicated"];
                        [refinedBusStationList addObject:busStationInfo];
                        [busStationInfo release];
                    }
                    
                    // 제거
                    [currentTotalInfo release];
                    
                }
                
                [previousRenderedBusStationOverlayList release];
                
                
                
                for (NSDictionary *poi in refinedBusStationList)
                {
                    BOOL duplicated = [[poi objectForKeyGC:@"Duplicated"] boolValue];
                    Coord coordinate = CoordMake([numberValueOfDiction(poi, @"X") doubleValue] , [numberValueOfDiction(poi, @"Y") doubleValue]);
                    OMImageOverlayTrafficBusStation *overlay = nil;
                    if (duplicated)
                    {
                        overlay = [[OMImageOverlayTrafficBusStation alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_poi_busstop.png"]];
                        for (NSString *key in [poi allKeys])
                        {
                            [overlay.additionalInfo setObject:[poi objectForKeyGC:key] forKey:key];
                        }
                    }
                    else
                    {
                        overlay =  [[OMImageOverlayTrafficBusStation alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_busstop.png"]];
                        NSDictionary *single = [[poi objectForKeyGC:@"POIs"] objectAtIndexGC:0];
                        for (NSString *key in [single allKeys] )
                        {
                            [overlay.additionalInfo setObject:[single objectForKeyGC:key] forKey:key];
                        }
                    }
                    [overlay setDuplicated:duplicated];
                    [overlay setSelected:NO];
                    [overlay setCoord:coordinate];
                    [overlay setDelegate:self];
                    [mc.kmap addOverlay:overlay];
                    
                    [overlay release];
                }
                
                // 렌더링 끝난 리스트 제거
                [refinedBusStationList removeAllObjects];
                [refinedBusStationList release];
            }
        }
        @catch (NSException *exception)
        {
#ifdef _TB_SERVER
            NSMutableDictionary *toast = [[NSMutableDictionary alloc] init];
            [toast setObject:@"버스정류장 POI 를 그리는데 실패했습니다." forKey:@"Message"];
            [toast setObject:self.view forKey:@"SuperView"];
            [toast setObject:[NSNumber numberWithFloat:self.vwCurrentAddressGroup.frame.origin.y-10] forKey:@"MaxBottomPoint"];
            [toast setObject:[NSNumber numberWithBool:YES] forKey:@"AutoClose"];
            [self performSelectorOnMainThread:@selector(doWork_ToastMessage:) withObject:toast waitUntilDone:YES];
            [toast release];
#endif
        }
        @finally
        {
        }
    }
}

- (void) pinTrafficOptionSubwayPOIOverlay:(ServerRequester *)request
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    //  MIK.geun :: 20121009 // 교통옵션 오버레이 삭제하지 않는다. 이벤트 발생시점에서 처리하도록 수정됐음.
    //[mc.kmap removeAllTrafficOverlay];
    
    _trafficOptionLastRenderCoordinate = mc.kmap.centerCoordinate;
    
    if ( [request userObject] )
    {
        NSDictionary *subwayStationListContainer = (NSDictionary*)[request userObject];
        [NSThread detachNewThreadSelector:@selector(doWork_PinTrafficOptionSubwayPOIOverlayCheck:) toTarget:self withObject:subwayStationListContainer
         ];
    }
    
}
- (void) doWork_PinTrafficOptionSubwayPOIOverlayCheck :(id)object
{
    @autoreleasepool
    {
        @try
        {
            MapContainer *mc = [MapContainer sharedMapContainer_Main];
            
            NSDictionary *subwayStationListContainer = (NSDictionary*)object;
            
            // 카운트가 존재하면 리스트 정렬 시작
            if ( [numberValueOfDiction(subwayStationListContainer, @"total_count") intValue] > 0 )
            {
                NSMutableArray *refinedSubwayStationList = [[NSMutableArray alloc] init];
                
                // 기존 지하철역 오버레이와 신규 지하철역 검색결과 비교후 유지/삭제 대상 정제한다.
                NSMutableArray *previousRenderedSubwayStationOverlayList = [[NSMutableArray alloc] init];
                NSMutableArray *deleteTargetRenderedSubwayStationOverlayList = [[NSMutableArray alloc] init];
                
                for (Overlay *overlay in mc.kmap.getOverlays)
                {
                    if ( [overlay isKindOfClass:[OMImageOverlayTrafficSubwayStation  class]] )
                    {
                        // 오버레이가 현재 좌표기준으로 일정거리내에 있는지 체크 ==> 유지/삭제 결정
                        // 검색시에는 1/2값을 사용하지만, 삭제할때는 1/1.8 값을 사용하기로함.. 외곽라인에 대해 좀더 중첩체크를 보정하기위해서..
                        if ( CoordDistance(overlay.coord, _trafficOptionLastRenderCoordinate) > mc.getCurrentMapZoomLevelMeterWithScreen/2.5 )
                            [deleteTargetRenderedSubwayStationOverlayList addObject:overlay];
                        else
                            [previousRenderedSubwayStationOverlayList addObject:overlay];
                    }
                }
                
                // 삭제대상 오버레이 제거
                for (OMImageOverlayTrafficSubwayStation *overlay in deleteTargetRenderedSubwayStationOverlayList)
                {
                    [mc.kmap removeOverlay:overlay];
                }
                // 삭제대상 오버레이 목록 클리어
                [deleteTargetRenderedSubwayStationOverlayList removeAllObjects];
                [deleteTargetRenderedSubwayStationOverlayList release];
                
                for (NSDictionary *poi in [subwayStationListContainer objectForKeyGC:@"poi"])
                {
                    Coord currentCoordinate = CoordMake( [numberValueOfDiction(poi, @"x") doubleValue], [numberValueOfDiction(poi, @"y") doubleValue]);
                    //NSString *currentID = stringValueOfDictionary(poi, @"id");
                    NSString *currentStationID = stringValueOfDictionary(poi, @"st_id");
                    //NSString *currentType = @"TR_RAW";
                    NSString *currentType = @"TR";
                    NSString *currentName = stringValueOfDictionary(poi, @"name");
                    
                    NSMutableDictionary *currentTotalInfo = [[NSMutableDictionary alloc] init];
                    //[currentTotalInfo setObject:currentID forKey:@"ID"];
                    // 지하철역인거 알고 있으니 type 은 바로 TR 사용, ID값도 바로 STID 사용
                    [currentTotalInfo setObject:currentStationID forKey:@"ID"];
                    [currentTotalInfo setObject:currentStationID forKey:@"STID"];
                    [currentTotalInfo setObject:currentType forKey:@"Type"];
                    [currentTotalInfo setObject:currentName forKey:@"Name"];
                    [currentTotalInfo setObject:[NSNumber numberWithDouble:currentCoordinate.x] forKey:@"X"];
                    [currentTotalInfo setObject:[NSNumber numberWithDouble:currentCoordinate.y] forKey:@"Y"];
                    
                    // 기존 렌더링된 오버레이 해당 정보가 포함되어 있는지 체크
                    BOOL previousDuplicated = NO;
                    for (OMImageOverlayTrafficSubwayStation *overlay in previousRenderedSubwayStationOverlayList)
                    {
                        // 기존 오버레이에 포함된 지하철역 정보와 현재 지하철역 정보가 중복되는지 확인한다. (싱글/중첩별로 구조가 다르다)
                        if ( overlay.duplicated )
                        {
                            
                            for (NSDictionary *info in [overlay.additionalInfo objectForKeyGC:@"POIs"] )
                            {
                                if ( [stringValueOfDictionary(info, @"Type") isEqualToString:currentType]
                                    && [stringValueOfDictionary(info, @"ID") isEqualToString:currentStationID]  )
                                {
                                    previousDuplicated = YES;
                                    break;
                                }
                            }
                        }
                        else
                        {
                            if ( [stringValueOfDictionary(overlay.additionalInfo, @"Type") isEqualToString:currentType]
                                && [stringValueOfDictionary(overlay.additionalInfo, @"ID") isEqualToString:currentStationID]  )
                            {
                                previousDuplicated = YES;
                            }
                        }
                        // 동일한 지하철역 확인되면 현재 오버레이 체크 빠져나감.
                        if ( previousDuplicated ) break;
                    }
                    // 기존 오버레이와 중복된 경우 지하철역 테마는 건너뛰어야 한다.
                    if ( previousDuplicated ) continue;
                    
                    // 기존 데이터와 중첩되는지 체크
                    BOOL duplicated = NO;
                    for (NSMutableDictionary *preSubwayStation in refinedSubwayStationList)
                    {
                        Coord preCoordinate = CoordMake( [numberValueOfDiction(preSubwayStation, @"X") doubleValue] , [numberValueOfDiction(preSubwayStation, @"Y") doubleValue]);
                        
                        // 위치 중첩되는 경우 중첩데이터로 처리
                        if ( [self isDuplicatePOI:preCoordinate :currentCoordinate] )
                        {
                            duplicated = YES;
                            [preSubwayStation setObject:[NSNumber numberWithBool:duplicated] forKey:@"Duplicated"];
                            [[preSubwayStation objectForKeyGC:@"POIs"] addObject:currentTotalInfo];
                            break;
                        }
                    }
                    // 기존 데이터와 위치 중첩되지 않을 경우 신규 POI 저장
                    if ( duplicated == NO )
                    {
                        NSMutableDictionary *subwayStationInfo = [[NSMutableDictionary alloc] init];
                        
                        [subwayStationInfo setObject:[NSNumber numberWithDouble:currentCoordinate.x] forKey:@"X"];
                        [subwayStationInfo setObject:[NSNumber numberWithDouble:currentCoordinate.y] forKey:@"Y"];
                        [subwayStationInfo setObject:[NSMutableArray array] forKey:@"POIs"];
                        [[subwayStationInfo objectForKeyGC:@"POIs"] addObject:currentTotalInfo];
                        [subwayStationInfo setObject:[NSNumber numberWithBool:NO] forKey:@"Duplicated"];
                        [refinedSubwayStationList addObject:subwayStationInfo];
                        [subwayStationInfo release];
                    }
                    
                    // 제거
                    [currentTotalInfo release];
                    
                }
                
                // 렌더링하자~~
                for (NSDictionary *poi in refinedSubwayStationList)
                {
                    BOOL duplicated = [[poi objectForKeyGC:@"Duplicated"] boolValue];
                    Coord coordinate = CoordMake([numberValueOfDiction(poi, @"X") doubleValue] , [numberValueOfDiction(poi, @"Y") doubleValue]);
                    OMImageOverlayTrafficSubwayStation *overlay = nil;
                    if (duplicated)
                    {
                        overlay = [[OMImageOverlayTrafficSubwayStation alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_poi_subway.png"]];
                        for (NSString *key in [poi allKeys])
                        {
                            [overlay.additionalInfo setObject:[poi objectForKeyGC:key] forKey:key];
                        }
                    }
                    else
                    {
                        overlay =  [[OMImageOverlayTrafficSubwayStation alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_subway.png"]];
                        NSDictionary *single = [[poi objectForKeyGC:@"POIs"] objectAtIndexGC:0];
                        for (NSString *key in [single allKeys] )
                        {
                            [overlay.additionalInfo setObject:[single objectForKeyGC:key] forKey:key];
                        }
                    }
                    [overlay setDuplicated:duplicated];
                    [overlay setSelected:NO];
                    [overlay setCoord:coordinate];
                    [overlay setDelegate:self];
                    [mc.kmap addOverlay:overlay];
                    
                    
                    [overlay release];
                }
                
                // 렌더링 끝난 리스트 제거
                [refinedSubwayStationList removeAllObjects];
                [refinedSubwayStationList release];
            }
            
        }
        @catch (NSException *exception)
        {
#ifdef _TB_SERVER
            NSMutableDictionary *toast = [[NSMutableDictionary alloc] init];
            [toast setObject:@"지하철역 POI 를 그리는데 실패했습니다." forKey:@"Message"];
            [toast setObject:self.view forKey:@"SuperView"];
            [toast setObject:[NSNumber numberWithFloat:self.vwCurrentAddressGroup.frame.origin.y-10] forKey:@"MaxBottomPoint"];
            [toast setObject:[NSNumber numberWithBool:YES] forKey:@"AutoClose"];
            [self performSelectorOnMainThread:@selector(doWork_ToastMessage:) withObject:toast waitUntilDone:YES];
            [toast release];
#endif
        }
        @finally
        {
        }
    }
}


- (void) pinThemePOIOverlay:(BOOL)isDisplay
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    //OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    if (isDisplay)
    {
        // MIK.geun :: 20121009 // 기존 오버레이들을 제거하지 않는다.
        /*
         // 기존 모든 오버레이 제거하기, 단 교통옵션 오버레이는 존재시킨다.
         [mc.kmap removeAllOverlaysWithoutTraffic];
         */
        
        // 마지막으로 체크된 테마 렌더링 좌표 설정
        _themeLastRenderingCoordinate = [MapContainer sharedMapContainer_Main].kmap.centerCoordinate;
        
        [NSThread detachNewThreadSelector:@selector(doWork_PinThemePOIOverlayCheck:) toTarget:self withObject:nil];
        
    }
    else
    {
        // 검색결과 테마POI 골라서 삭제하기
        [mc.kmap removeSpecialOverlaysKindOfClass:[OMImageOverlayTheme class]];
        // 마커옵션 오버레이 제거
        [self pinPOIMarkerOption:NO targetInfo:nil animated:YES];
    }
    
}
- (void) doWork_PinThemePOIOverlayCheck :(id)object
{
    @autoreleasepool
    {
        @try
        {
            MapContainer *mc = [MapContainer sharedMapContainer_Main];
            OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
            
            // 지도상에 존재하는 테마 오버레이를 걸러낸다.
            NSMutableArray *previousRenderedThemeOverlayList = [[NSMutableArray alloc] init];
            NSMutableArray *deleteTargetPreviousRenderedThemeOverlayList = [[NSMutableArray alloc] init];
            
            for (Overlay *overlay in mc.kmap.getOverlays)
            {
                if ( [overlay isKindOfClass:[OMImageOverlayTheme class]] )
                {
                    
                    // 기존 테마오버레이중 현재좌표 기준으로 일정거리 벗어난 경우 제거하도록 한다. (테마 리서치하는 기준거리와 동일하게 가져감)
                    if ( CoordDistance(overlay.coord, _themeLastRenderingCoordinate) > mc.getCurrentMapZoomLevelMeterWithScreen/2.5 )
                        [deleteTargetPreviousRenderedThemeOverlayList addObject:overlay];
                    // 거리내에 존재하는경우 유지대상으로 ..
                    else
                        [previousRenderedThemeOverlayList addObject:overlay];
                }
            }
            
            // 일정거리 벗어난 제거대상 먼저 제거하도록 하자.
            for (OMImageOverlayTheme *overlay in deleteTargetPreviousRenderedThemeOverlayList)
            {
                [mc.kmap removeOverlay:overlay];
            }
            [deleteTargetPreviousRenderedThemeOverlayList removeAllObjects];
            [deleteTargetPreviousRenderedThemeOverlayList release];
            
            
            // 검색된 테마 중복체크하기
            // MIK.geun :: 20121009 // 기존 지도에 렌더링된 오버레와의 중복체크도 추가함.
            NSMutableArray *refinedThemeList = [[NSMutableArray alloc] init];
            NSMutableArray *themeSearchResultList = oms.themeSearchResultList.copy;
            for (NSDictionary *theme in themeSearchResultList)
            {
                
                Coord currentCoordinate = CoordMake([numberValueOfDiction(theme, @"x") doubleValue], [numberValueOfDiction(theme, @"y")doubleValue]);
                
                NSString *currentType = stringValueOfDictionary(theme, @"type");
                NSString *currentID = nil;
                if ( [currentType isEqualToString:@"MV"] || [currentType isEqualToString:@"OL"] )
                {
                    currentID = stringValueOfDictionary(theme, @"docId");
                    if ( currentID.length <= 0 ) currentID = stringValueOfDictionary(theme, @"id");
                }
                else
                    currentID = stringValueOfDictionary(theme, @"id");
                NSString *currentName = stringValueOfDictionary(theme, @"name");
                
                NSMutableDictionary *currentTotalInfo = [[NSMutableDictionary alloc] init];
                [currentTotalInfo setObject:currentID forKey:@"ID"];
                [currentTotalInfo setObject:currentType forKey:@"Type"];
                [currentTotalInfo setObject:currentName forKey:@"Name"];
                [currentTotalInfo setObject:[NSNumber numberWithDouble:currentCoordinate.x] forKey:@"X"];
                [currentTotalInfo setObject:[NSNumber numberWithDouble:currentCoordinate.y] forKey:@"Y"];
                
                // MIK.geun :: 20121009 // 기존오버레이와도 중복되는지 체크
                BOOL previousDuplicated = NO;
                for (OMImageOverlayTheme *overlay in previousRenderedThemeOverlayList)
                {
                    // 기존 오버레이에 포함된 테마정보와 현재 테마정보가 동일한지 체크한다. (싱글/중첩에 따라 구조가 다르다)
                    if ( overlay.duplicated )
                    {
                        for (NSDictionary *info in [overlay.additionalInfo objectForKeyGC:@"POIs"] )
                        {
                            if ( [stringValueOfDictionary(info, @"Type") isEqualToString:currentType]
                                && [stringValueOfDictionary(info, @"ID") isEqualToString:currentID]  )
                            {
                                previousDuplicated = YES;
                                break;
                            }
                        }
                    }
                    else
                    {
                        if ( [stringValueOfDictionary(overlay.additionalInfo, @"Type") isEqualToString:currentType]
                            && [stringValueOfDictionary(overlay.additionalInfo, @"ID") isEqualToString:currentID]  )
                        {
                            previousDuplicated = YES;
                        }
                    }
                    // 동일한 테마확인되면 현재 오버레이 체크 빠져나감.
                    if ( previousDuplicated ) break;
                }
                // 기존 오버레이와 중복된 경우 해당 테마는 건너뛰어야 한다.
                if ( previousDuplicated ) continue;
                
                // 기존 데이터와 중첩되는지 체크
                BOOL duplicated = NO;
                for (NSMutableDictionary *preTheme in refinedThemeList)
                {
                    Coord preCoordinate = CoordMake( [numberValueOfDiction(preTheme, @"X") doubleValue] , [numberValueOfDiction(preTheme, @"Y") doubleValue]);
                    
                    // 위치 중첩되는 경우 중첩데이터로 처리 (**테마는 와이드하게 중첩체크 )
                    if ( [self isDuplicatePOI:preCoordinate :currentCoordinate :YES] )
                    {
                        duplicated = YES;
                        [preTheme setObject:[NSNumber numberWithBool:duplicated] forKey:@"Duplicated"];
                        [[preTheme objectForKeyGC:@"POIs"] addObject:currentTotalInfo];
                        break;
                    }
                }
                // 기존 데이터와 위치 중첩되지 않을 경우 신규 POI 저장
                if ( duplicated == NO )
                {
                    NSMutableDictionary *newTheme = [[NSMutableDictionary alloc] init];
                    
                    [newTheme setObject:[NSNumber numberWithDouble:currentCoordinate.x] forKey:@"X"];
                    [newTheme setObject:[NSNumber numberWithDouble:currentCoordinate.y] forKey:@"Y"];
                    [newTheme setObject:[NSMutableArray array] forKey:@"POIs"];
                    [[newTheme objectForKeyGC:@"POIs"] addObject:currentTotalInfo];
                    [newTheme setObject:[NSNumber numberWithBool:NO] forKey:@"Duplicated"];
                    [refinedThemeList addObject:newTheme];
                    [newTheme release];
                }
                
                // 제거
                [currentTotalInfo release];
            }
            [themeSearchResultList release];
            
            // 기존오버레이와 신규오버레이 카운트가 0 일 경우 안내..
            if ( previousRenderedThemeOverlayList.count <= 0 && refinedThemeList.count <= 0 )
            {
                NSMutableDictionary *toast = [[NSMutableDictionary alloc] init];
                [toast setObject:@"선택하신 테마가 현재 지도화면에 없습니다." forKey:@"Message"];
                [toast setObject:self.view forKey:@"SuperView"];
                [toast setObject:[NSNumber numberWithFloat:self.vwCurrentAddressGroup.frame.origin.y-10] forKey:@"MaxBottomPoint"];
                [toast setObject:[NSNumber numberWithBool:YES] forKey:@"AutoClose"];
                [self performSelectorOnMainThread:@selector(doWork_ToastMessage:) withObject:toast waitUntilDone:YES];
                [toast release];
            }
            
            // 미리 아이콘 이미지 준비하라우.
            NSString *mainThemeCode = stringValueOfDictionary([ThemeCommon sharedThemeCommon].additionalInfo, @"MainThemeCode");
            UIImage *themeImageSingle = [UIImage imageWithContentsOfFile: [ThemeCommon getThemeImageFileFullPath:mainThemeCode :ThemeImageType_Marker_Normal ] ];
            UIImage *themeImageDuplicated = [UIImage imageWithContentsOfFile: [ThemeCommon getThemeImageFileFullPath:mainThemeCode :ThemeImageType_Marker_Normal_Nest ] ];
            
            // 기존오버레이 목록 클리어
            [previousRenderedThemeOverlayList removeAllObjects];
            [previousRenderedThemeOverlayList release];
            
            // 렌더링하자~~
            for (NSDictionary *poi in refinedThemeList)
            {
                BOOL duplicated = [[poi objectForKeyGC:@"Duplicated"] boolValue];
                Coord coordinate = CoordMake([numberValueOfDiction(poi, @"X") doubleValue] , [numberValueOfDiction(poi, @"Y") doubleValue]);
                OMImageOverlayTheme *overlay = nil;
                if (duplicated)
                {
                    overlay = [[OMImageOverlayTheme alloc] initWithImage:themeImageDuplicated];
                    for (NSString *key in [poi allKeys])
                    {
                        [overlay.additionalInfo setObject:[poi objectForKeyGC:key] forKey:key];
                    }
                }
                else
                {
                    overlay =  [[OMImageOverlayTheme alloc] initWithImage:themeImageSingle];
                    NSDictionary *single = [[poi objectForKeyGC:@"POIs"] objectAtIndexGC:0];
                    for (NSString *key in [single allKeys] )
                    {
                        [overlay.additionalInfo setObject:[single objectForKeyGC:key] forKey:key];
                    }
                }
                [overlay setDuplicated:duplicated];
                [overlay setSelected:NO];
                [overlay setCoord:coordinate];
                [overlay setDelegate:self];
                [mc.kmap addOverlay:overlay];
                
                [overlay release];
            }
            
            [refinedThemeList removeAllObjects];
            [refinedThemeList release];
            
            // 테마 렌더링 이후 선택된 POI 가 없다면... 마커옵션 비활성화처리
            BOOL poiSelected = NO;
            for (Overlay *overlay in mc.kmap.getOverlays)
            {
                if ( [overlay isKindOfClass:[OMImageOverlay class]] && ((OMImageOverlay*)overlay).selected )
                {
                    poiSelected = YES;
                    break;
                }
            }
            // 선택된 POI 가 없다면 마서커옵션비활성화
            if ( !poiSelected )
            {
                NSMutableDictionary *option = [[NSMutableDictionary alloc] init];
                [option setObject:[NSNumber numberWithBool:NO] forKey:@"Display"];
                [option setObject:[NSNumber numberWithBool:NO] forKey:@"Animated"];
                //[option setObject:[NSNull null] forKey:@"TargetInfo"]; // null은 생략
                [self performSelectorOnMainThread:@selector(doWork_PinPOIMarkerOption:) withObject:nil waitUntilDone:YES];
                [option release];
            }
        }
        @catch (NSException *exception)
        {
#ifdef _TB_SERVER
            NSMutableDictionary *toast = [[NSMutableDictionary alloc] init];
            [toast setObject:@"테마 POI 를 그리는데 실패했습니다." forKey:@"Message"];
            [toast setObject:self.view forKey:@"SuperView"];
            [toast setObject:[NSNumber numberWithFloat:self.vwCurrentAddressGroup.frame.origin.y-10] forKey:@"MaxBottomPoint"];
            [toast setObject:[NSNumber numberWithBool:YES] forKey:@"AutoClose"];
            [self performSelectorOnMainThread:@selector(doWork_ToastMessage:) withObject:toast waitUntilDone:YES];
            [toast release];
#endif
        }
        @finally
        {
        }
    }
}

- (void) doWork_ToastMessage :(id)object
{
    NSDictionary *toast = (NSDictionary*)object;
    // 토스트 띄우기
    [[OMToast sharedToast] showToastMessagePopup:stringValueOfDictionary(toast, @"Message") superView:[toast objectForKeyGC:@"SuperView"] maxBottomPoint:[numberValueOfDiction(toast, @"MaxBottomPoint") floatValue] autoClose:[numberValueOfDiction(toast, @"AutoClose") boolValue]];
}
- (void) doWork_PinPOIMarkerOption :(id)object
{
    NSDictionary *option = (NSDictionary*)object;
    [self pinPOIMarkerOption:[numberValueOfDiction(option, @"Display") boolValue] targetInfo:[option objectForKeyGC:@"TargetInfo"] animated:[numberValueOfDiction(option, @"Animated") boolValue]];
}


- (void) pinPOIMarkerOption:(BOOL)isDisplay targetInfo:(NSDictionary *)targetInfo animated:(BOOL)animated
{
    [self pinPOIMarkerOption:isDisplay targetInfo:targetInfo duplicatedInfo:nil animated:animated];
}
- (void) pinPOIMarkerOption:(BOOL)isDisplay targetInfo:(NSDictionary *)targetInfo duplicatedInfo:(NSDictionary*)duplicatedInfo animated:(BOOL)animated
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    if ( isDisplay )
    {
        // 기존에 존재하던 마커옵션 전부 날리기
        [mc.kmap removeSpecialOverlaysKindOfClass:[OMUserOverlayMarkerOption class]];
        
        // 교통 실시간 정보 렌더링 ( 버스 or 지하철)
        NSString *realtimeTableTargetType = stringValueOfDictionary(targetInfo, @"Type") ;
        NSString *realtimeTableTargetSTID = stringValueOfDictionary(targetInfo, @"ID");
        if ( [realtimeTableTargetType isEqualToString:@"TR_BUS"] && realtimeTableTargetSTID.length > 0)
        {
            [[ServerConnector sharedServerConnection] requestTrafficRealtimeBusTimeTable:self action:@selector(finishTrafficRealtimeBusTimeTable:) busid:realtimeTableTargetSTID ];
        }
        else if ( [realtimeTableTargetType isEqualToString:@"TR"] && realtimeTableTargetSTID.length > 0 )
        {
            [[ServerConnector sharedServerConnection] requestTrafficRealtimeSubwayTimeTable:self action:@selector(finishTrafficRealtimeSubwayTimeTable:) subwayid:realtimeTableTargetSTID];
        }
        else if ( [realtimeTableTargetType isEqualToString:@"TR_RAW"] && realtimeTableTargetSTID.length > 0)
        {
            [[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(finishPoiDetailForRealtimeTimetable:) poiId:realtimeTableTargetSTID isSimple:1];
        }
        // 그외 해당하지않을 경우 제거
        else
        {
            [self clearRealtimeTrafficTimeTable];
        }
        
        // 마커옵션 오버레이 중앙 좌표
        Coord markerCoordinate = CoordMake([[targetInfo objectForKeyGC:@"X"] floatValue], [[targetInfo objectForKeyGC:@"Y"] floatValue] );
        
        // 중복정보 존재할경우 보정
        if ( duplicatedInfo)
        {
            markerCoordinate = CoordMake( [numberValueOfDiction(duplicatedInfo, @"X") floatValue], [numberValueOfDiction(duplicatedInfo, @"Y") floatValue]);
        }
        
        
        /*
         if ( animated && CoordDistance(mc.kmap.centerCoordinate, markerCoordinate) > 0 )
         {
         animated = NO;
         }
         */
        // MIK.geun :: 20121008 // 2차때 적용안함
        /*
         // MIK.geun :: 20120928 // 마커옵션 열릴때 중앙으로 이동시키도록 추가
         [self toggleMyLocationMode:MapLocationMode_None];
         [mc.kmap setCenterCoordinate:markerCoordinate animated:YES];
         */
        
        // 마커옵션 타이틀
        NSString *markerTitle = [NSString stringWithFormat:@"%@", [targetInfo objectForKeyGC:@"Name"]];
        
        // 마커옵션 오버레이 선언
        OMUserOverlayMarkerOptionTitle *markerTitleOverlay = nil;
        OMUserOverlayMarkerOption *markerLeftButtonOverlay = nil;
        OMUserOverlayMarkerOption *markerBottomtButtonOverlay = nil;
        OMUserOverlayMarkerOption *markerRightButtonOverlay = nil;
        
        // ===============
        // 마커옵션 타이틀
        // ===============
        
        // 제목/아이콘 클릭시 동작할 액션영역
        CGRect markerTitleActionFrame = CGRectMake(15, 8, 0, 15);
        OMControl *markerTitleAction = [[OMControl alloc] initWithFrame:markerTitleActionFrame];
        // 타이틀 들어갈 라벨
        UILabel *markerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 14)];
        [markerTitleLabel setFont:[UIFont systemFontOfSize:14]];
        [markerTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [markerTitleLabel setBackgroundColor:[UIColor clearColor]];
        [markerTitleLabel setTextColor:[UIColor whiteColor]];
        [markerTitleLabel setText:markerTitle];
        CGSize markerTitleLabelAdjustSize  = [markerTitleLabel.text sizeWithFont:markerTitleLabel.font constrainedToSize:CGSizeMake(FLT_MAX, 14) lineBreakMode:markerTitleLabel.lineBreakMode];
        [markerTitleLabel setFrame:CGRectMake(0, 0, markerTitleLabelAdjustSize.width, 14)];
        // 타이틀 텍스트 길이에 맞춰서 액션영역 다시 조정
        markerTitleActionFrame.size.width = markerTitleLabelAdjustSize.width + 4 + 9;
        [markerTitleAction setFrame:markerTitleActionFrame];
        // 화살표 아이콘
        UIImageView *markerTitleArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_layer_arrow.png"]];
        [markerTitleArrowImageView setFrame:CGRectMake(markerTitleLabelAdjustSize.width+4, 0, markerTitleArrowImageView.image.size.width, markerTitleArrowImageView.image.size.height)];
        // 타이틀 액션영역에 추가
        [markerTitleAction addSubview:markerTitleLabel];
        // MIK.geun :: 20121016 // 와이파이 타입만 별도처리하도록 하드코딩
        if ( [stringValueOfDictionary(targetInfo, @"Type") isEqualToString:@"wifi"] == NO )
        {
            // 화살표 액션영역에 추가
            [markerTitleAction addSubview:markerTitleArrowImageView];
            // 액션설정
            [markerTitleAction addTarget:self action:@selector(highlightPointOverlayDetailButton:) forControlEvents:UIControlEventTouchDown];
            [markerTitleAction addTarget:self action:@selector(cancelHighlightPointOverlayDetailButton:) forControlEvents:UIControlEventTouchUpOutside];
            [markerTitleAction addTarget:self action:@selector(onPOIMarkerOptionDetailButton:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            CGRect markerTitleLabelRect2 = markerTitleLabel.frame;
            markerTitleLabelRect2.origin.x += 5;
            [markerTitleLabel setFrame:markerTitleLabelRect2];
        }
        // 배경/컨테이너 - 배경이미지
        CGRect markerTitleBackgroundFrame = CGRectMake(0, 0, markerTitleActionFrame.size.width+15+ 8, 46);
        UIImageView *markerTitleBackgroundLeftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_layer_left.png"]];
        [markerTitleBackgroundLeftImageView setFrame:CGRectMake(0, 0, 15, 46)];
        UIImageView *markerTitleBackgroundRightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_layer_right.png"]];
        [markerTitleBackgroundRightImageView setFrame:CGRectMake(markerTitleBackgroundFrame.size.width-15, 0, 15, 46)];
        UIImageView *markerTitleBackgroundMiddleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_layer_middle.png"]];
        [markerTitleBackgroundMiddleImageView setFrame:CGRectMake(15, 0, markerTitleBackgroundFrame.size.width-30, 46)];
        UIImageView *markerTitleBackgroundCenterImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_layer_center.png"]];
        [markerTitleBackgroundCenterImageView setFrame:CGRectMake((markerTitleBackgroundFrame.size.width/2)-6, 0, 12, 46)];
        // 배경컨테이너에 배경-타이틀 집어넣기
        UIView *markerTitleBackground = [[UIView alloc] initWithFrame:markerTitleBackgroundFrame];
        [markerTitleBackground addSubview:markerTitleBackgroundLeftImageView];
        [markerTitleBackground addSubview:markerTitleBackgroundMiddleImageView];
        [markerTitleBackground addSubview:markerTitleBackgroundRightImageView];
        [markerTitleBackground addSubview:markerTitleBackgroundCenterImageView];
        [markerTitleBackground addSubview:markerTitleAction];
        
        // 마커옵션 타이틀 오버레이 생성하기
        markerTitleOverlay = [[OMUserOverlayMarkerOptionTitle alloc] initWithSize:CGSizeMake(markerTitleBackgroundFrame.size.width+15+8, 46)];
        [markerTitleOverlay setCoord:markerCoordinate];
        [markerTitleOverlay setCenterOffset:CGPointMake(markerTitleBackgroundFrame.size.width/2, 35+46+12)]; // 중심좌표에서 35픽셀만큼 위로올려야 한다.
        // 오버레이 뷰에 추가
        [markerTitleOverlay.getOverlayView addSubview:markerTitleBackground];
        // 오버레이 추가~
        [mc.kmap addOverlay:markerTitleOverlay];
        // 액션 컨트롤/오버레이 내 추가정보 입력하기
        for (NSString *key in targetInfo.allKeys)
        {
            [markerTitleAction.additionalInfo setObject:[targetInfo objectForKeyGC:key] forKey:key];
            [markerTitleOverlay.additionalInfo setObject:[targetInfo objectForKeyGC:key] forKey:key];
        }
        
        // ============
        // 출발버튼 생성 (오버레이와는 별도작업임)
        // ============
        OMButton *searchRouteStartButton = [[OMButton alloc] initWithFrame:CGRectMake(0, 0, 41, 41)];
        [searchRouteStartButton setImage:[UIImage imageNamed:@"map_btn_start.png"] forState:UIControlStateNormal];
        for (NSString *key in targetInfo.allKeys)
        {
            [searchRouteStartButton.additionalInfo setObject:[targetInfo objectForKeyGC:key] forKey:key];
        }
        [searchRouteStartButton addTarget:self action:@selector(onPOIMarkerOptionStartButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // ============
        // 도착버튼 생성 (오버레이와는 별도작업임)
        // ============
        OMButton *searchRouteDestButton = [[OMButton alloc] initWithFrame:CGRectMake(0, 0, 41, 41)];
        [searchRouteDestButton setImage:[UIImage imageNamed:@"map_btn_stop.png"] forState:UIControlStateNormal];
        for (NSString *key in targetInfo.allKeys)
        {
            [searchRouteDestButton.additionalInfo setObject:[targetInfo objectForKeyGC:key] forKey:key];
        }
        [searchRouteDestButton addTarget:self action:@selector(onPOIMarkerOptionDestButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // ============
        // 경유버튼 생성 (오버레이와는 별도작업임)
        // ============
        OMButton *searchRouteVisitButton = [[OMButton alloc] initWithFrame:CGRectMake(0, 0, 41, 41)];
        [searchRouteVisitButton setImage:[UIImage imageNamed:@"map_btn_via.png"] forState:UIControlStateNormal];
        for (NSString *key in targetInfo.allKeys)
        {
            [searchRouteVisitButton.additionalInfo setObject:[targetInfo objectForKeyGC:key] forKey:key];
        }
        [searchRouteVisitButton addTarget:self action:@selector(onPOIMarkerOptionVisitButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // ============
        // 공유버튼 생성 (오버레이와는 별도작업임)
        // ============
        OMButton *searchRouteShareButton = [[OMButton alloc] initWithFrame:CGRectMake(0, 0, 41, 41)];
        [searchRouteShareButton setImage:[UIImage imageNamed:@"map_btn_share.png"] forState:UIControlStateNormal];
        for (NSString *key in targetInfo.allKeys)
        {
            [searchRouteShareButton.additionalInfo setObject:[targetInfo objectForKeyGC:key] forKey:key];
        }
        [searchRouteShareButton addTarget:self action:@selector(onPOIMarkerOptionShareButton:) forControlEvents:UIControlEventTouchUpInside];
        
        
        // ===============
        // 버튼 오버레이 생성
        // ===============
        // 왼쪽 오버레이
        markerLeftButtonOverlay = [[OMUserOverlayMarkerOption alloc] initWithSize:CGSizeMake(41, 41)];
        [markerLeftButtonOverlay setCoord:markerCoordinate];
        [markerLeftButtonOverlay setCenterOffset:CGPointMake((int)(42/2+41), (int)41 + 5)];
        [markerLeftButtonOverlay.getOverlayView addSubview:searchRouteStartButton];
        [mc.kmap addOverlay:markerLeftButtonOverlay];
        // 오른쪽 오버레이
        markerRightButtonOverlay = [[OMUserOverlayMarkerOption alloc] initWithSize:CGSizeMake(41, 41)];
        [markerRightButtonOverlay setCoord:markerCoordinate];
        [markerRightButtonOverlay setCenterOffset:CGPointMake(-(int)(42/2), (int)41 + 5)];
        [mc.kmap addOverlay:markerRightButtonOverlay];
        //  하단 오버레이
        markerBottomtButtonOverlay = [[OMUserOverlayMarkerOption alloc] initWithSize:CGSizeMake(41, 41)];
        [markerBottomtButtonOverlay setCoord:markerCoordinate];
        [markerBottomtButtonOverlay setCenterOffset:CGPointMake((int)41/2, -3)];
        [mc.kmap addOverlay:markerBottomtButtonOverlay];
        
        
        // 위치 초기화 (애니메이션 이전..)
        [markerTitleBackground setFrame:CGRectMake(0, markerTitleBackgroundFrame.size.height, markerTitleBackgroundFrame.size.width, markerTitleBackground.frame.size.height)];
        
        // 일반적인 지도화면 (출발-도착 버튼 노출)
        if (oms.currentSearchTargetType == SearchTargetType_NONE || oms.currentSearchTargetType == SearchTargetType_VOICENONE)
        {
            [markerLeftButtonOverlay.getOverlayView addSubview:searchRouteStartButton];
            [searchRouteStartButton setFrame:CGRectMake(41, 0, 41, 41)];
            [markerBottomtButtonOverlay.getOverlayView addSubview:searchRouteDestButton];
            [searchRouteDestButton setFrame:CGRectMake(0, -41, 41, 41)];
        }
        // 출발지만 나오는 지도화면
        else if ( oms.currentSearchTargetType == SearchTargetType_START || oms.currentSearchTargetType == SearchTargetType_VOICESTART )
        {
            [markerLeftButtonOverlay.getOverlayView addSubview:searchRouteStartButton];
            [searchRouteStartButton setFrame:CGRectMake(41, 0, 41, 41)];
        }
        // 도착지만 나오는 지도화면
        else if ( oms.currentSearchTargetType == SearchTargetType_DEST || oms.currentSearchTargetType == SearchTargetType_VOICEDEST )
        {
            [markerLeftButtonOverlay.getOverlayView addSubview:searchRouteDestButton];
            [searchRouteDestButton setFrame:CGRectMake(41, 0, 41, 41)];
        }
        // 경유지만 나오는 지도화면
        else if (oms.currentSearchTargetType == SearchTargetType_VISIT || oms.currentSearchTargetType == SearchTargetType_VOICEVISIT )
        {
            [markerLeftButtonOverlay.getOverlayView addSubview:searchRouteVisitButton];
            [searchRouteVisitButton setFrame:CGRectMake(41, 0, 41, 41)];
        }
        
        // 공유버튼은 항상 노출
        [markerRightButtonOverlay.getOverlayView addSubview:searchRouteShareButton];
        [searchRouteShareButton setFrame:CGRectMake(-41, 0, 41, 41)];
        
        
        /*
         [UIView animateWithDuration:0.5f delay: 0.0f options: UIViewAnimationCurveEaseIn
         animations:^{
         // 위치 반영 (애니메이션 이후.. 또는 애니메이션미적용시)
         [markerTitleBackground setFrame:markerTitleBackgroundFrame];
         [searchRouteStartButton setFrame:CGRectMake(0, 0, 41, 41)];
         [searchRouteDestButton setFrame:CGRectMake(0, 0, 41, 41)];
         [searchRouteVisitButton setFrame:CGRectMake(0, 0, 41, 41)];
         [searchRouteShareButton setFrame:CGRectMake(0, 0, 41, 41)];
         }
         completion:^(BOOL finished){
         }];
         */
        
        // 애니메이션 효과 설정
        if (animated)
        {
            [UIView beginAnimations:@"POIMarkerOption" context:nil];
            [UIView setAnimationDuration:0.5f];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        }
        // 위치 반영 (애니메이션 이후.. 또는 애니메이션미적용시)
        [markerTitleBackground setFrame:markerTitleBackgroundFrame];
        [searchRouteStartButton setFrame:CGRectMake(0, 0, 41, 41)];
        [searchRouteDestButton setFrame:CGRectMake(0, 0, 41, 41)];
        [searchRouteVisitButton setFrame:CGRectMake(0, 0, 41, 41)];
        [searchRouteShareButton setFrame:CGRectMake(0, 0, 41, 41)];
        // 애니메이션 효과 적용
        if (animated)
        {
            [UIView commitAnimations];
        }
        
        
        [markerTitleAction release];
        [markerTitleBackground release];
        [markerTitleBackgroundMiddleImageView release];
        [markerTitleBackgroundRightImageView release];
        [markerTitleBackgroundLeftImageView release];
        [markerTitleBackgroundCenterImageView release];
        [markerTitleArrowImageView release];
        [markerTitleLabel release];
        
        [searchRouteStartButton release];
        [searchRouteDestButton release];
        [searchRouteVisitButton release];
        [searchRouteShareButton release];
        
        [markerTitleOverlay release];
        [markerRightButtonOverlay release];
        [markerLeftButtonOverlay release];
        [markerBottomtButtonOverlay release];
        
    }
    else
    {
        // 마커옵션 관련 오버레이 제거
        [mc.kmap removeSpecialOverlaysKindOfClass:[OMUserOverlayMarkerOption class]];
        // 혹시 있을지 모르는 실시간 교통정보 뷰 제거
        [self clearRealtimeTrafficTimeTable];
    }
    
}

- (void) onPOIMarkerOptionStartButton:(id)sender
{
    OMButton *startButton = (OMButton*)sender;
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    [oms.searchResultRouteStart reset];
    [oms.searchResultRouteStart setUsed:YES];
    [oms.searchResultRouteStart setIsCurrentLocation:NO];
    [oms.searchResultRouteStart setStrLocationName:[startButton.additionalInfo objectForKeyGC:@"Name"]];
    [oms.searchResultRouteStart setStrLocationAddress:[startButton.additionalInfo objectForKeyGC:@"Address"]];
    [oms.searchResultRouteStart setStrID:[startButton.additionalInfo objectForKeyGC:@"ID"]];
    [oms.searchResultRouteStart setStrType:[startButton.additionalInfo objectForKeyGC:@"Type"]];
    [oms.searchResultRouteStart setCoordLocationPoint:CoordMake( [[startButton.additionalInfo objectForKeyGC:@"X"] floatValue] , [[startButton.additionalInfo objectForKeyGC:@"Y"] floatValue] )];
    
    [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
}
- (void) onPOIMarkerOptionDestButton:(id)sender
{
    OMButton *destButton = (OMButton*)sender;
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    [oms.searchResultRouteDest reset];
    [oms.searchResultRouteDest setUsed:YES];
    [oms.searchResultRouteDest setIsCurrentLocation:NO];
    [oms.searchResultRouteDest setStrLocationName:[destButton.additionalInfo objectForKeyGC:@"Name"]];
    [oms.searchResultRouteDest setStrLocationAddress:[destButton.additionalInfo objectForKeyGC:@"Address"]];
    [oms.searchResultRouteDest setStrID:[destButton.additionalInfo objectForKeyGC:@"ID"]];
    [oms.searchResultRouteDest setStrType:[destButton.additionalInfo objectForKeyGC:@"Type"]];
    [oms.searchResultRouteDest setCoordLocationPoint:CoordMake( [[destButton.additionalInfo objectForKeyGC:@"X"] floatValue] , [[destButton.additionalInfo objectForKeyGC:@"Y"] floatValue] )];
    
    [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
}

- (void) onPOIMarkerOptionVisitButton:(id)sender
{
    OMButton *visitButton = (OMButton*)sender;
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    [oms.searchResultRouteVisit reset];
    [oms.searchResultRouteVisit setUsed:YES];
    [oms.searchResultRouteVisit setIsCurrentLocation:NO];
    [oms.searchResultRouteVisit setStrLocationName:[visitButton.additionalInfo objectForKeyGC:@"Name"]];
    [oms.searchResultRouteVisit setStrLocationAddress:[visitButton.additionalInfo objectForKeyGC:@"Address"]];
    [oms.searchResultRouteVisit setStrID:[visitButton.additionalInfo objectForKeyGC:@"ID"]];
    [oms.searchResultRouteVisit setStrType:[visitButton.additionalInfo objectForKeyGC:@"Type"]];
    [oms.searchResultRouteVisit setCoordLocationPoint:CoordMake( [[visitButton.additionalInfo objectForKeyGC:@"X"] floatValue] , [[visitButton.additionalInfo objectForKeyGC:@"Y"] floatValue] )];
    
    [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
}

- (void) onPOIMarkerOptionShareButton:(id)sender
{
    OMButton *shareButton = (OMButton*)sender;
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    Coord shareCoord =  CoordMake( [[shareButton.additionalInfo objectForKeyGC:@"X"] floatValue] , [[shareButton.additionalInfo objectForKeyGC:@"Y"] floatValue] );
    NSString *shareID = [NSString stringWithFormat:@"%@", [shareButton.additionalInfo objectForKeyGC:@"ID"]];
    NSString *shareName = [NSString stringWithFormat:@"%@", [shareButton.additionalInfo objectForKeyGC:@"Name"]];
    NSString *shareAddress = [NSString stringWithFormat:@"%@", [shareButton.additionalInfo objectForKeyGC:@"Address"] ? [shareButton.additionalInfo objectForKeyGC:@"Address"] : @""];
    NSString *shareTelNumber = [NSString stringWithFormat:@"%@", [shareButton.additionalInfo objectForKeyGC:@"Tel"] ? [shareButton.additionalInfo objectForKeyGC:@"Tel"] : @""];
    
    NSString *shareType = [NSString stringWithFormat:@"%@", [shareButton.additionalInfo objectForKeyGC:@"Type"]];
    
    if([shareType isEqualToString:@"TR_RAW"])
    {
        if([oms.searchResultOneTouchPOI.strType isEqualToString:@"TR"])
            shareType = @"TR";
        else if ([oms.searchResultOneTouchPOI.strType isEqualToString:@"TR_BUS"])
            shareType = @"TR_BUS";
    }


    // 이벤트 트래킹 - 롱탭 후 공유선택
    if (_nMapRenderType == MapRenderType_Normal) [oms trackPageView:@"/main_map/long_tab/share"];
    
    //[[ServerConnector sharedServerConnection] requestShortenURL:self action:@selector(didFinishRequestShortURL:) PX:(int)shareCoord.x PY:(int)shareCoord.y Level:mc.kmap.zoomLevel MapType:mc.kmap.mapType Name:shareName PID:shareID Addr:shareAddress Tel:shareTelNumber sendNum:1];

    // 새로운 url공유(타입추가해봄)
        
        int detailType = 0;
    
        if([shareType isEqualToString:@"TR_BUS"])
        {
            detailType = 1;
        }
        else if([shareType isEqualToString:@"TR"])
        {
            detailType = 2;
        }
        else if ([shareType isEqualToString:@"CCTV"])
        {
            detailType = 3;
        }
        else if ([shareType isEqualToString:@"ADDR"])
        {
            detailType = 4;
        }
            
        [[ServerConnector sharedServerConnection] requestMapURL:self action:@selector(didFinishRequestShortURL:) PX:(int)shareCoord.x PY:(int)shareCoord.y PID:(NSString *)shareID Name:(NSString *)shareName Addr:(NSString *)shareAddress Tel:(NSString *)shareTelNumber poiButton:sender detailType:detailType mapType:mc.kmap.mapType];
    
    
    //[[ServerConnector sharedServerConnection] requestShortenURL:self action:@selector(didFinishRequestShortURL:) PX:(int)shareCoord.x PY:(int)shareCoord.y Level:mc.kmap.zoomLevel MapType:mc.kmap.mapType Name:shareName PID:shareID Addr:shareAddress Tel:shareTelNumber Type:(NSString *)shareType ID:(NSString *)shareID poiButton:sender];
}

- (void) onPOIMarkerOptionDetailButton:(id)sender
{
    OMControl *detailControl = (OMControl*)sender;
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    for (UIView *subview in detailControl.subviews)
    {
        // 내부 텍스트 라벨 가져와서 생상변경
        if ([subview isKindOfClass:[UILabel class]] )
        {
            UILabel *lbl = (UILabel*)subview;
            [lbl setTextColor:[UIColor whiteColor]];
            break;
        }
    }
    
    // 추가정보가 없을 경우 더이상 진행할 수 없음.
    NSMutableDictionary *additionalInfo = detailControl.additionalInfo;
    if ( additionalInfo == nil)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
        return;
    }
    // 추가정보 꺼내기
    NSString *shareID = stringValueOfDictionary(additionalInfo, @"ID");
    NSString *shareType = stringValueOfDictionary(additionalInfo, @"Type");
    NSString *shareName = stringValueOfDictionary(additionalInfo, @"Name");
    //NSString *shareAddress = stringValueOfDictionary(additionalInfo, @"Address");
    NSString *shareNewAddress = stringValueOfDictionary(additionalInfo, @"SubAddress");
    NSString *shareOldorNew = stringValueOfDictionary(additionalInfo, @"OldOrNew");
    //NSString *shareTel = stringValueOfDictionary(additionalInfo, @"Tel");
    Coord shareCoord = CoordMake([numberValueOfDiction(additionalInfo, @"X") floatValue], [numberValueOfDiction(additionalInfo, @"Y") floatValue]);
    
    NSLog(@"add : %@", [additionalInfo objectForKeyGC:@"Name"]);
    
    // 이벤트 트래킹 - 롱탭 후 상세보기
    if (_nMapRenderType == MapRenderType_Normal) [oms trackPageView:@"/main_map/long_tab/detail"];
    // 이벤트 트래킹 - 검색 후 상세보기
    else if (_nMapRenderType == MapRenderType_SearchResult_SinglePOI || _nMapRenderType == MapRenderType_SearchResult_MultiPOI)
        [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail"];
    
    // 상세보기에서 넘어온 SinglePOI 일 경우 상세보기 버튼 클릭시 뒤로 돌아가도록 한다.
    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    // 뷰컨트롤러가 1보다 많아야 한다. 1개인 경우는 메인화면 하나일경우밖에 없음.
    if (nc.viewControllers.count > 1 && _nMapRenderType == MapRenderType_SearchResult_SinglePOI && _selectedMultiPOIIndex == -1)
    {
        UIViewController *vc = [nc.viewControllers objectAtIndexGC:nc.viewControllers.count-2];
        if ([vc isKindOfClass:[CommonPOIDetailViewController class]])
        {
            // 화면 나가기 전에 현재 지도의 모든 오버레이 제거한다.
            [[MapContainer sharedMapContainer_Main].kmap removeAllOverlaysWithoutTraffic];
            
            // 화면 나가기
            [nc popViewControllerAnimated:NO];
            return;
        }
    }
    
    // 상세정보 ID값이 존재하는 확인
    if ( [shareType isEqualToString:@"wifi"] )
    {
        //  WiFi 일경우에는... 조용히 무시하고 지나감.
        return;
    }
    else if ( shareID.length == 0 && ![shareType isEqualToString:@"ADDR"] )
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
        return;
    }
    
    // OneTouchPOI에서 넘어온 경우 TR_RAW 를 재분류해야한다.
    if ( [shareType isEqualToString:@"TR_RAW"] )
    {
        [[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(didFinishRequestPOISimpleInfo:) poiId:shareID isSimple:1];
    }
    // 지하철역 정보
    else if ([shareType isEqualToString:@"TR"])
    {
        //[[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(didFinishRequestPOISimpleInfo:) poiId:omsr.strID isSimple:1];
        [[ServerConnector sharedServerConnection] requestSubStation:self action:@selector(didFinishRequestAllPOIDetail:) stationId:shareID];
    }
    else if ([shareType isEqualToString:@"TR_BUS"])
    {
        [[ServerConnector sharedServerConnection] requestBusStationInfoStid:self action:@selector(didFinishRequestAllPOIDetail:) stId:shareID];
    }
    // 유가정보의 ORG_DB_ID 를 구하기 위해 한번더 검색
    else if ([shareType isEqualToString:@"OL"])
    {
        [[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(didFinishRequestAllPOIDetail:) poiId:shareID isSimple:0];
    }
    // 영화관 MV
    else if ([shareType isEqualToString:@"MV"])
    {
        [[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(didFinishRequestAllPOIDetail:) poiId:shareID isSimple:0];
    }
    // 일반 MP
    else if ([shareType isEqualToString:@"MP"])
    {
        [[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(didFinishRequestAllPOIDetail:) poiId:shareID isSimple:0];
    }
    // CCTV
    else if ( [shareType isEqualToString:@"CCTV"])
    {
        [[ServerConnector sharedServerConnection] requestTrafficOptionCCTVInfo:self action:@selector(finishTrafficOptionCCTVInfo:) cctvid:shareID cctvCoordinate:shareCoord];
    }
    // 주소일 경우 상세정보 처리안함
    else if ([shareType isEqualToString:@"ADDR"])
    {
        AddressPOIViewController *avc = [[AddressPOIViewController alloc] initWithNibName:@"AddressPOIViewController" bundle:nil];
        avc.poiAddress = [NSString stringWithFormat:@"%@", shareName];
        avc.poiSubAddress = [NSString stringWithFormat:@"%@", shareNewAddress];
        avc.poiCrd = shareCoord;
        avc.oldOrNew = [NSString stringWithFormat:@"%@",shareOldorNew];
        //avc.mapBtnHidden = YES;
        avc.displayMapBtn = NO;
        [[OMNavigationController sharedNavigationController] pushViewController:avc animated:NO];
        [avc release];
    }
    //  그외의 경우도 상세정보 처리안함
    else
    {
        // 120912 mmv변경으로 구버전에서 만든 url 호출시 암것도 안뜸
        [[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(didFinishRequestPOISimpleInfo:) poiId:shareID isSimple:1];
        //[OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
    }
}

- (void) redrawMarkerOptionOverlayOnFront
{
    // MIK.geun : :20120926
    // 마커옵션 오버레이를 제거했다가 다시 추가하는 방식으로 수정
    NSMutableArray *redrawOverlayList = [[NSMutableArray alloc] init];
    // 마커옵션 오버레이 탐색
    for (Overlay *overlay in [MapContainer sharedMapContainer_Main].kmap.getOverlays)
    {
        if ( [overlay isKindOfClass:[OMUserOverlayMarkerOption class]] )
            [redrawOverlayList addObject:overlay];
    }
    // 걸러낸 마커옵션 오버레이 다시그리기
    for (OMUserOverlayMarkerOption *overlay in redrawOverlayList)
    {
        [[MapContainer sharedMapContainer_Main].kmap removeOverlay:overlay];
        [[MapContainer sharedMapContainer_Main].kmap addOverlay:overlay];
    }
    [redrawOverlayList removeAllObjects];
    [redrawOverlayList release];
}


// 교통옵션 다중POI 팝업호출
- (void) showDuplicatedPOIList:(OMImageOverlay *)overlay
{
    //[OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@", overlay.additionalInfo]];
    
    NSMutableArray *list = nil;
    // 오버레이에서 POI 정보 추출
    if ( overlay )
    {
        list = [[NSMutableArray alloc] init];
        for (NSDictionary *poiDic in [overlay.additionalInfo objectForKeyGC:@"POIs"] )
        {
            [list addObject:poiDic];
        }
    }
    
    if ( list == nil || list.count <= 0 )
    {
        [OMMessageBox showAlertMessage:@"" :@"중첩POI 관련 정보가 존재하지 않습니다."];
        [list release];
        return;
    }
    
    // 팝업 리스트 컨테이너 클리어
    for (UIView *subview in _vwMultiPOISelectorContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    [_vwMultiPOISelectorContainer removeFromSuperview];
    
    // 팝업 리스트 뷰 생성
    UIView *vwMultiPOISelector = [[UIView alloc] initWithFrame:CGRectMake(37, 116, 246, 233)];
    
    // 팝업 리스트 뷰 배경
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_m_bg.png"]];
    [imgvwBack setFrame:CGRectMake(0, 0, imgvwBack.image.size.width, imgvwBack.image.size.height)];
    [vwMultiPOISelector addSubview:imgvwBack];
    [imgvwBack release];
    
    // 리스트 스크롤뷰 컨텐츠 높이
    float listContentsHeight = 0.0f;
    
    // 스크롤뷰 생성
    OMScrollView *svwList = [[OMScrollView alloc] initWithFrame:CGRectMake(9, 14, 228, 162)];
    [svwList setDelegate:self];
    [svwList setScrollType:2];
    // 라인뷰 생성
    {
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, listContentsHeight, svwList.frame.size.width, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0f)];
        [vwLine setHidden:YES];//첫번째 라인 보이지 않도록
        [svwList addSubview:vwLine];
        [vwLine release];
        listContentsHeight += 1;
    }
    for (NSMutableDictionary *poiDic in list)
    {
        int index = [numberValueOfDiction(poiDic, @"Index") intValue];
        
        // POI 뷰 생성
        CGRect rectCell = CGRectMake(0, listContentsHeight, svwList.frame.size.width, 45);
        OMControl *vwCell = [[OMControl alloc] initWithFrame:rectCell];
        [vwCell setTag:index];
        [vwCell.additionalInfo setObject:overlay forKey:@"Overlay"];
        [vwCell.additionalInfo setObject:poiDic forKey:@"CurrentAdditionalInfo"];
        [vwCell addTarget:self action:@selector(onSelectDuplicatePOI:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addTarget:self action:@selector(onSelectDuplicatePOI_Down:) forControlEvents:UIControlEventTouchDown];
        [vwCell addTarget:self action:@selector(onSelectDuplicatePOI_UpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        
        // 라벨
        CGRect rectName = CGRectMake(41, 15, 179, 15);
        UILabel *lblName =[[UILabel alloc] initWithFrame:rectName];
        [lblName setFont:[UIFont systemFontOfSize:15]];
        [lblName setTextColor:[UIColor blackColor]];
        [lblName setBackgroundColor:[UIColor clearColor]];
        [lblName setTextAlignment:NSTextAlignmentLeft];
        [lblName setLineBreakMode:NSLineBreakByClipping];
        [lblName setText:[NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"Name"]]];
        [lblName setNumberOfLines:999];
        rectName.size = [lblName.text sizeWithFont:lblName.font constrainedToSize:CGSizeMake(rectName.size.width, FLT_MAX) lineBreakMode:lblName.lineBreakMode];
        if (rectName.size.height < 15) rectName.size.height = 15;
        [lblName setFrame:rectName];
        [vwCell addSubview:lblName];
        [lblName release];
        
        // 라벨에 따른 뷰 사이즈 수정
        rectCell.size.height = rectName.size.height + 15 + 15;
        
        if ( [overlay isMemberOfClass:[OMImageOverlayTrafficCCTV class]]
            || [overlay isMemberOfClass:[OMImageOverlayTrafficBusStation class]]
            || [overlay isMemberOfClass:[OMImageOverlayTrafficSubwayStation class]] )
        {
            UIImage *iconImage = nil;
            if ( [overlay isMemberOfClass:[OMImageOverlayTrafficCCTV class]] )
            {
                iconImage = [UIImage imageNamed:@"list_b_marker_cctv.png"];
            }
            else if ( [overlay isMemberOfClass:[OMImageOverlayTrafficBusStation class]] )
            {
                iconImage = [UIImage imageNamed:@"list_b_marker_busstop.png"];
            }
            else if ( [overlay isMemberOfClass:[OMImageOverlayTrafficSubwayStation class]] )
            {
                iconImage = [UIImage imageNamed:@"list_b_marker_subway.png"];
            }
            
            // 교통옵션 인덱스 아이콘 풍선
            UIImageView *imgvwIndexIconBalloon = [[UIImageView alloc] initWithImage:iconImage];
            CGRect rectIndexIconBalloon = CGRectMake(10, 0, imgvwIndexIconBalloon.image.size.width , imgvwIndexIconBalloon.image.size.height);
            rectIndexIconBalloon.origin.y = (rectCell.size.height - imgvwIndexIconBalloon.frame.size.height) / 2 ;
            [imgvwIndexIconBalloon setFrame:rectIndexIconBalloon];
            [vwCell addSubview:imgvwIndexIconBalloon];
            [imgvwIndexIconBalloon release];
        }
        else if ( [overlay isMemberOfClass:[OMImageOverlayTheme class]])
        {
            NSString *mainThemeCode = stringValueOfDictionary([ThemeCommon sharedThemeCommon].additionalInfo, @"MainThemeCode");
            UIImage *themeImageSingle = [UIImage imageWithContentsOfFile: [ThemeCommon getThemeImageFileFullPath:mainThemeCode :ThemeImageType_Marker_list ] ];
            
            // 테마 아이콘 풍선
            UIImageView *imgvwIndexIconBalloons = [[UIImageView alloc] initWithImage:themeImageSingle];
            
            CGRect rectIndexIconBalloon = CGRectMake(10, 0, imgvwIndexIconBalloons.image.size.width , imgvwIndexIconBalloons.image.size.height);
            rectIndexIconBalloon.origin.y = (rectCell.size.height - imgvwIndexIconBalloons.frame.size.height+2) / 2 ;
            [imgvwIndexIconBalloons setFrame:rectIndexIconBalloon];
            [vwCell addSubview:imgvwIndexIconBalloons];
            [imgvwIndexIconBalloons release];
        }
        else
        {
            // 인덱스 아이콘 풍선
            UIImageView *imgvwIndexIconBalloon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_b_marker.png"]];
            CGRect rectIndexIconBalloon = CGRectMake(10, 0,
                                                     imgvwIndexIconBalloon.image.size.width,
                                                     imgvwIndexIconBalloon.image.size.height);
            rectIndexIconBalloon.origin.y = (rectCell.size.height - imgvwIndexIconBalloon.frame.size.height) / 2 ;
            [imgvwIndexIconBalloon setFrame:rectIndexIconBalloon];
            [vwCell addSubview:imgvwIndexIconBalloon];
            [imgvwIndexIconBalloon release];
            
            // 인덱스 아이콘
            UIImageView *imgvwIndexIcon = [[UIImageView alloc]
                                           initWithImage:[UIImage imageNamed:
                                                          [NSString stringWithFormat:@"list_marker_%d.png", index+1]]];
            CGRect rectIndexIcon = CGRectMake(rectIndexIconBalloon.origin.x + 6,
                                              rectIndexIconBalloon.origin.y + 5,
                                              imgvwIndexIcon.image.size.width,
                                              imgvwIndexIcon.image.size.height);
            
            [imgvwIndexIcon setFrame:rectIndexIcon];
            [vwCell addSubview:imgvwIndexIcon];
            [imgvwIndexIcon release];
        }
        
        // POI 뷰 삽입
        [vwCell setFrame:rectCell];
        [svwList addSubview:vwCell];
        [vwCell release];
        listContentsHeight += rectCell.size.height;
        
        // 라인 삽입
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, listContentsHeight, svwList.frame.size.width, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0f)];
        [svwList addSubview:vwLine];
        [vwLine release];
        listContentsHeight += 1;
    }
    [svwList setContentSize:CGSizeMake(svwList.frame.size.width, listContentsHeight)];
    [vwMultiPOISelector addSubview:svwList];
    [svwList release];
    
    // 리스트 해제
    [list release];
    
    // 닫기 버튼
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(88, 183, 70, 31)];
    [btnClose setImage:[UIImage imageNamed:@"popup_btn_close.png"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(onCloseDuplicatePOIList:) forControlEvents:UIControlEventTouchUpInside];
    [vwMultiPOISelector addSubview:btnClose];
    [btnClose release];
    
    // 팝업 리스트 뷰 삽입
    [_vwMultiPOISelectorContainer addSubview:vwMultiPOISelector];
    [vwMultiPOISelector release];
    
    // 팝업 리스트 컨테이너 삽입
    [self.view addSubview:_vwMultiPOISelectorContainer];
    
    
}


- (void) setMapLocationWithCoordinate:(Coord)coordinate WithZoomLevel:(int)zoomLevel
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    // 좌표가 이전값과 다를 경우 새 좌표로 변경
    if ( CoordDistance(coordinate, mc.kmap.lastMapCenterCoordinate) > 0 )
    {
        [mc.kmap setCenterCoordinate:coordinate];
        [mc.kmap setLastMapCenterCoordinate:coordinate];
    }
    
    // 줌 레벨이 이전과 다를 경우 새 레벨로 변경
    if ( zoomLevel != mc.kmap.lastMapZoomLevel )
    {
        [mc.kmap setZoomLevel:zoomLevel];
        [mc.kmap setLastMapZoomLevel:zoomLevel];
    }
    
}

// ******************************


// ======================
// [ 검색서비스 콜백함수 ]
// ======================

- (void) didFinishRequestOneTouchPOI :(id)request
{
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
	if ([request finishCode] == OMSRFinishCode_Completed)
	{
        // 해당 마스터POI 있는지 여부
        BOOL existsMAsterPOI = NO;
        int nMasterGroup = -1;
        int nMasterIndex = -1;
        
        // 정상적인 데이터 들어있는제 확인
        if ( oms.oneTouchPOIDictionary && [[oms.oneTouchPOIDictionary allKeys] containsObject:@"RESULTDATA"] )
        {
            
            // 위성/노멀 타입별로 최대 줌레벨 달라짐, 일반(작은글씨)지도일때 기본 축척이 2배씩됨
            
            // 최단거리 초기화
            double shortDistance = 0;
            // 일반(작은글씨) 지도는 전국지도 축척이 204km
            if (mc.kmap.mapDisplay == KMapDisplayNormalSmallText) shortDistance = 204000;
            // 일반(큰글씨), HD지도는 전국지도 축척이 102km
            else shortDistance = 102000;
            
            // 현제 줌레벨에 맞는 shortDistance 구하기
            //for (int i=0; i<mc.kmap.zoomLevel; i++) {shortDistance = shortDistance / 2;}
            // 2012.07.24 수정 // shortDistance 값을 1/2로 한번 더 나눴음.
            for (int i=0; i<=mc.kmap.zoomLevel; i++) {shortDistance = shortDistance / 2;}
            
            // 터치된 타일내 존재하는 POI 검색
            NSDictionary *oneTouchPOI = [oms.oneTouchPOIDictionary objectForKeyGC:@"RESULTDATA"];
            if ( [[oneTouchPOI allKeys] containsObject:@"TILE_INFO"] )
            {
                NSArray *array_tile = [oneTouchPOI  objectForKeyGC:@"TILE_INFO"];
                for (int i = 0; i < array_tile.count; i++)
                {
                    NSMutableDictionary *dic = [array_tile objectAtIndexGC:i];
                    Coord c = CoordMake([[dic objectForKeyGC:@"X"] doubleValue], [[dic objectForKeyGC:@"Y"] doubleValue]);
                    double currentDistance = CoordDistance(mc.kmap.lastLongTapCoordinate, c);
                    if (currentDistance < shortDistance)
                    {
                        shortDistance = currentDistance;
                        nMasterGroup = 0;
                        nMasterIndex = i;
                        existsMAsterPOI = YES;
                    }
                }
            } // end - tile_info
            
            // 터치된 타일 주변 8개 타일에 존재하는 POI 검색
            if ( [[oneTouchPOI allKeys] containsObject:@"NEARTILE_INFO"] )
            {
                NSArray *array_neartile = [oneTouchPOI objectForKeyGC:@"NEARTILE_INFO"];
                for (int i = 0; i < array_neartile.count; i++)
                {
                    NSMutableDictionary *dic = [array_neartile objectAtIndexGC:i];
                    Coord c = CoordMake([[dic objectForKeyGC:@"X"] doubleValue], [[dic objectForKeyGC:@"Y"] doubleValue]);
                    double currentDistance = CoordDistance(mc.kmap.lastLongTapCoordinate, c);
                    if (currentDistance < shortDistance)
                    {
                        shortDistance = currentDistance;
                        nMasterGroup = 1;
                        nMasterIndex = i;
                        existsMAsterPOI = YES;
                    }
                }
            } // end - neartile_info
        }
        
        // 최단거리 결정된 POI 정보조회
        if (existsMAsterPOI)
        {
            //existsMAsterPOI = YES;
            
            NSMutableDictionary *mdic = nil;
            if (nMasterGroup == 0)
            {
                //mdic = [array_tile objectAtIndexGC:nMasterIndex];
                mdic = [[[oms.oneTouchPOIDictionary objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"TILE_INFO"] objectAtIndexGC:nMasterIndex];
            }
            else if (nMasterGroup == 1)
            {
                //mdic = [array_neartile objectAtIndexGC:nMasterIndex];
                mdic = [[[oms.oneTouchPOIDictionary objectForKeyGC:@"RESULTDATA"] objectForKeyGC:@"NEARTILE_INFO"] objectAtIndexGC:nMasterIndex];
            }
            NSString *strName =  [mdic objectForKeyGC:@"NAME"];
            NSString *strAddr = [mdic objectForKeyGC:@"ADDR"];
            NSString *strID = [mdic objectForKeyGC:@"MST_ID"];
            // TR인경우 지하철/버스 구분을 위해 일단 RAW처리해둔다.
            NSString *strType = [NSString stringWithFormat:@"%@", stringValueOfDictionary(mdic, @"ORG_DB_TYPE")];
            if ([strType isEqualToString:@"TR"]) strType = @"TR_RAW";
            NSString *strTel = [NSString stringWithFormat:@"%@", stringValueOfDictionary(mdic, @"TEL")];
            if ( [strTel isEqualToString:@"<null>"] ) strTel = [NSString string];
            
            Coord c = CoordMake([[mdic objectForKeyGC:@"X"] doubleValue], [[mdic objectForKeyGC:@"Y"] doubleValue]);
            
            [oms.searchResultOneTouchPOI setUsed:YES];
            [oms.searchResultOneTouchPOI setIsCurrentLocation:NO];
            [oms.searchResultOneTouchPOI setCoordLocationPoint:c];
            [oms.searchResultOneTouchPOI setStrLocationName:strName];
            [oms.searchResultOneTouchPOI setStrLocationAddress:strAddr];
            [oms.searchResultOneTouchPOI setStrID:strID];
            [oms.searchResultOneTouchPOI setStrType:strType];
            [oms.searchResultOneTouchPOI setStrTel:strTel];
            
            //[OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@ %@ %@ %@", strName, strAddr, strID, strType]];
            
            //[self pinnedPointOverlay:YES];
            [self pinLongtapPOIOverlay:YES];
        }
        
        // 마스터 타일이 존재하지 않을 경우 현재터치좌표 주소 사용
        else //if (!existsMAsterPOI)
        {
            // 리버스 지오코딩 이용해서 현재 선택지점을 POI로 사용
            [self requestReversGeocodingAddress:[MapContainer sharedMapContainer_Main].kmap.lastLongTapCoordinate geoType:1];
        }
        
    }
    // 검색중 오류가 리턴된 경우
    else if ( [request finishCode] == OMSRFinishCode_Error_Parser)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithExceptionParser", @"")];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    
}

- (void) didFinishRequestPOISimpleInfo :(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        NSString *strType = [NSString stringWithFormat:@"%@", [oms.poiDetailDictionary objectForKeyGC:@"ORG_DB_TYPE"]];
        NSString *strTheme = [NSString stringWithFormat:@"%@", [oms.poiDetailDictionary objectForKeyGC:@"POI_THEME_CODE"]];
        NSString *strID = [NSString stringWithFormat:@"%@", [oms.poiDetailDictionary objectForKeyGC:@"ORG_DB_ID"]];
        
        // 지하철
        if ( [strType isEqualToString:@"TR"] && [strTheme rangeOfString:@"0406"].length > 0 )
        {
            // Normal or SingplePOI 인 경우 omsr 에 기록
            if ( _nMapRenderType == MapRenderType_Normal )
            {
            }
            else if ( _nMapRenderType == MapRenderType_SearchResult_SinglePOI )
            {
            }
            // MultiPOIU 인경우 poiDic에 기록
            else if (_nMapRenderType == MapRenderType_SearchResult_MultiPOI && _selectedMultiPOIIndex >= 0)
            {
                NSMutableDictionary *poiDic = [_refinedMultiPOIList objectAtIndexGC:_selectedMultiPOIIndex];
                [poiDic setObject:@"TR" forKey:@"Type"];
                [poiDic setObject:strID forKey:@"ID"];
            }
            // 원티치 POI 인경우
            else if (_selectedMultiPOIIndex == -2)
            {
                [oms.searchResultOneTouchPOI setStrType:@"TR"];
                [oms.searchResultOneTouchPOI setStrID:strID];
            }
            
            [[ServerConnector sharedServerConnection] requestSubStation:self action:@selector(didFinishRequestSubwayDetail:) stationId:[oms.poiDetailDictionary objectForKeyGC:@"ORG_DB_ID"]];
        }
        // 버스
        else if ( [strType isEqualToString:@"TR"] && [strTheme rangeOfString:@"0407"].length > 0 )
        {
            // Normal or SingplePOI 인 경우 omsr 에 기록
            if ( _nMapRenderType == MapRenderType_Normal )
            {
            }
            else if ( _nMapRenderType == MapRenderType_SearchResult_SinglePOI )
            {
            }
            // MultiPOIU 인경우 poiDic에 기록
            else if (_nMapRenderType == MapRenderType_SearchResult_MultiPOI && _selectedMultiPOIIndex >= 0)
            {
                NSMutableDictionary *poiDic = [_refinedMultiPOIList objectAtIndexGC:_selectedMultiPOIIndex];
                [poiDic setObject:@"TR_BUS" forKey:@"Type"];
                [poiDic setObject:strID forKey:@"ID"];
            }
            // 원티치 POI 인경우
            else if (_selectedMultiPOIIndex == -2)
            {
                [oms.searchResultOneTouchPOI setStrType:@"TR_BUS"];
                [oms.searchResultOneTouchPOI setStrID:strID];
            }
            
            [[ServerConnector sharedServerConnection] requestBusStationInfoStid:self action:@selector(didFinishRequestBusDetail:) stId:[oms.poiDetailDictionary objectForKeyGC:@"ORG_DB_ID"]];
        }
        // 아무것도 걸리지 않을 경우
        else
        {
            [[ServerConnector sharedServerConnection] requestPoiDetailAtPoiId:self action:@selector(didFinishRequestAllPOIDetail:) poiId:strID isSimple:0];
        }
        
        
    }
}
// 지하철상세 UI콜백
-(void)didFinishRequestSubwayDetail:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        if([oms.subwayDetailDictionary count] <= 0)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
        }
        else
        {
            SubwayPOIDetailViewController *spdvc = [[SubwayPOIDetailViewController alloc] initWithNibName:@"SubwayPOIDetailViewController" bundle:nil];
            [[OMNavigationController sharedNavigationController] pushViewController:spdvc animated:NO];
            [spdvc release];
        }
    }
    // 검색중 오류가 리턴된 경우
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    
}
// 버스정류장상세 UI콜백
- (void) didFinishRequestBusDetail:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        if ([oms.busStationNewDictionary count] <= 0)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
        }
        else
        {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:[oms.busStationNewDictionary objectForKeyGC:@"stid"] forKey:@"STID"];
            [oms.pushDataBusStationArray addObject:dic];
            BusStationDetailViewController *bspdvc = [[BusStationDetailViewController alloc] initWithNibName:@"BusStationDetailViewController" bundle:nil];
            [[OMNavigationController sharedNavigationController] pushViewController:bspdvc animated:NO];
            [bspdvc release];
        }
    }
    // 검색중 오류가 리턴된 경우
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}

- (void) didFinishRequestAllPOIDetail :(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        NSMutableDictionary *additionalInfo = nil;
        for (Overlay *currentOverlay in [MapContainer sharedMapContainer_Main].kmap.getOverlays)
        {
            if ( [currentOverlay isMemberOfClass:[OMUserOverlayMarkerOptionTitle class]] )
            {
                OMUserOverlayMarkerOptionTitle *currentMarkerOptionTitleOverlay = (OMUserOverlayMarkerOptionTitle*)currentOverlay;
                additionalInfo = currentMarkerOptionTitleOverlay.additionalInfo;
                break;
            }
        }
        NSString *detailType = stringValueOfDictionary(additionalInfo, @"Type");
        
        // 상세정보 존재여부 판단
        BOOL hasDetailInfo = NO;
        if ( [detailType isEqualToString:@"TR"] )
        {
            hasDetailInfo = [oms.subwayDetailDictionary count] > 0;
        }
        else if ( [detailType isEqualToString:@"TR_BUS"] )
        {
            hasDetailInfo = [oms.busStationNewDictionary count] > 0;
        }
        // ver3 ktx 가 타입은 TR인데 ID는 MP로 옴 ㅡㅡ
        else if ([detailType isEqualToString:@"TR_RAW"])
        {
            hasDetailInfo = [oms.poiDetailDictionary count] > 0;
            detailType = @"MP";
        }
        else
        {
            hasDetailInfo = [oms.poiDetailDictionary count] > 0;
        }
        
        
        // 멀티POI 검색결과 지도에서 무료통화조회
        if (_nMapRenderType == MapRenderType_SearchResult_MultiPOI && _selectedMultiPOIIndex >= 0)
        {
            NSDictionary *poiDic = [_refinedMultiPOIList objectAtIndexGC:_selectedMultiPOIIndex];
            [oms.searchLocalDictionary setObject:[poiDic objectForKeyGC:@"STHEME_CODE"] forKey:@"LastExtendFreeCall"];
        }
        // 단일 검색결과 지도에서 무료통화 조회 - 일반/최근/즐겨찾기/지도
        else if ( _nMapRenderType == MapRenderType_SearchResult_SinglePOI)
        {
            if ( oms.searchResult.strSTheme )
                [oms.searchLocalDictionary setObject:oms.searchResult.strSTheme forKey:@"LastExtendFreeCall"];
            else
                [oms.searchLocalDictionary setObject:@"0" forKey:@"LastExtendFreeCall"];    
        }
        else if (_nMapRenderType == MapRenderType_SearchResult_LinePolyGon)
        {
            if( oms.searchResult.strShape)
                [oms.searchLocalDictionary setObject:oms.searchResult.strShape forKey:@"LastExtendShapeType"];
            
            if( oms.searchResult.strShapeFcNm)
                [oms.searchLocalDictionary setObject:oms.searchResult.strShapeFcNm forKey:@"LastExtendFCNM"];
            
            if( oms.searchResult.strShapeIdBgm)
                [oms.searchLocalDictionary setObject:oms.searchResult.strShapeIdBgm forKey:@"LastExtendIDBGM"];
            
            [oms.searchLocalDictionary setObject:@"0" forKey:@"LastExtendFreeCall"];
        }
        else
        {
            [oms.searchLocalDictionary setObject:@"" forKey:@"LastExtendShapeType"];
            [oms.searchLocalDictionary setObject:@"" forKey:@"LastExtendFCNM"];
            [oms.searchLocalDictionary setObject:@"" forKey:@"LastExtendIDBGM"];
            [oms.searchLocalDictionary setObject:@"0" forKey:@"LastExtendFreeCall"];
        }
        
        // MIK.geun :: 20121017 // 테마이면서, 무료통화 테마인경우 하드코딩
        if ( [MapContainer sharedMapContainer_Main].kmap.theme
            && [stringValueOfDictionary([ThemeCommon sharedThemeCommon].additionalInfo, @"MainThemeCode") isEqualToString:@"PG1201000000008"] )
        {
            for (Overlay *overlay in [MapContainer sharedMapContainer_Main].kmap.getOverlays)
            {
                if ( [overlay isKindOfClass:[OMImageOverlayTheme class]] )
                {
                    if ( ((OMImageOverlayTheme*)overlay).selected )
                    {
                        [oms.searchLocalDictionary setObject:@"PG1201000000008" forKey:@"LastExtendFreeCall"];
                        break;
                    }
                }
            }
        }
        
        
        if (hasDetailInfo == NO)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
        }
        else if ([detailType isEqualToString:@"MP"])
        {
            // 공유 url 수정 130912
            // 새로운 공유 url 에서는 웹에서 앱을 호출 시 MP MV OL 을 구분하지 않고 그냥 다 MP로 줘서 영화관, 주유소 같은게 전부 MP로 들어와서 일반상세 dic에서 타입을 다시 비교
            NSString *requestType = [oms.poiDetailDictionary objectForKeyGC:@"ORG_DB_TYPE"];
            
            NSLog(@"requestType : %@, detailType : %@", requestType, detailType);
            
            if(![requestType isEqualToString:detailType] && [requestType isEqualToString:@"MV"])
            {
                MoviePOIDetailViewController *vc = [[MoviePOIDetailViewController alloc] initWithNibName:@"MoviePOIDetailViewController" bundle:nil];
                NSString *shareName = stringValueOfDictionary(additionalInfo, @"Name");
                [vc setThemeToDetailName:shareName];
                [vc setDisplayMapBtn:_nMapRenderType == MapRenderType_Normal];
                [vc setDisplayMapBtn:NO];
                [[OMNavigationController sharedNavigationController] pushViewController:vc animated:NO];
                [vc release];
            }
            else if(![requestType isEqualToString:detailType] && [requestType isEqualToString:@"OL"])
            {
                OilPOIDetailViewController *vc = [[OilPOIDetailViewController alloc] initWithNibName:@"OilPOIDetailViewController" bundle:nil];
                [vc setDisplayMapBtn:_nMapRenderType == MapRenderType_Normal];
                [vc setDisplayMapBtn:NO];
                [[OMNavigationController sharedNavigationController] pushViewController:vc animated:NO];
                [vc release];
            }
            else
            {
                //[OMMessageBox showAlertMessage:oms.searchResultOneTouchPOI.strType :@"POI 조회 완료"];
                GeneralPOIDetailViewController *vc = [[GeneralPOIDetailViewController alloc] initWithNibName:@"GeneralPOIDetailViewController" bundle:nil];
                [vc setDisplayMapBtn:_nMapRenderType == MapRenderType_Normal];
                [vc setDisplayMapBtn:NO];
            
                NSString *shareName = stringValueOfDictionary(additionalInfo, @"Name");
            
                NSLog(@"%@", shareName);
                [vc setThemeToDetailName:shareName];
            
                [[OMNavigationController sharedNavigationController] pushViewController:vc animated:NO];
                [vc release];
            }

        }
        else if ([detailType isEqualToString:@"MV"])
        {
            //[OMMessageBox showAlertMessage:oms.searchResultOneTouchPOI.strType :@"POI 조회 완료"];
            MoviePOIDetailViewController *vc = [[MoviePOIDetailViewController alloc] initWithNibName:@"MoviePOIDetailViewController" bundle:nil];
            NSString *shareName = stringValueOfDictionary(additionalInfo, @"Name");
            [vc setThemeToDetailName:shareName];
            [vc setDisplayMapBtn:_nMapRenderType == MapRenderType_Normal];
            [vc setDisplayMapBtn:NO];
            [[OMNavigationController sharedNavigationController] pushViewController:vc animated:NO];
            [vc release];
        }
        else if ([detailType isEqualToString:@"OL"])
        {
            OilPOIDetailViewController *vc = [[OilPOIDetailViewController alloc] initWithNibName:@"OilPOIDetailViewController" bundle:nil];
            [vc setDisplayMapBtn:_nMapRenderType == MapRenderType_Normal];
            [vc setDisplayMapBtn:NO];
            [[OMNavigationController sharedNavigationController] pushViewController:vc animated:NO];
            [vc release];
        }
        else if ([detailType isEqualToString:@"TR"])
        {
            //[OMMessageBox showAlertMessage:oms.searchResultOneTouchPOI.strType :@"POI 조회 완료"];
            SubwayPOIDetailViewController *vc = [[SubwayPOIDetailViewController alloc] initWithNibName:@"SubwayPOIDetailViewController" bundle:nil];
            [vc setDisplayMapBtn:_nMapRenderType == MapRenderType_Normal];
            [vc setDisplayMapBtn:NO];
            [[OMNavigationController sharedNavigationController] pushViewController:vc animated:NO];
            [vc release];
        }
        else if ([detailType isEqualToString:@"TR_BUS"])
        {
            BusStationDetailViewController *vc = [[BusStationDetailViewController alloc] initWithNibName:@"BusStationDetailViewController" bundle:nil];
            [vc setDisplayMapBtn:_nMapRenderType == MapRenderType_Normal];
            [vc setDisplayMapBtn:NO];
            [[OMNavigationController sharedNavigationController] pushViewController:vc animated:NO];
            [vc release];
        }
        else
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_POI_DetailView_NothingInfo", @"")];
        }
    }
    // 검색중 오류가 리턴된 경우
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}

- (void) didFinishRequestShortURL:(id)request
{
    
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        //OMSearchResult *omsr = [self getCurrentSearchResult];
        
        OMButton *shareButton = (OMButton*)[request userObject];
        
        [oms.shareDictionary setObject:stringValueOfDictionary(shareButton.additionalInfo, @"Name") forKey:@"NAME"];
        [oms.shareDictionary setObject:stringValueOfDictionary(shareButton.additionalInfo, @"Address") forKey:@"ADDR"];
        [oms.shareDictionary setObject:stringValueOfDictionary(shareButton.additionalInfo, @"Tel") forKey:@"TEL"];
        
        // 20130227 타입,id,좌표도 shareDic에 추가
        [oms.shareDictionary setObject:stringValueOfDictionary(shareButton.additionalInfo, @"Type") forKey:@"POI_TYPE"];
        [oms.shareDictionary setObject:stringValueOfDictionary(shareButton.additionalInfo, @"ID") forKey:@"POI_ID"];
        [oms.shareDictionary setObject:stringValueOfDictionary(shareButton.additionalInfo, @"X") forKey:@"POI_X"];
        [oms.shareDictionary setObject:stringValueOfDictionary(shareButton.additionalInfo, @"Y") forKey:@"POI_Y"];
        
        [ShareViewController sharePopUpView:self.view];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_ShortURL_NotResponse", @"")];
    }
}


- (void) didFinishRequestThemeSearch:(id)requst
{
    if ( [requst finishCode] == OMSRFinishCode_Completed )
    {
        // MIK.geun :: 20121004 // 동일 버튼 연타로 인해 검색결과 받기 이전에 다시 버튼 비활성화 됐을 경우..
        if ( [MapContainer sharedMapContainer_Main].kmap.theme )
        {
            
            NSTimeInterval requestTime =[[[_themesRequestInfo objectForKeyGC:@"Theme"] objectForKeyGC:@"Time"] doubleValue];
            
            // 검색요청좌표가 일치하거나, 최초 검색시작 좌표이거나...
            // **테마화면에서 지도로 넘어오면서 위치정보 다시 활성화 시키면서 좌표가 3~4번 흔들리는 이유때문에 보정;;;
            if ( requestTime == _themeLastRequestTime )
            {
                [self pinThemePOIOverlay:YES];
            }
            else
            {
            }
        }
    }
    else
    {
        /*
         // 네트워크 오류 발생시 오류메세지 노출할까?? 토스트 팝업으로 처리할까??
         // 메세지 조합하기
         NSString *message = NSLocalizedString(@"Msg_SearchFailedWithException", @"");
         // 토스트 띄우기
         [[OMToast sharedToast] showToastMessagePopup:message superView:self.view maxBottomPoint:self.vwCurrentAddressGroup.frame.origin.y-10 autoClose:YES];
         */
    }
    
}

// **********************


// ====================
// [ 네비게이션 메소드 ]
// ====================
- (void) navGoToRootView:(id)sender
{
    // 뒤로가기/루트로가기일 경우 singlePOI/multiPOI 인경우이므로 기존 오버레이를 제거하도록 한다.
    //[[MapContainer sharedMapContainer_Main].kmap removeAllOverlays];
    [[MapContainer sharedMapContainer_Main].kmap removeAllOverlaysWithoutTraffic];
    
    [[OMNavigationController sharedNavigationController] popToRootViewControllerAnimated:NO];
}
- (void) navGoToPrevView:(id)sender
{
    // 뒤로가기/루트로가기일 경우 singlePOI/multiPOI 인경우이므로 기존 오버레이를 제거하도록 한다. (교통옵션 제외)
    [[MapContainer sharedMapContainer_Main].kmap removeAllOverlaysWithoutTraffic];
    // 선택된 오버레이가 남아있을 경우 전부 해제해버린다.
    [[MapContainer sharedMapContainer_Main].kmap selectPOIOverlay:nil];
    
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}
// ********************

// ======================
// [ 지도교통옵션 메소드 ]
// ======================

- (void) showMapTrafficOptionView:(BOOL)show
{
    [self showMapTrafficOptionView:show currentMapContainer:[MapContainer sharedMapContainer_Main] currentMapViewController:self];
}
- (void) onOptionViewCloseButton:(id)sender
{
    [super onOptionViewCloseButton:sender];
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    // 창이 닫힐 시점에.. 교통옵션 버튼 선택여부 처리..
    _btnSideTraffic.selected = mc.kmap.trafficInfo || mc.kmap.trafficCCTV || mc.kmap.trafficBusStation || mc.kmap.trafficSubwayStation || mc.kmap.CadastralInfo;
}
// 지적도 보기 메서드
- (void) onOPtionViewUseTrafficAddress:(id)sender
{
    // 부모 클래스 인스턴스 메소드에는 아무동작 없음.
    [super onOPtionViewUseTrafficAddress:sender];
    
    // 실제구현은 여기부터 시작
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    // HD지도는 지적도 지원안함
    if(mc.kmap.mapDisplay == KMapDisplayHD)
    {
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"알림" message:@"지적편집도는 HD모드에서\n 제공되지 않습니다.\n설정 > 지도해상도 에서 다른 지도모드로 변경해 주세요" delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
//        [alert show];
//        [alert release];
        
        UIView *popUpDimmedView =[[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                          [[UIScreen mainScreen] bounds].size.width,
                                                                          [[UIScreen mainScreen] bounds].size.height
                                                                          - 20
                                                                          - ([[UIApplication sharedApplication] statusBarFrame].size.height-20) )];
        [popUpDimmedView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight];
        [popUpDimmedView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.5]];
        [popUpDimmedView setTag:4314];
        
        UIView *closePopupView = [[UIView alloc] init];
        [closePopupView setFrame:CGRectMake(37, 87, 246, 191)];
        
        
        UIImageView *closePopupBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_bg_08.png"]];
        [closePopupBg setFrame:CGRectMake(0, 0, 246, 191)];
        [closePopupView addSubview: closePopupBg];
        [closePopupBg release];
        
        UILabel *closeLabel = [[UILabel alloc] init];
        [closeLabel setFrame:CGRectMake(0, 15, 246, 98)];
        [closeLabel setNumberOfLines:0];
        [closeLabel setFont:[UIFont systemFontOfSize:16]];
        [closeLabel setText:@"지적편집도는 HD모드에서\n제공되지 않습니다.\n설정 > 지도 해상도에서\n다른 지도 모드로 변경해 주세요"];
        [closeLabel setBackgroundColor:[UIColor clearColor]];
        [closeLabel setTextAlignment:NSTextAlignmentCenter];
        [closePopupView addSubview:closeLabel];
        [closeLabel release];
        
        UIButton *closePopUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closePopUpBtn setImage:[UIImage imageNamed:@"popup_btn_close"] forState:UIControlStateNormal];
        [closePopUpBtn setFrame:CGRectMake(88, 140, 70, 31)];
        [closePopUpBtn addTarget:self action:@selector(dimmedPopUpClose:) forControlEvents:UIControlEventTouchUpInside];
        [closePopupView addSubview:closePopUpBtn];
        
        [popUpDimmedView addSubview:closePopupView];
        
        [closePopupView release];
        
        [self.view addSubview:popUpDimmedView];

        return;
    }
    
    // 버튼 매칭
    UIButton *trafficAddressButton = (UIButton*)sender;
    [trafficAddressButton setSelected:!trafficAddressButton.selected];
    [self.btnBottomLegend setHidden:!trafficAddressButton.selected];
    
    
    // 실시간 켜져있으면 디스플레이 닫음
    if(mc.kmap.trafficInfo)
    {
        // 실시간 교통량 닫는다
        [mc.kmap setTrafficInfo:!trafficAddressButton.selected clearCache:YES];
        [_vwTrafficGroup setHidden:!mc.kmap.trafficInfo];
        
    
    }

    
    [mc.kmap setCadastralInfo:trafficAddressButton.selected];
    
    // 옵션뷰 새로 그리기
    [self refreshMapTrafficOptionView];
}
- (void) dimmedPopUpClose:(id)sender
{
    UIView *parentView = [self.view viewWithTag:4314];
    
    for (UIView *view in parentView.subviews) {
        [view removeFromSuperview];
    }
    [parentView removeFromSuperview];
}
- (void) onOptionViewUseTrafficInfo:(id)sender
{
    // 부모 클래스 인스턴스 메소드에는 아무동작 없음.
    [super onOptionViewUseTrafficInfo:sender];
    
    // 실제구현은 여기부터 시작
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    // 버튼 매칭
    UIButton *trafficInfoButton = (UIButton*)sender;
    [trafficInfoButton setSelected:!trafficInfoButton.selected];
    
    // 지적도 닫는다
    [mc.kmap setCadastralInfo:!trafficInfoButton.selected];
    
    if(mc.kmap.CadastralInfo == NO)
       [self.btnBottomLegend setHidden:YES];
    
    // 지도 교통량 처리
    [mc.kmap setTrafficInfo:trafficInfoButton.selected clearCache:YES];
    
    // 지도 교통량 뷰 디스플레이
    [_vwTrafficGroup setHidden:!trafficInfoButton.selected];
    
    // 옵션뷰 새로 그리기
    [self refreshMapTrafficOptionView];
}
- (void) onOptionViewUseTrafficCCTV:(id)sender
{
    // 부모 클래스 인스턴스 메소드에는 아무동작 없음.
    [super onOptionViewUseTrafficCCTV:sender];
    
    // 실제 구현은 여기서부터 시작
    UIButton *trafficCCTVButton = (UIButton*)sender;
    [trafficCCTVButton setSelected:!trafficCCTVButton.selected];
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    [mc.kmap setTrafficCCTV:trafficCCTVButton.selected];
    [mc.kmap setTrafficBusStation:NO];
    [mc.kmap setTrafficSubwayStation:NO];
    
    // 뭔가 새로그리는 단계가 필요함 (검색을 위한 인디케이터활성화 된상태라 고민하지는 말자.)
    [mc.kmap removeAllTrafficOverlayWithoutLinePoly];
    
    // 교통실시간 정보 처리
    BOOL overlaySelected = NO;
    if ( !_vwRealtimeTrafficTimeTableContainer.hidden ) // 실시간 정보 활성화되어 있을 경우
        for (Overlay *overlay in mc.kmap.getOverlays)       // 오버레이를 검색해서..
        {
            if ( [overlay isKindOfClass:[OMImageOverlay class]] && ((OMImageOverlay*)overlay).selected ) // 선택된 오버레이가 존재하는지 체크..
            {
                overlaySelected = YES;
                break;
            }
        }
    if ( !overlaySelected ) // 존재하지 않는다면 실시간정보도 닫기
    {
        [self clearRealtimeTrafficTimeTable];
    }
    
    // 그려지는 지점을 미리 맞춰줌.. 검색중... 살짝 움직여서 다시 검색하는일 없도록.. (최초값이 0,0일수있음.)
    _trafficOptionLastRenderCoordinate = mc.kmap.centerCoordinate;
    // 검색/렌더링 전 검증을 위한 정보 처리
    _trafficOptionLastRequestTime = [NSDate timeIntervalSinceReferenceDate];
    NSMutableDictionary *traffic = [[NSMutableDictionary alloc] init];
    [traffic setObject:[NSNumber numberWithInt:1] forKey:@"Type"];
    [traffic setObject:[NSNumber numberWithBool:YES] forKey:@"IsZoom"];
    [traffic setObject:[NSNumber numberWithDouble:_trafficOptionLastRequestTime] forKey:@"Time"];
    [_themesRequestInfo setObject:traffic forKey:@"Traffic"];
    [traffic release];
    
    // CCTV 검색시도
    if ( mc.kmap.trafficCCTV  && mc.kmap.adjustZoomLevel >= 4 ) // 6km == zoom 4
    {
        Coord utmkMinCoord = [mc.kmap convertPoint:CGPointMake(-50, -50)];
        Coord utmkMaxCoord = [mc.kmap convertPoint:CGPointMake(self.view.frame.size.width+50, self.view.frame.size.height+50)];
        Coord wgsMinCoord = [mc.kmap convertCoordinate:utmkMinCoord inCoordType:KCoordType_UTMK outCoordType:KCoordType_WGS84];
        Coord wgsMaxCoord = [mc.kmap convertCoordinate:utmkMaxCoord inCoordType:KCoordType_UTMK outCoordType:KCoordType_WGS84];
        
        [[ServerConnector sharedServerConnection] requestTrafficOptionCCTVList:self action:@selector(finishTrafficOptionCCTVList:) minX:wgsMinCoord.x minY:wgsMinCoord.y maxX:wgsMaxCoord.x maxY:wgsMaxCoord.y];
    }
    
    // 옵션뷰 새로 그리기
    [self refreshMapTrafficOptionView];
}
- (void) onOptionViewUseTrafficBusStation:(id)sender
{
    // 부모 클래스 인스턴스 메소드에는 아무동작 없음.
    [super onOptionViewUseTrafficBusStation:sender];
    
    // 실제 구현은 여기서부터 시작
    UIButton *trafficBusStationButton = (UIButton*)sender;
    [trafficBusStationButton setSelected:!trafficBusStationButton.selected];
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    [mc.kmap setTrafficCCTV:NO];
    [mc.kmap setTrafficBusStation:trafficBusStationButton.selected];
    [mc.kmap setTrafficSubwayStation:NO];
    
    // 뭔가 새로그리는 단계가 필요함 (검색을 위한 인디케이터활성화 된상태라 고민하지는 말자.)
    [mc.kmap removeAllTrafficOverlay];
    
    // 교통실시간 정보 처리
    BOOL overlaySelected = NO;
    if ( !_vwRealtimeTrafficTimeTableContainer.hidden ) // 실시간 정보 활성화되어 있을 경우
        for (Overlay *overlay in mc.kmap.getOverlays)       // 오버레이를 검색해서..
        {
            if ( [overlay isKindOfClass:[OMImageOverlay class]] && ((OMImageOverlay*)overlay).selected ) // 선택된 오버레이가 존재하는지 체크..
            {
                overlaySelected = YES;
                break;
            }
        }
    if ( !overlaySelected ) // 존재하지 않는다면 실시간정보도 닫기
    {
        [self clearRealtimeTrafficTimeTable];
    }
    
    // 그려지는 지점을 미리 맞춰줌.. 검색중... 살짝 움직여서 다시 검색하는일 없도록.. (최초값이 0,0일수있음.)
    _trafficOptionLastRenderCoordinate = mc.kmap.centerCoordinate;
    // 검색/렌더링 전 검증을 위한 정보 처리
    _trafficOptionLastRequestTime = [NSDate timeIntervalSinceReferenceDate];
    NSMutableDictionary *traffic = [[NSMutableDictionary alloc] init];
    [traffic setObject:[NSNumber numberWithInt:1] forKey:@"Type"];
    [traffic setObject:[NSNumber numberWithBool:YES] forKey:@"IsZoom"];
    [traffic setObject:[NSNumber numberWithDouble:_trafficOptionLastRequestTime] forKey:@"Time"];
    [_themesRequestInfo setObject:traffic forKey:@"Traffic"];
    [traffic release];
    
    // 버스정류장 검색 시작
    if ( mc.kmap.trafficBusStation && mc.kmap.adjustZoomLevel >= 9 ) // 200m == zoom 9
    {
        [[ServerConnector sharedServerConnection] requestTrafficOptionBusStationList:self action:@selector(finishTrafficOptionBusStationList:) coordidate:mc.kmap.centerCoordinate radius:mc.getCurrentMapZoomLevelMeterWithScreen/2];
    }
    
    // 옵션뷰 새로 그리기
    [self refreshMapTrafficOptionView];
}
- (void) onOptionViewUseTrafficSubwayStation:(id)sender
{
    // 부모 클래스 인스턴스 메소드에는 아무동작 없음.
    [super onOptionViewUseTrafficSubwayStation:sender];
    
    // 실제 구현은 여기서부터 시작
    UIButton *trafficSubwayStationButton = (UIButton*)sender;
    [trafficSubwayStationButton setSelected:!trafficSubwayStationButton.selected];
    
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    [mc.kmap setTrafficCCTV:NO];
    [mc.kmap setTrafficBusStation:NO];
    [mc.kmap setTrafficSubwayStation:trafficSubwayStationButton.selected];
    
    // 뭔가 새로그리는 단계가 필요함 (검색을 위한 인디케이터활성화 된상태라 고민하지는 말자.)
    [mc.kmap removeAllTrafficOverlay];
    
    // 교통실시간 정보 처리
    BOOL overlaySelected = NO;
    if ( !_vwRealtimeTrafficTimeTableContainer.hidden ) // 실시간 정보 활성화되어 있을 경우
        for (Overlay *overlay in mc.kmap.getOverlays)       // 오버레이를 검색해서..
        {
            if ( [overlay isKindOfClass:[OMImageOverlay class]] && ((OMImageOverlay*)overlay).selected ) // 선택된 오버레이가 존재하는지 체크..
            {
                overlaySelected = YES;
                break;
            }
        }
    if ( !overlaySelected ) // 존재하지 않는다면 실시간정보도 닫기
    {
        [self clearRealtimeTrafficTimeTable];
    }
    
    // 그려지는 지점을 미리 맞춰줌.. 검색중... 살짝 움직여서 다시 검색하는일 없도록.. (최초값이 0,0일수있음.)
    _trafficOptionLastRenderCoordinate = mc.kmap.centerCoordinate;
    // 검색/렌더링 전 검증을 위한 정보 처리
    _trafficOptionLastRequestTime = [NSDate timeIntervalSinceReferenceDate];
    NSMutableDictionary *traffic = [[NSMutableDictionary alloc] init];
    [traffic setObject:[NSNumber numberWithInt:1] forKey:@"Type"];
    [traffic setObject:[NSNumber numberWithBool:YES] forKey:@"IsZoom"];
    [traffic setObject:[NSNumber numberWithDouble:_trafficOptionLastRequestTime] forKey:@"Time"];
    [_themesRequestInfo setObject:traffic forKey:@"Traffic"];
    [traffic release];
    
    // 검색시작
    if (mc.kmap.trafficSubwayStation && mc.kmap.adjustZoomLevel >= 7 ) // 800m == zoom 7
        [[ServerConnector sharedServerConnection] requestTrafficOptionSubwayStationList:self action:@selector(finishTrafficOptionSubwayStationList:) coordidate:mc.kmap.centerCoordinate radius:mc.getCurrentMapZoomLevelMeterWithScreen/2];
    
    // 옵션뷰 새로 그리기
    [self refreshMapTrafficOptionView];
}
- (void) refreshMapTrafficOptionView
{
    // 기존 옵션뷰 지웟다가
    [self showMapTrafficOptionView:NO];
    // 옵션뷰 새로 그리기.. -  끝.. 참~~쉽죠~~잉...
    [self showMapTrafficOptionView:YES];
}


- (void) finishTrafficOptionCCTVList :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        NSLog(@"CCTV 목록 검색 - 성공...");
        // MIK.geun :: 20121004 // 동일 버튼 연타로 인해 검색결과 받기 이전에 다시 버튼 비활성화 됐을 경우..
        if ( [MapContainer sharedMapContainer_Main].kmap.trafficCCTV )
        {
            NSTimeInterval requestTime = [[[_themesRequestInfo objectForKeyGC:@"Traffic"] objectForKeyGC:@"Time"] doubleValue];
            
            if ( requestTime == _trafficOptionLastRequestTime )
            {
                [self pinTrafficOptionCCTVPOIOverlay:request];
                [self redrawMarkerOptionOverlayOnFront];
            }
        }
    }
    else
    {
        // 과연 오류가 발생했는데 메세지를 띄울것이냐???
        NSLog(@"CCTV 목록 검색 - 실패...");
    }
    
}
- (void) finishTrafficOptionCCTVInfo :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        NSDictionary *cctvInfo = (NSDictionary*)[request userObject];
        
        NSLog(@"cctvInfo : %@", cctvInfo);
        
        CCTVViewController *cctvVC = [[CCTVViewController alloc] initWithNibName:@"CCTVViewController" bundle:nil];
        [[OMNavigationController sharedNavigationController] pushViewController:cctvVC animated:NO];
        [cctvVC showCCTV:cctvInfo];
        [cctvVC release];
    }
    // 오류발생했을 경우 경고메세지
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}
- (void) finishTrafficOptionBusStationList :(ServerRequester*)request
{
    // 검색 성공여부에 따라 렌더링 처리
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        // MIK.geun :: 20121004 // 동일 버튼 연타로 인해 검색결과 받기 이전에 다시 버튼 비활성화 됐을 경우..
        if ( [MapContainer sharedMapContainer_Main].kmap.trafficBusStation )
        {
            NSTimeInterval requestTime = [[[_themesRequestInfo objectForKeyGC:@"Traffic"] objectForKeyGC:@"Time"] doubleValue];
            
            if ( requestTime == _trafficOptionLastRequestTime )
            {
                [self  pinTrafficOptionBusStationPOIOverlay:request];
                [self redrawMarkerOptionOverlayOnFront];
            }
        }
    }
    else
    {
        // 과연 오류가 발생했는데 메세지를 띄울것이냐???
    }
}
- (void) finishTrafficOptionSubwayStationList :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        // MIK.geun :: 20121004 // 동일 버튼 연타로 인해 검색결과 받기 이전에 다시 버튼 비활성화 됐을 경우..
        if ( [MapContainer sharedMapContainer_Main].kmap.trafficSubwayStation )
        {
            NSTimeInterval requestTime = [[[_themesRequestInfo objectForKeyGC:@"Traffic"] objectForKeyGC:@"Time"] doubleValue];
            
            if ( requestTime == _trafficOptionLastRequestTime )
            {
                [self pinTrafficOptionSubwayPOIOverlay:request];
                [self redrawMarkerOptionOverlayOnFront];
            }
        }
    }
    else
    {
        // 과연 오류가 발생했는데 메세지를 띄울것이냐???
    }
}

- (void) finishTrafficRealtimeBusTimeTable :(ServerRequester*) request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        [self renderRealtimeTrafficBusTimeTable :(NSDictionary*)[request userObject] :[request userString]];
    }
    else
    {
        // 과연 오류가 발생했는데 메세지를 띄울것이냐???
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}
- (void) finishTrafficRealtimeSubwayTimeTable :(ServerRequester*) request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        [self renderRealtimeTrafficSubwayTimeTable :(NSArray*)[request userObject] :[request userString]];
    }
    else
    {
        // 과연 오류가 발생했는데 메세지를 띄울것이냐???
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}
- (void) refreshTrafficRealtimeTimetable :(id)sender
{
    OMButton *refresher = (OMButton*)sender;
    
    if ( [numberValueOfDiction(refresher.additionalInfo, @"IsBus") boolValue] )
    {
        // 버스
        [[ServerConnector sharedServerConnection] requestTrafficRealtimeBusTimeTable:self action:@selector(finishTrafficRealtimeBusTimeTable:) busid:stringValueOfDictionary(refresher.additionalInfo, @"BusID")];
    }
    else
    {
        // 지하철
        [[ServerConnector sharedServerConnection] requestTrafficRealtimeSubwayTimeTable:self action:@selector(finishTrafficRealtimeSubwayTimeTable:) subwayid:stringValueOfDictionary(refresher.additionalInfo, @"SubwayID")];
    }
    
}
- (void) finishPoiDetailForRealtimeTimetable :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        
        NSString *type = stringValueOfDictionary((NSDictionary*)[request userObject], @"ORG_DB_TYPE");
        NSString *theme = stringValueOfDictionary((NSDictionary*)[request userObject], @"POI_THEME_CODE");
        NSString *trafficID = stringValueOfDictionary((NSDictionary*)[request userObject], @"ORG_DB_ID");
        
        // 지하철
        if ( [type isEqualToString:@"TR"] && [theme rangeOfString:@"0406"].length > 0 )
        {
            [[OllehMapStatus sharedOllehMapStatus].searchResultOneTouchPOI setStrType:@"TR"];
            [[ServerConnector sharedServerConnection] requestTrafficRealtimeSubwayTimeTable:self action:@selector(finishTrafficRealtimeSubwayTimeTable:) subwayid:trafficID];
        }
        // 버스
        else if ( [type isEqualToString:@"TR"] && [theme rangeOfString:@"0407"].length > 0 )
        {
            [[OllehMapStatus sharedOllehMapStatus].searchResultOneTouchPOI setStrType:@"TR_BUS"];
            [[ServerConnector sharedServerConnection] requestTrafficRealtimeBusTimeTable:self action:@selector(finishTrafficRealtimeBusTimeTable:) busid:trafficID];
        }
    }
    else
    {
        // 네트워크 오류로 실패한 경우에도 메세지 노출
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}

// ======================

// ======================
// [ IBOulet 메소드 시작 ]
// ======================
-(Coord) tester :(Coord)anotherC pointA:(Coord)lineOnA pointB:(Coord)lineOnB
{
    double xx = 0.0;
    double yy = 0.0;
    
    // Ax와 Bx 가 같을때(y에 평행)
    if(lineOnA.x == lineOnB.x)
    {
        xx = lineOnA.x;
        yy = anotherC.y;
    }
    // Ay와 By 가 같을때(x에 평행)
    else if (lineOnA.y == lineOnB.y)
    {
        xx = anotherC.x;
        yy = lineOnA.y;
    }
    else
    {
        // 직선의 방정식(1) y= m1x + k1
        // 점A와 B를 지나는 직선의 기울기
    double m1 = (lineOnB.y - lineOnA.y)/(lineOnB.x - lineOnA.x);
        //
    double k1 = -m1 * lineOnA.x + lineOnA.y;
    
        // (1)과 직교하고 화면중심을 지나는 직선의 방정식 y= m2x + k2
        // 직교하기 때문에 기울기의 곱은 -1 이됨 m1 * m2 = -1
        double m2 = -1 / m1;
        double k2 = - m2 * anotherC.x + anotherC.y;
    
    // 두 직선의 교점을 찾는다 m1x + k1 = m2x + k2
    xx = (k2-k1) / (m1 - m2);
    yy = m1 * xx + k1;
    }
    Coord returnCrd = CoordMake(xx, yy);
    
    //double dist = CoordDistance(anotherC, returnCrd);
    
    double leftX = lineOnA.x < lineOnB.x ? lineOnA.x : lineOnB.x;
    double rightX = lineOnA.x > lineOnB.x ? lineOnA.x : lineOnB.x;
    double leftY = lineOnA.y < lineOnB.y ? lineOnA.y : lineOnB.y;
    double rightY = lineOnA.y > lineOnB.y ? lineOnA.y : lineOnB.y;
    
    if(SquareIn(leftX, leftY, rightX, rightY, returnCrd.x, returnCrd.y))
    {
        
    }
    else
    {
        double dist1 = CoordDistance(anotherC, lineOnA);
        double dist2 = CoordDistance(anotherC, lineOnB);
        
        if(dist1 < dist2)
            returnCrd = lineOnA;
        else
            returnCrd = lineOnB;
    }
    
    return returnCrd;

}
- (IBAction)clickMyLocationButton:(id)sender
{
    
//    // 오버레이 생성
//    OMImageOverlaySearchSingle *overlay = nil;
//    
//        overlay = [[OMImageOverlaySearchSingle alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_pressed.png"]];
//        overlay.usePOIIcon = NO;
//
//    [overlay setSelected:YES];
//    [overlay setCoord:CoordMake(946254, 1943321)];
//    [overlay setDelegate:self];
//    [[MapContainer sharedMapContainer_Main].kmap addOverlay:overlay];
//    [overlay release];
//    
//    // 오버레이 생성
//    OMImageOverlaySearchSingle *overlay2 = nil;
//    
//    overlay2 = [[OMImageOverlaySearchSingle alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_pressed.png"]];
//    overlay2.usePOIIcon = NO;
//    
//    [overlay2 setSelected:YES];
//    [overlay2 setCoord:CoordMake(946476, 1942983)];
//    [overlay2 setDelegate:self];
//    [[MapContainer sharedMapContainer_Main].kmap addOverlay:overlay2];
//    [overlay2 release];
//    
//    // 오버레이 생성
//    OMImageOverlaySearchSingle *overlay3 = nil;
//    
//    overlay3 = [[OMImageOverlaySearchSingle alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_pressed.png"]];
//    overlay3.usePOIIcon = NO;
//    
//    [overlay3 setSelected:YES];
//    [overlay3 setCoord:CoordMake(946548, 1943251)];
//    [overlay3 setDelegate:self];
//    [[MapContainer sharedMapContainer_Main].kmap addOverlay:overlay3];
//    [overlay3 release];
//    
//    CoordList *vertexList = [[CoordList alloc] init];
//    
//    [vertexList addCoord:overlay.coord];
//    [vertexList addCoord:overlay2.coord];
//    
//    NSLog(@"vertextList : %@", vertexList);
//    // 버스 노선 경로렌더링
//    PolylineOverlay *plOverlay = [[PolylineOverlay alloc] initWithCoordList:vertexList];
//    
//    // 경로 색상
//    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
//    CGColorRef stroke = CGColorCreate(rgb, (CGFloat[]){convertHexToDecimal(@"1A") ,convertHexToDecimal(@"68") ,convertHexToDecimal(@"C9") ,1.0f});
//    plOverlay.strokeColor = stroke;
//    CGColorSpaceRelease(rgb);
//    CFRelease(stroke);
//    // 경로 나머지 설정
//    plOverlay.lineWidth = 5;
//    plOverlay.delegate = self;
//    plOverlay.canShowBalloon = NO;
//    // 오버레이 삽입
//    [[MapContainer sharedMapContainer_Main].kmap addOverlay:plOverlay];
//    // 오버레이 해제
//    [plOverlay release];
//    [vertexList release];
//
//    OMImageOverlaySearchSingle *overlayResult = nil;
//    
//    overlayResult = [[OMImageOverlaySearchSingle alloc] initWithImage:[UIImage imageNamed:@"map_b_marker_pressed.png"]];
//    overlayResult.usePOIIcon = NO;
//    
//    [overlayResult setSelected:YES];
//    [overlayResult setCoord:[self tester:overlay3.coord pointA:overlay.coord pointB:overlay2.coord]];
//    [overlay3 setDelegate:self];
//    [[MapContainer sharedMapContainer_Main].kmap addOverlay:overlayResult];
//    [overlayResult release];
//
//    
//    
//    return;
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    if ( [MapContainer CheckLocationService] )
    {
        // 다음 모드 값 계산
        int nextmode = (oms.currentMapLocationMode + 1) %3;
        // 구해진 다음 모드 값으로 전환
        [self toggleMyLocationMode:nextmode];
    }
    else
    {
        // 위치서비스 사용불가시 무조건 해제처리
        [self toggleMyLocationMode:MapLocationMode_None];
    }
}
-(IBAction)openThemes:(id)sender
{
    // 일단 테마정보 가져오기 전에 단말기 정보 체크
    [[ServerConnector sharedServerConnection] requestDeviceDisplay:self action:@selector(didFinishRequestDeviceDisplayID:)];
}
- (void) didFinishRequestDeviceDisplayID :(id)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        // 일단 테마버전 체크
        [[ServerConnector sharedServerConnection] requestThemeVersion:self action:@selector(didFinishRequestThemeVersion:)];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}
- (void) didFinishRequestThemeVersion:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed && [request userObject] )
    {
        NSDictionary *themeVersionInfo = (NSDictionary*)[request userObject];
        NSLog(@"테마버전 정보 : %@", themeVersionInfo );
        
        NSString *serverThemeVersion = stringValueOfDictionary(themeVersionInfo, @"version");
        NSString *serverThemeUpdate = stringValueOfDictionary(themeVersionInfo, @"update_date");
        
        [[ThemeCommon sharedThemeCommon].additionalInfo setObject:serverThemeVersion forKey:@"ThemeVersion"];
        [[ThemeCommon sharedThemeCommon].additionalInfo setObject:serverThemeUpdate forKey:@"ThemeUpdate"];
        
        NSString *deviceThemeVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"ThemeVersion"];
        NSString *deviceThemeUpdate =[[NSUserDefaults standardUserDefaults] stringForKey:@"ThemeUpdate"];
        
        // 업데이트 필요여부
        BOOL requiredUpdate = NO;
        
        // 테마정보 없음.
        if ( deviceThemeVersion == nil || deviceThemeUpdate == nil )
        {
            requiredUpdate = YES;
        }
        // 테마정보가 구버전임.
        else if ( [serverThemeVersion compare:deviceThemeVersion] != NSOrderedSame
                 || [serverThemeUpdate compare:deviceThemeUpdate] != NSOrderedSame )
        {
            requiredUpdate = YES;
        }
        // 테마정보가 최신버전임.
        else
        {
            requiredUpdate = NO;
        }
        
#ifdef DEBUG
        //requiredUpdate = YES;
#endif
        
        [[ThemeCommon sharedThemeCommon].additionalInfo setObject:[NSNumber numberWithBool:requiredUpdate] forKey:@"RequiredUpdate"];
        
        // 테마 정보 호출
        [[ServerConnector sharedServerConnection] requestThemeInfoList:self action:@selector(didFinishRequestThemeInfoList:) version:serverThemeVersion];
        
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}
- (void) didFinishRequestThemeInfoList:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        BOOL requiredUpdate = [numberValueOfDiction([ThemeCommon sharedThemeCommon].additionalInfo, @"RequiredUpdate") boolValue];
        
        // 업데이트가 필요한 경우 다운로드 먼저 처리
        if ( requiredUpdate)
        {
            [self.view addSubview:  _vwThemeUpdateContainer];
            [_pvwThemeUpdateProgress setProgress:0];
            
            NSArray *imageType = [NSArray arrayWithObjects:@"icon", @"marker_normal", @"marker_down", @"marker_normal_nest", @"marker_down_nest", @"marker_list", nil];
            
            // 테마정보에서 다운로드 이미지 목록 생성
            NSMutableArray *downloadList = [NSMutableArray array];
            for (NSDictionary *themeInfo in [OllehMapStatus sharedOllehMapStatus].themeInfoList)
            {
                for (NSString *type in imageType)
                {
                    NSMutableDictionary *downInfo = [[NSMutableDictionary alloc] init];
                    NSString *filename = [NSString stringWithFormat:@"%@_%@", stringValueOfDictionary(themeInfo, @"code"), type];
                    [downInfo setObject:filename forKey:@"FILENAME"];
                    [downInfo setObject:stringValueOfDictionary(themeInfo, type) forKey:@"URL"];
                    [downloadList addObject:downInfo];
                    [downInfo release];
                }
            }
            
            // 다운로드하기전에 테마이미지 폴더 제거하기
            NSString *documentThemeDirectory = [ThemeCommon getThemeImageDirectory];
            NSError *error = nil;
            BOOL isDirectory = NO;
            BOOL downloadSuccess = NO;
            if ( [[NSFileManager defaultManager] fileExistsAtPath:documentThemeDirectory isDirectory:&isDirectory] && isDirectory
                && [[NSFileManager defaultManager] removeItemAtPath:documentThemeDirectory error:&error] == NO )
            {
                // 삭제 실패
                NSLog(@"테마 도큐먼트 디렉토리 삭제 실패.. %@", error.localizedDescription);
                downloadSuccess = NO;
            }
            else if (  [[NSFileManager defaultManager] createDirectoryAtPath:documentThemeDirectory withIntermediateDirectories:NO attributes:nil error:&error] == NO)
            {
                // 디렉토리 생성실패
                NSLog(@"테마 도큐먼트 디렉토리 생성 실패.. %@", error.localizedDescription);
                downloadSuccess = NO;
            }
            // 성공한 경우... 다운로드 시도
            else
            {
                downloadSuccess = YES;
            }
            
            if ( downloadSuccess )
            {
                // 다운로드 시작 0인덱스부터~
                [[ServerConnector sharedServerConnection] requestThemeInfoImageDownload:self action:@selector(didFinishRequestThemeImageDownload:) downloadList:downloadList downloadIndex:0];
            }
            else
            {
                [_vwThemeUpdateContainer removeFromSuperview];
                [OMMessageBox showAlertMessage:@"" :@"최신 테마정보 업데이트 도중 오류가 발생했습니다. 잠시후 다시 이용해주세요."];
            }
        }
        // 업데이트가 필요하지 않은 경우... 바로 테마뷰 호출
        else
        {
            ThemeViewController *themeVC = [[ThemeViewController alloc] initWithNibName:@"ThemeViewController" bundle:nil];
            [[OMNavigationController sharedNavigationController] pushViewController:themeVC animated:NO];
            [themeVC release];
        }
        
    }
    else
    {
        [_vwThemeUpdateContainer removeFromSuperview];
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}
- (void) didFinishRequestThemeImageDownload :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        
        NSArray *downloadList = (NSArray*)[request userObject];
        NSInteger downloadIndex = [request userInt] + 1;
        
        float progress = ( (downloadIndex+1)*1.0f) / (downloadList.count*1.0f) ;
        if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
            [_pvwThemeUpdateProgress setProgress:progress animated:YES];
        else
            [_pvwThemeUpdateProgress setProgress:progress];
        
        // 다음 이미지 다운로드 시도
        if ( downloadList.count > downloadIndex )
        {
            [[ServerConnector sharedServerConnection] requestThemeInfoImageDownload:self action:@selector(didFinishRequestThemeImageDownload:) downloadList:downloadList downloadIndex:downloadIndex];
        }
        // 다운로드 완료된 경우 테마 열기
        else
        {
            [_vwThemeUpdateContainer removeFromSuperview];
            
            // 테마 버전정보 가져오기
            NSString *themeVersion = stringValueOfDictionary([ThemeCommon sharedThemeCommon].additionalInfo , @"ThemeVersion") ;
            NSString *themeUpdate = stringValueOfDictionary([ThemeCommon sharedThemeCommon].additionalInfo , @"ThemeUpdate") ;
            [[NSUserDefaults standardUserDefaults] setObject:themeVersion forKey:@"ThemeVersion"];
            [[NSUserDefaults standardUserDefaults] setObject:themeUpdate forKey:@"ThemeUpdate"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            ThemeViewController *themeVC = [[ThemeViewController alloc] initWithNibName:@"ThemeViewController" bundle:nil];
            [[OMNavigationController sharedNavigationController] pushViewController:themeVC animated:NO];
            [themeVC release];
        }
        
    }
    else
    {
        // 이미지 다운로드 실패한경우.... 경고처리하고 프로세스를 끝낸다.
        [_vwThemeUpdateContainer removeFromSuperview];
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    
}

-(IBAction)searchRoute:(id)sender
{
    [[OllehMapStatus sharedOllehMapStatus] setCurrentActionType:ActionType_SEARCHROUTE];
    [[SearchRouteDialogViewController sharedSearchRouteDialog] showSearchRouteDialog];
}
-(IBAction)openConfiguration:(id)sender
{
    
    [[ServerConnector sharedServerConnection] requestNoticeList:self action:@selector(finishNoticeListUICallBack:)];
    
    
    //[OMMessageBox showAlertMessage:@"설정" :@"설정을 선택했습니다."];
}
- (void) finishNoticeListUICallBack:(id)request
{
    [[OllehMapStatus sharedOllehMapStatus] setCurrentActionType:ActionType_CONFIG];
    
    SettingViewController2 *svc = [[SettingViewController2 alloc] initWithNibName:@"SettingViewController2" bundle:nil];
    
    [[OMNavigationController sharedNavigationController] pushViewController:svc animated:NO];
    [svc release];
}
- (IBAction) touchSearchBox:(id)sender
{
    [self openSearchView];
}
- (void) openSearchView
{
    // 버스 정류장/노선도 처리를 위한 배열 초기화
    [[OllehMapStatus sharedOllehMapStatus].pushDataBusNumberArray removeAllObjects];
    [[OllehMapStatus sharedOllehMapStatus].pushDataBusStationArray removeAllObjects];
    
    // 무조건 검색창 호출시 기존 검색화면으로 돌려보낸다.
    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    for (int i=nc.viewControllers.count-1; i>=0; i--)
    {
        UIViewController *vc = [nc.viewControllers objectAtIndexGC:i];
        if ([vc isKindOfClass:[SearchViewController class]])
        {
            // 기존 오버레이 제거
            //[[MapContainer sharedMapContainer_Main].kmap removeAllOverlays];
            [[MapContainer sharedMapContainer_Main].kmap removeAllOverlaysWithoutTraffic];
            // 검색 뷰까지 돌아가기
            [nc popToViewController:vc animated:NO];
            return;
        }
    }
    // 기존 검색창이 없을 경우 새로 생성하자
    SearchViewController *svc = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    [nc pushViewController:svc animated:NO];
    [svc release];
    
}

- (IBAction) onTraffic:(id)sender
{
    // 지도교통옵션 띄우기
    [self showMapTrafficOptionView:YES];
}
- (IBAction) onKMapStyle:(id)sender
{
    [_btnSideKMapType setSelected:!_btnSideKMapType.selected];
    
    [self toggleKMapStyle];
}
- (IBAction) onFavorite:(id)sender
{
    
}
- (void) highlightPointOverlayDetailButton:(id)sender
{
    // 호출한 Control 가져와서
    UIControl *cell = (UIControl*)sender;
    // 내부 텍스트 라벨 가져와서 생상변경
    for (UIView *subview in cell.subviews)
    {
        if ([subview isKindOfClass:[UILabel class]] )
        {
            UILabel *lbl = (UILabel*)subview;
            [lbl setTextColor:[UIColor grayColor]];
            break;
        }
    }
}
- (void) cancelHighlightPointOverlayDetailButton:(id)sender
{
    // 호출한 Control 가져와서
    UIControl *cell = (UIControl*)sender;
    // 내부 텍스트 라벨 가져와서 생상변경
    for (UIView *subview in cell.subviews)
    {
        if ([subview isKindOfClass:[UILabel class]] )
        {
            UILabel *lbl = (UILabel*)subview;
            [lbl setTextColor:[UIColor whiteColor]];
            break;
        }
    }
}

// 중첩POI 관련 메소드
- (void) onCloseDuplicatePOIList :(id)sender
{
    // 중첩 POI 리스트 선택 팝업 컨테이너 제거
    for (UIView *subview in _vwMultiPOISelectorContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    [_vwMultiPOISelectorContainer removeFromSuperview];
}

- (void) onSelectDuplicatePOI:(id)sender
{
    OMControl *vwCell = sender;
    
    // 팝업 제거
    [self onCloseDuplicatePOIList:sender];
    
    NSInteger index = vwCell.tag;
    
    // 마커옵션 활성화
    _selectedMultiPOIIndex = index;
    
    OMImageOverlay *overlay = (OMImageOverlay*)[vwCell.additionalInfo objectForKeyGC:@"Overlay"];
    NSMutableDictionary *searchMultiOverlayAdditonalInfo = (NSMutableDictionary*)[vwCell.additionalInfo objectForKeyGC:@"CurrentAdditionalInfo"];
    
    NSMutableDictionary *searchMultiOverlayDuplicatedInfo = [[NSMutableDictionary alloc] init];
    [searchMultiOverlayDuplicatedInfo setObject:[NSNumber numberWithFloat:overlay.coord.x] forKey:@"X"];
    [searchMultiOverlayDuplicatedInfo setObject:[NSNumber numberWithFloat:overlay.coord.y] forKey:@"Y"];
    [self pinPOIMarkerOption:YES targetInfo:searchMultiOverlayAdditonalInfo duplicatedInfo:searchMultiOverlayDuplicatedInfo animated:YES];
    [searchMultiOverlayDuplicatedInfo release];
    
    [[MapContainer sharedMapContainer_Main].kmap selectPOIOverlay:overlay];
}

- (void) onSelectDuplicatePOI_Down:(id)sender
{
    UIControl *cell = (UIControl*)sender;
    [cell setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0f)];
}
- (void) onSelectDuplicatePOI_UpOutside:(id)sender
{
    UIControl *cell = (UIControl*)sender;
    [cell setBackgroundColor:[UIColor whiteColor]];
}

// **********************


// =======================================
// [ 좌표-주소 메소드 시작 ]
// =======================================

// AddrNearestPosSearch 검색
- (void)requestReversGeocodingAddress:(Coord)coord geoType:(int)geoType
{
    [[ServerConnector sharedServerConnection] requestGeocodingCoordToAddress:self action:@selector(finishReversGeocodingAddress:) x:coord.x y:coord.y radius:1000 type:geoType];
}
- (void) finishReversGeocodingAddress:(id)request
{
    
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        switch ([request userInt])
        {
            case 0:
            case 10:
            {
                // 현재 위치 주소가져오기
                [_lblCurrentAddress setText:[request userString]];
                break;
            }
            case 1:
            {
                if ( [[request userString] isEqualToString:@""] )
                {
                    [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailed_NonReversGeocoding", @"")];
                }
                else
                {
                    // 특정 좌표 롱탭시 발생
                    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
                    [oms.searchResultOneTouchPOI reset];
                    [oms.searchResultOneTouchPOI setUsed:YES];
                    [oms.searchResultOneTouchPOI setIsCurrentLocation:NO];
                    [oms.searchResultOneTouchPOI setStrLocationAddress:(NSString*)[request userObject]];
                    [oms.searchResultOneTouchPOI setStrLocationName:[request userString]];
                    [oms.searchResultOneTouchPOI setCoordLocationPoint:[MapContainer sharedMapContainer_Main].kmap.lastLongTapCoordinate];
                    [oms.searchResultOneTouchPOI setStrTel:@""];
                    // 주소데이터를 바로 사용할 경우 상세정보를 사용할 수 없으므로 ADDR 정의해서 처리한다.
                    [oms.searchResultOneTouchPOI setStrType:@"ADDR"];
                    
                    //[self pinnedPointOverlay:YES];
                    [self pinLongtapPOIOverlay:YES];
                }
                break;
            }
        }
    }
    // 검색중 오류가 리턴된 경우
    else
    {
        switch ([request userInt])
        {
            case 0:
            case 10:
                // 현재 주소창 업데이트 인 경우는 오류메세지 노출하지 않음
                break;
            default:
                // 그외 주소 검색시 ( ex:롱탭 좌표 주소검색 ) 오류 메세지 리턴
                [OMMessageBox showAlertMessage:[request errorInfo].localizedDescription :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
        }
    }
}

// AddrNearestPosSearch2 검색
- (void) requestReversGeocodingToShortAddress :(Coord)coord geoType:(int)geoType;
{
    [[ServerConnector sharedServerConnection] requestGeocodingCoordToShortAddress:self action:@selector(finishReversGeocodingToShortAddress:) type:geoType x:coord.x y:coord.y dong:1];
}
- (void) finishReversGeocodingToShortAddress :(id)request
{
    // 더이상 UI 콜백 필요없어짐. (롱탭/현위치 주소 다른함수 사용)
    // 해당 리퀘스트는 길찾기 검색시 현재 위치에 대해 파싱콜백에서 처리끝남.
    return;
    
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        
        switch ([request userInt])
        {
            case 0:
            case 10:
            {
                // 현재 위치 주소가져오기
                [_lblCurrentAddress setText:[request userString]];
                break;
            }
            case 1:
            {
                // 특정 좌표 롱탭시 발생
                OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
                [oms.searchResultOneTouchPOI reset];
                [oms.searchResultOneTouchPOI setUsed:YES];
                [oms.searchResultOneTouchPOI setIsCurrentLocation:NO];
                [oms.searchResultOneTouchPOI setStrLocationAddress:[request userString]];
                [oms.searchResultOneTouchPOI setStrLocationName:[request userString]];
                [oms.searchResultOneTouchPOI setCoordLocationPoint:[MapContainer sharedMapContainer_Main].kmap.lastLongTapCoordinate];
                // 주소데이터를 바로 사용할 경우 상세정보를 사용할 수 없으므로 ADDR 정의해서 처리한다.
                [oms.searchResultOneTouchPOI setStrType:@"ADDR"];
                //[self pinnedPointOverlay:YES];
                [self pinLongtapPOIOverlay:YES];
                break;
            }
        }
    }
    // 검색중 오류가 리턴된 경우
    else
    {
        switch ([request userInt])
        {
            case 0:
            case 10:
                // 현재 주소창 업데이트 인 경우는 오류메세지 노출하지 않음
                //[_lblCurrentAddress setText:[NSString stringWithFormat:@"Failed Reversgeocoding (%.0f,%.0f)",[OllehMapStatus sharedOllehMapStatus].lastMapCoord.x,[OllehMapStatus sharedOllehMapStatus].lastMapCoord.y ]];
                break;
            default:
                // 그외 주소 검색시 ( ex:롱탭 좌표 주소검색 ) 오류 메세지 리턴
                [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
        }
    }
}

// ***************************************


// ===================
// [ 보조 메소드 시작 ]
// ===================
- (Coord) translateNSValueToCoord :(NSValue *)value
{
    Coord transCoord = CoordMake(0, 0);
    [value getValue:&transCoord];
    return transCoord;
}

- (NSString*) convertToMeterStringFromZoomLevel :(int)zoomLevel checkMapDisplay:(BOOL)checkMapDisplay
{
    
    if ( checkMapDisplay && [MapContainer sharedMapContainer_Main].kmap.mapDisplay == KMapDisplayNormalSmallText)
        zoomLevel--;
    
    switch (zoomLevel)
    {
        case -1: // 일반지도-작은글씨 일 경우에만 해당됨
            return @"204km";
        case 0:
            return @"102km";
        case 1:
            return @"51km";
        case 2:
            return @"26km";
        case 3:
            return @"13km";
        case 4:
            return @"6km";
        case 5:
            return @"3km";
        case 6:
            return @"1600m";
        case 7:
            return @"800m";
        case 8:
            return @"400m";
        case 9:
            return @"200m";
        case 10:
            return @"100m";
        case 11:
            return @"50m";
        case 12:
            return @"25m";
        case 13:
            return @"12m";
        default:
            return @"";
    }
}

- (void) finishAppVersionCallBack:(id)request
{
    
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        NSString *deviceVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        
        NSArray *deviceVersionArray = [deviceVersion componentsSeparatedByString:@"."];
        NSString *deviceVersionMajor = [deviceVersionArray objectAtIndexGC:0];
        NSString *deviceVersionMinor = [deviceVersionArray objectAtIndexGC:1];
        NSString *deviceVersionBuild = [deviceVersionArray objectAtIndexGC:2];
        
        NSString *recentVersionMajor = [[oms.appVersionDictionary objectForKeyGC:@"VERSION"] objectForKeyGC:@"majorVersion"];
        NSString *recentVersionMinor = [[oms.appVersionDictionary objectForKeyGC:@"VERSION"] objectForKeyGC:@"minorVersion"];
        NSString *recentVersionBuild = [[oms.appVersionDictionary objectForKeyGC:@"VERSION"] objectForKeyGC:@"buildVersion"];
        //NSString *recentVersion = [NSString stringWithFormat:@"%@.%@.%@", recentVersionMajor, recentVersionMinor, recentVersionBuild];
        
        int deviceVersionValue = [deviceVersionMajor intValue] * 100000 + [deviceVersionMinor intValue] * 1000 + [deviceVersionBuild intValue] * 1;
        int recentVersionValue = [recentVersionMajor intValue] * 100000 + [recentVersionMinor intValue] * 1000 + [recentVersionBuild intValue] * 1;
        BOOL requireUpdate = recentVersionValue > deviceVersionValue;
        
        // 업데이트가 필요한 경우
        if (requireUpdate)
        {
            // 확인 메세지
            [OMMessageBox showAlertMessageTwoButtonsWithTitle:@"" message:@"올레 map의 새로운 버전이 있습니다. 지금 업데이트 하시겠습니까?" target:self firstAction:@selector(onAppUpdateCancel:) secondAction:@selector(onAppUpdateGo:) firstButtonLabel:@"나중에" secondButtonLabel:@"업데이트"];
            // 그리고 종료..
            return;
        }
    }
    
    // 여기까지 온 이상.... 업데이트정보 검색실패했던지, 최신버전이던지.. 아니겠는가?? 그냥 디비업데이트 가자..
    [[ServerConnector sharedServerConnection] requestRecommendWordVersion:self action:@selector(didFinishRequestRecommendWordVersion:)];
}
- (void) onAppUpdateCancel :(id)sender
{
    // 업데이트 하지 않겠다 했으니 바로 디비업데이트 정보 처리
    [[ServerConnector sharedServerConnection] requestRecommendWordVersion:self action:@selector(didFinishRequestRecommendWordVersion:)];  ;
}
- (void) onAppUpdateGo :(id)sender
{
    // 사파리 이동
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL]];
    // 업데이트하러 가더라도 맵에서는 디비업데이트 처리중..
    [[ServerConnector sharedServerConnection] requestRecommendWordVersion:self action:@selector(didFinishRequestRecommendWordVersion:)];  ;
}


- (void) didFinishRequestRecommendWordVersion:(id)request
{
    //  성공적으로 확인된 경우
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        NSString *updateHash = [request userString];
        int updateVersion = [request userInt];
        NSNumber *updateSizeObject = (NSNumber*)[request userObject];
        int updateSize = [updateSizeObject intValue];
        
        // 현재 단말기에 배포된 데이터 버전을 확인한다.
        int currentVersion = [[[NSUserDefaults standardUserDefaults] objectForKeyGC:@"RecommendWordDataVersion"]  intValue];
        // 추천검색어 DB가 없을 경우 Bundle DB 버전을 처리해준다.
        if (currentVersion == 0)
        {
            currentVersion = _LastRecommendWordVersion; // 최신버전을 번들버전으로 맞추고
            DbHelper *dbh= [[DbHelper alloc] init];
            [dbh initAutomakeKeywordDB]; // 추천검색어 DB 초기화 시키고
            [dbh release];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:currentVersion] forKey:@"RecommendWordDataVersion"];
            [[NSUserDefaults standardUserDefaults] synchronize]; // 최신버전(번들버전)을 설정에 기록해둔다.
        }
        
#ifdef DEBUG
        // 디버깅 모드일때는 항상 추천검색어 업데이트 하도록 강제..
        //currentVersion = -1;
#endif
        
        // 최신버전 확인이 되면 파일 카피를 시작하다.
        if (updateVersion > currentVersion)
        {
            // 업데이트 정보 생성 ... 해제는 콜백함수에서 처리
            _updateInfoAutoRecommWord = [[NSMutableDictionary alloc] init];
            [_updateInfoAutoRecommWord setObject:[NSNumber numberWithInt:updateVersion] forKey:@"UpdateVersion"];
            [_updateInfoAutoRecommWord setObject:updateHash forKey:@"UpdateHash"];
            
            NSMutableString *updateAlertMessage = [[NSMutableString alloc] init];
            [updateAlertMessage appendFormat:@"DB 업데이트 파일이 존재합니다.\n다운로드 받으시겠습니까? (약 %dMB)\n\n", (updateSize/1024/1024) ];
            [updateAlertMessage appendFormat:@"(3G/LTE 환경에서도 다운로드 가능하며,데이터 통화료는 가입하신 요금제에 따라 차감/별도 부과됩니다.)"];
            [OMMessageBox showAlertMessageTwoButtonsWithTitle:@"업데이트 알림" message:updateAlertMessage target:self firstAction:@selector(callbackAutoUpdateCancel:) secondAction:@selector(callbackAutoUpdateExecute:) firstButtonLabel:@"아니오" secondButtonLabel:@"예"];
            [updateAlertMessage release];
            
            // 최신버전 확인했으면 여기서 벗어나도록 한다. 마지막 팝업처리 호출되지 않도록..
            return;
        }
    }
    
    // 업데이트 성공하지 못한채 이곳까지 오면 자동적으로 팝업 공지 처리한다.
    [[ServerConnector sharedServerConnection] requestNoticePopup:self action:@selector(didFinishRequestNoticePopup:)];
}

- (void) callbackAutoUpdateCancel :(id)sender
{
    [_updateInfoAutoRecommWord release];
    _updateInfoAutoRecommWord = nil;
    
    // 팝업공지 실행 (**실제 호출하는 함수는 자동업데이트 해제함수..)
    [self announceAutoUpdate:[NSNumber numberWithBool:NO]];
    
}
- (void) callbackAutoUpdateExecute :(id)sender
{
    
    NSString *updateHash = [NSString stringWithFormat:@"%@", [_updateInfoAutoRecommWord objectForKeyGC:@"UpdateHash"]];
    int updateVersion =[ [_updateInfoAutoRecommWord objectForKeyGC:@"UpdateVersion"] intValue];
    
    [_updateInfoAutoRecommWord release];
    _updateInfoAutoRecommWord = nil;
    
    [_lblAutoUpdateStatus setText:NSLocalizedString(@"Body_AutoUpdate_Processing", @"")];
    [self announceAutoUpdate:[NSNumber numberWithBool:YES]];
    [[ServerConnector sharedServerConnection] requestRecommendWordDownload:self action:@selector(didFinishRequestRecommendWordDownload:) version:updateVersion hash:updateHash];
}

- (void) didFinishRequestRecommendWordDownload :(id)request
{
    //  성공적으로 확인된 경우
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        NSNumber *successObject = (NSNumber*)[request userObject];
        BOOL success = [successObject boolValue];
        
        // 파일을 성공적으로 생성/교체 했을 경우 버전 정보를 업데이트 한다.
        if (success)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[request userInt]] forKey:@"RecommendWordDataVersion"];
            
            // 성공적으로 파일교체 한뒤..
            [_lblAutoUpdateStatus setText:NSLocalizedString(@"Body_AutoUpdate_Sucess", @"")];
            //[self announceAutoUpdate:NO];
            [self performSelector:@selector(announceAutoUpdate:) withObject:[NSNumber numberWithBool:NO] afterDelay:2.0];
        }
        else
        {
            // 파일 생성/교체를 실패한경우
            [_lblAutoUpdateStatus setText:[NSString stringWithFormat:@"%@ (AU-001)", NSLocalizedString(@"Body_AutoUpdate_Failed", @"")]];
            [self performSelector:@selector(announceAutoUpdate:) withObject:[NSNumber numberWithBool:NO] afterDelay:2.0];
        }
    }
    // 다운로드 자체를 실패한경우
    else
    {
        [_lblAutoUpdateStatus setText:[NSString stringWithFormat:@"%@ (AU-001)", NSLocalizedString(@"Body_AutoUpdate_Failed", @"")]];
        [self performSelector:@selector(announceAutoUpdate:) withObject:[NSNumber numberWithBool:NO] afterDelay:2.0];
    }
    
}
- (void) announceAutoUpdate :(NSNumber*)show
{
    if ([show boolValue])
    {
        // 딛드 활성화
        [self.view addSubview:_vwAutoUpdateContainer];
        [_vwAutoUpdateContainer setAlpha:1.0f];
        
        // 알림 메세지 컨테이너
        UIView *vwNotiContainer = [[UIView alloc] initWithFrame:CGRectMake(27, 195, 276, 69)];
        
        // 배경 삽입
        UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toast_popup_bg.png"]];
        [imgvwBack setFrame:CGRectMake(0, 0, imgvwBack.image.size.width, imgvwBack.image.size.height)];
        [vwNotiContainer addSubview:imgvwBack];
        [imgvwBack release];
        
        // 라벨 삽입
        [vwNotiContainer addSubview:_lblAutoUpdateStatus];
        
        // 메세지 컨테이너 삽입
        [_vwAutoUpdateContainer addSubview:vwNotiContainer];
        [_lblAutoUpdateStatus setAlpha:1.0f];
        
        // 애니메이션
        if (YES)
        {
            [_vwAutoUpdateContainer setAlpha:0.0f];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:1.0f];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            [_vwAutoUpdateContainer setAlpha:1.0f];
            
            [UIView commitAnimations];
        }
        
        // 알림 메세지 컨테이너 해제
        [vwNotiContainer release];
        
    }
    else
    {
        // 애니메이션
        if (YES)
        {
            [_vwAutoUpdateContainer setAlpha:1.0f];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:1.0f];
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];
            
            [_vwAutoUpdateContainer setAlpha:0.0f];
            
            [UIView commitAnimations];
        }
        
        // 딤드제거
        [_vwAutoUpdateContainer removeFromSuperview];
        
        // 서브뷰 제거
        for (UIView *subview in _vwAutoUpdateContainer.subviews)
        {
            [subview removeFromSuperview];
        }
    }
    
    // 업데이트 알림창이 닫힐때 기다렸다가 팝업공지 처리한다.
    if (![show boolValue])
    {
        // 팝업공지
        [[ServerConnector sharedServerConnection] requestNoticePopup:self action:@selector(didFinishRequestNoticePopup:)];
        
    }
}

- (void) didFinishRequestNoticePopup :(id)request
{
    //  성공적으로 확인된 경우
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        NSDictionary *dic = (NSDictionary*)[request userObject];
        if (dic != nil && dic.count > 0)
        {
            int noticeType = [[dic objectForKeyGC:@"noticeType"] intValue];
            int sequence = [[dic objectForKeyGC:@"sequence"] intValue];
            
            // 한번 읽음 처리된 공지는 보여주지 않는다.
            int lastSequence = [[[NSUserDefaults standardUserDefaults] objectForKeyGC:@"NoticePopupLastSequence"] intValue];
            if (lastSequence >= sequence) return;
            
            // 텍스트 팝업
            if ( noticeType == 1 )
            {
                //NSString *title = [NSString stringWithFormat:@"%@", [dic objectForKeyGC:@"title"] ];
                NSString *content = [NSString stringWithFormat:@"%@", [dic objectForKeyGC:@"content"] ];
                
                // 텍스트 팝업은 항상 한번만 노출
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:sequence] forKey:@"NoticePopupLastSequence"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                //[OMMessageBox showAlertMessage:title :content];
                [OMMessageBox showAlertMessage:@"안내" :[NSString stringWithFormat:@"%@", content]];
            }
            // 이미지 팝업
            else
            {
                //  이미지 팝업 정보 가져오기
                NSDictionary *attDic = [dic objectForKeyGC:@"attachment"];
                if ( attDic != nil && [[attDic allKeys]  containsObject:@"url"] )
                {
                    //NSString *title = [NSString stringWithFormat:@"%@", [dic objectForKeyGC:@"title"] ];
                    NSString *url = [NSString  stringWithFormat:@"http://%@%@",COMMON_SERVER_IP, [attDic objectForKeyGC:@"url"]];
                    //[OMMessageBox showAlertMessage:title :url];
                    
                    // 이미지 팝업 띄우기
                    [self.view addSubview:_vwNoticePopupContainer];
                    
                    // 웹뷰 삽입
                    UIWebView *webvwNotice = [[UIWebView alloc]
                                              initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,
                                                                       [[UIScreen mainScreen] bounds].size.height - 20)];
                    webvwNotice.delegate = self;
                    [[[webvwNotice subviews] lastObject] setScrollEnabled:NO];
                    [webvwNotice setBackgroundColor:[UIColor blackColor]];
                    NSURLRequest *popupRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
                    [webvwNotice loadRequest:popupRequest];
                    [_vwNoticePopupContainer addSubview:webvwNotice];
                    [webvwNotice release];
                    
                    // 하단 영역
                    UIView *vwBottom = [[UIView alloc] initWithFrame:CGRectMake(0, _vwNoticePopupContainer.frame.size.height-34, 320, 34)];
                    [vwBottom setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
                    [vwBottom  setBackgroundColor:[UIColor clearColor]];
                    
                    // 하단 영역 배경
                    UIImageView *imgvwBottomBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"event_check_bg.png"]];
                    [imgvwBottomBack setFrame:CGRectMake(0, 0, 320, 68/2)];
                    [vwBottom addSubview:imgvwBottomBack];
                    [imgvwBottomBack release];
                    
                    // 다시보지않기 체크박스 이미지
                    [vwBottom addSubview:_imgvwNoticePopupNoReminerCheckbox];
                    [_imgvwNoticePopupNoReminerCheckbox setImage:[UIImage imageNamed:@"event_check_off.png"]];
                    [_imgvwNoticePopupNoReminerCheckbox setTag:0];
                    
                    // 다시보지않기 텍스트
                    CGRect rectNoReminderLabel = CGRectMake(74/2, 20/2, 100, 26/2);
                    UILabel *lblNoReminder = [[UILabel alloc] initWithFrame:rectNoReminderLabel];
                    [lblNoReminder setFont:[UIFont boldSystemFontOfSize:13]];
                    [lblNoReminder setTextColor:[UIColor whiteColor]];
                    [lblNoReminder setBackgroundColor:[UIColor clearColor]];
                    [lblNoReminder setText:@"다시 보지 않기"];
                    rectNoReminderLabel.size = [lblNoReminder.text sizeWithFont:lblNoReminder.font constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX) lineBreakMode:lblNoReminder.lineBreakMode];
                    [lblNoReminder setFrame:rectNoReminderLabel];
                    [vwBottom addSubview:lblNoReminder];
                    [lblNoReminder release];
                    
                    // 다시보지않기 컨트롤
                    float buttonWidth = _imgvwNoticePopupNoReminerCheckbox.frame.size.width + rectNoReminderLabel.size.width;
                    UIButton *btnNoReminder = [[UIButton alloc] initWithFrame:CGRectMake(18/2, 0, buttonWidth, 68/2)];
                    [btnNoReminder setBackgroundColor:[UIColor clearColor]];
                    [btnNoReminder addTarget:self action:@selector(onNoticePopup_CheckNoReminder:) forControlEvents:UIControlEventTouchUpInside];
                    [vwBottom addSubview:btnNoReminder];
                    [btnNoReminder release];
                    
                    //  닫기 버튼
                    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(510/2, 0, 130/2, 68/2)];
                    [btnClose setImage:[UIImage imageNamed:@"event_close.png"] forState:UIControlStateNormal];
                    [btnClose addTarget:self action:@selector(onNoticePopup_Close:) forControlEvents:UIControlEventTouchUpInside];
                    [btnClose setTag:sequence]; // 버튼 태그에 현재공지 번호를 입력해서 창이 닫힐때 보지않음 처리를한다.
                    [vwBottom addSubview:btnClose];
                    [btnClose release];
                    
                    // 하단영역 삽입
                    [_vwNoticePopupContainer addSubview:vwBottom];
                    //[self.view addSubview:vwBottom];
                    [vwBottom release];
                }
            }
        }
    }
    // 서버 응답오류
    else
    {
    }
}
- (void) onNoticePopup_CheckNoReminder :(id)sender
{
    UIButton *btn = (UIButton*)sender;
    [btn setSelected:!btn.selected];
    
    if (btn.selected)
    {
        [_imgvwNoticePopupNoReminerCheckbox setImage:[UIImage imageNamed:@"event_check_on.png"]];
        [_imgvwNoticePopupNoReminerCheckbox setTag:1];
    }
    else
    {
        [_imgvwNoticePopupNoReminerCheckbox setImage:[UIImage imageNamed:@"event_check_off.png"]];
        [_imgvwNoticePopupNoReminerCheckbox setTag:0];
    }
}
- (void) onNoticePopup_Close:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    
    // 공지 팝업 클리어
    for (UIView *subview in _vwNoticePopupContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    // 공지팝업 제거
    [_vwNoticePopupContainer removeFromSuperview];
    
    // 공지다시보지 않기 설정처리
    if (_imgvwNoticePopupNoReminerCheckbox.tag == 1)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:btn.tag] forKey:@"NoticePopupLastSequence"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}


- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isKindOfClass:[OMScrollView class]])
    {
        
        if ([(OMScrollView *)scrollView scrollType] == 0)
        {
        }
        else if ([(OMScrollView *)scrollView scrollType] == 1)
        {
            [scrollView setContentOffset: CGPointMake(scrollView.contentOffset.x, 0)];
        }
        else if ([(OMScrollView *)scrollView scrollType] == 2)
        {
            [scrollView setContentOffset: CGPointMake(0, scrollView.contentOffset.y)];
        }
        else if ([(OMScrollView *)scrollView scrollType] == 3)
        {
            if (scrollView.contentOffset.y < 0)
                [scrollView setContentOffset: CGPointMake(scrollView.contentOffset.x, 0)];
            else if (scrollView.contentOffset.y > scrollView.contentSize.height-scrollView.frame.size.height)
                [scrollView setContentOffset: CGPointMake(scrollView.contentOffset.x, scrollView.contentSize.height-scrollView.frame.size.height)];
        }
    }
    
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // 프로토콜을 분석 ollehmap으로 들어오면 내부처리 // 아니면 사파리 호출
    if ( navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    //직접 UIWebView에서 처리하고자 할 때에는 여기에서 처리를 하게 된다.
    return YES;
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [[OMIndicator sharedIndicator] startAnimating];
}
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [[OMIndicator sharedIndicator] stopAnimating];
}



// *******************


- (void) mapConfigPrepared:(KMapView *)mapView
{
    //NSLog(@"MapConfigPrepared 호출.. mainmap");
    
    //hd버그
    //NSLog(@"준비끝 해상도 : %d", [MapContainer sharedMapContainer_Main].kmap.mapDisplay);
    
    //[[MapContainer sharedMapContainer_Main].kmap setMapDisplay:[[OllehMapStatus sharedOllehMapStatus] getDisplayMapResolution]];
}


- (void) addOverlayOnNewThread :(id)data
{
    @autoreleasepool
    {
    }
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
//            ResolutionViewController *rvc = [[ResolutionViewController alloc] initWithNibName:@"ResolutionViewController" bundle:nil];
//            [[OMNavigationController sharedNavigationController] pushViewController:rvc animated:NO];
//            [rvc release];
        }
            break;
        default:
            break;
    }
}
- (void) currentOverlayNoSelected
{
    _currentLongTapOverlay = nil;
}

- (IBAction)onLegend:(id)sender
{
    LegendViewController *lvc = [[LegendViewController alloc] init];
    [[OMNavigationController sharedNavigationController] pushViewController:lvc animated:NO];
    [lvc release];
}
@end
