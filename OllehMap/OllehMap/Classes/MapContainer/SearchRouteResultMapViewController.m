//
//  SearchRouteResultMapViewController.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 6. 11..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "SearchRouteResultMapViewController.h"

CGColorRef CGColorCreateRGB(float r,float g,float b,float a)
{
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    const CGFloat myColor[] = {r,g,b,a};
    CGColorRef col = CGColorCreate(rgb, myColor);
    CGColorSpaceRelease(rgb);
    return col;
    
}

void SetPolylineOverlayStrokeColor (PolylineOverlay *overlay, float r, float g, float b, float a)
{
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGColorRef stroke = CGColorCreate(rgb, (CGFloat[]){r,g,b,a});
    overlay.strokeColor = stroke;
    CGColorSpaceRelease(rgb);
    CFRelease(stroke);
}

typedef enum
{
    RouteImageOverlay_Type_Normal = 0,
    RouteImageOverlay_Type_Start = 1,
    RouteImageOverlay_Type_Dest = 2,
    RouteImageOverlay_Type_Visit = 3
}RouteImageOverlay_Type;



@implementation CarScrollView

@end

@implementation PublicScrollView

@end

@interface RouteImageOverlay : ImageOverlay
{
    RouteImageOverlay_Type _routeImageOverlayType;
}
@property (assign,nonatomic) RouteImageOverlay_Type routeImageOverlayType;
@end
@implementation RouteImageOverlay
@synthesize routeImageOverlayType = _routeImageOverlayType;
@end


@implementation SearchRouteResultMapViewController

@synthesize themesRequestInfo = _themesRequestInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    BOOL isPublicFirst = NO;
    if ( [nibNameOrNil isEqualToString:@"SearchRouteResultMapViewController_PublicFirst"] )
    {
        nibNameOrNil = @"SearchRouteResultMapViewController";
        isPublicFirst = YES;
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        _isPublicFirst = isPublicFirst;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initComponents];
}

- (void) dealloc
{
    [_vwRealtimeTrafficTimeTableContainer release];
    _vwRealtimeTrafficTimeTableContainer = nil;
    [_btnRealtimeRefresh release];
    _btnRealtimeRefresh = nil;
    
    [_themesRequestInfo release];
    _themesRequestInfo = nil;
    
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    // 네비게이션 그룹
    [_vwNavigationGroup release];
    [_btnNavigationLeftButton release];
    [_btnNavigationRightButton release];
    [_btnNavigationCarButton release];
    [_btnNavigationPublicButton release];
    
    // 지도&목록 그룹
    // _vwRoutePathMapContainer 주석해제 길찾기 오류시 제일먼저 확인하도록
    
    [_vwRoutePathMapContainer release];
    [_vwRoutePathListContainer release];
    [_btnMyLocation release];
    [_btnMapTrafficInfo release];
    [_btnMapRenderStyle release];
    
    //  지도 폴리곤라인
    [_plovrPath release];
    [_plovrWalk1 release];
    [_plovrWalk2 release];
    [_plovrWalk3 release];
    
    // 내위치 이미지뷰
    [_imgvwMyArea release];
    [_imgvwMyDirection release];
    
    // 상세포인트 관리를 위한 리스트
    [_detailPointOverlays release];
    
    // 하단버튼 그룹
    [_vwBottomButtonGroup release];
    
    // 경로탑색 다이얼로그 그룹
    [_vwRouteSelectorDialog release];
    
    // 자동차-지도 그룹
    [_vwCarRouteDetailPathInfoGroup release];
    [_vwCarRouteSummaryInfoGroup release];
    [_vwCarRouteSelectorPopup release];
    
    // 대중교통-선택 그룹
    [_vwPublicRouteSelector release];
    
    
    // 대중교통-지도 그룹
    [_vwPublicRouteDetailPathInfoGroup release];
    [_vwPublicRouteSummaryInfoGroup release];
    
    //ver3
    [_scrollView release];
    [_pageControl release];
    
    [_scrollViewPub release];
    [_pageControlPub release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 화면이 나타날대 위치서비스도 시작하도록 해준다.
    [[MapContainer sharedMapContainer_SearchRouteResult].kmap restartUserLocationTracing];
    
    if ( _isPublicFirst )
    {
        
        
        // 지도 컨테이너 뷰 클리어
        for (UIView *subView in _vwRoutePathMapContainer.subviews)
        {
            [subView removeFromSuperview];
        }
        // 지도 삽입
        [[MapContainer sharedMapContainer_SearchRouteResult] showMapContainer:_vwRoutePathMapContainer :self];
        
        [self showPublicSelectList:nil];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    // 지도 화면이 사라질때 위치서비스도 중단시켜준다.
    [[MapContainer sharedMapContainer_SearchRouteResult].kmap stopUserLocationTracing];
    // 나침반 모드에서 화면 닫을 때, 뒤늦게 화면변환 애니메이션 이벤트때문에 죽는다.
    // 강제로 릴리즈 시켜주자.
    [MapContainer closeMapContainer_SearchRouteResult];
    
    [super viewWillDisappear:animated];
}



// =========================
// [ 화면공통 렌더링 메소드 ]
// =========================

- (void) initComponents
{
    
    // ***********************
    // [ 뷰 컨트롤러 상태변수 ]
    // ***********************
    
    // 현재 뷰 컨트롤러 렌더링 타입
    _currentViewRenderType = OM_SRRMV_ViewRenderType_NONE;
    
    // 길찾기 세부경로 (-1:전체)
    _currentRouteDetailPathIndex = -1;
    
    // 내위치 모드 (일반/내위치/나침판) **OMS에서 관리하는 메인맵의 내위치 모드와는 독립적이어야 함
    _currentMyLocationMode = MapLocationMode_None;
    
    // 자동차 길찾기 경로선택 옵션 (기본 실시간)
    _currentRouteCarSelector = SearchRoute_Car_SearchType_RealTime;
    
    
    // 교통옵션 관련추가됨!! 길찾기지도에서 교통옵션 선택
    
    // 실시간 교통정보 컨테이너 뷰 초기화
    _vwRealtimeTrafficTimeTableContainer = [[UIView alloc] initWithFrame:CGRectMake(20/2, 79+65, 1, 1)];  //79+65 ==> 검색창하단좌표~실시간상단좌표간격
    [_vwRealtimeTrafficTimeTableContainer setBackgroundColor:[UIColor clearColor]];
    [_vwRealtimeTrafficTimeTableContainer setBackgroundColor:[UIColor redColor]];
    
    // 교통옵션 사용시 마지막으로 렌더링한 좌표값
    _trafficOptionLastRenderCoordinate = CoordMake(0, 0);
    _trafficOptionLastRequestTime = 0;
    // 테마 사용시 마지막으로 렌더링한 좌표값
    _themeLastRenderingCoordinate = CoordMake(0, 0);
    // 교통&테마 반경검색 관련 딜레이관리용
    _themesRequestInfo = [[NSMutableDictionary alloc] init];

    
    // ****************************
    // [ 뷰 컨트롤러 공통 오브젝트 ]
    // ****************************
    
    // 상단 네비게이션 그룹 뷰
    _vwNavigationGroup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
    [self.view addSubview:_vwNavigationGroup];
    // 배경 삽입
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_bg.png"]];
    [_vwNavigationGroup insertSubview:imgvwBack atIndex:0];
    [imgvwBack release];
    // 네비게이션 좌우측 버튼
    _btnNavigationLeftButton = [[UIButton alloc] init];
    [_btnNavigationLeftButton addTarget:self action:@selector(onNavigationLeftButton:) forControlEvents:UIControlEventTouchUpInside];
    _btnNavigationRightButton = [[UIButton alloc] init];
    [_btnNavigationRightButton addTarget:self action:@selector(onNavigationRightButton:) forControlEvents:UIControlEventTouchUpInside];
    // 네비게이선 중앙 버튼
    _btnNavigationCarButton = [[UIButton alloc] initWithFrame:CGRectMake(75, 4, 85, 28)];
    [_btnNavigationCarButton setImage:[UIImage imageNamed:@"title_2tab_btn1.png"] forState:UIControlStateNormal];
    [_btnNavigationCarButton setImage:[UIImage imageNamed:@"title_2tab_btn1_pressed.png"] forState:UIControlStateSelected];
    [_btnNavigationCarButton addTarget:self action:@selector(showCarMap:) forControlEvents:UIControlEventTouchUpInside];
    [_vwNavigationGroup addSubview:_btnNavigationCarButton];
    _btnNavigationPublicButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 4, 85, 28)];
    [_btnNavigationPublicButton setImage:[UIImage imageNamed:@"title_2tab_btn2.png"] forState:UIControlStateNormal];
    [_btnNavigationPublicButton setImage:[UIImage imageNamed:@"title_2tab_btn2_pressed.png"] forState:UIControlStateSelected];
    [_btnNavigationPublicButton addTarget:self action:@selector(showPublicSelectList:) forControlEvents:UIControlEventTouchUpInside];
    [_vwNavigationGroup addSubview:_btnNavigationPublicButton];
    
    // 지도 (KMap 포함)
    [MapContainer resetMapContainer_SearchRouteResult]; // 길찾기용 지도 리셋
    _lastKMapZoomLevel = [MapContainer  sharedMapContainer_SearchRouteResult].kmap.zoomLevel;
    
    _vwRoutePathMapContainer = [[UIView alloc]
                                initWithFrame:CGRectMake(0, 37,[UIScreen mainScreen].bounds.size.width,
                                                         [UIScreen mainScreen].bounds.size.height -
                                                         [UIApplication sharedApplication].statusBarFrame.size.height
                                                         - 74)];
    [_vwRoutePathMapContainer setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_vwRoutePathMapContainer setBackgroundColor:[UIColor whiteColor]];
    _plovrPath = [[PolylineOverlay alloc] init];
    _plovrWalk1 = [[PolylineOverlay alloc] init];
    _plovrWalk2 = [[PolylineOverlay alloc] init];
    _plovrWalk3 = [[PolylineOverlay alloc] init];
    
    // 목록
    _vwRoutePathListContainer = [[UIView alloc]
                                 initWithFrame:CGRectMake(0, 37,
                                                          [UIScreen mainScreen].bounds.size.width,
                                                          [UIScreen mainScreen].bounds.size.height -
                                                          [UIApplication sharedApplication].statusBarFrame.size.height
                                                          - 74)];
    [_vwRoutePathListContainer setBackgroundColor:[UIColor whiteColor]];
    [_vwRoutePathListContainer setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    // 내위치 이미지뷰
    _imgvwMyArea = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_radius.png"]];
    [_imgvwMyArea setFrame:CGRectMake(0, 0, _imgvwMyArea.image.size.width, _imgvwMyArea.image.size.height)];
    [_imgvwMyArea setHidden:YES];
    // 내위치 반경 이미지뷰
    _imgvwMyDirection = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_circinus.png"]];
    [_imgvwMyDirection setFrame:CGRectMake((320-_imgvwMyDirection.image.size.width)/2, 193-_imgvwMyDirection.image.size.height, _imgvwMyDirection.image.size.width, _imgvwMyDirection.image.size.height)];
    [_imgvwMyDirection setHidden:YES];
    
    // 상세포인트 관리를 위한 리스트
    _detailPointOverlays = [[NSMutableArray alloc] init];
    
    // 내위치 토글 버튼
    _btnMyLocation = [[UIButton alloc] initWithFrame:CGRectMake(12, 15, 37, 37)];
    [_btnMyLocation setImage:[UIImage imageNamed:@"map_btn_location.png"] forState:UIControlStateNormal];
    [_btnMyLocation addTarget:self action:@selector(onMyLocation:) forControlEvents:UIControlEventTouchUpInside];
    [_vwRoutePathMapContainer addSubview:_btnMyLocation];
    
    // 지도 교통량 안내 이미지뷰
    _imgvwMapTrafficInfo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"traffic_pop.png"]];
    [_imgvwMapTrafficInfo setFrame:CGRectMake(77, 15, 166, 21)];
    [_vwRoutePathMapContainer addSubview:_imgvwMapTrafficInfo];
    [_imgvwMapTrafficInfo setHidden:YES];
    
    // 지도 교통량 토글 버튼
    _btnMapTrafficInfo = [[UIButton alloc] initWithFrame:CGRectMake(271, 15, 37, 37)];
    [_btnMapTrafficInfo setImage:[UIImage imageNamed:@"map_btn_realtime.png"] forState:UIControlStateNormal];
    [_btnMapTrafficInfo setImage:[UIImage imageNamed:@"map_btn_realtime_pressed.png"] forState:UIControlStateSelected];
    [_btnMapTrafficInfo addTarget:self action:@selector(onTraffic:) forControlEvents:UIControlEventTouchUpInside];
    // 지도타입 토글 버튼 (일반/하이브리드)
    _btnMapRenderStyle = [[UIButton alloc] initWithFrame:CGRectMake(271, 55, 37, 37)];
    [_btnMapRenderStyle setImage:[UIImage imageNamed:@"map_btn_aviation.png"] forState:UIControlStateNormal];
    [_btnMapRenderStyle setImage:[UIImage imageNamed:@"map_btn_aviation_pressed.png"] forState:UIControlStateSelected];
    [_btnMapRenderStyle addTarget:self action:@selector(onMapRenderType:) forControlEvents:UIControlEventTouchUpInside];
    
    // 하단 버튼 그룹 뷰 (실제 버튼은 상황별로 각각 렌더링하도록 한다)
    _vwBottomButtonGroup = [[UIView alloc] initWithFrame:CGRectMake(0, 423, 320, 37)];
    [_vwBottomButtonGroup setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_vwBottomButtonGroup setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_vwBottomButtonGroup];
    
    // 경로탐색 다이얼로그
    _vwRouteSelectorDialog = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    // *********************
    // [ 자동차 + 지도 모드 ]
    // *********************
    
    // 하단 스크롤 부분
    _scrollView = [[CarScrollView alloc] init];
    //[_scrollView setContentOffset:CGPointMake(320, 0)];
    
    [_scrollView setPagingEnabled:YES];
    [_scrollView setContentSize:CGSizeMake(960, 60)];
    _scrollView.delegate = self;
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.currentPage = 1;
    _pageControl.numberOfPages = 3;
    [_pageControl addTarget:self action:@selector(pageChangeValue:) forControlEvents:UIControlEventValueChanged];
    // 하단 길찾기 경로정보 ( 시간거리 || 포인트정보)
    _vwCarRouteDetailPathInfoGroup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    [_vwCarRouteDetailPathInfoGroup setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_vwCarRouteDetailPathInfoGroup setBackgroundColor:[UIColor clearColor]];
    
    // 하단 길찾기 요약정보 - 전체경로 & 옵션 -
    _vwCarRouteSummaryInfoGroup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [_vwCarRouteSummaryInfoGroup setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_vwCarRouteSummaryInfoGroup setBackgroundColor:[UIColor clearColor]];
    
    // 경로옵션 뷰 (딤드팝업)
    _vwCarRouteSelectorPopup = [[UIView alloc]
                                initWithFrame:CGRectMake(0, 0,
                                                         [UIScreen mainScreen].bounds.size.width,
                                                         [UIScreen mainScreen].bounds.size.height - 20)];
    [_vwCarRouteSelectorPopup setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    
    // *********************
    // [ 자동차 + 목록 모드 ]
    // *********************
    
    // ***************************
    // [ 대중교통 + 경로선택 모드 ]
    // ***************************
    
    // 경로선택 뷰
    _vwPublicRouteSelector = [[UIView alloc]
                              initWithFrame:CGRectMake(0, 37,
                                                       [UIScreen mainScreen].bounds.size.width,
                                                       [UIScreen mainScreen].bounds.size.height -
                                                       [UIApplication sharedApplication].statusBarFrame.size.height -
                                                       17)];
    [_vwPublicRouteSelector setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_vwPublicRouteSelector setBackgroundColor:[UIColor whiteColor]];
    // 현재 선택된 대중교통 종류
    _currentPublicMethod = OM_SRRMV_PublicMethodType_Recommend;
    
    // ************************
    // [ 대중교통 + 지도 모드 ]
    // ************************
    
    // 하단 스크롤 부분
    _scrollViewPub = [[PublicScrollView alloc] init];
    
    [_scrollViewPub setPagingEnabled:YES];
    
    _scrollViewPub.delegate = self;
    [_scrollViewPub setShowsHorizontalScrollIndicator:NO];
    _pageControlPub = [[UIPageControl alloc] init];
    _pageControlPub.currentPage = 1;
    _pageControlPub.numberOfPages = 3;
    [_pageControlPub addTarget:self action:@selector(pageChangeValuePub:) forControlEvents:UIControlEventValueChanged];
    
    // 하단 길찾기 경로정보 ( 시간거리 || 포인트정보)
    _vwPublicRouteDetailPathInfoGroup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 31)];
    [_vwPublicRouteDetailPathInfoGroup setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_vwPublicRouteDetailPathInfoGroup setBackgroundColor:[UIColor clearColor]];
    // 하단 길찾기 요약정보 - 전체경로 & 옵션 -
    _vwPublicRouteSummaryInfoGroup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 71)];
    [_vwPublicRouteSummaryInfoGroup setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_vwPublicRouteSummaryInfoGroup setBackgroundColor:[UIColor clearColor]];
    
    // ************************
    // [ 대중교통 + 목록 모드 ]
    // ************************
    
    
    // 검색 결과별로 첫 화면 다르게 보여줌
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 길찾기 자동차 검색결과 존재하면 우선적으로 보여줌
    if (oms.searchRouteData.isRouteCar)
    {
        [self renderCarMap];
    }
}

- (void) renderCommonNavigationBar
{
    // 좌우측 버튼은 매번 변경되므로 일단 제거
    [_btnNavigationLeftButton removeFromSuperview];
    [_btnNavigationRightButton removeFromSuperview];
    
    // 네비게이션 버튼
    switch (_currentViewRenderType)
    {
        case OM_SRRMV_ViewRenderType_CAR_MAP:
        {
            // 좌측(닫기)
            [_btnNavigationLeftButton setImage:[UIImage imageNamed:@"title_btn_close.png"] forState:UIControlStateNormal];
            [_btnNavigationLeftButton setFrame:CGRectMake(7, 4, 42, 28)];
            [_vwNavigationGroup addSubview:_btnNavigationLeftButton];
            // 우측(목록)
            [_btnNavigationRightButton setImage:[UIImage imageNamed:@"title_btn_list.png"] forState:UIControlStateNormal];
            [_btnNavigationRightButton setFrame:CGRectMake(271, 4, 42, 28)];
            [_vwNavigationGroup addSubview:_btnNavigationRightButton];
            // 중앙-자동차 활성화
            [_btnNavigationCarButton setSelected:YES];
            // 중앙-대중교통 비활성화
            [_btnNavigationPublicButton setSelected:NO];
            break;
        }
        case OM_SRRMV_ViewRenderType_CAR_LIST:
        {
            // 좌측(닫기)
            [_btnNavigationLeftButton setImage:[UIImage imageNamed:@"title_btn_close.png"] forState:UIControlStateNormal];
            [_btnNavigationLeftButton setFrame:CGRectMake(7, 4, 42, 28)];
            [_vwNavigationGroup addSubview:_btnNavigationLeftButton];
            // 우측(지도)
            [_btnNavigationRightButton setImage:[UIImage imageNamed:@"title_btn_map.png"] forState:UIControlStateNormal];
            [_btnNavigationRightButton setFrame:CGRectMake(271, 4, 42, 28)];
            [_vwNavigationGroup addSubview:_btnNavigationRightButton];
            // 중앙-자동차 활성화
            [_btnNavigationCarButton setSelected:YES];
            // 중앙-대중교통 비활성화
            [_btnNavigationPublicButton setSelected:NO];
            break;
        }
        case OM_SRRMV_ViewRenderType_PUBLIC_SELECT:
        {
            // 좌측(닫기)
            [_btnNavigationLeftButton setImage:[UIImage imageNamed:@"title_btn_close.png"] forState:UIControlStateNormal];
            [_btnNavigationLeftButton setFrame:CGRectMake(7, 4, 42, 28)];
            [_vwNavigationGroup addSubview:_btnNavigationLeftButton];
            // 우측(없음)
            // 중앙-자동차 비활성화
            [_btnNavigationCarButton setSelected:NO];
            // 중앙-대중교통 활성화
            [_btnNavigationPublicButton setSelected:YES];
            break;
        }
        case OM_SRRMV_ViewRenderType_PUBLIC_MAP:
        {
            // 좌측(닫기)
            [_btnNavigationLeftButton setImage:[UIImage imageNamed:@"title_bt_before.png"] forState:UIControlStateNormal];
            [_btnNavigationLeftButton setFrame:CGRectMake(7, 4, 47, 28)];
            [_vwNavigationGroup addSubview:_btnNavigationLeftButton];
            // 우측(목록)
            [_btnNavigationRightButton setImage:[UIImage imageNamed:@"title_btn_list.png"] forState:UIControlStateNormal];
            [_btnNavigationRightButton setFrame:CGRectMake(271, 4, 42, 28)];
            [_vwNavigationGroup addSubview:_btnNavigationRightButton];
            // 중앙-자동차 비활성화
            [_btnNavigationCarButton setSelected:NO];
            // 중앙-대중교통 활성화
            [_btnNavigationPublicButton setSelected:YES];
            break;
        }
        case OM_SRRMV_ViewRenderType_PUBLIC_LIST:
        {
            // 좌측(닫기)
            [_btnNavigationLeftButton setImage:[UIImage imageNamed:@"title_bt_before.png"] forState:UIControlStateNormal];
            [_btnNavigationLeftButton setFrame:CGRectMake(7, 4, 47, 28)];
            [_vwNavigationGroup addSubview:_btnNavigationLeftButton];
            // 우측(목록)
            [_btnNavigationRightButton setImage:[UIImage imageNamed:@"title_btn_map.png"] forState:UIControlStateNormal];
            [_btnNavigationRightButton setFrame:CGRectMake(271, 4, 42, 28)];
            [_vwNavigationGroup addSubview:_btnNavigationRightButton];
            // 중앙-자동차 비활성화
            [_btnNavigationCarButton setSelected:NO];
            // 중앙-대중교통 활성화
            [_btnNavigationPublicButton setSelected:YES];
            break;
        }
            
        case OM_SRRMV_ViewRenderType_NONE:
        default:
            break;
    }
    
    
}

- (void) renderCommonBottomButtonsWithOllehNavi :(BOOL) useOllehNavi
{
    // 기존 뷰 제거
    for (UIView *subView in _vwBottomButtonGroup.subviews)
    {
        [subView removeFromSuperview];
    }
    [_vwBottomButtonGroup removeFromSuperview];
    
    if (useOllehNavi)
    {
        UIButton *btnFavorite = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 160, 37)] ;
        [btnFavorite setImage:[UIImage imageNamed:@"info_btn_hotlist.png"] forState:UIControlStateNormal];
        [btnFavorite addTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
        [_vwBottomButtonGroup addSubview:btnFavorite];
        [btnFavorite release];
        UIButton *btnOllehnavi = [[UIButton alloc] initWithFrame:CGRectMake(160, 0, 160, 37)];
        [btnOllehnavi setImage:[UIImage imageNamed:@"info_btn_navi.png"] forState:UIControlStateNormal];
        [btnOllehnavi addTarget:self action:@selector(linkOllehNavi:) forControlEvents:UIControlEventTouchUpInside];
        [_vwBottomButtonGroup addSubview:btnOllehnavi];
        [btnOllehnavi release];
    }
    else
    {
        UIButton *btnOllehnavi = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
        [btnOllehnavi setImage:[UIImage imageNamed:@"info_btn_hotlist_01.png"] forState:UIControlStateNormal];
        [btnOllehnavi addTarget:self action:@selector(addFavorite:) forControlEvents:UIControlEventTouchUpInside];
        [_vwBottomButtonGroup addSubview:btnOllehnavi];
        [btnOllehnavi release];
    }
    
    [self.view addSubview:_vwBottomButtonGroup];
}

- (void) addFavorite :(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    DbHelper *dbh = [[DbHelper alloc] init];
    
    NSMutableDictionary *favoriteDic = nil;
    if (_currentViewRenderType == OM_SRRMV_ViewRenderType_CAR_MAP || _currentViewRenderType == OM_SRRMV_ViewRenderType_CAR_LIST)
    {
        favoriteDic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Route title1:oms.searchResultRouteStart.strLocationName title2:oms.searchResultRouteDest.strLocationName title3:oms.searchResultRouteVisit.strLocationName iconType:Favorite_IconType_Course coord1x:oms.searchResultRouteStart.coordLocationPoint.x coord1y:oms.searchResultRouteStart.coordLocationPoint.y coord2x:oms.searchResultRouteDest.coordLocationPoint.x coord2y:oms.searchResultRouteDest.coordLocationPoint.y coord3x:oms.searchResultRouteVisit.coordLocationPoint.x coord3y:oms.searchResultRouteVisit.coordLocationPoint.y detailType:@"" detailID:@"" shapeType:@"" fcNm:@"" idBgm:@""];
    }
    else if (_currentViewRenderType == OM_SRRMV_ViewRenderType_PUBLIC_LIST || _currentViewRenderType == OM_SRRMV_ViewRenderType_PUBLIC_MAP)
    {
        favoriteDic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Route title1:oms.searchResultRouteStart.strLocationName title2:oms.searchResultRouteDest.strLocationName title3:@"" iconType:Favorite_IconType_Course coord1x:oms.searchResultRouteStart.coordLocationPoint.x coord1y:oms.searchResultRouteStart.coordLocationPoint.y coord2x:oms.searchResultRouteDest.coordLocationPoint.x coord2y:oms.searchResultRouteDest.coordLocationPoint.y coord3x:0 coord3y:0 detailType:@"" detailID:@"" shapeType:@"" fcNm:@"" idBgm:@""];
    }
    [dbh addFavorite:favoriteDic];
    [dbh release];
    
    
    // 즐겨찾기 통계
    if (_currentViewRenderType == OM_SRRMV_ViewRenderType_CAR_MAP
        || _currentViewRenderType == OM_SRRMV_ViewRenderType_CAR_LIST)
        [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/find_route/car/favorite"];
    else [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/find_route/public/favorite"];
}

- (void) linkOllehNavi :(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 도착점 설정
    [oms.shareDictionary setObject:[NSNumber numberWithDouble:oms.searchResultRouteDest.coordLocationPoint.x] forKey:@"X"];
    [oms.shareDictionary setObject:[NSNumber numberWithDouble:oms.searchResultRouteDest.coordLocationPoint.y] forKey:@"Y"];
    [ShareViewController ollehNaviAlertView];
    
    // 올레navi 통계
    [oms trackPageView:@"/find_route/car/olleh_navi"];
    
}

- (void) showPublicSelectList :(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 현재 자동차 모드가 아니면 무시 (대중교통모드에서 다시 대중교통 모드 렌더링 하지 않도록)
    if (_currentViewRenderType == OM_SRRMV_ViewRenderType_PUBLIC_SELECT
        || _currentViewRenderType == OM_SRRMV_ViewRenderType_PUBLIC_MAP
        || _currentViewRenderType == OM_SRRMV_ViewRenderType_PUBLIC_LIST)
    {
        return;
    }
    
    [self toggleMyLocationMode:MapLocationMode_None];
    
    // 대중교통 모드 선택화면 렌더링
    
    [_btnNavigationCarButton setSelected:NO];
    [_btnNavigationPublicButton setSelected:YES];
    
    // 현재 선택된 상세경로 인덱스 초기화
    _currentRouteDetailPathIndex = -1;
    
    // 메모리에 대중교통 결과가 없으면 검색시도
    if (!oms.searchRouteData.isRoutePublic)
    {
        // 검색시도
        [self requestPublicSearchRoute];
    }
    // 메모리에 대중교통 결과가 존재하면 바로 경로선택 화면 렌더링
    else
    {
        [self renderPublicSelector];
    }
    
}

- (void) showCarMap :(id)sender
{
    // 현재 대중교통 모드가 아니면 무시 (자동차모드에서 다시 자동차 모드 렌더링하지 않도록)
    if (_currentViewRenderType == OM_SRRMV_ViewRenderType_CAR_MAP
        || _currentViewRenderType == OM_SRRMV_ViewRenderType_CAR_LIST)
    {
        return;
    }
    
    [self toggleMyLocationMode:MapLocationMode_None];
    
    // 현재 선택된 상세경로 인덱스 초기화
    _currentRouteDetailPathIndex = -1;
    
    // 자동차 맵 렌더링
    [_btnNavigationCarButton setSelected:YES];
    [_btnNavigationPublicButton setSelected:NO];
    
    if ( [OllehMapStatus sharedOllehMapStatus].searchRouteData.isRouteCar )
    {
        // 검색된 결과 존재하면 그대로 자동차화면 렌더링
        [self renderCarMap];
    }
    else
    {
        // 결과 없을 경우 재검색.. (특히 애플지도에서 대중교통 검색으로 바로 들어온 경우 필요)
        _currentViewRenderType = OM_SRRMV_ViewRenderType_CAR_MAP;
        _currentRouteCarSelector = SearchRoute_Car_SearchType_RealTime;
        [self requestCarSearchRouteSelector];
    }
}

- (void) onMyLocation :(id)sender
{
    if ( [MapContainer CheckLocationService] )
    {
        // 다음 모드 값 계산
        int nextmode = (_currentMyLocationMode + 1) %3;
        // 구해진 다음 모드 값으로 전환
        [self toggleMyLocationMode:nextmode];
    }
}
// 교통량 체크
- (void) trafficInfoSelect:(BOOL)selected
{
        [_btnMapTrafficInfo setSelected:selected];
    
        // 지도 교통량 처리
        [[MapContainer sharedMapContainer_SearchRouteResult].kmap setTrafficInfo:selected clearCache:YES];
        
        // 지도 교통량 뷰 디스플레이
        [_imgvwMapTrafficInfo setHidden:!selected];

}
- (void) onTraffic :(id)sender
{
    
    // 길찾기에선 교통옵션 팝업 사용 안하는 대신 실시간교통량만 체크
    UIButton *button = (UIButton *)sender;
    [button setSelected:!button.selected];
    
    [self trafficInfoSelect:button.selected];
    
    
    
    //[self showMapTrafficOptionView:YES];
    /*
     [_btnMapTrafficInfo setSelected:!_btnMapTrafficInfo.selected];
     
     MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
     [mc.kmap setTrafficInfo: _btnMapTrafficInfo.selected clearCache:YES];
     [_imgvwMapTrafficInfo setHidden:!_btnMapTrafficInfo.selected];
     */
}

- (void) onMapRenderType :(id)sender
{
    [_btnMapRenderStyle setSelected:!_btnMapRenderStyle.selected];
    
    if ( _btnMapRenderStyle.selected )
        [[MapContainer sharedMapContainer_SearchRouteResult].kmap setMapType:KMapTypeHybrid];
    else
        [[MapContainer sharedMapContainer_SearchRouteResult].kmap setMapType:KMapTypeStandard];
}

- (void) onNavigationLeftButton :(id)sender
{
    if (_currentViewRenderType == OM_SRRMV_ViewRenderType_CAR_MAP)
    {
        [[MapContainer sharedMapContainer_Main].kmap removeAllRouteOverlay];
        
        [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
    }
    else if (_currentViewRenderType == OM_SRRMV_ViewRenderType_CAR_LIST)
    {
        [[MapContainer sharedMapContainer_Main].kmap removeAllRouteOverlay];
        
        [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];}
    else if (_currentViewRenderType == OM_SRRMV_ViewRenderType_PUBLIC_SELECT)
    {
        [[MapContainer sharedMapContainer_Main].kmap removeAllRouteOverlay];
        
        [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
    }
    else if (_currentViewRenderType == OM_SRRMV_ViewRenderType_PUBLIC_MAP)
        [self renderPublicSelector];
    else if (_currentViewRenderType == OM_SRRMV_ViewRenderType_PUBLIC_LIST)
        [self renderPublicSelector];
    
    // ver4 길찾기 창에 진입했을 경우엔 닫기 하면 무조건 길찾기팝업 닫히게
    [[SearchRouteDialogViewController sharedSearchRouteDialog] closeSearchRouteDialog];
}

- (void) onNavigationRightButton :(id)sender
{
    if (_currentViewRenderType == OM_SRRMV_ViewRenderType_CAR_MAP)
        [self renderCarList];
    else if (_currentViewRenderType == OM_SRRMV_ViewRenderType_CAR_LIST)
        [self renderCarMap];
    else if (_currentViewRenderType == OM_SRRMV_ViewRenderType_PUBLIC_MAP)
        [self renderPublicList];
    else if (_currentViewRenderType == OM_SRRMV_ViewRenderType_PUBLIC_LIST)
        [self renderPublicMap];
}

- (void) adjustMyArea
{
    // 반경이미지를 SDK에서 그려주기 때문에 더이상 이미지를 렌더링 하지 않아도 됨.
    [_imgvwMyArea setHidden:YES];
    [_imgvwMyDirection setHidden:YES];
    
    /*
     switch (_currentMyLocationMode)
     {
     case MapLocationMode_None:
     [_imgvwMyArea setHidden:YES];
     [_imgvwMyDirection setHidden:YES];
     break;
     case MapLocationMode_NorthUp:
     [_imgvwMyArea setHidden:NO];
     [_imgvwMyDirection setHidden:YES];
     [self adjustMyAreaRadius];
     break;
     case MapLocationMode_Commpass:
     [_imgvwMyArea setHidden:NO];
     [_imgvwMyDirection setHidden:NO];
     [self adjustMyAreaRadius];
     
     break;
     }
     */
}

- (void) adjustMyAreaRadius
{
}

- (void) showRouteRouteImageOverlay:(BOOL)show
{
    for (Overlay *overlay in [MapContainer sharedMapContainer_SearchRouteResult].kmap.getOverlays)
    {
        if ( [overlay isKindOfClass:[RouteImageOverlay class]] )
        {
            RouteImageOverlay *routeOverlay = (RouteImageOverlay*)overlay;
            if (routeOverlay.routeImageOverlayType == RouteImageOverlay_Type_Normal)
            {
                CGSize imageSize = CGSizeMake(0, 0);
                if (show) imageSize = routeOverlay.imageView.image.size;
                
                [routeOverlay setImageSize:imageSize];
            }
        }
    }
}

- (void) onOptionViewCloseButton :(id)sender
{
    [super onOptionViewCloseButton:sender];
    
    
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];

    _btnMapTrafficInfo.selected = mc.kmap.trafficInfo || mc.kmap.trafficCCTV || mc.kmap.trafficBusStation || mc.kmap.trafficSubwayStation || mc.kmap.CadastralInfo;
}

// *************************


// ================================
// [ 자동차 - 공통 - 렌더링 메소드 ]
// ================================


- (void) showCarRouteSelector:(id)sender
{
    [self toggleMyLocationMode:MapLocationMode_None];
    
    // 팝업 메인뷰 생성
    UIView *vwSelectorMain = [[UIView alloc] initWithFrame:CGRectMake(37, 89, 246, 278)];
    
    // 배경
    UIImageView *imgvwSelectorMainBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_bg_01.png"]];
    [vwSelectorMain addSubview:imgvwSelectorMainBack];
    
    // 타이틀
    UILabel *lblSelectorMainTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 246, 19)];
    [lblSelectorMainTitle setFont:[UIFont systemFontOfSize:19]];
    [lblSelectorMainTitle setBackgroundColor:[UIColor clearColor]];
    [lblSelectorMainTitle setTextColor:[UIColor whiteColor]];
    [lblSelectorMainTitle setTextAlignment:NSTextAlignmentCenter];
    [lblSelectorMainTitle setText:NSLocalizedString(@"Body_SRRM_RouteSelector_Title", @"")];
    [vwSelectorMain addSubview:lblSelectorMainTitle];
    
    // 취소버튼
    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(88, 228, 70, 31)];
    [btnCancel setImage:[UIImage imageNamed:@"popup_cancel_btn.png"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(closeCarRouteSelector:) forControlEvents:UIControlEventTouchUpInside];
    [vwSelectorMain addSubview:btnCancel];
    
    // 실시간빠른길
    {
        UIControl *ctrlRoute = [[UIControl alloc] initWithFrame:CGRectMake(9, 37, 228, 46)];
        [ctrlRoute setTag:999+1];
        UIImageView *imgvwChecker;
        if (_currentRouteCarSelector == SearchRoute_Car_SearchType_RealTime)
        {
            imgvwChecker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
        }
        else
        {
            imgvwChecker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
            [ctrlRoute addTarget:self action:@selector(searchRouteCarRealTime:) forControlEvents:UIControlEventTouchUpInside];
            [ctrlRoute addTarget:self action:@selector(onCarRouteSelectorCell_Down:) forControlEvents:UIControlEventTouchDown];
            [ctrlRoute addTarget:self action:@selector(onCarRouteSelectorCell_Up:) forControlEvents:UIControlEventTouchUpOutside];
        }
        [imgvwChecker setTag:SearchRoute_Car_SearchType_RealTime];
        [imgvwChecker setFrame:CGRectMake(10, 11, 25, 25)];
        [ctrlRoute addSubview:imgvwChecker];
        UILabel *lblRoute = [[UILabel alloc] initWithFrame:CGRectMake(45, 15, 172, 15)];
        [lblRoute setFont:[UIFont systemFontOfSize:15]];
        [lblRoute setText:NSLocalizedString(@"Body_SRRM_RouteSelector_RealTime", @"")];
        [ctrlRoute addSubview:lblRoute];
        [vwSelectorMain addSubview:ctrlRoute];
        
        // 라인
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, 45, 228, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0)];
        [ctrlRoute addSubview:vwLine];
        
        [ctrlRoute release];
        [imgvwChecker release];
        [lblRoute release];
        [vwLine release];
        
    }
    // 무료도로
    {
        UIControl *ctrlRoute = [[UIControl alloc] initWithFrame:CGRectMake(9, 83, 228, 46)];
        [ctrlRoute setTag:999+2];
        UIImageView *imgvwChecker;
        if (_currentRouteCarSelector == SearchRoute_Car_SearchType_FreePass)
        {
            imgvwChecker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
        }
        else
        {
            imgvwChecker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
            [ctrlRoute addTarget:self action:@selector(searchRouteCarFreePass:) forControlEvents:UIControlEventTouchUpInside];
            [ctrlRoute addTarget:self action:@selector(onCarRouteSelectorCell_Down:) forControlEvents:UIControlEventTouchDown];
            [ctrlRoute addTarget:self action:@selector(onCarRouteSelectorCell_Up:) forControlEvents:UIControlEventTouchUpOutside];
        }
        [imgvwChecker setTag:SearchRoute_Car_SearchType_FreePass];
        [imgvwChecker setFrame:CGRectMake(10, 11, 25, 25)];
        [ctrlRoute addSubview:imgvwChecker];
        UILabel *lblRoute = [[UILabel alloc] initWithFrame:CGRectMake(45, 15, 172, 15)];
        [lblRoute setFont:[UIFont systemFontOfSize:15]];
        [lblRoute setText:NSLocalizedString(@"Body_SRRM_RouteSelector_FreePass", @"")];
        [ctrlRoute addSubview:lblRoute];
        [vwSelectorMain addSubview:ctrlRoute];
        
        // 라인
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, 45, 228, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0)];
        [ctrlRoute addSubview:vwLine];
        
        [ctrlRoute release];
        [imgvwChecker release];
        [lblRoute release];
        [vwLine release];
        
    }
    // 최단거리
    {
        UIControl *ctrlRoute = [[UIControl alloc] initWithFrame:CGRectMake(9, 129, 228, 46)];
        [ctrlRoute setTag:999+3];
        UIImageView *imgvwChecker;
        if (_currentRouteCarSelector == SearchRoute_Car_SearchType_ShortDistance)
        {
            imgvwChecker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
        }
        else
        {
            imgvwChecker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
            [ctrlRoute addTarget:self action:@selector(searchRouteCarShortDistance:) forControlEvents:UIControlEventTouchUpInside];
            [ctrlRoute addTarget:self action:@selector(onCarRouteSelectorCell_Down:) forControlEvents:UIControlEventTouchDown];
            [ctrlRoute addTarget:self action:@selector(onCarRouteSelectorCell_Up:) forControlEvents:UIControlEventTouchUpOutside];
        }
        [imgvwChecker setTag:SearchRoute_Car_SearchType_ShortDistance];
        [imgvwChecker setFrame:CGRectMake(10, 11, 25, 25)];
        [ctrlRoute addSubview:imgvwChecker];
        UILabel *lblRoute = [[UILabel alloc] initWithFrame:CGRectMake(45, 15, 172, 15)];
        [lblRoute setFont:[UIFont systemFontOfSize:15]];
        [lblRoute setText:NSLocalizedString(@"Body_SRRM_RouteSelector_ShortDistance", @"")];
        [ctrlRoute addSubview:lblRoute];
        [vwSelectorMain addSubview:ctrlRoute];
        
        // 라인
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, 45, 228, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0)];
        [ctrlRoute addSubview:vwLine];
        
        [ctrlRoute release];
        [imgvwChecker release];
        [lblRoute release];
        [vwLine release];
        
    }
    // 고속(화)도로
    {
        UIControl *ctrlRoute = [[UIControl alloc] initWithFrame:CGRectMake(9, 175, 228, 46)];
        [ctrlRoute setTag:999+4];
        UIImageView *imgvwChecker;
        if (_currentRouteCarSelector == SearchRoute_Car_SearchType_HighWay)
        {
            imgvwChecker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
        }
        else
        {
            imgvwChecker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
            [ctrlRoute addTarget:self action:@selector(searchRouteCarHighWay:) forControlEvents:UIControlEventTouchUpInside];
            [ctrlRoute addTarget:self action:@selector(onCarRouteSelectorCell_Down:) forControlEvents:UIControlEventTouchDown];
            [ctrlRoute addTarget:self action:@selector(onCarRouteSelectorCell_Up:) forControlEvents:UIControlEventTouchUpOutside];
        }
        [imgvwChecker setTag:SearchRoute_Car_SearchType_HighWay];
        [imgvwChecker setFrame:CGRectMake(10, 11, 25, 25)];
        [ctrlRoute addSubview:imgvwChecker];
        UILabel *lblRoute = [[UILabel alloc] initWithFrame:CGRectMake(45, 15, 172, 15)];
        [lblRoute setFont:[UIFont systemFontOfSize:15]];
        [lblRoute setText:NSLocalizedString(@"Body_SRRM_RouteSelector_HighWay", @"")];
        [ctrlRoute addSubview:lblRoute];
        [vwSelectorMain addSubview:ctrlRoute];
        
        // 라인
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, 45, 228, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0)];
        [ctrlRoute addSubview:vwLine];
        
        [ctrlRoute release];
        [imgvwChecker release];
        [lblRoute release];
        [vwLine release];
        
    }
    
    
    // 팝업 메인뷰 삽입
    [_vwCarRouteSelectorPopup addSubview:vwSelectorMain];
    [self.view addSubview:_vwCarRouteSelectorPopup];
    
    [vwSelectorMain release];
    [imgvwSelectorMainBack release];
    [lblSelectorMainTitle release];
    [btnCancel release];
    
}

- (void) closeCarRouteSelector :(id)sender
{
    for (UIView *subView in _vwCarRouteSelectorPopup.subviews)
    {
        [subView removeFromSuperview];
    }
    
    [_vwCarRouteSelectorPopup removeFromSuperview];
}

- (void) onCarRouteSelectorCell_Down :(id)sender
{
    UIControl *cell =(UIControl*)sender;
    
    UIView *vwSelectorMain = cell.superview;
    
    // 전부 아이콘 제거
    for (UIView *subview in vwSelectorMain.subviews)
    {
        if ( subview.tag >= 999+1 && subview.tag <= 999+4) // 셀 뷰일때만..
            for (UIView *imgvw in subview.subviews)
            {
                if ([imgvw isKindOfClass:[UIImageView class]])
                {
                    if (subview.tag == cell.tag)
                        [((UIImageView*)imgvw) setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
                    else
                        [((UIImageView*)imgvw) setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
                }
            }
    }
}
- (void) onCarRouteSelectorCell_Up :(id)sender
{
    UIControl *cell =(UIControl*)sender;
    
    UIView *vwSelectorMain = cell.superview;
    
    // 전부 아이콘 제거
    for (UIView *subview in vwSelectorMain.subviews)
    {
        if ( subview.tag >= 999+1 && subview.tag <= 999+4) // 셀 뷰일때만..
            for (UIView *imgvw in subview.subviews)
            {
                if ([imgvw isKindOfClass:[UIImageView class]])
                {
                    if (imgvw.tag == _currentRouteCarSelector)
                        [((UIImageView*)imgvw) setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
                    else
                        [((UIImageView*)imgvw) setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
                }
            }
    }
}

- (void) searchRouteCarRealTime :(id)sender
{
    _currentRouteCarSelector = SearchRoute_Car_SearchType_RealTime;
    [self requestCarSearchRouteSelector];
}

- (void) searchRouteCarFreePass :(id)sender
{
    _currentRouteCarSelector = SearchRoute_Car_SearchType_FreePass;
    [self requestCarSearchRouteSelector];
}

- (void) searchRouteCarShortDistance :(id)sender
{
    _currentRouteCarSelector = SearchRoute_Car_SearchType_ShortDistance;
    [self requestCarSearchRouteSelector];
}

- (void) searchRouteCarHighWay :(id)sender
{
    _currentRouteCarSelector = SearchRoute_Car_SearchType_HighWay;
    [self requestCarSearchRouteSelector];
}

- (void) requestCarSearchRouteSelector
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    Coord crdStart = oms.searchResultRouteStart.coordLocationPoint;
    Coord crdVisit = oms.searchResultRouteVisit.coordLocationPoint;
    Coord crdEnd = oms.searchResultRouteDest.coordLocationPoint;
    
    // 길찾기 검색요청을 시도함
    [[ServerConnector sharedServerConnection] requestRouteSearch:self action:@selector(finishCarSearchRouteSelector:) SX:crdStart.x SY:crdStart.y EX:crdEnd.x EY:crdEnd.y RPType:0/*자동차검색*/ CoordType:7 VX1:crdVisit.x VY1:crdVisit.y Priority:_currentRouteCarSelector];
}
- (void) finishCarSearchRouteSelector :(ServerRequester*)request
{
    // 데이터 수신 완료
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        [self closeCarRouteSelector:nil];
        
        // 현재 경로 인덱스 초기화
        _currentRouteDetailPathIndex = -1;
        
        if (_currentViewRenderType == OM_SRRMV_ViewRenderType_CAR_MAP)
        {
            // 맵 렌더링
            [self renderCarMap];
        }
        else if (_currentViewRenderType == OM_SRRMV_ViewRenderType_CAR_LIST)
        {
            [self renderCarList];
        }
        else
        {
            // 지도 or 목록이 아니면 의미없음.
        }
    }
    // 데이터 수신 실패 // request 단에서 미리 네트워크 오류 메세지 처리함
    else
    {
        //[OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}

- (void) onCarListSelectDetailPathCell :(id)sender
{
    _currentRouteDetailPathIndex = ((UIControl*)sender).tag;
    [self renderCarMap];
}
- (void) onCarListSelectDetailPathCell_Down :(id)sender
{
    UIControl *cell = (UIControl*)sender;
    [cell setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0f)];
}
- (void) onCarListSelectDetailPathCell_UpOutside :(id)sender
{
    UIControl *cell = (UIControl*)sender;
    [cell setBackgroundColor:[UIColor whiteColor]];
}
// ********************************


// ================================
// [ 자동차 - 지도 - 렌더링 메소드 ]
// ================================

- (void) renderCarMap
{
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    //OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 자동차 - 지도 상태설정
    _currentViewRenderType = OM_SRRMV_ViewRenderType_CAR_MAP; // 자동차-길찾기
    
    // 현재 선택된 경로 인덱스는 그대로 유지한다
    //_currentRouteDetailPathIndex = -1; // -1 전체경로
    
    // 네비게이션 영역 렌더링
    [self renderCommonNavigationBar];
    
    // 하단 버튼 영역 렌더링 ( +OllehNavi )
    [self renderCommonBottomButtonsWithOllehNavi:YES];
    
    // 지도 컨테이너 뷰 사이즈 교정
    [_vwRoutePathMapContainer setFrame:CGRectMake(0, 37, [[UIScreen mainScreen] bounds].size.width,
                                                  [[UIScreen mainScreen] bounds].size.height -
                                                  [[UIApplication sharedApplication] statusBarFrame].size.height
                                                  - 74)];
    
    // 지도 컨테이너 뷰 클리어
    for (UIView *subView in _vwRoutePathMapContainer.subviews)
    {
        [subView removeFromSuperview];
    }
    [_vwRoutePathMapContainer removeFromSuperview];
    
    // 지도 컨테이너 뷰 삽입
    [self.view addSubview:_vwRoutePathMapContainer];
    [self.view bringSubviewToFront:_vwBottomButtonGroup];
    
    // 지도 삽입
    [mc showMapContainer:_vwRoutePathMapContainer :self];
    
    // 지도 위 버튼삽입
    [_vwRoutePathMapContainer addSubview:_btnMyLocation];
    [_vwRoutePathMapContainer addSubview:_btnMapTrafficInfo];
    [_vwRoutePathMapContainer addSubview:_btnMapRenderStyle];
    [_vwRoutePathMapContainer addSubview:_imgvwMapTrafficInfo];
    
    // 지도 컨테이너 뷰 위 내위치 반경 삽입
    [_vwRoutePathMapContainer addSubview:_imgvwMyArea];
    [_vwRoutePathMapContainer addSubview:_imgvwMyDirection];
    
    // 경로 폴리곤라인 렌더링
    [self renderCarMapPathPolygon];
    
    // 지도 하단 정보영역 렌더링
    [self renderCarMapRouteDetailPathInfo:_currentRouteDetailPathIndex];
    [self renderCarMapRouteSummaryInfo];
    
}

- (void) renderCarMapPathPolygon
{
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 기존 모든 오버레이 제거
    //[mc.kmap removeAllOverlays];
    [mc.kmap removeAllOverlaysWithoutTraffic];
    
    // 도보 라인 설정
    CoordList* coordListwalkS = [[CoordList alloc] init];
    CoordList* coordListwalkD = [[CoordList alloc] init];
    CoordList* coordListwalkV = [[CoordList alloc] init];
    
    // 상세포인트 오버레이 관리용 리스트 비우기..
    [_detailPointOverlays removeAllObjects];
    
    // 각 포인트 렌더링
    BOOL isCatchVisit = NO;
    for (NSDictionary *pdic in oms.searchRouteData.routeCarPoints)
    {
        // 출발/경유/도착 지점은 숫자 포인트를 찍지 않는다.
        if ([[pdic objectForKeyGC:@"Type"] intValue] == 999)
        {
            [coordListwalkS addCoord:CoordMake(oms.searchResultRouteStart.coordLocationPoint.x, oms.searchResultRouteStart.coordLocationPoint.y)];
            [coordListwalkS addCoord:CoordMake([[pdic objectForKeyGC:@"X"] doubleValue], [[pdic objectForKeyGC:@"Y"] doubleValue])];
            
            // 시작점 오버레이 렌더링
            RouteImageOverlay *imgovrStart = [[RouteImageOverlay alloc] initWithImage:[UIImage imageNamed:@"map_marker_start.png"]];
            [imgovrStart setRouteImageOverlayType:RouteImageOverlay_Type_Start];
            [imgovrStart setCoord:oms.searchResultRouteStart.coordLocationPoint];
            [imgovrStart setCenterOffset:CGPointMake( (int)(imgovrStart.imageSize.width/2), (int)(imgovrStart.imageSize.height) )];
            [imgovrStart setTag:10000];
            [imgovrStart setDelegate:self];
            [mc.kmap addOverlay:imgovrStart];
            [_detailPointOverlays addObject:imgovrStart];
            [imgovrStart release];
        }
        else if ([[pdic objectForKeyGC:@"Type"] intValue] == 1001)
        {
            [coordListwalkD addCoord:CoordMake(oms.searchResultRouteDest.coordLocationPoint.x, oms.searchResultRouteDest.coordLocationPoint.y)];
            [coordListwalkD addCoord:CoordMake([[pdic objectForKeyGC:@"X"] doubleValue], [[pdic objectForKeyGC:@"Y"] doubleValue])];
            
            // 도착점 오버레이 렌더링
            RouteImageOverlay *imgovrEnd = [[RouteImageOverlay alloc] initWithImage:[UIImage imageNamed:@"map_marker_stop"]];
            [imgovrEnd setRouteImageOverlayType:RouteImageOverlay_Type_Dest];
            [imgovrEnd setCoord:oms.searchResultRouteDest.coordLocationPoint];
            [imgovrEnd setCenterOffset:CGPointMake( (int)(imgovrEnd.imageSize.width/2), (int)(imgovrEnd.imageSize.height) )];
            [imgovrEnd setTag:[[pdic objectForKeyGC:@"Index"] intValue]+10000];
            if (isCatchVisit) [imgovrEnd setTag:imgovrEnd.tag+1];
            [imgovrEnd setDelegate:self];
            [mc.kmap addOverlay:imgovrEnd];
            [_detailPointOverlays addObject:imgovrEnd];
            [imgovrEnd release];
        }
        else if ([[pdic objectForKeyGC:@"Type"] intValue] == 1000)
        {
            [coordListwalkV addCoord:CoordMake(oms.searchResultRouteVisit.coordLocationPoint.x, oms.searchResultRouteVisit.coordLocationPoint.y)];
            [coordListwalkV addCoord:CoordMake([[pdic objectForKeyGC:@"X"] doubleValue], [[pdic objectForKeyGC:@"Y"] doubleValue])];
            
            // 경유지 발견한 뒤로는 인덱스를 1씩 늘려잡아준다.
            isCatchVisit = YES;
            
            // 경유지 오버레이 렌더링
            RouteImageOverlay *imgovrVisit = [[RouteImageOverlay alloc] initWithImage:[UIImage imageNamed:@"map_marker_via"]];
            [imgovrVisit setRouteImageOverlayType:RouteImageOverlay_Type_Visit];
            [imgovrVisit setCoord:oms.searchResultRouteVisit.coordLocationPoint];
            [imgovrVisit setCenterOffset:CGPointMake( (int)(imgovrVisit.imageSize.width/2), (int)(imgovrVisit.imageSize.height) )];
            [imgovrVisit setTag:[[pdic objectForKeyGC:@"Index"] intValue]+10000+1];
            [imgovrVisit setDelegate:self];
            [mc.kmap addOverlay:imgovrVisit];
            [_detailPointOverlays addObject:imgovrVisit];
            [imgovrVisit release];
        }
        else
        {
            Coord pCrd = CoordMake([[pdic objectForKeyGC:@"X"] doubleValue], [[pdic objectForKeyGC:@"Y"] doubleValue]);
            NSString *strImageName = [NSString stringWithFormat:@"marker_num_%03d.png", [[pdic objectForKeyGC:@"Index"] intValue]];
            RouteImageOverlay *imgovrPoint = [[RouteImageOverlay alloc] initWithImage:[UIImage imageNamed:strImageName]];
            [imgovrPoint setRouteImageOverlayType:RouteImageOverlay_Type_Normal];
            [imgovrPoint setCoord:pCrd];
            [imgovrPoint setCenterOffset:CGPointMake( (int)(imgovrPoint.imageSize.width/2), (int)(imgovrPoint.imageSize.height/2) )];
            [imgovrPoint setTag:[[pdic objectForKeyGC:@"Index"] intValue]+10000];
            if (isCatchVisit) [imgovrPoint setTag:imgovrPoint.tag+1];
            [imgovrPoint setDelegate:self];
            [mc.kmap addOverlay:imgovrPoint];
            [_detailPointOverlays addObject:imgovrPoint];
            [imgovrPoint release];
        }
    }
    
    // 자동차경로 (실선)
    _plovrPath.coordList = oms.searchRouteData.routeCarLinks;
    _plovrPath.lineWidth = 5;
    _plovrPath.delegate = self;
    _plovrPath.canShowBalloon = NO;
    //_plovrPath.strokeColor = CGColorCreateRGB(convertHexToDecimal(@"E8") ,convertHexToDecimal(@"35") ,convertHexToDecimal(@"6F") ,1.0f);
    SetPolylineOverlayStrokeColor(_plovrPath, convertHexToDecimal(@"1A") ,convertHexToDecimal(@"68") ,convertHexToDecimal(@"C9") ,1.0f);
    
    [mc.kmap addOverlay:_plovrPath];
    
    // 출발지 도보 (점선)
    _plovrWalk1.coordList = coordListwalkS;
    _plovrWalk1.lineWidth = 5;
    _plovrWalk1.delegate = self;
    _plovrWalk1.canShowBalloon = NO;
    //_plovrWalk1.strokeColor = CGColorCreateRGB(convertHexToDecimal(@"E8") ,convertHexToDecimal(@"35") ,convertHexToDecimal(@"6F") ,1.0f);
    SetPolylineOverlayStrokeColor(_plovrWalk1, convertHexToDecimal(@"1A") ,convertHexToDecimal(@"68") ,convertHexToDecimal(@"C9") ,1.0f);
    _plovrWalk1.lineType = kLineType_Dash;
    [mc.kmap addOverlay:_plovrWalk1];
    
    // 도착지 도보 (점선)
    _plovrWalk2.coordList = coordListwalkD;
    _plovrWalk2.lineWidth = 5;
    _plovrWalk2.delegate = self;
    _plovrWalk2.canShowBalloon = NO;
    //_plovrWalk2.strokeColor = CGColorCreateRGB(convertHexToDecimal(@"E8") ,convertHexToDecimal(@"35") ,convertHexToDecimal(@"6F") ,1.0f);
    SetPolylineOverlayStrokeColor(_plovrWalk2, convertHexToDecimal(@"1A") ,convertHexToDecimal(@"68") ,convertHexToDecimal(@"C9") ,1.0f);
    _plovrWalk2.lineType = kLineType_Dash;
    [mc.kmap addOverlay:_plovrWalk2];
    
    // 경유 도보 (점선)
    /* MIK.geun ::20120605 // 경유지의 경우 도보처리 하지 않기로함.*/
    // MIK.geun :: 20121128 // 경유지 다시 도보처리하기로함.
    _plovrWalk3.coordList = coordListwalkV;
    _plovrWalk3.lineWidth = 5;
    _plovrWalk3.delegate = self;
    _plovrWalk3.canShowBalloon = NO;
    SetPolylineOverlayStrokeColor(_plovrWalk3, convertHexToDecimal(@"1A") ,convertHexToDecimal(@"68") ,convertHexToDecimal(@"C9") ,1.0f);
    _plovrWalk3.lineType = kLineType_Dash;
    [mc.kmap addOverlay:_plovrWalk3];
    
    
    [coordListwalkS release];
    [coordListwalkD release];
    [coordListwalkV release];
    
}
- (void) renderCarMapRouteDetailPathInfo:(int)pathIndex
{
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 상세경로 포인트 인덱스가 -1일경우 전체경로로 처리
    _currentRouteDetailPathIndex = pathIndex;
    if (_currentRouteDetailPathIndex == -1)
    {
        //[self showRouteRouteImageOverlay:NO];
        
        // 경로 영역 계산후 전체경로가 나오도록 조정
        // MIK.geun :: 20120530 // 맵영역 하단에 경로정보(불투명) 사이즈 고려해야함.
        KBounds kb = oms.searchRouteData.routeCarMapArea;
        [mc.kmap zoomToExtent:kb];
        // MIK.geun :: 20120820 // zommToExtent 이후 바로 줌레벨 변경하려 했더니... 맵이 못견디고 죽어버린다.??? 이건 해제하도록 하자.
        //mc.kmap.zoomLevel--;
    }
    else if (_currentRouteDetailPathIndex >= 0 && _currentRouteDetailPathIndex <= oms.searchRouteData.routeCarPointCount)
    {
        
        //[self showRouteRouteImageOverlay:YES];
        NSDictionary *point = [oms.searchRouteData.routeCarPoints objectAtIndexGC:_currentRouteDetailPathIndex];
        
        // 출발지, 경유지, 도착지점은 별도로 이동
        if ( [[point objectForKeyGC:@"Type"] intValue] == 999 )
        {
            [mc.kmap setCenterCoordinate:oms.searchResultRouteStart.coordLocationPoint];
        }
        else if ( [[point objectForKeyGC:@"Type"] intValue] == 1000 )
        {
            [mc.kmap setCenterCoordinate:oms.searchResultRouteVisit.coordLocationPoint];
        }
        else if ( [[point objectForKeyGC:@"Type"] intValue] == 1001 )
        {
            [mc.kmap setCenterCoordinate:oms.searchResultRouteDest.coordLocationPoint];
        }
        else
        {
            Coord crd = CoordMake([[point objectForKeyGC:@"X"] doubleValue], [[point objectForKeyGC:@"Y"] doubleValue]);
            [mc.kmap setCenterCoordinate:crd];
        }
        
        // 선택된 상세포인트 오버레이 다시그리기. (가장위로 오도록)
        ImageOverlay *currentPointOverlay = [_detailPointOverlays objectAtIndexGC:_currentRouteDetailPathIndex];
        if ( currentPointOverlay )
        {
            [mc.kmap removeOverlay:currentPointOverlay];
            [mc.kmap addOverlay:currentPointOverlay];
        }
        
        // 지점 이동후 줌레벨은 12 (25m) 고정
        [mc.kmap setZoomLevel:12];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"[OllehMap Debug]" :@"잘못된 상세경로 인덱스가 처리되어 길찾기 첫화면으로 이동합니다."];
        // 강제로 전국지도로 태우자.
        [self renderCarMapRouteDetailPathInfo:-1];
        return; // 뒤로 이러지는 뷰렌더링 함수 타지 않도록
    }
    
    //  전국지도 번호 아이콘 노출여부
#if 0
    for (Overlay *overlay in mc.kmap.getOverlays)
    {
        if ( [overlay isKindOfClass:[RouteImageOverlay class]] )
        {
            RouteImageOverlay *riovr = (RouteImageOverlay*)overlay;
            if (  _currentRouteDetailPathIndex == -1 && riovr.routeImageOverlayType == RouteImageOverlay_Type_Normal  )
            {
                riovr.imageSize = CGSizeMake(0, 0);
            }
            else
            {
                riovr.imageSize = CGSizeMake(riovr.imageView.image.size.width, riovr.imageView.image.size.height);
            }
        }
    }
#endif
    
    // ******************
    // [ 뷰 렌더링 설정 ]
    // ******************
    
    // 기존 뷰 클리어
    for (UIView *subView in _vwCarRouteDetailPathInfoGroup.subviews)
    {
        [subView removeFromSuperview];
    }
    NSLog(@"_current : %d", _currentRouteDetailPathIndex);
    // 첫번째(안보임)
    [self renderCarMapRouteDetailPathInfoMiddle:_currentRouteDetailPathIndex-1 :0];
    [self renderCarMapRouteDetailPathInfoMiddle:_currentRouteDetailPathIndex+1 :640];
    // 가운데(보임)
    [self renderCarMapRouteDetailPathInfoMiddle :_currentRouteDetailPathIndex:320];
    // 마지막(안보임)
    
    CGRect scrollRect = [_vwCarRouteDetailPathInfoGroup frame];
    
    if(_currentRouteDetailPathIndex != -1)
    {
        scrollRect.origin.y = 326;
    }
    
    CGRect detailRect = [_vwCarRouteDetailPathInfoGroup frame];
    
    NSLog(@"%f", scrollRect.origin.y);
    scrollRect.size.width *= 3;
    scrollRect.origin.x = -320;
    detailRect.origin.x = 320;
    detailRect.origin.y = 0;
    
    NSLog(@"scrollRect : %@ detailRect : %@", NSStringFromCGRect(scrollRect), NSStringFromCGRect(detailRect));
    
    [_scrollView removeFromSuperview];
    [_vwCarRouteDetailPathInfoGroup removeFromSuperview];
    
    [_scrollView setFrame:scrollRect];
    
    NSLog(@"scrollRect : %@ detailRect : %@", NSStringFromCGRect(scrollRect), NSStringFromCGRect(detailRect));
    [_vwCarRouteDetailPathInfoGroup setFrame:detailRect];
    [_scrollView setContentOffset:CGPointMake(320, 60)];
    // 여긴건들지마
    
    [_vwCarRouteDetailPathInfoGroup setFrame:CGRectMake(0, 0, 320 * 3, scrollRect.size.height)];
    
    //[_scrollView setFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-20-37-37-scrollRect.size.height, 320, scrollRect.size.height)];
    
    [_scrollView setFrame:CGRectMake(0, self.view.frame.size.height- 37 - 37 - scrollRect.size.height, 320, scrollRect.size.height)];
    
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    //[_scrollView setBackgroundColor:[UIColor yellowColor]];
    [_scrollView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"info_bg.png"]]];
    [_scrollView addSubview:_vwCarRouteDetailPathInfoGroup];
    [_vwRoutePathMapContainer addSubview:_scrollView];
    
}
- (void) renderCarMapRouteDetailPathInfoMiddle :(int)pathIndex : (int)viewSight
{
    
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    
    int maxIndexCount = oms.searchRouteData.routeCarPointCount-1;
    if (oms.searchResultRouteVisit.used) maxIndexCount++;
    
    NSLog(@"maxCount : %d", maxIndexCount);
    
    if (pathIndex == -1) // 전체경로 일때..
    {
        // 거리
        CGRect rectDistance = CGRectMake(35 + viewSight, 12, 0, 0);
        UILabel *lblDistance = [[UILabel alloc] initWithFrame:rectDistance];
        [lblDistance setFont:[UIFont boldSystemFontOfSize:16]];
        [lblDistance setText:[NSString stringWithFormat:@"약 %@",[self getDistanceRefined:oms.searchRouteData.routeCarTotalDistance]]];
        [lblDistance setTextColor:convertHexToDecimalRGBA(@"2F", @"C9", @"EB", 1.0f)];
        [lblDistance setBackgroundColor:[UIColor clearColor]];
        rectDistance.size = [lblDistance.text sizeWithFont:lblDistance.font constrainedToSize:CGSizeMake(FLT_MAX, 16) lineBreakMode:NSLineBreakByClipping];
        [lblDistance setFrame:rectDistance];
        [_vwCarRouteDetailPathInfoGroup addSubview:lblDistance];
        
        // 시간
        CGRect rectTime = CGRectMake(35+rectDistance.size.width+15 + viewSight, 12, 0, 0);
        UILabel *lblTime = [[UILabel alloc] initWithFrame:rectTime];
        [lblTime setFont:[UIFont boldSystemFontOfSize:16]];
        [lblTime setText:[NSString stringWithFormat:@"약 %@",[self getTimeRefined:oms.searchRouteData.routeCarTotalTime]]];
        [lblTime setTextColor:convertHexToDecimalRGBA(@"2F", @"C9", @"EB", 1.0f)];
        [lblTime setBackgroundColor:[UIColor clearColor]];
        rectTime.size = [lblTime.text sizeWithFont:lblTime.font constrainedToSize:CGSizeMake(FLT_MAX, 16) lineBreakMode:NSLineBreakByClipping];
        [lblTime setFrame:rectTime];
        [_vwCarRouteDetailPathInfoGroup addSubview:lblTime];
        
        // 택시비
        UILabel *lblTaxi = [[UILabel alloc] initWithFrame:CGRectMake(35+viewSight, 35, 217, 13)];
        [lblTaxi setFont:[UIFont systemFontOfSize:13]];
        [lblTaxi setTextColor:[UIColor whiteColor]];
        [lblTaxi setBackgroundColor:[UIColor clearColor]];
        [lblTaxi setText:[NSString stringWithFormat:@"택시비 약 %@원", [self getTaxiFareRefined:oms.searchRouteData.routeCarTotalDistance localCode:oms.searchRouteData.routeCarTotalTime]]];
        [_vwCarRouteDetailPathInfoGroup addSubview:lblTaxi];
        
        // 재미삼아
        /*
         if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.1f)
         [lblTaxi setText:[NSString stringWithFormat:@"택시비 😱 약 %@원 😭💦", [self getTaxiFareRefined:oms.searchRouteData.routeCarTotalDistance localCode:0]]];
         */
        
        // 길찾기 경로정보 뷰 정리
        [_vwCarRouteDetailPathInfoGroup setFrame:CGRectMake(0+viewSight, [[UIScreen mainScreen] bounds].size.height-20-37-37-60, 320, 60)];
        //        UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_bg.png"]];
        //        [imgvwBack setFrame:CGRectMake(0+viewSight, 0, 320, 60)];
        //[_vwCarRouteDetailPathInfoGroup insertSubview:imgvwBack atIndex:0];
        [_vwRoutePathMapContainer addSubview:_vwCarRouteDetailPathInfoGroup];
        
        [lblDistance release];
        [lblTime release];
        [lblTaxi release];
        //[imgvwBack release];
    }
    else if (pathIndex == -2 || pathIndex > maxIndexCount)
    {
        //        UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_bg.png"]];
        //        [imgvwBack setFrame:CGRectMake(viewSight, 0, 320, 60)];
        //[_vwCarRouteDetailPathInfoGroup insertSubview:imgvwBack atIndex:0];
        [_vwRoutePathMapContainer addSubview:_vwCarRouteDetailPathInfoGroup];
        //[imgvwBack release];
        return;
    }
    // 세부경로 - 출발/도착/경유
    else if ( [[[oms.searchRouteData.routeCarPoints objectAtIndexGC:pathIndex] objectForKeyGC:@"Type"] intValue] >= 999
             && [[[oms.searchRouteData.routeCarPoints objectAtIndexGC:pathIndex] objectForKeyGC:@"Type"] intValue] <= 1001)
    {
        int type = [[[oms.searchRouteData.routeCarPoints objectAtIndexGC:pathIndex] objectForKeyGC:@"Type"] intValue];
        
        UILabel *lblPointName = [[UILabel alloc] initWithFrame:CGRectMake(75+viewSight, 0, 218, 13)];
        [lblPointName setFont:[UIFont systemFontOfSize:13]];
        [lblPointName setTextColor:[UIColor whiteColor]];
        [lblPointName setLineBreakMode:NSLineBreakByClipping];
        [lblPointName setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *imgvwIcon;
        
        if (type == 999)
        {
            [lblPointName setText:oms.searchResultRouteStart.strLocationName];
            imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"start.png"]];
        }
        else if (type == 1000)
        {
            [lblPointName setText:oms.searchResultRouteVisit.strLocationName];
            imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"via.png"]];
        }
        else if (type == 1001)
        {
            [lblPointName setText:oms.searchResultRouteDest.strLocationName];
            imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stop.png"]];
        }
        // 이런경우는 없지만 경고문을 처리위해..
        else
        {
            [lblPointName setText:@""];
            imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stop.png"]];
        }
        
        // 텍스트 사이즈 구하기
        CGRect rectPointName = lblPointName.frame;
        rectPointName.size = [lblPointName.text sizeWithFont:lblPointName.font constrainedToSize:CGSizeMake(218, FLT_MAX) lineBreakMode:lblPointName.lineBreakMode];
        int textMaxLine = rectPointName.size.height / 13;
        if (((int)rectPointName.size.height) % 13 > 0) textMaxLine++;
        [lblPointName setNumberOfLines:textMaxLine];
        
        // 길찾기 경로정보 뷰 정리 (구해진 텍스트 사이즈를 기준으로 상위 뷰 사이즈 재조정)
        CGRect rectCarRouteDetailPathInfoGroup = _vwCarRouteDetailPathInfoGroup.frame;
        
        if (lblPointName.frame.size.height + 25 > 60)
            rectCarRouteDetailPathInfoGroup.size.height = lblPointName.frame.size.height + 25;
        else
            rectCarRouteDetailPathInfoGroup.size.height = 60;
        
        [_vwCarRouteDetailPathInfoGroup setFrame:rectCarRouteDetailPathInfoGroup];
        //        UIImageView *imgvwBackm = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_bg.png"]];
        //        [imgvwBackm setFrame:CGRectMake(0+viewSight, 0, 320, rectCarRouteDetailPathInfoGroup.size.height)];
        //[_vwCarRouteDetailPathInfoGroup addSubview:imgvwBackm];
        //        [_vwCarRouteDetailPathInfoGroup insertSubview:imgvwBack atIndex:0];
        [_vwRoutePathMapContainer addSubview:_vwCarRouteDetailPathInfoGroup];
        
        // 텍스트 사이즈 재조정
        rectPointName.origin.y = (rectCarRouteDetailPathInfoGroup.size.height - rectPointName.size.height) / 2;
        [lblPointName setFrame:rectPointName];
        [_vwCarRouteDetailPathInfoGroup addSubview:lblPointName];
        
        // 아이콘 사이즈
        CGRect rectIcon = imgvwIcon.frame;
        rectIcon.origin.y = (rectCarRouteDetailPathInfoGroup.size.height - rectIcon.size.height) / 2;
        rectIcon.origin.x = 25 + viewSight;
        [imgvwIcon setFrame:rectIcon];
        [_vwCarRouteDetailPathInfoGroup addSubview:imgvwIcon];
        
        [lblPointName release];
        [imgvwIcon release];
        //[imgvwBackm release];
        
    }
    
    // 세부경로 - 포인트
    else
    {
        // 세부경로 데이터 조회
        NSDictionary *dic = [oms.searchRouteData.routeCarPoints objectAtIndexGC:pathIndex];
        
        // 상세 길안내 라벨 생성
        //UILabel *lblPointName = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 159, 13)];
        UILabel *lblPointName = [[UILabel alloc] initWithFrame:CGRectMake(102+viewSight, 0, 191+11, 13)];
        [lblPointName setFont:[UIFont systemFontOfSize:13]];
        [lblPointName setTextColor:[UIColor whiteColor]];
        [lblPointName setLineBreakMode:NSLineBreakByClipping];
        [lblPointName setBackgroundColor:[UIColor clearColor]];
        
        // 상세 길안내
        NSMutableString *strPath = [NSMutableString string];
        if ( [[dic objectForKeyGC:@"Type"] intValue] >= 0 )
        {
            [strPath appendFormat:@"%@ 이동 후 " , [self getDistanceRefined:[[dic objectForKeyGC:@"NextDistance"] intValue]]];
            
            NSString *strDirection = [NSString stringWithFormat:@"%@", [dic objectForKeyGC:@"Direction"]];
            if (strDirection.length > 0)
                [strPath appendFormat:@"%@ 방향 " , strDirection];
            [strPath appendFormat:@"%@", [self getSearchRouteCarRGType:[[dic objectForKeyGC:@"Type"] intValue]]];
        }
        else
            [strPath appendFormat:@"%@ 이동 " , [self getDistanceRefined:[[dic objectForKeyGC:@"NextDistance"] intValue]]];
        
        [lblPointName setText:strPath];
        
        // 아이콘 이미지
        UIImageView *imgvwDirection = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%02d.png", [[dic objectForKeyGC:@"Type"] intValue ] ]]];
        UIImageView *imgvwIndex = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"marker_num_%03d.png", [[dic objectForKeyGC:@"Index"] intValue]]]];
        
        // 텍스트 사이즈 구하기
        CGRect rectPointName = lblPointName.frame;
        rectPointName.size = [lblPointName.text sizeWithFont:lblPointName.font constrainedToSize:CGSizeMake(191, FLT_MAX) lineBreakMode:lblPointName.lineBreakMode];
        /*
         int textMaxLine = rectPointName.size.height / 13;
         if (((int)rectPointName.size.height) % 13 > 0) textMaxLine++;
         [lblPointName setNumberOfLines:textMaxLine];
         */
        [lblPointName setNumberOfLines:999];
        
        // 길찾기 경로정보 뷰 정리 (구해진 텍스트 사이즈를 기준으로 상위 뷰 사이즈 재조정)
        CGRect rectCarRouteDetailPathInfoGroup = _vwCarRouteDetailPathInfoGroup.frame;
        if (rectPointName.size.height + 22 > 60)
        {
            rectCarRouteDetailPathInfoGroup.size.height = rectPointName.size.height + 22;
        }
        else
        {
            rectCarRouteDetailPathInfoGroup.size.height = 60;
        }
        rectCarRouteDetailPathInfoGroup.origin.y = [[UIScreen mainScreen] bounds].size.height - 20 - 37 - 37 - rectCarRouteDetailPathInfoGroup.size.height;
        [_vwCarRouteDetailPathInfoGroup setFrame:rectCarRouteDetailPathInfoGroup];
        
        //        UIImageView *imgvwBacke = [[UIImageView alloc] init];
        //        [imgvwBacke setImage:[UIImage imageNamed:@"info_bg.png"]];
        //        [imgvwBacke setFrame:CGRectMake(0+viewSight, 0, 320, rectCarRouteDetailPathInfoGroup.size.height)];
        //[_vwCarRouteDetailPathInfoGroup addSubview:imgvwBacke];
        //[_vwCarRouteDetailPathInfoGroup insertSubview:imgvwBack atIndex:0];
        [_scrollView addSubview:_vwCarRouteDetailPathInfoGroup];
        
        // 텍스트 사이즈 재조정
        rectPointName.origin.y = (rectCarRouteDetailPathInfoGroup.size.height - rectPointName.size.height) / 2;
        [lblPointName setFrame:rectPointName];
        [_vwCarRouteDetailPathInfoGroup addSubview:lblPointName];
        
        // 아이콘 사이즈
        CGRect rectDirection = imgvwDirection.frame;
        rectDirection.origin.y = (rectCarRouteDetailPathInfoGroup.size.height - rectDirection.size.height) / 2;
        rectDirection.origin.x = 25 + viewSight;
        [imgvwDirection setFrame:rectDirection];
        [_vwCarRouteDetailPathInfoGroup addSubview:imgvwDirection];
        CGRect rectIndex = imgvwIndex.frame;
        rectIndex.origin.y = (rectCarRouteDetailPathInfoGroup.size.height - rectIndex.size.height) / 2;
        rectIndex.origin.x = 71 + viewSight;
        [imgvwIndex setFrame:rectIndex];
        [_vwCarRouteDetailPathInfoGroup addSubview:imgvwIndex];
        
        [lblPointName release];
        [imgvwDirection release];
        [imgvwIndex release];
        //[imgvwBacke release];
        
    }
    
    
    
    // *************
    // [ 버튼 처리 ]
    // *************
    
    // 이전 경로 버튼
    UIButton *btnRoutePathPrev = [[UIButton alloc] initWithFrame:CGRectMake(viewSight, (60-35)/2, 25, 35)];
    [btnRoutePathPrev setImage:[UIImage imageNamed:@"info_btn_arrow_left.png"] forState:UIControlStateNormal];
    [btnRoutePathPrev setImage:[UIImage imageNamed:@"info_btn_arrow_left_disabled.png"] forState:UIControlStateDisabled];
    [btnRoutePathPrev addTarget:self action:@selector(onCarRoutePathPrev:) forControlEvents:UIControlEventTouchUpInside];
    [_vwCarRouteDetailPathInfoGroup addSubview:btnRoutePathPrev];
    [btnRoutePathPrev release];
    
    // 다음 경로 버튼
    UIButton *btnRoutePathNext = [[UIButton alloc] initWithFrame:CGRectMake(295 + viewSight, (60-35)/2, 25, 35)];
    [btnRoutePathNext setImage:[UIImage imageNamed:@"info_btn_arrow_right.png"] forState:UIControlStateNormal];
    [btnRoutePathNext setImage:[UIImage imageNamed:@"info_btn_arrow_right_disabled.png"] forState:UIControlStateDisabled];
    [btnRoutePathNext addTarget:self action:@selector(onCarRoutePathNext:) forControlEvents:UIControlEventTouchUpInside];
    [_vwCarRouteDetailPathInfoGroup addSubview:btnRoutePathNext];
    [btnRoutePathNext release];
    
    // 버튼 중앙정렬
    CGRect rectButton = btnRoutePathPrev.frame;
    rectButton.origin.y = (_vwCarRouteDetailPathInfoGroup.frame.size.height - rectButton.size.height) / 2;
    [btnRoutePathPrev setFrame:rectButton];
    rectButton.origin.x = btnRoutePathNext.frame.origin.x;
    [btnRoutePathNext setFrame:rectButton];
    
    // 상세경로 이동버튼 (좌 : 전체지도 일경우 더이상 뒤로 갈수 없으므로 비활성화)
    if (_currentRouteDetailPathIndex <= -1) [btnRoutePathPrev setEnabled:NO];
    // 상세경로 이동버튼 (우 : 도착점일 경우 더이상 진행불가, 경유지 포함여부 고려해야함)
    
    // MIK.geun :: 20121128
    // 현재 메소드 상위라인에 아래 두줄 선처리 되어 있음.. 왜 그렇게 된거지????
    //int maxIndexCount = oms.searchRouteData.routeCarPointCount-1;
    //if (oms.searchResultRouteVisit.used) maxIndexCount++;
    
    NSLog(@"maxCount : %d", maxIndexCount);
    
    if (_currentRouteDetailPathIndex >= maxIndexCount) [btnRoutePathNext setEnabled:NO];
    
    NSLog(@"%f, %f", _scrollView.frame.origin.x, _scrollView.frame.origin.y);
    
    return;
    
    CGRect scrollRect = [_vwCarRouteDetailPathInfoGroup frame];
    
    if(_currentRouteDetailPathIndex != -1)
    {
        scrollRect.origin.y = 326;
    }
    
    CGRect detailRect = [_vwCarRouteDetailPathInfoGroup frame];
    
    NSLog(@"%f", scrollRect.origin.y);
    scrollRect.size.width *= 3;
    scrollRect.origin.x = -320;
    detailRect.origin.x = 320;
    detailRect.origin.y = 0;
    
    NSLog(@"scrollRect : %@ detailRect : %@", NSStringFromCGRect(scrollRect), NSStringFromCGRect(detailRect));
    
    [_scrollView removeFromSuperview];
    [_vwCarRouteDetailPathInfoGroup removeFromSuperview];
    
    [_scrollView setFrame:scrollRect];
    
    NSLog(@"scrollRect : %@ detailRect : %@", NSStringFromCGRect(scrollRect), NSStringFromCGRect(detailRect));
    [_vwCarRouteDetailPathInfoGroup setFrame:detailRect];
    //ver3
    
    
    
    [_vwRoutePathMapContainer addSubview:_scrollView];
    [_scrollView addSubview:_vwCarRouteDetailPathInfoGroup];
    
    //_vwCarRouteDetailPathInfoGroup
    //_vwRoutePathMapContainer removeFromSuperview
}

- (void) renderCarMapRouteSummaryInfo
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 요약정보 뷰 클리어
    for (UIView *subView in _vwCarRouteSummaryInfoGroup.subviews)
    {
        [subView removeFromSuperview];
    }
    
    // 요약정보 배경
    UIImageView *imgvwBackLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_align_bg_01.png"]];
    [imgvwBackLeft setFrame:CGRectMake(0, 0, 241, 31)];
    [_vwCarRouteSummaryInfoGroup addSubview:imgvwBackLeft];
    UIImageView *imgvwBackRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_align_bg_02.png"]];
    [imgvwBackRight setFrame:CGRectMake(241, 0, 79, 31)];
    [_vwCarRouteSummaryInfoGroup addSubview:imgvwBackRight];
    
    // 요약정보 라벨
    UILabel *lblRouteSummaryPath = [[UILabel alloc] initWithFrame:CGRectMake(7, 9, 219, 13)];
    [lblRouteSummaryPath setLineBreakMode:NSLineBreakByTruncatingTail];
    [lblRouteSummaryPath setFont:[UIFont boldSystemFontOfSize:13]];
    [lblRouteSummaryPath setBackgroundColor:[UIColor clearColor]];
    [lblRouteSummaryPath setTextColor:[UIColor whiteColor]];
    [lblRouteSummaryPath setLineBreakMode:NSLineBreakByTruncatingTail];
    NSString *routeSummaryPathText = [NSString stringWithFormat:@"%@ ➜ %@", oms.searchResultRouteStart.strLocationName, oms.searchResultRouteDest.strLocationName];
    CGSize sizeRouteSummaryPathText = [routeSummaryPathText sizeWithFont:lblRouteSummaryPath.font constrainedToSize:CGSizeMake(FLT_MAX, 13) lineBreakMode:lblRouteSummaryPath.lineBreakMode];
    if ( sizeRouteSummaryPathText.width > 219 )
    {
        NSArray *sidoList = [[NSArray alloc] initWithObjects:@"서울특별시 ", @"인천광역시 ", @"광주광역시 ", @"대전광역시 ", @"대구광역시 ", @"울산광역시 ", @"부산광역시 ", @"경기도 ", @"충청북도 ", @"충청남도 ", @"전라북도 ", @"전라남도 ", @"강원도 ", @"경상북도 ", @"경상남도 ", @"제주도 ", nil];
        
        // 출발지 처리
        NSArray *startAddressComponents = [oms.searchResultRouteStart.strLocationName componentsSeparatedByString:@" "];
        NSMutableString *startAddressNonSido = [[NSMutableString alloc] init];
        // 주소가 확실한 경우
        if ( [oms.searchResultRouteStart.strType isEqualToString:@"ADDR"]  && startAddressComponents && startAddressComponents.count > 1)
        {
            for (int i =1, maxi=startAddressComponents.count; i < maxi; i++)
            {
                [startAddressNonSido appendFormat:@"%@ ", [startAddressComponents objectAtIndexGC:i] ];
            }
        }
        // 불분명한 경우
        else  if ( [oms.searchResultRouteStart.strType isEqualToString:@""]  && startAddressComponents && startAddressComponents.count > 1)
        {
            // 미리 기본값 하나 설정하고 들어감
            [startAddressNonSido setString:oms.searchResultRouteStart.strLocationName];
            // 잘라내기 시작
            for (NSString *sido in sidoList)
            {
                NSRange range = [oms.searchResultRouteStart.strLocationName rangeOfString:sido];
                if ( range.location != NSNotFound)
                {
                    [startAddressNonSido setString: [oms.searchResultRouteStart.strLocationName substringFromIndex:range.length] ];
                    break;
                }
            }
        }
        else
            [startAddressNonSido setString:oms.searchResultRouteStart.strLocationName];
        
        
        // 도착지 처리
        NSArray *destAddressComponents = [oms.searchResultRouteDest.strLocationName componentsSeparatedByString:@" "];
        NSMutableString *destAddressNonSido = [[NSMutableString alloc] init];
        // 주소가 확실한 경우
        if ( [oms.searchResultRouteDest.strType isEqualToString:@"ADDR"] && destAddressComponents && destAddressComponents.count > 1)
        {
            for (int i =1, maxi=destAddressComponents.count; i < maxi; i++)
            {
                [destAddressNonSido appendFormat:@"%@ ", [destAddressComponents objectAtIndexGC:i] ];
            }
        }
        // 불분명한 경우
        else  if ( [oms.searchResultRouteDest.strType isEqualToString:@""]  && destAddressComponents && destAddressComponents.count > 1)
        {
            // 미리 기본값 하나 설정하고 들어감
            [destAddressNonSido setString:oms.searchResultRouteDest.strLocationName];
            // 잘라내기 시작
            for (NSString *sido in sidoList)
            {
                NSRange range = [oms.searchResultRouteDest.strLocationName rangeOfString:sido];
                if ( range.location != NSNotFound)
                {
                    [destAddressNonSido setString: [oms.searchResultRouteDest.strLocationName substringFromIndex:range.length] ];
                    break;
                }
            }
        }
        else
            [destAddressNonSido setString:oms.searchResultRouteDest.strLocationName];
        
        
        // 조합
        routeSummaryPathText = [NSString stringWithFormat:@"%@ ➜ %@", startAddressNonSido, destAddressNonSido];
        
        // 필수자료들 해제
        [startAddressNonSido release];
        [destAddressNonSido release];
        [sidoList release];
    }
    
    
    [lblRouteSummaryPath setText:routeSummaryPathText];
    
    [_vwCarRouteSummaryInfoGroup addSubview:lblRouteSummaryPath];
    
#if 0
    // MIK.geun :: 20120612
    // iOS자체 Truncation 사용해서 말줄임처리 할경우 끝자리가 약간 어색해서 커스터마이징 처리함.
    [lblRouteSummaryPath setLineBreakMode:NSLineBreakByCharWrapping];
    CGRect rectRouteSummaryPath = lblRouteSummaryPath.frame;
    rectRouteSummaryPath.size = [lblRouteSummaryPath.text sizeWithFont:lblRouteSummaryPath.font constrainedToSize:CGSizeMake(FLT_MAX, 13) lineBreakMode:lblRouteSummaryPath.lineBreakMode];
    if (rectRouteSummaryPath.size.width > 219)
    {
        [lblRouteSummaryPath setFrame:CGRectMake(7, 9, 200, 13)];
        UILabel *lblRouteSummaryPathTruncation = [[UILabel alloc] initWithFrame:CGRectMake(7+208-3, 9, 19, 13)];
        [lblRouteSummaryPathTruncation setFont:[UIFont boldSystemFontOfSize:13]];
        [lblRouteSummaryPathTruncation setBackgroundColor:[UIColor clearColor]];
        [lblRouteSummaryPathTruncation setTextColor:[UIColor whiteColor]];
        [lblRouteSummaryPathTruncation setText:@"…"];
        [_vwCarRouteSummaryInfoGroup addSubview:lblRouteSummaryPathTruncation];
        [lblRouteSummaryPathTruncation release];
    }
#endif
    
    [imgvwBackLeft release];
    [imgvwBackRight release];
    [lblRouteSummaryPath release];
    
    
    
    // 길찾기 요약정보 뷰 삽입
    [_vwCarRouteSummaryInfoGroup setFrame:CGRectMake(0, _scrollView.frame.origin.y-31, 320, 31)];
    [_vwRoutePathMapContainer addSubview:_vwCarRouteSummaryInfoGroup];
    
    UILabel *lblRouteSelector = [[UILabel alloc] initWithFrame:CGRectMake(256, 9, 79, 13)];
    [lblRouteSelector setFont:[UIFont boldSystemFontOfSize:13]];
    [lblRouteSelector setLineBreakMode:NSLineBreakByClipping];
    [lblRouteSelector setBackgroundColor:[UIColor clearColor]];
    [lblRouteSelector setTextColor:[UIColor whiteColor]];
    UIImageView *imgvwRouteSelector = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_btn_align_arrow.png"]];
    [_vwCarRouteSummaryInfoGroup addSubview:imgvwRouteSelector];
    
    // 길찾기 경로선택 옵션 SearchRoute_Car_SearchType_XXX
    switch (_currentRouteCarSelector)
    {
        case SearchRoute_Car_SearchType_RealTime:
            [lblRouteSelector setText:@"실시간"];
            [lblRouteSelector setFrame:CGRectMake(510/2, 18/2, 80/2, 26/2)];
            [imgvwRouteSelector setFrame:CGRectMake(590/2, 24/2, 22/2, 16/2)];
            break;
        case SearchRoute_Car_SearchType_FreePass:
            [lblRouteSelector setText:@"무료"];
            [lblRouteSelector setFrame:CGRectMake(522/2, 18/2, 56/2, 26/2)];
            [imgvwRouteSelector setFrame:CGRectMake(578/2, 24/2, 22/2, 16/2)];
            break;
        case SearchRoute_Car_SearchType_HighWay:
            [lblRouteSelector setText:@"고속"];
            [lblRouteSelector setFrame:CGRectMake(522/2, 18/2, 56/2, 26/2)];
            [imgvwRouteSelector setFrame:CGRectMake(578/2, 24/2, 22/2, 16/2)];
            break;
        case SearchRoute_Car_SearchType_ShortDistance:
            [lblRouteSelector setText:@"최단"];
            [lblRouteSelector setFrame:CGRectMake(522/2, 18/2, 56/2, 26/2)];
            [imgvwRouteSelector setFrame:CGRectMake(578/2, 24/2, 22/2, 16/2)];
            break;
    }
    
    /*
     // 라벨 & 이미지 사이즈 조절
     CGRect rectRouteSelector = lblRouteSelector.frame;
     rectRouteSelector.size = [lblRouteSelector.text sizeWithFont:lblRouteSelector.font constrainedToSize:CGSizeMake(FLT_MAX, 13) lineBreakMode:lblRouteSelector.lineBreakMode];
     rectRouteSelector.size.height = 13;
     rectRouteSelector.origin.x = 241 + ((79-rectRouteSelector.size.width-11)/2) - 1;
     [lblRouteSelector setFrame:rectRouteSelector];
     [imgvwRouteSelector setFrame:CGRectMake(rectRouteSelector.origin.x+rectRouteSelector.size.width+1, 11, 11, 8)];
     */
    // 라벨&이미지 삽입
    [_vwCarRouteSummaryInfoGroup addSubview:lblRouteSelector];
    [_vwCarRouteSummaryInfoGroup addSubview:imgvwRouteSelector];
    
    // 터치이벤트
    UIControl *ctrlSelector = [[UIControl alloc] initWithFrame:CGRectMake(241, 0, 79, 31)];
    [ctrlSelector setBackgroundColor:[UIColor clearColor]];
    [ctrlSelector addTarget:self action:@selector(showCarRouteSelector:) forControlEvents:UIControlEventTouchUpInside];
    [_vwCarRouteSummaryInfoGroup addSubview:ctrlSelector];
    
    [lblRouteSelector release];
    [imgvwRouteSelector release];
    [ctrlSelector release];
}

- (void) onCarRoutePathPrev :(id)sender
{
    [self toggleMyLocationMode:MapLocationMode_None];
    [self renderCarMapRouteDetailPathInfo:_currentRouteDetailPathIndex-1];
    [self renderCarMapRouteSummaryInfo];
}

- (void) onCarRoutePathNext :(id)sender
{
    [self toggleMyLocationMode:MapLocationMode_None];
    [self renderCarMapRouteDetailPathInfo:_currentRouteDetailPathIndex+1];
    [self renderCarMapRouteSummaryInfo];
}

// ********************************


// ================================
// [ 자동차 - 목록 - 렌더링 메소드 ]
// ================================

- (void) renderCarList
{
    // 자동차 - 지도 상태설정
    _currentViewRenderType = OM_SRRMV_ViewRenderType_CAR_LIST; // 자동차-길찾기
    
    // 현재 선택된 경로 인덱스는 그대로 유지한다 (지도 특정 지점에서 넘어왔을 경우 셀 배경 처리필요)
    //_currentRouteDetailPathIndex = -1; // -1 전체경로
    
    // 네비게이션 영역 렌더링
    [self renderCommonNavigationBar];
    
    // 하단 버튼 영역 렌더링 ( +OllehNavi )
    [self renderCommonBottomButtonsWithOllehNavi:YES];
    
    // 목록 컨테이너 뷰 클리어
    for (UIView *subView in _vwRoutePathListContainer.subviews)
    {
        [subView removeFromSuperview];
    }
    [_vwRoutePathListContainer removeFromSuperview];
    
    // 지도 컨테이너 뷰 삽입
    [self.view addSubview:_vwRoutePathListContainer];
    
    // 요약정보 및 테이블 렌더링
    [self renderCarListRouteSummaryInfo];
    [self renderCarListRouteDetailPathTable];
}

- (void) renderCarListRouteSummaryInfo
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    /* 지도화면에서는 특정 포인트 이동시 다시 렌더링해야 하는 이유로 _vwCarRouteSummaryInfoGroup 변수로 관리하지만
     목록에서는 뷰컨트롤러 생성시 한번만 생성하면 끝이므로 일회성으로 관리한다.
     */
    
    // *****************
    // [ 목록 요약정보 ]
    // *****************
    
    // 목록 요약정보 뷰 생성
    UIView *vwCarRouteSummaryInfo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
    [vwCarRouteSummaryInfo setBackgroundColor:[UIColor orangeColor]];
    
    // 목록 요약정보 뷰 - 전체경로 라벨
    UILabel *lblCarRouteSummaryInfoPath = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 221, 15)];
    [lblCarRouteSummaryInfoPath setFont:[UIFont boldSystemFontOfSize:15]];
    [lblCarRouteSummaryInfoPath setTextColor:[UIColor whiteColor]];
    [lblCarRouteSummaryInfoPath setBackgroundColor:[UIColor clearColor]];
    [lblCarRouteSummaryInfoPath setLineBreakMode:NSLineBreakByClipping];
    [lblCarRouteSummaryInfoPath setText:[NSString stringWithFormat:@"%@ ➜ %@", oms.searchResultRouteStart.strLocationName, oms.searchResultRouteDest.strLocationName]];
    CGRect rectCarRouteSummaryInfoPath = lblCarRouteSummaryInfoPath.frame;
    rectCarRouteSummaryInfoPath.size.width = [lblCarRouteSummaryInfoPath.text sizeWithFont:lblCarRouteSummaryInfoPath.font constrainedToSize:CGSizeMake(FLT_MAX, 15) lineBreakMode:lblCarRouteSummaryInfoPath.lineBreakMode].width;
    
    // 전체경로 라벨이 221보다 작아서 한화면에 전부 노출될때는 그냥 렌더링
    if (rectCarRouteSummaryInfoPath.size.width <= 221)
    {
        [vwCarRouteSummaryInfo addSubview:lblCarRouteSummaryInfoPath];
        [lblCarRouteSummaryInfoPath release];
    }
    // 전체경로 라벨 사이즈가 커질경우 marquee 효과를 주기위해 컨테이너 뷰를 렌더링한다.
    else
    {
        // marquee 용 라벨 2개를 포함하는 뷰 생성
        UIView *vwMarqueeContainer = [[[UIView alloc] initWithFrame:CGRectMake(10, 10, rectCarRouteSummaryInfoPath.size.width*2 + 50, 15)] autorelease];
        
        // 첫번째 텍스트 라벨 삽입
        rectCarRouteSummaryInfoPath.origin.x = 0;
        rectCarRouteSummaryInfoPath.origin.y = 0;
        [lblCarRouteSummaryInfoPath setFrame:rectCarRouteSummaryInfoPath];
        [vwMarqueeContainer addSubview:lblCarRouteSummaryInfoPath];
        
        // 두번째 텍스
        rectCarRouteSummaryInfoPath.origin.x += rectCarRouteSummaryInfoPath.size.width + 50;
        UILabel *lblCarRouteSummaryInfoPath2 = [[UILabel alloc] initWithFrame:rectCarRouteSummaryInfoPath];
        [lblCarRouteSummaryInfoPath2 setFont:[UIFont boldSystemFontOfSize:15]];
        [lblCarRouteSummaryInfoPath2 setTextColor:[UIColor whiteColor]];
        [lblCarRouteSummaryInfoPath2 setBackgroundColor:[UIColor clearColor]];
        [lblCarRouteSummaryInfoPath2 setLineBreakMode:NSLineBreakByClipping];
        [lblCarRouteSummaryInfoPath2 setText:lblCarRouteSummaryInfoPath.text];
        [vwMarqueeContainer addSubview:lblCarRouteSummaryInfoPath2];
        
        [vwCarRouteSummaryInfo addSubview:vwMarqueeContainer];
        
        [lblCarRouteSummaryInfoPath release];
        [lblCarRouteSummaryInfoPath2 release];
        
        [self performSelector:@selector(marqueeCarListRoutePathLabel:) withObject:vwMarqueeContainer afterDelay:1.0];
    }
    
    // 목록 요약정보 뷰 - 상단 배경 - 좌측 (*라벨 밑으로 깔려야한다)
    UIImageView *imgvwCarRouteSummaryInfoBackLeft = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"car_align_bg_01_list.png"]];
    [imgvwCarRouteSummaryInfoBackLeft setFrame:CGRectMake(0, 0, 241, 35)];
    [vwCarRouteSummaryInfo insertSubview:imgvwCarRouteSummaryInfoBackLeft atIndex:0];
    // 목록 요약정보 뷰 - 상단 배경 - 우측 (*라벨 위로 덮어써져야 한다)
    UIImageView *imgvwCarRouteSummaryInfoBackRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"car_align_bg_02_list.png"]];
    [imgvwCarRouteSummaryInfoBackRight setFrame:CGRectMake(241, 0, 79, 35)];
    [vwCarRouteSummaryInfo addSubview:imgvwCarRouteSummaryInfoBackRight];
    // 목록 요약정보 뷰 - 상단 배경 - 마스크
    UIImageView *imgvwMask01 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"car_align_bg_01_list_mask.png"]];
    [imgvwMask01 setFrame:CGRectMake(0, 0, 10, 35)];
    [vwCarRouteSummaryInfo addSubview:imgvwMask01];
    [imgvwMask01 release];
    UIImageView *imgvwMask02 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"car_align_bg_01_list_mask.png"]];
    [imgvwMask02 setFrame:CGRectMake(231, 0, 10, 35)];
    [vwCarRouteSummaryInfo addSubview:imgvwMask02];
    [imgvwMask02 release];
    
    
    UILabel *lblRouteSelector = [[UILabel alloc] initWithFrame:CGRectMake(256, 11, 79, 13)];
    [lblRouteSelector setFont:[UIFont boldSystemFontOfSize:13]];
    [lblRouteSelector setLineBreakMode:NSLineBreakByClipping];
    [lblRouteSelector setBackgroundColor:[UIColor clearColor]];
    [lblRouteSelector setTextColor:[UIColor whiteColor]];
    UIImageView *imgvwRouteSelector = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_btn_align_arrow.png"]];
    [vwCarRouteSummaryInfo addSubview:imgvwRouteSelector];
    
    // 길찾기 경로선택 옵션 SearchRoute_Car_SearchType_XXX
    switch (_currentRouteCarSelector)
    {
        case SearchRoute_Car_SearchType_RealTime:
            [lblRouteSelector setText:@"실시간"];
            [lblRouteSelector setFrame:CGRectMake(510/2, 22/2, 80/2, 26/2)];
            [imgvwRouteSelector setFrame:CGRectMake(590/2, 28/2, 22/2, 16/2)];
            break;
        case SearchRoute_Car_SearchType_FreePass:
            [lblRouteSelector setText:@"무료"];
            [lblRouteSelector setFrame:CGRectMake(522/2, 22/2, 56/2, 26/2)];
            [imgvwRouteSelector setFrame:CGRectMake(578/2, 28/2, 22/2, 16/2)];
            break;
        case SearchRoute_Car_SearchType_HighWay:
            [lblRouteSelector setText:@"고속"];
            [lblRouteSelector setFrame:CGRectMake(522/2, 22/2, 56/2, 26/2)];
            [imgvwRouteSelector setFrame:CGRectMake(578/2, 28/2, 22/2, 16/2)];
            break;
        case SearchRoute_Car_SearchType_ShortDistance:
            [lblRouteSelector setText:@"최단"];
            [lblRouteSelector setFrame:CGRectMake(522/2, 22/2, 56/2, 26/2)];
            [imgvwRouteSelector setFrame:CGRectMake(578/2, 28/2, 22/2, 16/2)];
            break;
    }
    
    /*
     // 라벨 & 이미지 사이즈 조절
     CGRect rectRouteSelector = lblRouteSelector.frame;
     rectRouteSelector.size.width = [lblRouteSelector.text sizeWithFont:lblRouteSelector.font constrainedToSize:CGSizeMake(FLT_MAX, 15) lineBreakMode:lblRouteSelector.lineBreakMode].width;
     rectRouteSelector.origin.x = 241 + ((79-rectRouteSelector.size.width-11)/2) - 1;
     [lblRouteSelector setFrame:rectRouteSelector];
     [imgvwRouteSelector setFrame:CGRectMake(rectRouteSelector.origin.x+rectRouteSelector.size.width+1, 13, 11, 8)];
     */
    
    // 라벨&이미지 삽입
    [vwCarRouteSummaryInfo addSubview:lblRouteSelector];
    [vwCarRouteSummaryInfo addSubview:imgvwRouteSelector];
    
    // 터치이벤트
    UIControl *ctrlSelector = [[UIControl alloc] initWithFrame:CGRectMake(241, 0, 79, 30)];
    [ctrlSelector setBackgroundColor:[UIColor clearColor]];
    [ctrlSelector addTarget:self action:@selector(showCarRouteSelector:) forControlEvents:UIControlEventTouchUpInside];
    [vwCarRouteSummaryInfo addSubview:ctrlSelector];
    
    // 목록뷰에 요약정보 뷰 삽입
    [_vwRoutePathListContainer addSubview:vwCarRouteSummaryInfo];
    
    [vwCarRouteSummaryInfo release];
    [imgvwCarRouteSummaryInfoBackLeft release];
    [imgvwCarRouteSummaryInfoBackRight release];
    [lblRouteSelector release];
    [imgvwRouteSelector release];
    [ctrlSelector release];
    
    
    // **********************
    // [ 목록 거리/시간 정보 ]
    // **********************
    
    // 목록 거리/시간 정보 뷰 생성
    UIView *vwCarRouteDistanceTimeInfo = [[UIView alloc] initWithFrame:CGRectMake(0, 35, 320, 58)];
    [vwCarRouteDistanceTimeInfo setBackgroundColor:convertHexToDecimalRGBA(@"F2", @"F2", @"F2", 1.0)];
    
    // 거리
    CGRect rectDistance = CGRectMake(10, 11, 0, 17);
    UILabel *lblDistance = [[UILabel alloc] initWithFrame:rectDistance];
    [lblDistance setFont:[UIFont boldSystemFontOfSize:17]];
    [lblDistance setTextColor:[UIColor blackColor]];
    [lblDistance setBackgroundColor:[UIColor clearColor]];
    [lblDistance setText:[NSString stringWithFormat:@"약 %@",[self getDistanceRefined:oms.searchRouteData.routeCarTotalDistance]]];
    rectDistance.size.width = [lblDistance.text sizeWithFont:lblDistance.font constrainedToSize:CGSizeMake(FLT_MAX, 17) lineBreakMode:NSLineBreakByClipping].width;
    [lblDistance setFrame:rectDistance];
    [vwCarRouteDistanceTimeInfo addSubview:lblDistance];
    
    // 구분 이미지
    UIImageView *imgvwSep = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_text_line_02.png"]];
    [imgvwSep setFrame:CGRectMake(rectDistance.origin.x+rectDistance.size.width, 11, 15, 16)];
    [vwCarRouteDistanceTimeInfo addSubview:imgvwSep];
    
    // 시간
    CGRect rectTime = CGRectMake(rectDistance.origin.x+rectDistance.size.width+15, 11, 0, 17);
    UILabel *lblTime = [[UILabel alloc] initWithFrame:rectTime];
    [lblTime setFont:[UIFont boldSystemFontOfSize:17]];
    [lblTime setTextColor:[UIColor blackColor]];
    [lblTime setBackgroundColor:[UIColor clearColor]];
    [lblTime setText:[NSString stringWithFormat:@"약 %@",[self getTimeRefined:oms.searchRouteData.routeCarTotalTime]]];
    rectTime.size.width = [lblTime.text sizeWithFont:lblTime.font constrainedToSize:CGSizeMake(FLT_MAX, 16) lineBreakMode:NSLineBreakByClipping].width;
    [lblTime setFrame:rectTime];
    [vwCarRouteDistanceTimeInfo addSubview:lblTime];
    
    // 택시비
    UILabel *lblTaxi = [[UILabel alloc] initWithFrame:CGRectMake(10, 34, 290, 13)];
    [lblTaxi setFont:[UIFont systemFontOfSize:13]];
    [lblTaxi setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0)];
    [lblTaxi setBackgroundColor:[UIColor clearColor]];
    [lblTaxi setText:[NSString stringWithFormat:@"택시비 약 %@원",[self getTaxiFareRefined:oms.searchRouteData.routeCarTotalDistance localCode:oms.searchRouteData.routeCarTotalTime]]];
    [vwCarRouteDistanceTimeInfo addSubview:lblTaxi];
    
    // 목록 거리/시간 정보 뷰 삽입
    [_vwRoutePathListContainer addSubview:vwCarRouteDistanceTimeInfo];
    
    // 목록 상단 라인 삽입
    UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, 93, 320, 1)];
    [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0)];
    [_vwRoutePathListContainer addSubview:vwLine];
    [vwLine release];
    
    [vwCarRouteDistanceTimeInfo release];
    [lblDistance release];
    [imgvwSep release];
    [lblTime release];
    [lblTaxi release];
    
}
- (void) marqueeCarListRoutePathLabel :(UIView *)container
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *str = [NSString stringWithFormat:@"%@ ➜ %@", oms.searchResultRouteStart.strLocationName, oms.searchResultRouteDest.strLocationName];
    CGSize size = [str sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(FLT_MAX, 15) lineBreakMode:NSLineBreakByClipping];
    float duration = size.width / 50;
    
    CGRect rect = container.frame;
    rect.origin.x = 10;
    [container setFrame:rect];
    
    rect.origin.x = rect.origin.x - size.width - 50;
    
    [UIView beginAnimations:@"marqueeCarListRoutePathLabel" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    [container setFrame:rect];
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(marqueeCarListRoutePathLabel:) withObject:container afterDelay:duration + 1.0];
}

- (void) renderCarListRouteDetailPathTable
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 스크롤뷰 생성
    OMScrollView *svwPathContainer = [[OMScrollView alloc]
                                      initWithFrame:CGRectMake(0, 94,
                                                               [[UIScreen mainScreen] bounds].size.width,
                                                               [[UIScreen mainScreen] bounds].size.height -
                                                               [[UIApplication sharedApplication] statusBarFrame].size.height -
                                                               168)];
    [svwPathContainer setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [svwPathContainer setDelegate:self];
    [svwPathContainer setScrollType:2];
    
    // 스크롤뷰 컨텐츠 높이
    int nPathContainerHeight = 0;
    
    // 첫번째 셀 상단라인 생성
    UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, nPathContainerHeight, 320, 1)];
    [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0)];
    [svwPathContainer addSubview:vwLine];
    nPathContainerHeight += vwLine.frame.size.height;
    [vwLine release];
    
    BOOL isCatchVisit = NO;
    for (NSDictionary *dic in oms.searchRouteData.routeCarPoints)
    {
        int type = [[dic objectForKeyGC:@"Type"] intValue];
        int index = [[dic objectForKeyGC:@"Index"] intValue];
        
        // 경유지 발견 이후로는 실제 포인트 이동 인덱스 값을 +1 해준다
        if (type == 1000) isCatchVisit = YES;
        
        // 셀 뷰 생성
        CGRect rectCell = CGRectMake(0, nPathContainerHeight, 320, 58);
        UIControl *vwCell = [[UIControl alloc] initWithFrame:rectCell];
        
        if (isCatchVisit) [vwCell setTag:index+1];
        else [vwCell setTag:index];
        
        switch (type)
        {
            case 999: // 출발
            case 1000: // 경유
            case 1001: // 도착
            {
                // 경로안내 라벨
                UILabel *lblPath = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 260, 15)];
                [lblPath setFont:[UIFont boldSystemFontOfSize:15]];
                [lblPath setTextColor:[UIColor blackColor]];
                [lblPath setBackgroundColor:[UIColor clearColor]];
                [lblPath setLineBreakMode:NSLineBreakByCharWrapping];
                if (type == 999)
                    [lblPath setText:oms.searchResultRouteStart.strLocationName];
                else  if (type == 1000)
                    [lblPath setText:oms.searchResultRouteVisit.strLocationName];
                else  if (type == 1001)
                    [lblPath setText:oms.searchResultRouteDest.strLocationName];
                [vwCell addSubview:lblPath];
                
                // 경로안내 라벨이 커질경우 사이즈 재조정
                CGRect rectPath = lblPath.frame;
                CGSize sizePath = [lblPath.text sizeWithFont:lblPath.font constrainedToSize:CGSizeMake(FLT_MAX, 15) lineBreakMode:lblPath.lineBreakMode];
                int maxLine = ceil([[NSString stringWithFormat:@"%02.1f", (sizePath.width / 260.0f)] doubleValue]);
                [lblPath setNumberOfLines:maxLine];
                rectPath.size.height = sizePath.height * maxLine;
                
                // 텍스트 라벨의 크기가 기본값 이상으로 커질경우 셀뷰 사이즈를 확장한다
                // 텍스트 라벨 높이 + 상하여백(20)
                rectCell.size.height = rectPath.size.height + 20;
                if (rectCell.size.height > 58) [vwCell setFrame:rectCell];
                
                // 라벨 사이즈도 조정
                rectPath.origin.y = (vwCell.frame.size.height - rectPath.size.height) / 2;
                [lblPath setFrame:rectPath];
                
                [lblPath release];
                
                // 출발/경유/도착  이미지
                UIImageView *imgvwDirection =nil;
                if (type == 999)
                    imgvwDirection = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_start.png"]];
                else  if (type == 1000)
                    imgvwDirection = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_via.png"]];
                else  if (type == 1001)
                    imgvwDirection = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_stop.png"]];
                [imgvwDirection setFrame:CGRectMake(10, (vwCell.frame.size.height-30)/2, 30, 30)];
                [vwCell addSubview:imgvwDirection];
                [imgvwDirection release];
            }
                break;
            default: // 일반
            {
                // 경로 텍스트
                NSMutableString *strPath = [NSMutableString string];
                if ( [[dic objectForKeyGC:@"Type"] intValue] >= 0 )
                {
                    [strPath appendFormat:@"%@ 이동 후 " , [self getDistanceRefined:[[dic objectForKeyGC:@"NextDistance"] intValue]]];
                    NSString *strDirection = [NSString stringWithFormat:@"%@", [dic objectForKeyGC:@"Direction"]];
                    if (strDirection.length > 0)
                        [strPath appendFormat:@"%@ 방향 " , strDirection];
                    [strPath appendFormat:@"%@", [self getSearchRouteCarRGType:[[dic objectForKeyGC:@"Type"] intValue]]];
                }
                else
                {
                    [strPath appendFormat:@"%@ 이동 " , [self getDistanceRefined:[[dic objectForKeyGC:@"NextDistance"] intValue]]];
                }
                
                // 경로안내 라벨
                UILabel *lblPath = [[UILabel alloc] initWithFrame:CGRectMake(72, 19, 228, 13)];
                [lblPath setFont:[UIFont systemFontOfSize:13]];
                [lblPath setTextColor:[UIColor blackColor]];
                [lblPath setBackgroundColor:[UIColor clearColor]];
                [lblPath setLineBreakMode:NSLineBreakByCharWrapping];
                [lblPath setText:strPath];
                [vwCell addSubview:lblPath];
                
                // 경로안내 라벨이 커질경우 사이즈 재조정
                CGRect rectPath = lblPath.frame;
                CGSize sizePath = [lblPath.text sizeWithFont:lblPath.font constrainedToSize:CGSizeMake(FLT_MAX, 13) lineBreakMode:lblPath.lineBreakMode];
                int maxLine = ceil([[NSString stringWithFormat:@"%02.1f", (sizePath.width / 228.0f)] doubleValue]);
                [lblPath setNumberOfLines:maxLine];
                rectPath.size.height = sizePath.height * maxLine;
                
                // 텍스트 라벨의 크기가 기본값 이상으로 커질경우 셀뷰 사이즈를 확장한다
                // 텍스트 라벨 높이 + 상하여백(20)
                rectCell.size.height = rectPath.size.height + 20;
                if (rectCell.size.height > 58) [vwCell setFrame:rectCell];
                
                // 라벨 사이즈도 조정
                rectPath.origin.y = (vwCell.frame.size.height - rectPath.size.height) / 2;
                [lblPath setFrame:rectPath];
                [lblPath release];
                
                // 방향 이미지
                UIImageView *imgvwDirection = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"list_%02d.png", [[dic objectForKeyGC:@"Type"]intValue]]]];
                [imgvwDirection setFrame:CGRectMake(10, (vwCell.frame.size.height-30)/2, 30, 30)];
                [vwCell addSubview:imgvwDirection];
                [imgvwDirection release];
                
                // 포인트 번호 이미지
                UIImageView *imgvwIndex = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"marker_num_%03d.png", index]]];
                [imgvwIndex setFrame:CGRectMake(48, (vwCell.frame.size.height-20)/2, 20, 20)];
                [vwCell addSubview:imgvwIndex];
                [imgvwIndex release];
            }
                break;
        }
        
        // 셀 이벤트 처리 및 상태
        [vwCell addTarget:self action:@selector(onCarListSelectDetailPathCell:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addTarget:self action:@selector(onCarListSelectDetailPathCell_Down:) forControlEvents:UIControlEventTouchDown];
        [vwCell addTarget:self action:@selector(onCarListSelectDetailPathCell_UpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        if (vwCell.tag == _currentRouteDetailPathIndex)
        {
            [vwCell setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0f)];
            [svwPathContainer setContentOffset:CGPointMake(0, nPathContainerHeight-(svwPathContainer.frame.size.height/3))];
        }
        
        
        // 셀 뷰 삽입
        [svwPathContainer addSubview:vwCell];
        nPathContainerHeight += vwCell.frame.size.height;
        [vwCell release];
        
        // 셀 라인 생성
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, nPathContainerHeight, 320, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0)];
        [svwPathContainer addSubview:vwLine];
        nPathContainerHeight += vwLine.frame.size.height;
        [vwLine release];
        
    }
    
    // 스크롤뷰 컨텐츠 영역 설정
    [svwPathContainer setContentSize:CGSizeMake(320, nPathContainerHeight)];
    
    // 스크롤뷰 삽입
    [_vwRoutePathListContainer addSubview:svwPathContainer];
    [svwPathContainer release];
    
    // 스크롤뷰 경계선 사이에 픽셀깨지는 현상 방지하기 위해 다시 하단영역을 앞으로 가져와서 덮어버림.
    [self.view bringSubviewToFront:_vwBottomButtonGroup];
    
}

// ********************************



// ==================================
// [ 대중교통 - 공통 - 렌더링 메소드 ]
// ==================================

- (void) requestPublicSearchRoute
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    Coord crdStart = oms.searchResultRouteStart.coordLocationPoint;
    Coord crdEnd = oms.searchResultRouteDest.coordLocationPoint;
    
    [[ServerConnector sharedServerConnection] requestRouteSearch:self action:@selector(finishPublicSearchRoute:) SX:crdStart.x SY:crdStart.y EX:crdEnd.x EY:crdEnd.y RPType:1 CoordType:7 VX1:0 VY1:0 Priority:0];
}
- (void) finishPublicSearchRoute :(ServerRequester *)request
{
    
    // 데이터 수신 완료
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        // 정상적으로 검색된 경우
        if(oms.searchRouteData.isRoutePublic)
        {
            // 경유지가 설정된 경우 경고메세지 출력
            if (oms.searchResultRouteVisit.used)
            {
                [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchRoutePublic_NotSupportVisit", @"")];
            }
            
            // 검색은 잘 됐는데... 아무 정보도 없다.??  ==>   <Response isRoute="true" />
            if ( oms.searchRouteData.routePublicBothCount + oms.searchRouteData.routePublicBusCount + oms.searchRouteData.routePublicRecommendCount + oms.searchRouteData.routePublicSubwayCount <= 0)
            {
                [OMMessageBox showAlertMessage:@"" :@"해당 지역에서는 경로탐색이 지원되지 않습니다.\n이용에 불편을 드려 죄송합니다."];
                [oms.searchRouteData resetPublic];
                // 자동차 길찾기 데이터 존재할 경우 되돌림
                if ( oms.searchRouteData.isRouteCar )
                {
                    [_btnNavigationCarButton setSelected:YES];
                    [_btnNavigationPublicButton setSelected:NO];
                }
                // 아닌경우 뒤로 돌아가기
                else
                {
                    [[OMNavigationController sharedNavigationController] popToRootViewControllerAnimated:NO];
                }
                
            }
            else
                [self renderPublicSelector];
            
        }
        // 검색에 실패한 경우
        else
        {
            // 경유지가 설정된 경우 경고메시지 추가해줌 (경유지경고+오류메세지)
            if (oms.searchResultRouteVisit.used)
            {
                [OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@\n\n%@",
                                                     NSLocalizedString(@"Msg_SearchRoutePublic_NotSupportVisit", @""),
                                                     [SearchRouteExecuter getSearchRouteErrorMessage:oms.searchRouteData.routePublicError]]];
            }
            else
            {
                [OMMessageBox showAlertMessage:@"" : [SearchRouteExecuter getSearchRouteErrorMessage:oms.searchRouteData.routePublicError] ];
            }
            
            // 대중교통 클리어
            [oms.searchRouteData resetPublic];
            
            // 자동차 길찾기 데이터 존재할 경우 되돌림
            if ( oms.searchRouteData.isRouteCar )
            {
                [_btnNavigationCarButton setSelected:YES];
                [_btnNavigationPublicButton setSelected:NO];
                
                // 기본적으로 자동차 길찾기 화면에서 건너왔음을 전제로 자동화면을 그대로 유지한다. (렌더링 다시 하지 않음)
                //[self  renderCarMap];
            }
        }
    }
    // 검색중 오류가 발생한 경우
    else
    {
        // 자동차 길찾기 데이터 존재할 경우 되돌림
        if ( [OllehMapStatus sharedOllehMapStatus].searchRouteData.isRouteCar )
        {
            [_btnNavigationCarButton setSelected:YES];
            [_btnNavigationPublicButton setSelected:NO];
            
            // 기본적으로 자동차 길찾기 화면에서 건너왔음을 전제로 자동화면을 그대로 유지한다. (렌더링 다시 하지 않음)
            //[self  renderCarMap];
        }
        
    }
    
}

- (NSDictionary *) getCurrentPublicRouteData
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSDictionary *routeDic = nil;
    switch (_currentPublicMethod)
    {
        case OM_SRRMV_PublicMethodType_Recommend:
            if (oms.searchRouteData.routePublicRecommendCount > _currentPublicMethodListIndex)
                routeDic = [oms.searchRouteData.routePublicRecommend objectAtIndexGC:_currentPublicMethodListIndex];
            break;
        case OM_SRRMV_PublicMethodType_Bus:
            if (oms.searchRouteData.routePublicBusCount > _currentPublicMethodListIndex)
                routeDic = [oms.searchRouteData.routePublicBus objectAtIndexGC:_currentPublicMethodListIndex];
            break;
        case OM_SRRMV_PublicMethodType_Subway:
            if (oms.searchRouteData.routePublicSubwayCount > _currentPublicMethodListIndex)
                routeDic = [oms.searchRouteData.routePublicSubway objectAtIndexGC:_currentPublicMethodListIndex];
            break;
        case OM_SRRMV_PublicMethodType_Both:
            if (oms.searchRouteData.routePublicBothCount > _currentPublicMethodListIndex)
                routeDic = [oms.searchRouteData.routePublicBoth objectAtIndexGC:_currentPublicMethodListIndex];
            break;
        default:
            routeDic = nil;
            break;
    }
    
    return routeDic;
}

- (int) getPublicMethodIconNumber :(int)methodtype :(int)subnumber
{
    switch (methodtype)
    {
        case 1: // 일반버스
            return 27;
        case 2: // 좌석버스
            return 28;
        case 3: // 마을버스
            return 29;
        case 4: // 직행 좌석 버스
            return 30;
        case 5: // 공항버스
            return 31;
        case 6: // 간선 급행 버스
            return 32;
        case 10: // 외곽 버스
            return 33;
        case 11: // 간선버스
            return 34;
        case 12: // 지선버스
            return 35;
        case 13: // 순환버스
            return 36;
        case 14: // 광역버스
            return 37;
        case 15: // 급행버스
            return 38;
        case 25: // 급행 간선 버스
            return 39;
            /* 인천/경기 버스는 아직 코드가 없음..
             case 1000: // 경기
             return 40;
             case ?: // 인천
             return 41;
             */
        case 2000: // 지하철
        {
            // subnumber로 lID가 넘어옴
            switch (subnumber)
            {
                case 1:  // 지하철 1호선
                case 11: // 1호선 인천
                case 12: // 1호선 수원
                case 13: // 1호선 광명
                case 18: // 1호선 서동탄
                    return 2;
                case 2 : // 지하철 2호선
                case 14: // 2호선 신도림
                case 15: // 2호선 성수
                    return 3;
                case 3: // 지하철 3호선
                    return 4;
                case 4: // 지하철 4호선
                    return 5;
                case 5: // 지하철 5호선
                case 16: // 5호선 상일
                case 17: // 5호선 마천
                    return 6;
                case 6: // 지하철 6호선
                    return 7;
                case 7: // 지하철 7호선
                    return 8;
                case 8: // 지하철 8호선
                    return 9;
                case 9: // 지하철 9호선
                    return 10;
                case 100: // 수도권 분당선
                    return 11;
                case 109: // 신분당선
                    return 12;
                case 103: // 수도권 중앙선
                    return 13;
                case 101: // 수도권 공항철도
                    return 14;
                case 21: // 인천 1호선
                case 20001: // 인천 1호선
                    return 15;
                case 104: // 경의선
                    return 16;
                case 108: // 경춘선
                    return 17;
                case 71: // 부산 1호선
                case 70001: // 부산 1호선
                    return 18;
                case 72: // 부산 2호선
                case 70002: // 부산 2호선
                    return 19;
                case 73: // 부산 3호선
                case 70003: // 부산 3호선
                    return 20;
                case 74: // 부산 4호선
                case 70004: // 부산 4호선
                    return 21;
                case 79: // 부산 김해경전철
                case 70009: // 부산 김해경전철
                    return 22;
                case 41: // 대구 1호선
                case 40001: // 대구 1호선
                    return 23;
                case 42: // 대구 2호선
                case 40002: // 대구 2호선
                    return 24;
                case 31: // 대전 1호선
                case 30001: // 대전 1호선
                    return 25;
                case 51: // 광주 1호선
                case 50001: // 광주 1호선
                    return 26;
                case 111: // 수인선
                    return 42;
                case 110: // 의정부 경전철
                    return 43;
                case 107: // 용인경전철
                    return 44;
                default:
                    return 0;
                    
            }
        }
        case 0: // 도보
            return 1;
        default:
            return 0;
    }
}

// **********************************

// ==================================
// [ 대중교통 - 선택 - 렌더링 메소드 ]
// ==================================
#pragma mark -
#pragma mark 대중교통 - 선택 - 렌더링 메소드
- (void) renderPublicSelector
{
    //MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    //OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 자동차 - 지도 상태설정
    _currentViewRenderType = OM_SRRMV_ViewRenderType_PUBLIC_SELECT; // 길찾기 대중교통 경로선택
    
    // 네비게이션 영역 렌더링
    [self renderCommonNavigationBar];
    
    
    // 경로선택 뷰 클리어
    for (UIView *subView in _vwPublicRouteSelector.subviews)
    {
        [subView removeFromSuperview];
    }
    [_vwPublicRouteSelector removeFromSuperview];
    
    
    // 상단 카테고리 렌더링
    [self renderPublicSelectorCategoryTab];
    
    // 본문 대중교통 선택 목록 렌더링
    [self renderPublicSelectorRouteMethodListTable];
    
    // 경로선택 뷰 삽입
    [self.view addSubview:_vwPublicRouteSelector];
    
}

- (void) renderPublicSelectorCategoryTab
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 상단 카테고리 뷰
    UIView *vwPublicRouteSelectorCategory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 36+35)];
    
    
    // 선택된 카테고리별 배경이미지 적용
    UIImageView *imgvwButtonsBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    if (_currentPublicMethod == OM_SRRMV_PublicMethodType_Recommend)
    {
        [imgvwButtonsBack setImage:[UIImage imageNamed:@"4tab_01.png"]];
    }
    else if (_currentPublicMethod == OM_SRRMV_PublicMethodType_Bus)
    {
        [imgvwButtonsBack setImage:[UIImage imageNamed:@"4tab_02.png"]];
    }
    else if (_currentPublicMethod == OM_SRRMV_PublicMethodType_Subway)
    {
        [imgvwButtonsBack setImage:[UIImage imageNamed:@"4tab_03.png"]];
    }
    else if (_currentPublicMethod == OM_SRRMV_PublicMethodType_Both)
    {
        [imgvwButtonsBack setImage:[UIImage imageNamed:@"4tab_04.png"]];
    }
    // 버튼배경 이미지 삽입
    [vwPublicRouteSelectorCategory addSubview:imgvwButtonsBack];
    [imgvwButtonsBack release];
    
    // 카테고리 추천 버튼
    UIButton *btnCategoryRecommend = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 69, 36)];
    [btnCategoryRecommend.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [btnCategoryRecommend.titleLabel setNumberOfLines:1];
    [btnCategoryRecommend.titleLabel setLineBreakMode:NSLineBreakByClipping];
    [btnCategoryRecommend setTitle:[NSString stringWithFormat:@"추천(%d)", oms.searchRouteData.routePublicRecommendCount] forState:UIControlStateNormal];
    if (oms.searchRouteData.routePublicRecommendCount <= 0)
    {
        [btnCategoryRecommend setTitleColor:convertHexToDecimalRGBA(@"95", @"95", @"95", 1.0f) forState:UIControlStateNormal];
    }
    else
    {
        if (_currentPublicMethod == OM_SRRMV_PublicMethodType_Recommend)
            [btnCategoryRecommend setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        else
            [btnCategoryRecommend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnCategoryRecommend addTarget:self action:@selector(onPublicCategoryRecommend:) forControlEvents:UIControlEventTouchUpInside];
    }
    [vwPublicRouteSelectorCategory addSubview:btnCategoryRecommend];
    [btnCategoryRecommend release];
    
    // 카테고리 버스 버튼
    UIButton *btnCategoryBus = [[UIButton alloc] initWithFrame:CGRectMake(70, 0, 69, 36)];
    [btnCategoryBus.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [btnCategoryBus.titleLabel setLineBreakMode:NSLineBreakByClipping];
    [btnCategoryBus setTitle:[NSString stringWithFormat:@"버스(%d)", oms.searchRouteData.routePublicBusCount] forState:UIControlStateNormal];
    if (oms.searchRouteData.routePublicBusCount <= 0)
    {
        [btnCategoryBus setTitleColor:convertHexToDecimalRGBA(@"95", @"95", @"95", 1.0f) forState:UIControlStateNormal];
    }
    else
    {
        if (_currentPublicMethod == OM_SRRMV_PublicMethodType_Bus)
            [btnCategoryBus setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        else
            [btnCategoryBus setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnCategoryBus addTarget:self action:@selector(onPublicCategoryBus:) forControlEvents:UIControlEventTouchUpInside];
    }
    [vwPublicRouteSelectorCategory addSubview:btnCategoryBus];
    [btnCategoryBus release];
    
    // 카테고리 지하철 버튼
    UIButton *btnCategorySubway = [[UIButton alloc] initWithFrame:CGRectMake(140, 0, 69, 36)];
    [btnCategorySubway.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [btnCategorySubway.titleLabel setNumberOfLines:1];
    [btnCategorySubway.titleLabel setLineBreakMode:NSLineBreakByClipping];
    [btnCategorySubway setTitle:[NSString stringWithFormat:@"지하철(%d)", oms.searchRouteData.routePublicSubwayCount] forState:UIControlStateNormal];
    if (oms.searchRouteData.routePublicSubwayCount <= 0)
    {
        [btnCategorySubway setTitleColor:convertHexToDecimalRGBA(@"95", @"95", @"95", 1.0f) forState:UIControlStateNormal];
    }
    else
    {
        if (_currentPublicMethod == OM_SRRMV_PublicMethodType_Subway)
            [btnCategorySubway setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        else
            [btnCategorySubway setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnCategorySubway addTarget:self action:@selector(onPublicCategorySubway:) forControlEvents:UIControlEventTouchUpInside];
    }
    [vwPublicRouteSelectorCategory addSubview:btnCategorySubway];
    [btnCategorySubway release];
    
    // 카테고리 버스+지하철 버튼
    UIButton *btnCategoryBoth = [[UIButton alloc] initWithFrame:CGRectMake(210, 0, 110, 36)];
    [btnCategoryBoth.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [btnCategoryBoth.titleLabel setNumberOfLines:1];
    [btnCategoryBoth.titleLabel setLineBreakMode:NSLineBreakByClipping];
    [btnCategoryBoth setTitle:[NSString stringWithFormat:@"버스+지하철(%d)", oms.searchRouteData.routePublicBothCount] forState:UIControlStateNormal];
    if (oms.searchRouteData.routePublicBothCount <= 0)
    {
        [btnCategoryBoth setTitleColor:convertHexToDecimalRGBA(@"95", @"95", @"95", 1.0f) forState:UIControlStateNormal];
    }
    else
    {
        if (_currentPublicMethod == OM_SRRMV_PublicMethodType_Both)
            [btnCategoryBoth setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        else
            [btnCategoryBoth setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnCategoryBoth addTarget:self action:@selector(onPublicCategoryBoth:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [vwPublicRouteSelectorCategory addSubview:btnCategoryBoth];
    [btnCategoryBoth release];
    
    
    // *******************
    // [ 전체경로 그룹 뷰 ]
    // *******************
    
    // 전체경로 그룹 뷰 생성
    UIView *vwRoutePathInfo = [[UIView alloc] initWithFrame:CGRectMake(0, 36, 320, 35)];
    // 전체경로 텍스트 라벨 생성
    CGRect rectRoutePathLabel = CGRectMake(10, 10, 300, 15);
    UILabel *lblRoutePath = [[UILabel alloc] initWithFrame:rectRoutePathLabel];
    [lblRoutePath setFont:[UIFont boldSystemFontOfSize:15]];
    [lblRoutePath setBackgroundColor:[UIColor clearColor]];
    [lblRoutePath setTextColor:[UIColor whiteColor]];
    [lblRoutePath setLineBreakMode:NSLineBreakByClipping];
    [lblRoutePath setText:[NSString stringWithFormat:@"%@ ➜ %@", oms.searchResultRouteStart.strLocationName, oms.searchResultRouteDest.strLocationName]];
    rectRoutePathLabel.size.width = [lblRoutePath.text sizeWithFont:lblRoutePath.font constrainedToSize:CGSizeMake(FLT_MAX, 15) lineBreakMode:lblRoutePath.lineBreakMode].width;
    [lblRoutePath setFrame:rectRoutePathLabel];
    // 전체경로 라벨 사이즈가 300보다 작을 경우 그대로 렌더링
    if (rectRoutePathLabel.size.width <= 300)
    {
        [vwRoutePathInfo addSubview:lblRoutePath];
        [lblRoutePath release];
    }
    // 전체경로 라벨 사이즈가 커질경우 marquee 효과를 주기위해 컨테이너 뷰를 렌더링한다.
    else
    {
        // marquee 용 라벨 2개를 포함하는 뷰 생성
        UIView *vwMarqueeContainer = [[[UIView alloc] initWithFrame:CGRectMake(10, 10, rectRoutePathLabel.size.width*2 + 50, 15)] autorelease];
        
        // 첫번째 텍스트 라벨 삽입
        rectRoutePathLabel.origin.x = 0;
        rectRoutePathLabel.origin.y = 0;
        [lblRoutePath setFrame:rectRoutePathLabel];
        [vwMarqueeContainer addSubview:lblRoutePath];
        
        // 두번째 텍스트
        rectRoutePathLabel.origin.x += rectRoutePathLabel.size.width + 50;
        UILabel *lblRoutePath2 = [[UILabel alloc] initWithFrame:rectRoutePathLabel];
        [lblRoutePath2 setFont:[UIFont boldSystemFontOfSize:15]];
        [lblRoutePath2 setTextColor:[UIColor whiteColor]];
        [lblRoutePath2 setBackgroundColor:[UIColor clearColor]];
        [lblRoutePath2 setLineBreakMode:NSLineBreakByClipping];
        [lblRoutePath2 setText:lblRoutePath.text];
        [vwMarqueeContainer addSubview:lblRoutePath2];
        
        [vwRoutePathInfo addSubview:vwMarqueeContainer];
        
        [lblRoutePath release];
        [lblRoutePath2 release];
        
        [self performSelector:@selector(marqueeCarListRoutePathLabel:) withObject:vwMarqueeContainer afterDelay:1.0];
    }
    
    
    
    // 배경+마스크 이미지
    UIImageView *imgvwRoutePathInfoBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_align_bg_03.png"]];
    //[vwRoutePathInfo addSubview:imgvwRoutePathInfoBack];
    [vwRoutePathInfo insertSubview:imgvwRoutePathInfoBack atIndex:0];
    [imgvwRoutePathInfoBack release];
    UIImageView *imgvwRoutePathInfoMask1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_align_bg_03.png"]];
    [imgvwRoutePathInfoMask1 setFrame:CGRectMake(0, 0, 10, 35)];
    [vwRoutePathInfo addSubview:imgvwRoutePathInfoMask1];
    [imgvwRoutePathInfoMask1 release];
    UIImageView *imgvwRoutePathInfoMask2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_align_bg_03.png"]];
    [imgvwRoutePathInfoMask2 setFrame:CGRectMake(310, 0, 10, 35)];
    [vwRoutePathInfo addSubview:imgvwRoutePathInfoMask2];
    [imgvwRoutePathInfoMask2 release];
    // 전체경로 그룹 뷰 삽입
    [vwPublicRouteSelectorCategory addSubview:vwRoutePathInfo];
    [vwRoutePathInfo release];
    
    // 카테고리 뷰 삽입
    [_vwPublicRouteSelector addSubview:vwPublicRouteSelectorCategory];
    
    
    // 자원해제
    [vwPublicRouteSelectorCategory release];
    
}
- (void) marqueePublicSelectorRoutePathLabel :(UIView *)container
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *str = [NSString stringWithFormat:@"%@ ➜ %@", oms.searchResultRouteStart.strLocationName, oms.searchResultRouteDest.strLocationName];
    CGSize size = [str sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(FLT_MAX, 15) lineBreakMode:NSLineBreakByClipping];
    float duration = size.width / 50;
    
    CGRect rect = container.frame;
    rect.origin.x = 10;
    [container setFrame:rect];
    
    rect.origin.x = rect.origin.x - size.width - 50;
    
    [UIView beginAnimations:@"marqueePublicSelectorRoutePathLabel" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    [container setFrame:rect];
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(marqueePublicSelectorRoutePathLabel:) withObject:container afterDelay:duration + 1.0];
}


- (void) renderPublicSelectorRouteMethodListTable
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 본문 대중교통 선택 목록
    OMScrollView *svwPublicRouteSelectorMethodList = [[OMScrollView alloc]
                                                      initWithFrame:CGRectMake(0, 36+35,
                                                                               [UIScreen mainScreen].bounds.size.width,
                                                                               [UIScreen mainScreen].bounds.size.height -
                                                                               [UIApplication sharedApplication].statusBarFrame.size.height
                                                                               - 108)];
    [svwPublicRouteSelectorMethodList setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [svwPublicRouteSelectorMethodList setDelegate:self];
    [svwPublicRouteSelectorMethodList setScrollType:2];
    
    // 목록 처리
    NSArray *arrRoutePublic;
    if (_currentPublicMethod == OM_SRRMV_PublicMethodType_Recommend) arrRoutePublic = oms.searchRouteData.routePublicRecommend;
    else if (_currentPublicMethod == OM_SRRMV_PublicMethodType_Bus) arrRoutePublic = oms.searchRouteData.routePublicBus;
    else if (_currentPublicMethod == OM_SRRMV_PublicMethodType_Subway) arrRoutePublic = oms.searchRouteData.routePublicSubway;
    else if (_currentPublicMethod == OM_SRRMV_PublicMethodType_Both) arrRoutePublic = oms.searchRouteData.routePublicBoth;
    
    float cellHeight = 0.0f;
    
    // 첫번째 셀 라인 삽입
    UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight, 320, 1)];
    [vwLine setBackgroundColor: convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0f)];
    [svwPublicRouteSelectorMethodList addSubview:vwLine];
    cellHeight += vwLine.frame.size.height;
    [vwLine release];
    
    
    for (NSDictionary *resultDic in arrRoutePublic)
    {
        NSDictionary *routeDic = [resultDic objectForKeyGC:@"RouteGate"];
        //NSLog(@"상위로그 : %@", resultDic);
        //NSLog(@"경로로그 : %@", routeDic);
        
        // 셀 생성
        UIControl *vwCell = [[UIControl alloc] initWithFrame:CGRectMake(0, cellHeight, 320, 81)];
        cellHeight += vwCell.frame.size.height;
        
        float labelLeftPosition = 10.0f;
        
        // 시간 생성/삽입
        UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPosition, 19, 1, 13)];
        [lblTime setFont:[UIFont boldSystemFontOfSize:13]];
        [lblTime setTextColor:convertHexToDecimalRGBA(@"19", @"A8", @"C7", 1.0f)];
        [lblTime setBackgroundColor:[UIColor clearColor]];
        @try { [lblTime setText:[NSString stringWithFormat:@"약 %@", [self getTimeRefined:[[routeDic objectForKeyGC:@"TotalTime"] intValue]]]]; }
        @catch (NSException *exception) { [lblTime setText:@" "]; }
        float timeWith = [lblTime.text sizeWithFont:lblTime.font constrainedToSize:CGSizeMake(FLT_MAX, 13) lineBreakMode:lblTime.lineBreakMode].width;
        [lblTime setFrame:CGRectMake(labelLeftPosition, 19, timeWith, 13)];
        labelLeftPosition += timeWith;
        [vwCell addSubview:lblTime];
        [lblTime release];
        // 구분자 삽입
        UIImageView *imgvwSep1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_text_line_01.png"]];
        [imgvwSep1 setFrame:CGRectMake(labelLeftPosition+3.5, 19, 11, 13)];
        labelLeftPosition += 11 + 7;
        [vwCell addSubview:imgvwSep1];
        // 요금 생성/삽입
        UILabel *lblFare = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPosition, 19, 1, 13)];
        [lblFare  setFont:[UIFont boldSystemFontOfSize:13]];
        [lblFare setTextColor:[UIColor blackColor]];
        [lblFare setBackgroundColor:[UIColor clearColor]];
        @try { [lblFare setText:[NSString stringWithFormat:@"약 %@원", [self getAfterFareRefined:[[routeDic objectForKeyGC:@"TotalFare"] doubleValue]]]]; }
        @catch (NSException *exception) { [lblFare setText:@" "]; }
        float fareWidth = [lblFare.text sizeWithFont:lblFare.font constrainedToSize:CGSizeMake(FLT_MAX, 13) lineBreakMode:lblFare.lineBreakMode].width;
        [lblFare setFrame:CGRectMake(labelLeftPosition, 19, fareWidth, 13)];
        labelLeftPosition += fareWidth;
        [vwCell addSubview:lblFare];
        [lblFare release];
        // 구분자 삽입
        UIImageView *imgvwSep2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_text_line_01.png"]];
        [imgvwSep2 setFrame:CGRectMake(labelLeftPosition+3.5, 19, 11, 13)];
        labelLeftPosition += 11 + 7;
        [vwCell addSubview:imgvwSep2];
        // 거리 생성/삽입
        UILabel *lblDistance = [[UILabel alloc] initWithFrame:CGRectMake(labelLeftPosition, 19, 1, 13)];
        [lblDistance  setFont:[UIFont boldSystemFontOfSize:13]];
        [lblDistance setTextColor:[UIColor blackColor]];
        [lblDistance setBackgroundColor:[UIColor clearColor]];
        @try { [lblDistance setText:[NSString stringWithFormat:@"약 %@", [self getDistanceRefined:[[routeDic objectForKeyGC:@"TotalDistance"] doubleValue]]]]; }
        @catch (NSException *exception) { [lblDistance setText:@" "]; }
        float distanceWidth = [lblDistance.text sizeWithFont:lblFare.font constrainedToSize:CGSizeMake(FLT_MAX, 13) lineBreakMode:lblDistance.lineBreakMode].width;
        [lblDistance setFrame:CGRectMake(labelLeftPosition, 19, distanceWidth, 13)];
        labelLeftPosition += distanceWidth;
        [vwCell addSubview:lblDistance];
        [lblDistance release];
        
        // 대중교통 종류 아이콘
        UIImage *imgMethodIcon;
        float iconLeftPosition = 10.0f;
        float iconTopPosition = 44.0f;
        for (NSDictionary *gate in [routeDic objectForKeyGC:@"Gates"])
        {
            @try
            {
                int methodtype = [[gate objectForKeyGC:@"MethodType"] intValue];
                int lid = [[gate objectForKeyGC:@"lID"] intValue];
                imgMethodIcon = [UIImage imageNamed:[NSString stringWithFormat:@"info_icon_%02d.png", [self getPublicMethodIconNumber:methodtype :lid]]];
            }
            // 오류 발생했을 경우 일단 해당 교통타입 무시하고 지나감
            @catch (NSException *exception)
            {
                NSLog(@"길찾기 - 대중교통 - 선택화면 - 대중교통 종류 아이콘 렌더링 오류\n%@", exception);
                imgMethodIcon = [UIImage imageNamed:@"info_icon_01.png"];
            }
            
            // 대중교통 종류 아이콘 삽입
            UIImageView *imgvwIcon = [[UIImageView alloc] initWithImage:imgMethodIcon];
            if (iconLeftPosition+imgvwIcon.frame.size.width > 289)
            {
                iconLeftPosition = 10.0f;
                iconTopPosition += 10.0f + 18;
                CGRect rectCell = vwCell.frame;
                rectCell.size.height += 10.0f + 18;
                [vwCell  setFrame:rectCell];
                cellHeight += 10.0f + 18;
            }
            [imgvwIcon setFrame:CGRectMake(iconLeftPosition, iconTopPosition, imgvwIcon.image.size.width, imgvwIcon.image.size.height)];
            iconLeftPosition += imgMethodIcon.size.width + 4;
            [vwCell addSubview:imgvwIcon];
            [imgvwIcon release];
            
        }
        
        // 우측 버튼 삽입
        UIImageView *imgvwArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_btn_arrow.png"]];
        [imgvwArrow setFrame:CGRectMake(298, (vwCell.frame.size.height-19)/2, 13, 19)];
        [vwCell addSubview:imgvwArrow];
        [imgvwArrow release];
        
        // 셀 이벤트 (경로선택)
        [vwCell setTag:[[resultDic objectForKeyGC:@"No"] intValue]-1];
        [vwCell addTarget:self action:@selector(onPublicMethod:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addTarget:self action:@selector(onPublicMethod_Down:) forControlEvents:UIControlEventTouchDown];
        [vwCell addTarget:self action:@selector(onPublicMethod_UpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        
        // 셀 삽입
        [svwPublicRouteSelectorMethodList addSubview:vwCell];
        [vwCell release];
        
        // 셀 라인 삽입
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, cellHeight, 320, 1)];
        [vwLine setBackgroundColor: convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0f)];
        [svwPublicRouteSelectorMethodList addSubview:vwLine];
        cellHeight += vwLine.frame.size.height;
        [vwLine release];
    }
    
    [svwPublicRouteSelectorMethodList setContentSize:CGSizeMake(320, cellHeight)];
    
    // 대중교통 선택목록 뷰 삽입
    [_vwPublicRouteSelector addSubview:svwPublicRouteSelectorMethodList];
}

- (void) onPublicCategoryRecommend :(id)sender
{
    _currentPublicMethod = OM_SRRMV_PublicMethodType_Recommend;
    [self renderPublicSelector];
}

- (void) onPublicCategoryBus :(id)sender
{
    _currentPublicMethod = OM_SRRMV_PublicMethodType_Bus;
    [self renderPublicSelector];
}

- (void) onPublicCategorySubway :(id)sender
{
    _currentPublicMethod = OM_SRRMV_PublicMethodType_Subway;
    [self renderPublicSelector];
}

- (void) onPublicCategoryBoth :(id)sender
{
    _currentPublicMethod = OM_SRRMV_PublicMethodType_Both;
    [self renderPublicSelector];
}

- (void) onPublicMethod :(id)sender
{
    UIControl *vwCell = sender;
    _currentPublicMethodListIndex = vwCell.tag;
    _currentRouteDetailPathIndex = -1;
    [self renderPublicList];
}
- (void) onPublicMethod_Down:(id)sender
{
    UIControl *cell = (UIControl*)sender;
    [cell setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0f)];
}
- (void) onPublicMethod_UpOutside:(id)sender
{
    UIControl *cell = (UIControl*)sender;
    [cell setBackgroundColor:[UIColor whiteColor]];
}

// **********************************


// ==================================
// [ 대중교통 - 목록 - 렌더링 메소드 ]
// ==================================
#pragma mark -
#pragma mark 대중교통 - 목록 - 렌더링 메소드
- (void) renderPublicList
{
    // 대중교통 - 목록 상태설정
    _currentViewRenderType = OM_SRRMV_ViewRenderType_PUBLIC_LIST; // 대중교통-길찾기
    
    // 네비게이션 영역 렌더링
    [self renderCommonNavigationBar];
    
    // 하단 버튼 영역 렌더링 ( +OllehNavi )
    [self renderCommonBottomButtonsWithOllehNavi:NO];
    
    // 목록 컨테이너 뷰 클리어
    for (UIView *subView in _vwRoutePathListContainer.subviews)
    {
        [subView removeFromSuperview];
    }
    [_vwRoutePathListContainer removeFromSuperview];
    
    // 지도 컨테이너 뷰 삽입
    [self.view addSubview:_vwRoutePathListContainer];
    
    // 요약정보 및 테이블 렌더링
    [self renderPublicListRouteSummaryInfo];
    [self renderPublicListRouteDetailPathTable];
}

- (void) renderPublicListRouteSummaryInfo
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    /* 지도화면에서는 특정 포인트 이동시 다시 렌더링해야 하는 이유로 _vwPublicRouteSummaryInfoGroup 변수로 관리하지만
     목록에서는 뷰컨트롤러 생성시 한번만 생성하면 끝이므로 일회성으로 관리한다.
     */
    
    // *****************
    // [ 목록 요약정보 ]
    // *****************
    
    // 목록 요약정보 뷰 생성
    UIView *vwPublicRouteSummaryInfo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 35)];
    [vwPublicRouteSummaryInfo setBackgroundColor:[UIColor orangeColor]];
    
    // 목록 요약정보 뷰 - 전체경로 라벨
    UILabel *lblPublicRouteSummaryInfoPath = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 15)];
    [lblPublicRouteSummaryInfoPath setFont:[UIFont boldSystemFontOfSize:15]];
    [lblPublicRouteSummaryInfoPath setTextColor:[UIColor whiteColor]];
    [lblPublicRouteSummaryInfoPath setBackgroundColor:[UIColor clearColor]];
    [lblPublicRouteSummaryInfoPath setLineBreakMode:NSLineBreakByClipping];
    [lblPublicRouteSummaryInfoPath setText:[NSString stringWithFormat:@"%@ ➜ %@", oms.searchResultRouteStart.strLocationName, oms.searchResultRouteDest.strLocationName]];
    CGRect rectCarRouteSummaryInfoPath = lblPublicRouteSummaryInfoPath.frame;
    rectCarRouteSummaryInfoPath.size.width = [lblPublicRouteSummaryInfoPath.text sizeWithFont:lblPublicRouteSummaryInfoPath.font constrainedToSize:CGSizeMake(FLT_MAX, 15) lineBreakMode:lblPublicRouteSummaryInfoPath.lineBreakMode].width;
    
    // 전체경로 라벨이 300보다 작아서 한화면에 전부 노출될때는 그냥 렌더링
    if (rectCarRouteSummaryInfoPath.size.width <= 300)
    {
        [vwPublicRouteSummaryInfo addSubview:lblPublicRouteSummaryInfoPath];
        [lblPublicRouteSummaryInfoPath release];
    }
    // 전체경로 라벨 사이즈가 커질경우 marquee 효과를 주기위해 컨테이너 뷰를 렌더링한다.
    else
    {
        // marquee 용 라벨 2개를 포함하는 뷰 생성
        UIView *vwMarqueeContainer = [[[UIView alloc] initWithFrame:CGRectMake(10, 10, rectCarRouteSummaryInfoPath.size.width*2 + 50, 15)] autorelease];
        
        // 첫번째 텍스트 라벨 삽입
        rectCarRouteSummaryInfoPath.origin.x = 0;
        rectCarRouteSummaryInfoPath.origin.y = 0;
        [lblPublicRouteSummaryInfoPath setFrame:rectCarRouteSummaryInfoPath];
        [vwMarqueeContainer addSubview:lblPublicRouteSummaryInfoPath];
        
        // 두번째 텍스
        rectCarRouteSummaryInfoPath.origin.x += rectCarRouteSummaryInfoPath.size.width + 50;
        UILabel *lblCarRouteSummaryInfoPath2 = [[UILabel alloc] initWithFrame:rectCarRouteSummaryInfoPath];
        [lblCarRouteSummaryInfoPath2 setFont:[UIFont boldSystemFontOfSize:15]];
        [lblCarRouteSummaryInfoPath2 setTextColor:[UIColor whiteColor]];
        [lblCarRouteSummaryInfoPath2 setBackgroundColor:[UIColor clearColor]];
        [lblCarRouteSummaryInfoPath2 setLineBreakMode:NSLineBreakByClipping];
        [lblCarRouteSummaryInfoPath2 setText:lblPublicRouteSummaryInfoPath.text];
        [vwMarqueeContainer addSubview:lblCarRouteSummaryInfoPath2];
        
        [vwPublicRouteSummaryInfo addSubview:vwMarqueeContainer];
        
        [lblPublicRouteSummaryInfoPath release];
        [lblCarRouteSummaryInfoPath2 release];
        
        [self performSelector:@selector(marqueePublicListRoutePathLabel:) withObject:vwMarqueeContainer afterDelay:1.0];
    }
    
    // 목록 요약정보 뷰 - 상단 배경 (*라벨 밑으로 깔려야한다)
    UIImageView *imgvwPublicRouteSummaryInfoBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_align_bg_03.png"]];
    [imgvwPublicRouteSummaryInfoBack setFrame:CGRectMake(0, 0, 320, 35)];
    [vwPublicRouteSummaryInfo insertSubview:imgvwPublicRouteSummaryInfoBack atIndex:0];
    // 목록 요약정보 뷰 - 상단 배경 - 마스크
    UIImageView *imgvwMask01 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"car_align_bg_01_list_mask.png"]];
    [imgvwMask01 setFrame:CGRectMake(0, 0, 10, 35)];
    [vwPublicRouteSummaryInfo addSubview:imgvwMask01];
    [imgvwMask01 release];
    UIImageView *imgvwMask02 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"car_align_bg_01_list_mask.png"]];
    [imgvwMask02 setFrame:CGRectMake(310, 0, 10, 35)];
    [vwPublicRouteSummaryInfo addSubview:imgvwMask02];
    [imgvwMask02 release];
    
    
    // 목록뷰에 요약정보 뷰 삽입
    [_vwRoutePathListContainer addSubview:vwPublicRouteSummaryInfo];
    
    [vwPublicRouteSummaryInfo release];
    [imgvwPublicRouteSummaryInfoBack release];
    
    
    // ******************************
    // [ 환승정보 / 거리 / 시간 정보 ]
    // ******************************
    
    // 환승정보 뷰 생성
    CGRect rectGatesInfo = CGRectMake(0, 35, 320, 0);
    UIView *vwGatesInfo = [[UIView alloc] initWithFrame:rectGatesInfo];
    [vwGatesInfo setBackgroundColor:convertHexToDecimalRGBA(@"F2", @"F2", @"F2", 1.0f)];
    
    // 환승정보 라벨
    UILabel *lblGatesPath = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, 300, 15)];
    [lblGatesPath setFont:[UIFont boldSystemFontOfSize:15]];
    [lblGatesPath setBackgroundColor:[UIColor clearColor]];
    [lblGatesPath setTextColor:[UIColor blackColor]];
    [lblGatesPath setLineBreakMode:NSLineBreakByClipping];
    // 환승정보 문자열 구성
    NSDictionary *routeDic = [self getCurrentPublicRouteData];
    NSMutableString *strGatesPath = [NSMutableString string];
    if (routeDic != nil && [[routeDic allKeys]containsObject:@"RouteGate"]
        && [[[routeDic objectForKeyGC:@"RouteGate"] allKeys] containsObject:@"Gates"])
    {
        //for (NSDictionary *gate in [[routeDic objectForKeyGC:@"RouteGate"] objectForKeyGC:@"Gates"])
        for (int count=0, maxCount=[[[routeDic objectForKeyGC:@"RouteGate"] objectForKeyGC:@"Gates"] count]-1; count<=maxCount; count++)
        {
            NSArray *gates = [[routeDic objectForKeyGC:@"RouteGate"] objectForKeyGC:@"Gates"];
            NSDictionary *gate = [gates objectAtIndexGC:count];
            
            if ( strGatesPath.length > 0 ) [strGatesPath appendFormat:@" ➜ "];
            switch ([[gate objectForKeyGC:@"RgType"] intValue])
            {
                case 1:
                    [strGatesPath appendFormat:@"%@번 (%d)", [gate objectForKeyGC:@"LaneName"], [[gate objectForKeyGC:@"Distance"] intValue]];
                    break;
                case 2:
                    if (count < maxCount && [[[gates objectAtIndexGC:count+1] objectForKeyGC:@"RgType"] isEqualToString:@"2"])
                        [strGatesPath appendFormat:@"%@", [gate objectForKeyGC:@"StartName"]];
                    else
                        [strGatesPath appendFormat:@"%@ ➜ %@", [gate objectForKeyGC:@"StartName"], [gate objectForKeyGC:@"EndName"]];
                    break;
                case 3:
                    [strGatesPath appendFormat:@"도보"];
                    break;
                case 4:
                    //[strGatesPath appendFormat:@"%@번 (%d) *환승/%@*", [gate objectForKeyGC:@"LaneName"], [[gate objectForKeyGC:@"Distance"] intValue], [gate objectForKeyGC:@"StartName"]];
                    [strGatesPath appendFormat:@"%@번 (%d)", [gate objectForKeyGC:@"LaneName"], [[gate objectForKeyGC:@"Distance"] intValue]];
                    break;
            }
        }
    }
    
    [lblGatesPath setText:strGatesPath];
    //[OMMessageBox showAlertMessage:@"환승정보" :strGatesPath];
    
    // 환승정보 텍스트 사이즈 조정
    CGSize gatesPathSize = [lblGatesPath.text sizeWithFont:lblGatesPath.font constrainedToSize:CGSizeMake (FLT_MAX, 15) lineBreakMode:lblGatesPath.lineBreakMode];
    int gatesPathMaxRow = gatesPathSize.width / 300;
    if ((int)gatesPathSize.width % 300 > 0) gatesPathMaxRow++;
    [lblGatesPath setFrame:CGRectMake(10, 14, 300, gatesPathSize.height*gatesPathMaxRow)];
    [lblGatesPath setNumberOfLines:gatesPathMaxRow];
    
    // 환승정보 텍스트 삽입
    [vwGatesInfo addSubview:lblGatesPath];
    
    // 시간 라벨
    UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(10, lblGatesPath.frame.origin.y + lblGatesPath.frame.size.height + 13, 0, 13)];
    [lblTime setFont:[UIFont boldSystemFontOfSize:13]];
    [lblTime setTextColor:convertHexToDecimalRGBA(@"19", @"A8", @"C7", 1.0f)];
    [lblTime setBackgroundColor:[UIColor clearColor]];
    double timeDoubleValue = [[[routeDic objectForKeyGC:@"RouteGate"] objectForKeyGC:@"TotalTime"] doubleValue];
    NSString *strTime = [NSString stringWithFormat:@"약 %@", [self getTimeRefined:timeDoubleValue]];
    [lblTime setText:strTime];
    CGRect rectTimeLabel = lblTime.frame;
    rectTimeLabel.size.width = [lblTime.text sizeWithFont:lblTime.font constrainedToSize:CGSizeMake(FLT_MAX, 13) lineBreakMode:lblTime.lineBreakMode].width;
    [lblTime setFrame:rectTimeLabel];
    
    // 구분자
    UIImageView *imgvwSep1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_text_line_01.png"]];
    [imgvwSep1 setFrame:CGRectMake(rectTimeLabel.origin.x + rectTimeLabel.size.width, lblTime.frame.origin.y, 15, 13)];
    
    // 요금 라벨
    UILabel *lblFare = [[UILabel alloc] initWithFrame:CGRectMake(imgvwSep1.frame.origin.x + imgvwSep1.frame.size.width, lblTime.frame.origin.y, 0, 13)];
    [lblFare setFont:[UIFont systemFontOfSize:13]];
    [lblFare setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
    [lblFare setBackgroundColor:[UIColor clearColor]];
    double fareDoubleValue =  [[[routeDic objectForKeyGC:@"RouteGate"] objectForKeyGC:@"TotalFare"] doubleValue];
    NSString *strFare = [NSString stringWithFormat:@"약 %@원", [self getAfterFareRefined:fareDoubleValue]];
    [lblFare setText:strFare];
    CGRect rectFareLabel = lblFare.frame;
    rectFareLabel.size.width = [lblFare.text sizeWithFont:lblFare.font constrainedToSize:CGSizeMake(FLT_MAX, 13) lineBreakMode:lblFare.lineBreakMode].width;
    [lblFare setFrame:rectFareLabel];
    
    // 구분자
    UIImageView *imgvwSep2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_text_line_01.png"]];
    [imgvwSep2 setFrame:CGRectMake(rectFareLabel.origin.x + rectFareLabel.size.width, lblTime.frame.origin.y, 15, 13)];
    
    // 거리 라벨
    UILabel *lblDistance = [[UILabel alloc] initWithFrame:CGRectMake(imgvwSep2.frame.origin.x + imgvwSep2.frame.size.width, lblTime.frame.origin.y, 0, 13)];
    [lblDistance setFont:[UIFont systemFontOfSize:13]];
    [lblDistance setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
    [lblDistance setBackgroundColor:[UIColor clearColor]];
    double distanceDoubleValue =  [[[routeDic objectForKeyGC:@"RouteGate"] objectForKeyGC:@"TotalDistance"] doubleValue];
    NSString *strDistance = [NSString stringWithFormat:@"약 %@", [self getDistanceRefined:distanceDoubleValue]];
    [lblDistance setText:strDistance];
    CGRect rectDistance = lblDistance.frame;
    rectDistance.size.width = [lblDistance.text sizeWithFont:lblDistance.font constrainedToSize:CGSizeMake(FLT_MAX, 13) lineBreakMode:lblDistance.lineBreakMode].width;
    [lblDistance setFrame:rectDistance];
    
    [vwGatesInfo addSubview:lblTime];
    [vwGatesInfo addSubview:imgvwSep1];
    [vwGatesInfo addSubview:lblFare];
    [vwGatesInfo addSubview:imgvwSep2];
    [vwGatesInfo addSubview:lblDistance];
    
    [lblTime release];
    [lblFare release];
    [lblDistance release];
    [imgvwSep1 release];
    [imgvwSep2 release];
    
    // 환승정보 뷰 사이즈 조정
    rectGatesInfo.size.height = 14 + lblGatesPath.frame.size.height + 11 + 13 + 14; // 상단여백+환승높이+중단여백+거리높이+하단여백
    [vwGatesInfo setFrame:rectGatesInfo];
    
    // 환승정보 뷰 삽입
    [_vwRoutePathListContainer addSubview:vwGatesInfo];
    
    // 자원해제
    [lblGatesPath release];
    [vwGatesInfo release];
    
}
- (void) marqueePublicListRoutePathLabel :(UIView *)container
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *str = [NSString stringWithFormat:@"%@ ➜ %@", oms.searchResultRouteStart.strLocationName, oms.searchResultRouteDest.strLocationName];
    CGSize size = [str sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(FLT_MAX, 15) lineBreakMode:NSLineBreakByClipping];
    float duration = size.width / 50;
    
    CGRect rect = container.frame;
    rect.origin.x = 10;
    [container setFrame:rect];
    
    rect.origin.x = rect.origin.x - size.width - 50;
    
    [UIView beginAnimations:@"marqueePublicListRoutePathLabel" context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    [container setFrame:rect];
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(marqueePublicListRoutePathLabel:) withObject:container afterDelay:duration + 1.0];
}


- (void) renderPublicListRouteDetailPathTable
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    float routeGateViewHeight = 0.0f;
    for (UIView *subView in _vwRoutePathListContainer.subviews)
    {
        routeGateViewHeight += subView.frame.size.height;
    }
    
    // 스크롤뷰 생성
    OMScrollView *svwRouteDetailPathList = [[OMScrollView alloc]
                                            initWithFrame:CGRectMake(0, routeGateViewHeight,
                                                                     [[UIScreen mainScreen] bounds].size.width,
                                                                     _vwRoutePathListContainer.frame.size.height - routeGateViewHeight)];
    [svwRouteDetailPathList setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [svwRouteDetailPathList setDelegate:self];
    [svwRouteDetailPathList setScrollType:2];
    
    // 경로 셀 인덱스 카운트 ( 0 출발 / 1~ 이동수단 / ~00 도착)
    int count = 0;
    
    float routeDetailPathListHeight = 0.0f;
    CGRect rectCell = CGRectZero;
    
    // 최상단 라인 렌더링
    {
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, routeDetailPathListHeight, 320, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0f)];
        
        routeDetailPathListHeight += 1;
        
        [svwRouteDetailPathList addSubview:vwLine];
        [vwLine release];
    }
    
    // 출발점 셀 렌더링
    {
        // 셀
        rectCell = CGRectMake(0, routeDetailPathListHeight, 320, 0);
        UIControl *vwCell = [[UIControl alloc] initWithFrame:rectCell];
        [vwCell setBackgroundColor:[UIColor whiteColor]];
        
        CGRect rectTextLabel = CGRectMake(50, 19, 260, 15);
        UILabel *lblPointName = [[UILabel alloc] initWithFrame:rectTextLabel];
        [lblPointName setFont:[UIFont boldSystemFontOfSize:15]];
        [lblPointName setBackgroundColor:[UIColor clearColor]];
        [lblPointName setLineBreakMode:NSLineBreakByClipping];
        [lblPointName setText:oms.searchResultRouteStart.strLocationName];
        
        rectTextLabel.size = [lblPointName.text sizeWithFont:lblPointName.font constrainedToSize:CGSizeMake(rectTextLabel.size.width, FLT_MAX) lineBreakMode:lblPointName.lineBreakMode];
        [lblPointName setFrame:rectTextLabel];
        int labelMaxRow = rectTextLabel.size.height / 15;
        if ((int)rectTextLabel.size.height % 15 > 0) labelMaxRow++;
        [lblPointName setNumberOfLines:labelMaxRow];
        [vwCell addSubview:lblPointName];
        [lblPointName release];
        
        rectCell.size.height = rectTextLabel.size.height + 19 + 18;
        [vwCell setFrame:rectCell];
        routeDetailPathListHeight += rectCell.size.height;
        
        UIImageView *imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_start.png"]];
        [imgvwIcon setFrame:CGRectMake(10, (rectCell.size.height-30)/2, imgvwIcon.image.size.width, imgvwIcon.image.size.height)];
        [vwCell addSubview:imgvwIcon];
        [imgvwIcon release];
        
        // 셀 이벤트 처리
        [vwCell setTag:count];
        [vwCell addTarget:self action:@selector(onPublicListRouteDetailPathTableToMap:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addTarget:self action:@selector(onPublicListRouteDetailPath_Down:) forControlEvents:UIControlEventTouchDown];
        [vwCell addTarget:self action:@selector(onPublicListRouteDetailPath_UpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        if (_currentRouteDetailPathIndex == vwCell.tag)
        {
            [vwCell setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0f)];
            [svwRouteDetailPathList setContentOffset:CGPointMake(0, routeDetailPathListHeight-(svwRouteDetailPathList.frame.size.height/3))];
        }
        
        [svwRouteDetailPathList addSubview:vwCell];
        [vwCell release];
        
        // 라인
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, routeDetailPathListHeight, 320, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0f)];
        
        routeDetailPathListHeight += 1;
        
        [svwRouteDetailPathList addSubview:vwLine];
        [vwLine release];
        
        count++;
    }
    
    // 환승정보 렌더링
    NSDictionary *routeDic = [self getCurrentPublicRouteData];
    if (routeDic != nil && [[routeDic allKeys]containsObject:@"RouteGate"]
        && [[[routeDic objectForKeyGC:@"RouteGate"] allKeys] containsObject:@"Gates"])
    {
        
        //for (int count=0, maxCount=[[[routeDic objectForKeyGC:@"RouteGate"] objectForKeyGC:@"Gates"] count]-1; count<=maxCount; count++)
        //{
        //   NSDictionary *gate = [[[routeDic objectForKeyGC:@"RouteGate"] objectForKeyGC:@"Gates"] objectAtIndexGC:count];
        //}
        
        for (NSDictionary *gate in [[routeDic objectForKeyGC:@"RouteGate"] objectForKeyGC:@"Gates"])
        {
            NSString *strGatesTitle;
            NSString *strGatesPath;
            
            NSString *strGatesPathStartName = nil;
            NSString *strGatesPathEndName = nil;
            // 출발지 도착지 이름은 상황에 따라 커스터마이징 필요
            strGatesPathStartName = [NSString stringWithFormat:@"%@", [gate objectForKeyGC:@"StartName"]];
            strGatesPathEndName = [NSString stringWithFormat:@"%@", [gate objectForKeyGC:@"EndName"]];
            
            double distanceGatesPath = [[gate objectForKeyGC:@"Distance"] doubleValue];
            int routeGateType = [[gate objectForKeyGC:@"RgType"] intValue];
            int methodType  = [[gate objectForKeyGC:@"MethodType"] intValue];
            int lID  = [[gate objectForKeyGC:@"lID"] intValue];
            
            switch (routeGateType)
            {
                case 1: // 버스
                case 4: // 버스(환승)
                    strGatesTitle = [NSString stringWithFormat:@"%@번", [gate objectForKeyGC:@"LaneName"]];
                    strGatesPath = [NSString stringWithFormat:@"%@에서 승차 후 %@에서 하차 (%d개 정류장)"
                                    , strGatesPathStartName
                                    , strGatesPathEndName
                                    , (int)distanceGatesPath ];
                    break;
                    
                case 2: // 지하철
                    strGatesTitle = [NSString stringWithFormat:@"지하철 %@", [gate objectForKeyGC:@"LaneName"]];
                    strGatesPath = [NSString stringWithFormat:@"%@에서 승차 후 %@에서 하차 (%d개 역)"
                                    , strGatesPathStartName
                                    , strGatesPathEndName
                                    , (int)distanceGatesPath ];
                    break;
                    
                case 3: // 도보
                    strGatesTitle = [NSString stringWithFormat:@"도보 이동"];
                    strGatesPath = [NSString stringWithFormat:@"%@에서 %@까지 %@ 걷기"
                                    , strGatesPathStartName
                                    , strGatesPathEndName
                                    , [self getDistanceRefined:distanceGatesPath] ];
                    break;
                    
                default:
                    strGatesTitle = @"";
                    strGatesPath = @"";
                    break;
            }
            //NSLog(@"%@ / %@", strGatesTitle, strGatesPath);
            
            
            // ******************
            // [ 노선정보 렌더링 ]
            // ******************
            
            // 셀 뷰 생성
            CGRect rectCell = CGRectMake(0, routeDetailPathListHeight, 320, 0);
            UIControl *vwCell = [[UIControl alloc] initWithFrame:rectCell];
            [vwCell setBackgroundColor:[UIColor whiteColor]];
            
            // 노선 순서 아이콘
            UIImageView *imgvwGateNumberIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"marker_num_%03d.png", count]]];
            [imgvwGateNumberIcon setFrame:CGRectMake(48, 8, imgvwGateNumberIcon.image.size.width, imgvwGateNumberIcon.image.size.height)];
            [vwCell addSubview:imgvwGateNumberIcon];
            
            // 노선 타이틀
            UILabel *lblGateTitle = [[UILabel alloc] initWithFrame:CGRectMake(72, 11, 238, 13)];
            [lblGateTitle setFont:[UIFont systemFontOfSize:13]];
            [lblGateTitle setTextColor:[UIColor blackColor]];
            [lblGateTitle setBackgroundColor:[UIColor clearColor]];
            [lblGateTitle setText:strGatesTitle];
            [vwCell addSubview:lblGateTitle];
            
            // 노선 경로
            CGRect rectGatePathLabel = CGRectMake(48, 11+lblGateTitle.frame.size.height+4, 272, 13);
            UILabel *lblGatePath = [[UILabel alloc] initWithFrame:rectGatePathLabel];
            [lblGatePath setFont:[UIFont systemFontOfSize:13]];
            [lblGatePath setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
            [lblGatePath setBackgroundColor:[UIColor clearColor]];
            [lblGatePath setText:strGatesPath];
            rectGatePathLabel.size = [lblGatePath.text sizeWithFont:lblGatePath.font constrainedToSize:CGSizeMake(272, FLT_MAX) lineBreakMode:lblGatePath.lineBreakMode];
            int gatePathMaxRow = rectGatePathLabel.size.height / 13;
            if ((int)rectGatePathLabel.size.height % 13 > 0) gatePathMaxRow++;
            [lblGatePath setFrame:rectGatePathLabel];
            [lblGatePath setNumberOfLines:gatePathMaxRow];
            [vwCell addSubview:lblGatePath];
            
            rectCell.size.height = 11 + lblGateTitle.frame.size.height + 4 + rectGatePathLabel.size.height + 11;
            [vwCell setFrame:rectCell];
            
            // 노선 아이콘
            NSString *strGateIconName = [NSString stringWithFormat:@"info_icon_%02d.png", [self getPublicMethodIconNumber:methodType :lID]];
            UIImageView *imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:strGateIconName]];
            [imgvwIcon setFrame:CGRectMake( (int)((48-imgvwIcon.image.size.width)/2)  , (int)((rectCell.size.height-imgvwIcon.image.size.height)/2), imgvwIcon.image.size.width, imgvwIcon.image.size.height)];
            
            [vwCell addSubview:imgvwIcon];
            
            routeDetailPathListHeight += rectCell.size.height;
            
            [imgvwGateNumberIcon release];
            [lblGateTitle release];
            [lblGatePath release];
            [imgvwIcon  release];
            
            // 셀 이벤트 처리
            [vwCell setTag:count];
            [vwCell addTarget:self action:@selector(onPublicListRouteDetailPathTableToMap:) forControlEvents:UIControlEventTouchUpInside];
            [vwCell addTarget:self action:@selector(onPublicListRouteDetailPath_Down:) forControlEvents:UIControlEventTouchDown];
            [vwCell addTarget:self action:@selector(onPublicListRouteDetailPath_UpOutside:) forControlEvents:UIControlEventTouchUpOutside];
            if (_currentRouteDetailPathIndex == vwCell.tag)
            {
                [vwCell setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0f)];
                [svwRouteDetailPathList setContentOffset:CGPointMake(0, routeDetailPathListHeight-(svwRouteDetailPathList.frame.size.height/3))];
            }
            
            // 뷰 삽입
            [svwRouteDetailPathList addSubview:vwCell];
            [vwCell release];
            
            // 하단 라인 삽입
            UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, routeDetailPathListHeight, 320, 1)];
            [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0f)];
            [svwRouteDetailPathList addSubview:vwLine];
            [vwLine release];
            routeDetailPathListHeight += 1;
            
            // 인덱스 카운트 증가
            count++;
            
        } // end - FOR
    } // end - IF
    
    // 도착점 렌더링
    {
        // 셀
        rectCell = CGRectMake(0, routeDetailPathListHeight, 320, 0);
        UIControl *vwCell = [[UIControl alloc] initWithFrame:rectCell];
        [vwCell setBackgroundColor:[UIColor whiteColor]];
        
        CGRect rectTextLabel = CGRectMake(50, 19, 260, 15);
        UILabel *lblPointName = [[UILabel alloc] initWithFrame:rectTextLabel];
        [lblPointName setFont:[UIFont boldSystemFontOfSize:15]];
        [lblPointName setBackgroundColor:[UIColor clearColor]];
        [lblPointName setLineBreakMode:NSLineBreakByClipping];
        [lblPointName setText:oms.searchResultRouteDest.strLocationName];
        
        rectTextLabel.size = [lblPointName.text sizeWithFont:lblPointName.font constrainedToSize:CGSizeMake(rectTextLabel.size.width, FLT_MAX) lineBreakMode:lblPointName.lineBreakMode];
        [lblPointName setFrame:rectTextLabel];
        int labelMaxRow = rectTextLabel.size.height / 15;
        if ((int)rectTextLabel.size.height % 15 > 0) labelMaxRow++;
        [lblPointName setNumberOfLines:labelMaxRow];
        [vwCell addSubview:lblPointName];
        [lblPointName release];
        
        rectCell.size.height = rectTextLabel.size.height + 19 + 18;
        [vwCell setFrame:rectCell];
        routeDetailPathListHeight += rectCell.size.height;
        
        UIImageView *imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_stop.png"]];
        [imgvwIcon setFrame:CGRectMake(10, (rectCell.size.height-30)/2, 30, 30)];
        [vwCell addSubview:imgvwIcon];
        [imgvwIcon release];
        
        // 셀 이벤트 처리
        //[vwCell setTag:count];
        [vwCell setTag: [[[routeDic objectForKeyGC:@"RouteGate"] objectForKeyGC:@"RGCount"] intValue]+1];
        [vwCell addTarget:self action:@selector(onPublicListRouteDetailPathTableToMap:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addTarget:self action:@selector(onPublicListRouteDetailPath_Down:) forControlEvents:UIControlEventTouchDown];
        [vwCell addTarget:self action:@selector(onPublicListRouteDetailPath_UpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        if (_currentRouteDetailPathIndex == vwCell.tag)
        {
            [vwCell setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0f)];
            [svwRouteDetailPathList setContentOffset:CGPointMake(0, routeDetailPathListHeight-(svwRouteDetailPathList.frame.size.height/3))];
        }
        
        
        [svwRouteDetailPathList addSubview:vwCell];
        [vwCell release];
        
        // 라인
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, routeDetailPathListHeight, 320, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0f)];
        
        routeDetailPathListHeight += 1;
        
        [svwRouteDetailPathList addSubview:vwLine];
        [vwLine release];
    }
    
    // 스크롤뷰 컨텐츠 사이즈 조정
    [svwRouteDetailPathList setContentSize:CGSizeMake(320, routeDetailPathListHeight)];
    
    // 스크롤뷰 삽입
    [_vwRoutePathListContainer addSubview:svwRouteDetailPathList];
    [svwRouteDetailPathList release];
    
    
    // 하단 즐겨찾기 뷰 그룹 앞으로 가져오기 (**스크롤뷰 경계선을 덮기위해)
    [self.view bringSubviewToFront:_vwBottomButtonGroup];
    
}

- (void) onPublicListRouteDetailPathTableToMap :(id)sender
{
    UIControl *vwCell = sender;
    
    // 현재 선택 인덱스 저장
    _currentRouteDetailPathIndex = vwCell.tag;
    
    // 지도모드 렌더링
    [self renderPublicMap];
    // 지도모드 렌더링 이후 상세경로정보 재설정
    [self renderPublicMapRouteDetailPathInfo:vwCell.tag];
    [self renderPublicMapRouteSummaryInfo];
}
- (void) onPublicListRouteDetailPath_Down:(id)sender
{
    UIControl *cell = (UIControl*)sender;
    [cell setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0f)];
}
- (void) onPublicListRouteDetailPath_UpOutside:(id)sender
{
    UIControl *cell = (UIControl*)sender;
    [cell setBackgroundColor:[UIColor whiteColor]];
}

// **********************************


// ==================================
// [ 대중교통 - 지도 - 렌더링 메소드 ]
// ==================================
- (void) renderPublicMap
{
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    //OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 대중교통 - 지도 상태설정
    _currentRouteDetailPathIndex = -1; // -1 전체경로
    _currentViewRenderType = OM_SRRMV_ViewRenderType_PUBLIC_MAP; // 대중교통-길찾기
    
    // 네비게이션 영역 렌더링
    [self renderCommonNavigationBar];
    
    // 하단 버튼 영역 렌더링 ( +OllehNavi )
    [self renderCommonBottomButtonsWithOllehNavi:NO];
    
    // 지도 컨테이너 뷰 클리어
    for (UIView *subView in _vwRoutePathMapContainer.subviews)
    {
        [subView removeFromSuperview];
    }
    [_vwRoutePathMapContainer removeFromSuperview];
    
    // 지도 컨테이너 뷰 삽입
    [self.view addSubview:_vwRoutePathMapContainer];
    [self.view bringSubviewToFront:_vwBottomButtonGroup];
    
    // 지도 삽입
    [mc showMapContainer:_vwRoutePathMapContainer :self];
    
    // 지도 위 버튼삽입
    [_vwRoutePathMapContainer addSubview:_btnMyLocation];
    [_vwRoutePathMapContainer addSubview:_btnMapTrafficInfo];
    [_vwRoutePathMapContainer addSubview:_btnMapRenderStyle];
    [_vwRoutePathMapContainer addSubview:_imgvwMapTrafficInfo];
    
    // 지도 컨테이너 뷰 위 내위치 반경 삽입
    [_vwRoutePathMapContainer addSubview:_imgvwMyArea];
    [_vwRoutePathMapContainer addSubview:_imgvwMyDirection];
    
    // 경로 폴리곤라인 렌더링
    [self renderPublicMapPathPolygon];
    
    
    // 지도 하단 정보영역 렌더링
    [self renderPublicMapRouteDetailPathInfo:_currentRouteDetailPathIndex];
    [self renderPublicMapRouteSummaryInfo];
    
}

- (void) renderPublicMapPathPolygon
{
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 기존 모든 오버레이 제거
    [mc.kmap removeAllOverlays];
    
    // 상세포인트 오버레이 관리 리스트 비우기
    [_detailPointOverlays removeAllObjects];
    
    // 도보 경로 배열
    NSMutableArray *routeWalkContainer = [NSMutableArray array];
    // 대중교통 경로 배열
    NSMutableArray *routeMethodContainer = [NSMutableArray array];
    
    // 현재 상태에 해당하는 대중교통 경로정보 가져오기
    NSDictionary *routeDic = [self getCurrentPublicRouteData];
    
    // 데이터 정확성 체크
    if (routeDic == nil || [routeDic isEqual:[NSNull null]])
    {
        [OMMessageBox showAlertMessage:@"" :@"길찾기(대중교통) 관련된 정보가 명확하지 않습니다."];
        return;
    }
    
    // 지도 줌레벨 설정 ( 초기화)
    KBounds kb;
    kb.minX = kb.maxX = oms.searchResultRouteStart.coordLocationPoint.x;
    kb.minY = kb.maxY = oms.searchResultRouteStart.coordLocationPoint.y;
    
    // 대중교통 경로 조합 (여러개의 리스트로 분리되어 있음)
    NSArray *methodList = [routeDic objectForKeyGC:@"MethodList"];
    Coord coordForWalk = CoordMake(0, 0);
    for (int methodCnt=0, methodMaxCnt=methodList.count; methodCnt<methodMaxCnt; methodCnt++)
        //for (NSDictionary *methodDic in methodList)
    {
        NSDictionary *methodDic = [methodList objectAtIndexGC:methodCnt];
        NSArray *vertexs = [methodDic objectForKeyGC:@"VertexList"];
        
        CoordList *coordListMethod = [[[CoordList alloc] init] autorelease];
        for (int cnt=0, maxcnt=vertexs.count; cnt<maxcnt; cnt++)
            //for (NSValue *vertexValue in vertexs)
        {
            NSValue *vertexValue = [vertexs objectAtIndexGC:cnt];
            CGPoint p = CGPointMake(0, 0);
            [vertexValue getValue:&p];
            Coord crd = CoordMake(p.x, p.y);
            
            [coordListMethod addCoord:crd];
            
            if (p.x < kb.minX) kb.minX = p.x;
            if (p.x > kb.maxX) kb.maxX = p.x;
            if (p.y < kb.minY) kb.minY = p.y;
            if (p.y > kb.maxY) kb.maxY = p.y;
            
            // 하나의 메소드 (-대중교통만 존재-)가 끝날 때 마지막 지점을 저장한다.
            // 메소드 사이에 도보가 존재할 경우 점선으로 처리하기 위해서...
            if (cnt == maxcnt-1 && coordForWalk.x == 0)
            {
                coordForWalk = crd;
            }
            // 하나의 메소드가 시작할 때 이전 메소드에서 기록된 좌표가 존재할 경우
            // 두 좌표 사이를 점선으로 처리한다.
            else if (cnt == 0 && coordForWalk.x != 0)
            {
                CoordList *coords = [[[CoordList alloc] init] autorelease];
                [coords addCoord:coordForWalk];
                [coords addCoord:crd];
                [routeWalkContainer addObject:coords];
                coordForWalk = CoordMake(0, 0);
            }
        }
        
        [routeMethodContainer addObject:coordListMethod];
        
    }
    
    //CGPoint pMin, pMax;
    //pMin = CGPointMake(kb.minX, kb.minY);
    //pMax = CGPointMake(kb.maxX, kb.maxY);
    
    //[((NSMutableDictionary *)routeDic) setObject:[NSValue valueWithCGPoint:pMin] forKey:@"MapAreaMin"];
    //[((NSMutableDictionary *)routeDic) setObject:[NSValue valueWithCGPoint:pMax] forKey:@"MapAreaMax"];
    
    NSArray *stations = [routeDic  objectForKeyGC:@"Station"];
    if (stations.count > 0)
    {
        CoordList *coordListWalkStart = [[[CoordList alloc] init] autorelease];
        [coordListWalkStart addCoord:oms.searchResultRouteStart.coordLocationPoint];
        [coordListWalkStart addCoord:CoordMake([[[stations objectAtIndexGC:0] objectForKeyGC:@"X"] doubleValue],
                                               [[[stations objectAtIndexGC:0] objectForKeyGC:@"Y"] doubleValue])];
        [routeWalkContainer addObject:coordListWalkStart];
        CoordList *coordListWalkDest = [[[CoordList alloc] init] autorelease];
        [coordListWalkDest addCoord:oms.searchResultRouteDest.coordLocationPoint];
        [coordListWalkDest addCoord:CoordMake([[[stations objectAtIndexGC:(stations.count-1)] objectForKeyGC:@"X"] doubleValue],
                                              [[[stations objectAtIndexGC:(stations.count-1)] objectForKeyGC:@"Y"] doubleValue])];
        [routeWalkContainer addObject:coordListWalkDest];
    }
    
    
    // 대중교통 경로 (실선)
    for (CoordList *clw in routeMethodContainer)
    {
        PolylineOverlay *plovr = [[PolylineOverlay alloc] initWithCoordList:clw];
        plovr.lineWidth = 5;
        plovr.delegate = self;
        plovr.canShowBalloon = NO;
        CGColorRef color = CGColorCreateRGB(convertHexToDecimal(@"1a") ,convertHexToDecimal(@"68") ,convertHexToDecimal(@"c9") ,1.0f);
        plovr.strokeColor = color;
        CFRelease(color);
        [mc.kmap addOverlay:plovr];
        [plovr release];
    }
    
    // 도보 경로 (점선)
    for (CoordList *clw in routeWalkContainer)
    {
        PolylineOverlay *plovr = [[PolylineOverlay alloc] initWithCoordList:clw];
        plovr.lineWidth = 5;
        plovr.delegate = self;
        plovr.canShowBalloon = NO;
        CGColorRef color = CGColorCreateRGB(convertHexToDecimal(@"1a") ,convertHexToDecimal(@"68") ,convertHexToDecimal(@"c9") ,1.0f);
        plovr.strokeColor = color;
        CFRelease(color);
        plovr.lineType = kLineType_Dash;
        [mc.kmap addOverlay:plovr];
        [plovr release];
    }
    
    
    // 출발/도착 포인트 렌더링
    {
        // 시작점 오버레이 렌더링
        RouteImageOverlay *imgovrStart = [[RouteImageOverlay alloc] initWithImage:[UIImage imageNamed:@"map_marker_start.png"]];
        [imgovrStart setRouteImageOverlayType:RouteImageOverlay_Type_Start];
        [imgovrStart setCoord:oms.searchResultRouteStart.coordLocationPoint];
        [imgovrStart setCenterOffset:CGPointMake( (int)(imgovrStart.imageSize.width/2), (int)(imgovrStart.imageSize.height) )];
        [imgovrStart setTag:20000];
        [imgovrStart setDelegate:self];
        [mc.kmap addOverlay:imgovrStart];
        [_detailPointOverlays addObject:imgovrStart];
        [imgovrStart release];
    }
    // 각 포인트 렌더링
    int pointIndex = 0;
    for (NSDictionary *pdic in [[routeDic objectForKeyGC:@"RouteGate"] objectForKeyGC:@"Gates"])
    {
        Coord pCrd = CoordMake([[pdic objectForKeyGC:@"X"] doubleValue], [[pdic objectForKeyGC:@"Y"] doubleValue]);
        NSString *strImageName = [NSString stringWithFormat:@"marker_num_%03d.png", pointIndex];
        RouteImageOverlay *imgovrPoint = [[RouteImageOverlay alloc] initWithImage:[UIImage imageNamed:strImageName]];
        [imgovrPoint setRouteImageOverlayType:RouteImageOverlay_Type_Normal];
        [imgovrPoint setCoord:pCrd];
        [imgovrPoint setCenterOffset:CGPointMake( (int)(imgovrPoint.imageSize.width/2), (int)(imgovrPoint.imageSize.height/2) )];
        [imgovrPoint setTag:pointIndex+20000];
        [imgovrPoint setDelegate:self];
        [mc.kmap addOverlay:imgovrPoint];
        if (pointIndex > 0 ) //  0일경우엔 이미 시작점 별도로 처리했으니 무시..
            [_detailPointOverlays addObject:imgovrPoint];
        [imgovrPoint release];
        
        pointIndex++;
    }
    // 출발/도착 포인트 렌더링
    {
        // 도착점 오버레이 렌더링
        RouteImageOverlay *imgovrEnd = [[RouteImageOverlay alloc] initWithImage:[UIImage imageNamed:@"map_marker_stop"]];
        [imgovrEnd setRouteImageOverlayType:RouteImageOverlay_Type_Dest];
        [imgovrEnd setCoord:oms.searchResultRouteDest.coordLocationPoint];
        [imgovrEnd setCenterOffset:CGPointMake((int)(imgovrEnd.imageSize.width/2), (int)(imgovrEnd.imageSize.height) )];
        [imgovrEnd setTag: pointIndex +20000];
        [imgovrEnd setDelegate:self];
        [mc.kmap addOverlay:imgovrEnd];
        [_detailPointOverlays addObject:imgovrEnd];
        [imgovrEnd release];
    }
    
    
}
- (void) renderPublicMapRouteDetailPathInfo:(int)pathIndex
{
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    _currentRouteDetailPathIndex = pathIndex;
    
    // 전국지도 단위 번호 아이콘 노출여부
#if 0
    for (Overlay *overlay in mc.kmap.getOverlays)
    {
        if ( [overlay isKindOfClass:[RouteImageOverlay class]] )
        {
            RouteImageOverlay *riovr = (RouteImageOverlay*)overlay;
            if (_currentRouteDetailPathIndex == -1 && riovr.routeImageOverlayType == RouteImageOverlay_Type_Normal )
            {
                riovr.imageSize = CGSizeMake(0, 0);
            }
            else
            {
                riovr.imageSize = CGSizeMake(riovr.imageView.image.size.width, riovr.imageView.image.size.height);
            }
        }
    }
#endif
    
    NSDictionary *routeDic = [self getCurrentPublicRouteData];
    NSDictionary *routeGateDic = [routeDic objectForKeyGC:@"RouteGate"];
    
    // 현재 선택된 상세포인터 지웠다가 다시 그리기 (앞으로 가져오도록)
    // MIK.geun :: 20121128 // 실제 화면에 보이는 포인터 오버레이와 데이터로 존재하는 카운트수에 한개의 차이가 존재.
    // 실제 검색결과값이  "출발"포함한, 그리고 "도착"점은 제외된 상태로 오기때문에
    // 항상 검색결과값의 최종값이 화면상에서는 뒤에서 두번째 값이 처리된다.
    // 지도에 오버레이 렌더링할때는 마지막 두개의 점이 "도착" 오버레이로 동일하게 처리됨. 주의하자..
    if ( pathIndex >= 0 && _detailPointOverlays.count >= pathIndex+1 )
    {
        RouteImageOverlay *currentPointOverlay = [_detailPointOverlays objectAtIndexGC:pathIndex];
        if ( currentPointOverlay )
        {
            [mc.kmap removeOverlay:currentPointOverlay];
            [mc.kmap addOverlay:currentPointOverlay];
        }
    }
    
    // 맵 포인트 이동
    if (pathIndex == 0)
    {
        
        [mc.kmap setCenterCoordinate:oms.searchResultRouteStart.coordLocationPoint];
        [mc.kmap setZoomLevel:12];
    }
    else if (pathIndex > 0 && pathIndex < [[routeGateDic objectForKeyGC:@"RGCount"] intValue])
    {
        CGPoint p = CGPointMake( [[[[routeGateDic objectForKeyGC:@"Gates"] objectAtIndexGC:pathIndex] objectForKeyGC:@"X"] doubleValue],
                                [[[[routeGateDic objectForKeyGC:@"Gates"] objectAtIndexGC:pathIndex] objectForKeyGC:@"Y"] doubleValue] );
        [mc.kmap setCenterCoordinate:CoordMake(p.x, p.y)];
        [mc.kmap setZoomLevel:12];
    }
    else if (pathIndex == -1)
    {
        KBounds kb;
        CGPoint pMin, pMax;
        [[routeDic objectForKeyGC:@"MapAreaMin"] getValue:&pMin];
        [[routeDic objectForKeyGC:@"MapAreaMax"] getValue:&pMax];
        kb.minX = pMin.x;
        kb.minY = pMin.y;
        kb.maxX = pMax.x;
        kb.maxY = pMax.y;
        [mc.kmap zoomToExtent:kb];
        mc.kmap.zoomLevel--;
    }
    else
    {
        [mc.kmap setCenterCoordinate:oms.searchResultRouteDest.coordLocationPoint];
        [mc.kmap setZoomLevel:12];
    }
    // 밑으로 건들지마
    
    
    for (UIView *subView in _vwPublicRouteDetailPathInfoGroup.subviews)
    {
        [subView removeFromSuperview];
    }
    
    [self renderPublicMapRouteDetailPathInfoMiddle:_currentRouteDetailPathIndex-1 :0];
    [self renderPublicMapRouteDetailPathInfoMiddle:_currentRouteDetailPathIndex+1 :640];
    [self renderPublicMapRouteDetailPathInfoMiddle:_currentRouteDetailPathIndex :320];
    
    CGRect detailRect = [_vwPublicRouteDetailPathInfoGroup frame];
    
    
    
    [_vwPublicRouteDetailPathInfoGroup setFrame:CGRectMake(0, 0, 320 * 3, 60)];
    
    [_scrollViewPub setFrame:CGRectMake(0, self.view.frame.size.height-37-37-detailRect.size.height, 320, detailRect.size.height)];
    [_scrollViewPub setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_scrollViewPub setContentSize:CGSizeMake(960, detailRect.size.height)];
    [_scrollViewPub setContentOffset:CGPointMake(320, 0)];
    //[_scrollView setBackgroundColor:[UIColor yellowColor]];
    [_scrollViewPub setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"info_bg.png"]]];
    [_scrollViewPub addSubview:_vwPublicRouteDetailPathInfoGroup];
    [_vwRoutePathMapContainer addSubview:_scrollViewPub];
}
- (void) renderPublicMapRouteDetailPathInfoMiddle:(int)pathIndex :(int)viewSight
{
    //
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    //_currentRouteDetailPathIndex = pathIndex;
    
    NSDictionary *routeDic = [self getCurrentPublicRouteData];
    NSDictionary *routeGateDic = [routeDic objectForKeyGC:@"RouteGate"];
    
    
    
    // 상세경로 정보 사이즈 구하기 (초기값)
    CGRect rectPublicRouteDetailPath = _vwPublicRouteDetailPathInfoGroup.frame;
    // 상세경로 컨텐츠 높이 구하기
    float routeDetailPathContentHeight = 0.0f;
    
    NSLog(@"%d",[[routeGateDic objectForKeyGC:@"RGCount"] intValue] + 1);
    
    // 전체경로 렌더링
    if (pathIndex == -1)
    {
        //[self showRouteRouteImageOverlay:NO];
        
        // 상세경로 컨텐츠 높이 구하기
        routeDetailPathContentHeight = 14.0f;
        
        // 시간 라벨
        CGRect rectTime = CGRectMake(35+viewSight, routeDetailPathContentHeight, 0, 13);
        UILabel *lblTime = [[UILabel alloc] initWithFrame:rectTime];
        [lblTime setFont:[UIFont boldSystemFontOfSize:13]];
        [lblTime setTextColor:convertHexToDecimalRGBA(@"2F", @"C9", @"EB", 1.0f)];
        [lblTime setBackgroundColor:[UIColor clearColor]];
        [lblTime setText:[NSString stringWithFormat:@"약 %@",[self getTimeRefined:[[routeGateDic objectForKeyGC:@"TotalTime"] doubleValue]]]];
        rectTime.size = [lblTime.text sizeWithFont:lblTime.font constrainedToSize:CGSizeMake(FLT_MAX, 13) lineBreakMode:lblTime.lineBreakMode];
        [lblTime setFrame:rectTime];
        [_vwPublicRouteDetailPathInfoGroup addSubview:lblTime];
        [lblTime release];
        
        // 시간-요금 구분이미지
        CGRect rectSep1 = CGRectMake(rectTime.origin.x+rectTime.size.width, routeDetailPathContentHeight, 11, 13);
        UIImageView *imgvwSep1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_text_line.png"]];
        [imgvwSep1 setFrame:rectSep1];
        [_vwPublicRouteDetailPathInfoGroup addSubview:imgvwSep1];
        [imgvwSep1 release];
        
        // 요금 라벨
        CGRect rectFare = CGRectMake(rectSep1.origin.x+rectSep1.size.width, routeDetailPathContentHeight, 0, 13);
        UILabel *lblFare = [[UILabel alloc] initWithFrame:rectFare];
        [lblFare setFont: [UIFont systemFontOfSize:13]];
        [lblFare setTextColor:[UIColor whiteColor]];
        [lblFare setBackgroundColor:[UIColor clearColor]];
        [lblFare setText:[NSString stringWithFormat:@"약 %@원",[self getAfterFareRefined:[[routeGateDic objectForKeyGC:@"TotalFare"] doubleValue]]]];
        rectFare.size = [lblFare.text sizeWithFont:lblFare.font constrainedToSize:CGSizeMake(FLT_MAX, 13) lineBreakMode:lblFare.lineBreakMode];
        [lblFare setFrame:rectFare];
        [_vwPublicRouteDetailPathInfoGroup addSubview:lblFare];
        [lblFare release];
        
        // 요금 - 거리 구분이미지
        CGRect rectSep2 = CGRectMake(rectFare.origin.x+rectFare.size.width, routeDetailPathContentHeight, 11, 13);
        UIImageView *imgvwSep2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_text_line.png"]];
        [imgvwSep2 setFrame:rectSep2];
        [_vwPublicRouteDetailPathInfoGroup addSubview:imgvwSep2];
        [imgvwSep2 release];
        
        // 거리 라벨
        CGRect rectDistance = CGRectMake(rectSep2.origin.x+rectSep2.size.width, routeDetailPathContentHeight, 0, 13);
        UILabel *lblDistance = [[UILabel alloc] initWithFrame:rectDistance];
        [lblDistance setFont: [UIFont systemFontOfSize:13]];
        [lblDistance setTextColor:[UIColor whiteColor]];
        [lblDistance setBackgroundColor:[UIColor clearColor]];
        [lblDistance setText:[NSString stringWithFormat:@"약 %@",[self getDistanceRefined:[[routeGateDic objectForKeyGC:@"TotalDistance"] doubleValue]]]];
        rectDistance.size = [lblDistance.text sizeWithFont:lblDistance.font constrainedToSize:CGSizeMake(FLT_MAX, 13) lineBreakMode:lblDistance.lineBreakMode];
        [lblDistance setFrame:rectDistance];
        [_vwPublicRouteDetailPathInfoGroup addSubview:lblDistance];
        [lblDistance release];
        
        // 컨텐츠 높이 (라벨 +여백 높이 반영)
        routeDetailPathContentHeight += rectTime.size.height + 11;
        
        int routeDetailPathContentIconLeftPosition = 35 + viewSight;
        for (NSDictionary *methodDic in [routeGateDic objectForKeyGC:@"Gates"])
        {
            int methodType = [[methodDic objectForKeyGC:@"MethodType"] intValue];
            int lID = [[methodDic objectForKeyGC:@"lID"] intValue];
            int methodIconNumber = [self getPublicMethodIconNumber:methodType :lID];
            UIImageView *imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"info_icon_%02d.png",methodIconNumber]]];
            
            if (routeDetailPathContentIconLeftPosition+imgvwIcon.image.size.width > 226 + viewSight)
            {
                routeDetailPathContentHeight += 10 + 18;
                routeDetailPathContentIconLeftPosition = 35 + viewSight;
            }
            [imgvwIcon setFrame:CGRectMake(routeDetailPathContentIconLeftPosition, routeDetailPathContentHeight, imgvwIcon.image.size.width, imgvwIcon.image.size.height)];
            routeDetailPathContentIconLeftPosition += imgvwIcon.image.size.width + 4;
            [_vwPublicRouteDetailPathInfoGroup addSubview:imgvwIcon];
            [imgvwIcon release];
        }
        
        //        UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_bg.png"]];
        //        [imgvwBack setFrame:CGRectMake(viewSight, 0, 320, 60)];
        //        [_vwPublicRouteDetailPathInfoGroup insertSubview:imgvwBack atIndex:0];
        [_vwRoutePathMapContainer addSubview:_vwPublicRouteDetailPathInfoGroup];
        //[imgvwBack release];
        // 컨텐츠 높이 추가 (여백+이미지사이즈+하단여백)
        routeDetailPathContentHeight += 18 + 15;
        
        
    }
    else if (pathIndex == -2 || pathIndex > [[routeGateDic objectForKeyGC:@"RGCount"] intValue] + 1)
    {
        //        UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_bg.png"]];
        //        [imgvwBack setFrame:CGRectMake(0, 0, 320, 60)];
        //        [_vwPublicRouteDetailPathInfoGroup addSubview:imgvwBack];
        [_vwRoutePathMapContainer addSubview:_vwPublicRouteDetailPathInfoGroup];
        //[imgvwBack release];
        return;
    }
    // 출발/도착점 렌더링
    else if (pathIndex == 0 || pathIndex == [[routeGateDic objectForKeyGC:@"RGCount"] intValue]+1)
    {
        //[self showRouteRouteImageOverlay:YES];
        
        routeDetailPathContentHeight = 0.0f;
        
        UILabel *lblPointName = [[UILabel alloc] initWithFrame:CGRectMake(75+viewSight, routeDetailPathContentHeight, 218, 13)];
        [lblPointName setFont:[UIFont systemFontOfSize:13]];
        [lblPointName setTextColor:[UIColor whiteColor]];
        [lblPointName setLineBreakMode:NSLineBreakByClipping];
        [lblPointName setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *imgvwIcon;
        if (pathIndex == 0)
        {
            [lblPointName setText:oms.searchResultRouteStart.strLocationName];
            imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"start.png"]];
        }
        else
        {
            [lblPointName setText:oms.searchResultRouteDest.strLocationName];
            imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stop.png"]];
        }
        
        // 텍스트 사이즈 구하기
        CGRect rectPointName = lblPointName.frame;
        rectPointName.size = [lblPointName.text sizeWithFont:lblPointName.font constrainedToSize:CGSizeMake(218, FLT_MAX) lineBreakMode:lblPointName.lineBreakMode];
        [lblPointName setNumberOfLines:999];
        
        if (rectPointName.size.height + 12 + 12 > 60)
            routeDetailPathContentHeight = 12;
        else
            routeDetailPathContentHeight = (60-rectPointName.size.height)/2;
        
        // 텍스트 사이즈 재조정
        rectPointName.origin.y = routeDetailPathContentHeight;
        [lblPointName setFrame:rectPointName];
        [_vwPublicRouteDetailPathInfoGroup addSubview:lblPointName];
        
        routeDetailPathContentHeight += routeDetailPathContentHeight + rectPointName.size.height;
        
        // 아이콘 사이즈
        CGRect rectIcon = imgvwIcon.frame;
        rectIcon.origin.y = (routeDetailPathContentHeight - rectIcon.size.height) / 2;
        rectIcon.origin.x = 25+viewSight;
        [imgvwIcon setFrame:rectIcon];
        [_vwPublicRouteDetailPathInfoGroup addSubview:imgvwIcon];
        
        [lblPointName release];
        [imgvwIcon release];
        
        //        UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_bg.png"]];
        //        [imgvwBack setFrame:CGRectMake(viewSight, 0, 320, 60)];
        //        [_vwPublicRouteDetailPathInfoGroup insertSubview:imgvwBack atIndex:0];
        [_vwRoutePathMapContainer addSubview:_vwPublicRouteDetailPathInfoGroup];
        //[imgvwBack release];
        
        
    }
    // 일반 지점 렌더링
    else
    {
        //[self showRouteRouteImageOverlay:YES];
        
        routeDetailPathContentHeight = 12.0f;
        
        NSDictionary *gate = [[routeGateDic objectForKeyGC:@"Gates"] objectAtIndexGC:pathIndex-1];
        
        NSString *strGatesTitle;
        NSString *strGatesPath;
        
        NSString *strGatesPathStartName = nil;
        NSString *strGatesPathEndName = nil;
        // 출발지 도착지 이름은 상황에 따라 커스터마이징 필요
        strGatesPathStartName = [NSString stringWithFormat:@"%@", [gate objectForKeyGC:@"StartName"]];
        strGatesPathEndName = [NSString stringWithFormat:@"%@", [gate objectForKeyGC:@"EndName"]];
        
        double distanceGatesPath = [[gate objectForKeyGC:@"Distance"] doubleValue];
        int routeGateType = [[gate objectForKeyGC:@"RgType"] intValue];
        int methodType  = [[gate objectForKeyGC:@"MethodType"] intValue];
        int lID  = [[gate objectForKeyGC:@"lID"] intValue];
        
        switch (routeGateType)
        {
            case 1: // 버스
            case 4: // 버스(환승)
                strGatesTitle = [NSString stringWithFormat:@"%@번", [gate objectForKeyGC:@"LaneName"]];
                strGatesPath = [NSString stringWithFormat:@"%@에서 승차 후 %@에서 하차 (%d개 정류장)"
                                , strGatesPathStartName
                                , strGatesPathEndName
                                , (int)distanceGatesPath ];
                break;
                
            case 2: // 지하철
                strGatesTitle = [NSString stringWithFormat:@"지하철 %@", [gate objectForKeyGC:@"LaneName"]];
                strGatesPath = [NSString stringWithFormat:@"%@에서 승차 후 %@에서 하차 (%d개 역)"
                                , strGatesPathStartName
                                , strGatesPathEndName
                                , (int)distanceGatesPath ];
                break;
                
            case 3: // 도보
                strGatesTitle = [NSString stringWithFormat:@"도보 이동"];
                strGatesPath = [NSString stringWithFormat:@"%@에서 %@까지 %@ 걷기"
                                , strGatesPathStartName
                                , strGatesPathEndName
                                , [self getDistanceRefined:distanceGatesPath] ];
                break;
                
            default:
                strGatesTitle = @"";
                strGatesPath = @"";
                break;
        }
        
        // 인덱스 넘버 아이콘
        UIImageView *imgvwNumberIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"marker_num_%03d.png", pathIndex]]];
        [imgvwNumberIcon setFrame:CGRectMake(76+viewSight, 9, imgvwNumberIcon.image.size.width, imgvwNumberIcon.image.size.height)];
        [_vwPublicRouteDetailPathInfoGroup addSubview:imgvwNumberIcon];
        [imgvwNumberIcon release];
        
        // 노선정보 타이틀 라벨
        CGRect rectRouteTitle = CGRectMake(100+viewSight, routeDetailPathContentHeight, 193, 13);
        UILabel *lblRouteTitle = [[UILabel alloc] initWithFrame:rectRouteTitle];
        [lblRouteTitle setFont:[UIFont systemFontOfSize:13]];
        [lblRouteTitle setTextColor:[UIColor whiteColor]];
        [lblRouteTitle setBackgroundColor:[UIColor clearColor]];
        [lblRouteTitle setText:strGatesTitle];
        [_vwPublicRouteDetailPathInfoGroup addSubview:lblRouteTitle];
        [lblRouteTitle release];
        
        // 컨텐츠 높이 갱신
        routeDetailPathContentHeight += rectRouteTitle.size.height + 6;
        
        // 노선정보 경로 라벨
        CGRect rectRoutePath = CGRectMake(76+viewSight, routeDetailPathContentHeight, 217, 0);
        UILabel *lblRoutePath = [[UILabel alloc] initWithFrame:rectRoutePath];
        [lblRoutePath setFont:[UIFont systemFontOfSize:13]];
        [lblRoutePath setTextColor:[UIColor whiteColor]];
        [lblRoutePath setBackgroundColor:[UIColor clearColor]];
        [lblRoutePath setText:strGatesPath];
        rectRoutePath.size = [lblRoutePath.text sizeWithFont:lblRoutePath.font constrainedToSize:CGSizeMake(rectRoutePath.size.width, FLT_MAX) lineBreakMode:lblRoutePath.lineBreakMode];
        [lblRoutePath setFrame:rectRoutePath];
        [lblRoutePath setNumberOfLines:999];
        [_vwPublicRouteDetailPathInfoGroup addSubview:lblRoutePath];
        [lblRoutePath release];
        
        // 컨텐츠 높이 갱신
        routeDetailPathContentHeight += rectRoutePath.size.height + 10;
        
        // 노선정보 아이콘
        UIImageView *imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"info_icon_%02d.png",  [self getPublicMethodIconNumber:methodType :lID]]]];
        [imgvwIcon setFrame:CGRectMake((int)(76 - 26 - (imgvwIcon.image.size.width / 2))+viewSight, (int)((routeDetailPathContentHeight-imgvwIcon.image.size.height)/2), imgvwIcon.image.size.width, imgvwIcon.image.size.height)];
        [_vwPublicRouteDetailPathInfoGroup addSubview:imgvwIcon];
        [imgvwIcon release];
        
        //        UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_bg.png"]];
        //        [imgvwBack setFrame:CGRectMake(viewSight, 0, 320, 60)];
        //        [_vwPublicRouteDetailPathInfoGroup insertSubview:imgvwBack atIndex:0];
        [_vwRoutePathMapContainer addSubview:_vwPublicRouteDetailPathInfoGroup];
        //[imgvwBack release];
        
    }
    
    if(viewSight == 320)
    {
        // 상세경로 정보 사이즈 재조정
        rectPublicRouteDetailPath.size.height = routeDetailPathContentHeight;
        rectPublicRouteDetailPath.origin.y = _vwRoutePathMapContainer.frame.size.height - rectPublicRouteDetailPath.size.height;
        [_vwPublicRouteDetailPathInfoGroup setFrame:rectPublicRouteDetailPath];
    }
    
    // 좌측 버튼
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(viewSight, (_vwPublicRouteDetailPathInfoGroup.frame.size.height-35)/2, 25, 35)];
    [btnLeft setImage:[UIImage imageNamed:@"info_btn_arrow_left.png"] forState:UIControlStateNormal];
    [btnLeft setImage:[UIImage imageNamed:@"info_btn_arrow_left_disabled.png"] forState:UIControlStateDisabled];
    [btnLeft addTarget:self action:@selector(onPublicRoutePathPrev:) forControlEvents:UIControlEventTouchUpInside];
    if (_currentRouteDetailPathIndex == -1) [btnLeft setEnabled:NO];
    [_vwPublicRouteDetailPathInfoGroup addSubview:btnLeft];
    [btnLeft release];
    // 우측 버튼
    UIButton *btnRight = [[UIButton alloc] initWithFrame:CGRectMake(295 + viewSight, (_vwPublicRouteDetailPathInfoGroup.frame.size.height-35)/2, 25, 35)];
    [btnRight setImage:[UIImage imageNamed:@"info_btn_arrow_right.png"] forState:UIControlStateNormal];
    [btnRight setImage:[UIImage imageNamed:@"info_btn_arrow_right_disabled.png"] forState:UIControlStateDisabled];
    [btnRight addTarget:self action:@selector(onPublicRoutePathNext:) forControlEvents:UIControlEventTouchUpInside];
    if (_currentRouteDetailPathIndex == [[routeGateDic objectForKeyGC:@"RGCount"] intValue] + 1) [btnRight setEnabled:NO];
    [_vwPublicRouteDetailPathInfoGroup addSubview:btnRight];
    [btnRight release];
    
    // 배경
    //    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_bg.png"]];
    //    [imgvwBack setFrame:CGRectMake(0, 0, rectPublicRouteDetailPath.size.width, rectPublicRouteDetailPath.size.height)];
    //    [_vwPublicRouteDetailPathInfoGroup insertSubview:imgvwBack atIndex:0];
    //    [imgvwBack release];
    
    // 상세경로 정보 삽입
    //[_vwRoutePathMapContainer addSubview:_vwPublicRouteDetailPathInfoGroup];
    
    
    
}

- (void) renderPublicMapRouteSummaryInfo
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 요약정보 클리어
    for (UIView *subView in _vwPublicRouteSummaryInfoGroup.subviews)
    {
        [subView removeFromSuperview];
    }
    [_vwPublicRouteSummaryInfoGroup removeFromSuperview];
    
    // 배경이미지
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_align_bg_01.png"]];
    [imgvwBack setFrame:CGRectMake(0, 0, 320, 31)];
    [_vwPublicRouteSummaryInfoGroup addSubview:imgvwBack];
    [imgvwBack release];
    
    // 전체경로 텍스트
    NSString *strRoute = [NSString stringWithFormat:@"%@ ➜ %@", oms.searchResultRouteStart.strLocationName, oms.searchResultRouteDest.strLocationName];
    
    // 전체경로 라벨
    UILabel *lblRoute = [[UILabel alloc] initWithFrame:CGRectMake(15, 9, 290, 13)];
    [lblRoute setFont:[UIFont boldSystemFontOfSize:13]];
    [lblRoute setTextColor:[UIColor whiteColor]];
    [lblRoute setBackgroundColor:[UIColor clearColor]];
    [lblRoute setLineBreakMode:NSLineBreakByTruncatingTail];
    [lblRoute setText:strRoute];
    [_vwPublicRouteSummaryInfoGroup addSubview:lblRoute];
    [lblRoute release];
    
    // 요약정보 뷰 위치 조정
    CGRect rectSummaryInfoGroup = _vwPublicRouteSummaryInfoGroup.frame;
    rectSummaryInfoGroup.size.height = 31;
    rectSummaryInfoGroup.origin.y = _vwPublicRouteDetailPathInfoGroup.frame.origin.y - rectSummaryInfoGroup.size.height;
    
    NSLog(@"%f", rectSummaryInfoGroup.origin.y);
    
    // ??
    //[_vwPublicRouteSummaryInfoGroup setFrame:rectSummaryInfoGroup];
    
    // 요약정보 뷰 삽입
    [_vwPublicRouteSummaryInfoGroup setFrame:CGRectMake(0, _scrollViewPub.frame.origin.y-31, 320, 31)];
    [_vwRoutePathMapContainer addSubview:_vwPublicRouteSummaryInfoGroup];
}

- (void) onPublicRoutePathPrev :(id)sender
{
    [self toggleMyLocationMode:MapLocationMode_None];
    [self renderPublicMapRouteDetailPathInfo:_currentRouteDetailPathIndex-1];
    [self renderPublicMapRouteSummaryInfo];
}

- (void) onPublicRoutePathNext :(id)sender
{
    [self toggleMyLocationMode:MapLocationMode_None];
    [self renderPublicMapRouteDetailPathInfo:_currentRouteDetailPathIndex+1];
    [self renderPublicMapRouteSummaryInfo];
}

// **********************************



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
}

- (void) mapLongTouched:(NSValue *)coord
{
}

- (void) mapDoubleTouched:(KMapView*)mapView Events:(UIEvent*)event
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    
    //터치이벤트 감지 // 더블탭
    [oms setCurrentTouchesType:TouchesType_DBLTAP];
    
    // 기존 싱글탭 메소드 실행 중지
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // 더블탭시 해당 영역을 확대처리한다. (최대 줌 레벨은 지도별로 다름)
    if (
        // 평면 지도의 경우 최대 줌레벨은 12
        (mc.kmap.mapType == KMapTypeStandard && mc.kmap.zoomLevel < KMap_ZoomLevel_Maximun)
        ||
        // 하이브리드 지도의 경우 최대 줌레벨은 13
        (mc.kmap.mapType == KMapTypeHybrid && mc.kmap.zoomLevel < KMap_ZoomLevel_MaximunHybrid)
        )
    {
        NSSet *touches = [event allTouches];
        CGPoint point = [[touches anyObject] locationInView:mc.kmap];
        // 맵을 줌인하기 전에 미리 화면-지도 좌표변환을 해둬야 정확한 Coord값이 나온다.
        Coord crd = [mc.kmap convertPoint:point];
        
        [mc.kmap setCenterCoordinate:crd animated:NO];
        [mc.kmap setZoomLevel:mc.kmap.zoomLevel+1];
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
}

- (void) mapTouchEnded:(KMapView*)mapView Events:(UIEvent*)event
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    switch ((enum OMStatus_TouchesType)oms.currentTouchesType)
    {
        case TouchesType_TAP:
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
    
}

- (void) overlayTouched:(Overlay *)overlay
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 오버레이 터치됐을 경우 터치이벤트 정리
    [oms setCurrentTouchesType:TouchesType_NOT];
    
    // 상세정보 포인트는 PointNumber + 10000 값을 태그로 저장함
    if (overlay.tag >= 10000 && overlay.tag <= 19999)
    {
        [self renderCarMapRouteDetailPathInfo:overlay.tag - 10000];
        [self renderCarMapRouteSummaryInfo];
        
        [self toggleMyLocationMode:MapLocationMode_None];
    }
    // 대중교통 상세정보 포인트는 PointNumber + 20000 값을 태그로 저장함
    if (overlay.tag >= 20000 && overlay.tag <= 29999)
    {
        [self renderPublicMapRouteDetailPathInfo:overlay.tag - 20000];
        [self renderPublicMapRouteSummaryInfo];
        
        [self toggleMyLocationMode:MapLocationMode_None];
    }
    
    
}

- (void) mapBoundsChanged:(KMapView *)mapView Bounds:(KBounds)bounds
{
}

- (void) mapStatusChanged:(NSNumber *)mapLoad isZoom:(NSNumber *)isZoom
{
    if ( [mapLoad intValue] == 2 )
    {
        MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
        
        // 줌레벨이 변경된 경우에만 동작
        if ( mc.kmap.zoomLevel != _lastKMapZoomLevel )
        {
            // 모든 오버레이 탐색
            for (Overlay *overlay in mc.kmap.getOverlays)
            {
                // 길찾기 경로 오버레이 여부 판단
                if ( [overlay isKindOfClass:[RouteImageOverlay class]] && ((RouteImageOverlay*)overlay).routeImageOverlayType == RouteImageOverlay_Type_Normal )
                {
                    // 길찾기 경로 이미지 오버레이 변환
                    RouteImageOverlay *riovr = (RouteImageOverlay*)overlay;
                    
                    // 9레벨보다 큰경우 이미지 표시
                    if (mc.kmap.zoomLevel > 9)
                        riovr.imageSize = CGSizeMake(riovr.imageView.image.size.width, riovr.imageView.image.size.height);
                    else
                        riovr.imageSize = CGSizeMake(0, 0);
                }
            }
            
            // 맵 줌레벨별로 경로 폴리곤라인의 두께를 조절해주도록 한다.
            int routeLineWidth = [MapContainer sharedMapContainer_SearchRouteResult].kmap.zoomLevel + 1;
            if (routeLineWidth > 5) routeLineWidth = 5;
            _plovrPath.lineWidth = routeLineWidth;
            
            // 최종 줌레벨 업데이트
            _lastKMapZoomLevel = mc.kmap.zoomLevel;
            
        }
        
        // 교통옵션 아무것이나 활성화 된상태에서 공통적으로 처리할 메소드 일정거리 이상 이동한 경우 공통적으로처리할 메소드
        if ( ( mc.kmap.trafficCCTV || mc.kmap.trafficBusStation || mc.kmap.trafficSubwayStation ) )
        {
            // MIK.geun :: 20120928
            // 교통옵션 활성화상태에서 실시간정보 창 닫는 케이스를 수정함
            // ==> 현재 선택된 POI  없거나, 현재 화면에서 사라졌을때 제거
            if (_vwRealtimeTrafficTimeTableContainer.hidden == NO)
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

    }
}



- (void) toggleMyLocationMode:(int)mode
{
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    
    _currentMyLocationMode = mode;
    
    switch (mode) {
        case MapLocationMode_NorthUp:
            [_btnMyLocation setImage:[UIImage imageNamed:@"map_btn_location_pressed_1.png"] forState:UIControlStateNormal];
            // 북쪽고정 + 트래킹 모드
            [mc.kmap setShowUserLocation:UserLocationNorthUpTrace];
            // 현재 맵중앙을 내위치로 바로 가져오도록 설정
            [mc.kmap setCenterCoordinate: mc.kmap.getUserLocation];
            // 내위치 이미지 설정
            [self adjustMyArea];
            break;
        case MapLocationMode_Commpass:
            [_btnMyLocation setImage:[UIImage imageNamed:@"map_btn_location_pressed_2.png"] forState:UIControlStateNormal];
            // 나침반 + 트래킹 모드
            [mc.kmap setShowUserLocation:UserLocationCompassTrace];
            // 현재 맵중앙을 내위치로 바로 가져오도록 설정
            [mc.kmap setCenterCoordinate: mc.kmap.getUserLocation];
            // 내위치 이미지 설정
            [self adjustMyArea];
            break;
        case MapLocationMode_None:
        default:
            [_btnMyLocation setImage:[UIImage imageNamed:@"map_btn_location.png"] forState:UIControlStateNormal];
            // 북쪽고정 모드
            [mc.kmap setShowUserLocation:UserLocationNorthUp];
            // 내위치 이미지 설정
            [self adjustMyArea];
            break;
    }
    
}

// ==============
// [ 지도교통옵션 메소드 ]
// ==============

- (void) showMapTrafficOptionView:(BOOL)show
{
    [self showMapTrafficOptionView:show currentMapContainer:[MapContainer sharedMapContainer_SearchRouteResult] currentMapViewController:self trafficOptionEnabled:NO];
}
// cctv 옵션
- (void) onOptionViewUseTrafficCCTV:(id)sender
{
    // 부모 클래스 인스턴스 메소드에는 아무동작 없음.
    [super onOptionViewUseTrafficCCTV:sender];
    
    // 실제 구현은 여기서부터 시작
    UIButton *trafficCCTVButton = (UIButton*)sender;
    [trafficCCTVButton setSelected:!trafficCCTVButton.selected];
    
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
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
    [self showMapTrafficOptionView:YES];
}
- (void) finishTrafficOptionCCTVList :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        NSLog(@"CCTV 목록 검색 - 성공...");
        // MIK.geun :: 20121004 // 동일 버튼 연타로 인해 검색결과 받기 이전에 다시 버튼 비활성화 됐을 경우..
        if ( [MapContainer sharedMapContainer_SearchRouteResult].kmap.trafficCCTV )
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
- (void) pinTrafficOptionCCTVPOIOverlay:(ServerRequester *)request
{
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    
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
            
            
            MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
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
            [OMMessageBox showAlertMessage:@"" :@"CCTV POI 그리기 실패"];
//            [toast setObject:self.view forKey:@"SuperView"];
//            [toast setObject:[NSNumber numberWithFloat:self.vwCurrentAddressGroup.frame.origin.y-10] forKey:@"MaxBottomPoint"];
//            [toast setObject:[NSNumber numberWithBool:YES] forKey:@"AutoClose"];
//            [self performSelectorOnMainThread:@selector(doWork_ToastMessage:) withObject:toast waitUntilDone:YES];
//            [toast release];
            
        }
        @finally
        {
        }
    }
}

// 버스정류장 옵션
- (void) onOptionViewUseTrafficBusStation:(id)sender
{
    // 부모 클래스 인스턴스 메소드에는 아무동작 없음.
    [super onOptionViewUseTrafficBusStation:sender];
    
    // 실제 구현은 여기서부터 시작
    UIButton *trafficBusStationButton = (UIButton*)sender;
    [trafficBusStationButton setSelected:!trafficBusStationButton.selected];
    
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    [mc.kmap setTrafficCCTV:NO];
    [mc.kmap setTrafficBusStation:trafficBusStationButton.selected];
    [mc.kmap setTrafficSubwayStation:NO];
    
    // 뭔가 새로그리는 단계가 필요함 (검색을 위한 인디케이터활성화 된상태라 고민하지는 말자.)
    [mc.kmap removeAllTrafficOverlay];
    
    // 실시간팝업 일단 없음
    
//    // 교통실시간 정보 처리
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
    [self showMapTrafficOptionView:YES];
}
- (void) finishTrafficOptionBusStationList :(ServerRequester*)request
{
    // 검색 성공여부에 따라 렌더링 처리
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        // MIK.geun :: 20121004 // 동일 버튼 연타로 인해 검색결과 받기 이전에 다시 버튼 비활성화 됐을 경우..
        if ( [MapContainer sharedMapContainer_SearchRouteResult].kmap.trafficBusStation )
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
- (void) pinTrafficOptionBusStationPOIOverlay:(ServerRequester *)request
{
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    
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
            MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
            
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
            [OMMessageBox showAlertMessage:@"" :@"버스정류장 poi 그리기 실패"];
//            NSMutableDictionary *toast = [[NSMutableDictionary alloc] init];
//            [toast setObject:@"버스정류장 POI 를 그리는데 실패했습니다." forKey:@"Message"];
//            [toast setObject:self.view forKey:@"SuperView"];
//            [toast setObject:[NSNumber numberWithFloat:self.vwCurrentAddressGroup.frame.origin.y-10] forKey:@"MaxBottomPoint"];
//            [toast setObject:[NSNumber numberWithBool:YES] forKey:@"AutoClose"];
//            [self performSelectorOnMainThread:@selector(doWork_ToastMessage:) withObject:toast waitUntilDone:YES];
//            [toast release];
#endif
        }
        @finally
        {
        }
    }
}
// 지하철역 옵션
- (void) onOptionViewUseTrafficSubwayStation:(id)sender
{
    // 부모 클래스 인스턴스 메소드에는 아무동작 없음.
    [super onOptionViewUseTrafficSubwayStation:sender];
    
    // 실제 구현은 여기서부터 시작
    UIButton *trafficSubwayStationButton = (UIButton*)sender;
    [trafficSubwayStationButton setSelected:!trafficSubwayStationButton.selected];
    
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
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
    [self showMapTrafficOptionView:YES];
}
- (void) finishTrafficOptionSubwayStationList :(ServerRequester*)request
{
    if ( [request finishCode] == OMSRFinishCode_Completed )
    {
        // MIK.geun :: 20121004 // 동일 버튼 연타로 인해 검색결과 받기 이전에 다시 버튼 비활성화 됐을 경우..
        if ( [MapContainer sharedMapContainer_SearchRouteResult].kmap.trafficSubwayStation )
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
- (void) pinTrafficOptionSubwayPOIOverlay:(ServerRequester *)request
{
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    
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
            MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
            
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
            [OMMessageBox showAlertMessage:@"" :@"지하철역 POI를 그릴수 없습니다"];
//            NSMutableDictionary *toast = [[NSMutableDictionary alloc] init];
//            [toast setObject:@"지하철역 POI 를 그리는데 실패했습니다." forKey:@"Message"];
//            [toast setObject:self.view forKey:@"SuperView"];
//            [toast setObject:[NSNumber numberWithFloat:self.vwCurrentAddressGroup.frame.origin.y-10] forKey:@"MaxBottomPoint"];
//            [toast setObject:[NSNumber numberWithBool:YES] forKey:@"AutoClose"];
//            [self performSelectorOnMainThread:@selector(doWork_ToastMessage:) withObject:toast waitUntilDone:YES];
//            [toast release];
#endif
        }
        @finally
        {
        }
    }
}

- (void) onOPtionViewUseTrafficAddress:(id)sender
{
    // 부모 클래스 인스턴스 메소드에는 아무동작 없음.
    [super onOPtionViewUseTrafficAddress:sender];
    
    // 실제구현은 여기부터 시작
    
    // 버튼 매칭
    UIButton *trafficAddressButton = (UIButton*)sender;
    [trafficAddressButton setSelected:!trafficAddressButton.selected];
    //[self.btnBottomLegend setHidden:!trafficAddressButton.selected];
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    
    // 실시간 켜져있으면 디스플레이 닫음
    if(mc.kmap.trafficInfo)
    {
        // 실시간 교통량 닫는다
        [mc.kmap setTrafficInfo:!trafficAddressButton.selected clearCache:YES];
        [_imgvwMapTrafficInfo setHidden:!mc.kmap.trafficInfo];
        
        
    }
    
    
    [mc.kmap setCadastralInfo:trafficAddressButton.selected];
    
    // 옵션뷰 새로 그리기
    [self showMapTrafficOptionView:YES];
}
//- (void) mapConfigPrepared:(KMapView *)mapView
//{
//    NSLog(@"mapConfigPrepared 호출.. SearchRoute");
//}
// 실시간교통 옵션
- (void) onOptionViewUseTrafficInfo:(id)sender
{
    // 부모 클래스 인스턴스 메소드에는 아무동작 없음.
    [super onOptionViewUseTrafficInfo:sender];
    
    // 실제구현은 여기부터 시작
    
    // 버튼 매칭
    UIButton *trafficInfoButton = (UIButton*)sender;
    [trafficInfoButton setSelected:!trafficInfoButton.selected];
    
    // 지도 교통량 처리
    [[MapContainer sharedMapContainer_SearchRouteResult].kmap setTrafficInfo:trafficInfoButton.selected clearCache:YES];
    
    // 지도 교통량 뷰 디스플레이
    [_imgvwMapTrafficInfo setHidden:!trafficInfoButton.selected];
    
    // 옵션뷰 새로 그리기
    [self showMapTrafficOptionView:YES];
}

// ==============

// ==============
// [ 보조 메소드 ]
// ==============

- (NSString*) getSearchRouteCarRGType :(int) type
{
    NSString *str;
    
    switch(type){
        case 1:
            str = @"직진";
            break;
        case 2:
            str = @"1시 방향 우회전";
            break;
        case 3:
            str = @"2시 방향 우회전";
            break;
        case 4:
            str = @"우회전";
            break;
        case 5:
            str = @"4시 방향 우회전";
            break;
        case 6:
            str = @"5시 방향 우회전";
            break;
        case 7:
            str = @"7시 방향 우회전";
            break;
        case 8:
            str = @"8시 방향 좌회전";
            break;
        case 9:
            str = @"좌회전";
            break;
        case 10:
            str = @"10시 방향 좌회전";
            break;
        case 11:
            str = @"11시 방향 좌회전";
            break;
        case 12:
            str = @"직진 방향에 고가도로 진입";
            break;
        case 13:
            str = @"오른쪽 방향에 고가도로 진입";
            break;
        case 14:
            str = @"왼쪽 방향에 고가도로 진입";
            break;
        case 15:
            str = @"지하차도";
            break;
        case 16:
            str = @"오른쪽 방향에 고가도로 옆 도로";
            break;
        case 17:
            str = @"왼쪽 방향에 고가도로 옆 도로";
            break;
        case 18:
            str = @"오른쪽 방향에 지하차도 옆 도로";
            break;
        case 19:
            str = @"왼쪽 방향에 지하차도 옆 도로";
            break;
        case 20:
            str = @"오른쪽 도로";
            break;
        case 21:
            str = @"왼쪽 도로";
            break;
        case 22:
            str = @"직진 방향에 고속도로 진입";
            break;
        case 23:
            str = @"오른쪽 방향에 고속도로 진입";
            break;
        case 24:
            str = @"왼쪽 방향에 고속도로 진입";
            break;
        case 25:
            str = @"직진 방향에 도시고속도로 진입";
            break;
        case 26:
            str = @"오른쪽 방향에 도시고속도로 진입";
            break;
        case 27:
            str = @"왼쪽 방향에 도시고속도로 진입";
            break;
        case 28:
            str = @"오른쪽 방향에 고속도로 출구";
            break;
        case 29:
            str = @"왼쪽 방향에 고속도로 출구";
            break;
        case 30:
            str = @"오른쪽 방향에 도시고속도로 출구";
            break;
        case 31:
            str = @"왼쪽 방향에 도시고속도로 출구";
            break;
        case 32:
            str = @"분기점에서 직진";
            break;
        case 33:
            str = @"분기점에서 오른쪽";
            break;
        case 34:
            str = @"분기점에서 왼쪽";
            break;
        case 35:
            str = @"U턴";
            break;
        case 36:
            str = @"무발성 직진";
            break;
        case 37:
            str = @"터널";
            break;
        case 40:
            str = @"로터리에서 1시 방향";
            break;
        case 41:
            str = @"로터리에서 2시 방향";
            break;
        case 42:
            str = @"로터리에서 3시 방향";
            break;
        case 43:
            str = @"로터리에서 4시 방향";
            break;
        case 44:
            str = @"로터리에서 5시 방향";
            break;
        case 45:
            str = @"로터리에서 6시 방향";
            break;
        case 46:
            str = @"로터리에서 7시 방향";
            break;
        case 47:
            str = @"로터리에서 8시 방향";
            break;
        case 48:
            str = @"로터리에서 9시 방향";
            break;
        case 49:
            str = @"로터리에서 10시 방향";
            break;
        case 50:
            str = @"로터리에서 11시 방향";
            break;
        case 51:
            str = @"로터리에서 12시 방향";
            break;
        case 999:
            str = @"출발지";
            break;
        case 1000:
            str = @"경유지";
            break;
        case 1001:
            str = @"도착지";
            break;
        case -1:
            str = @"";
            break;
        case 0:
        default:
            str = @"안내없음";
            break;
    }
    
    return str;
}

- (NSString*) getDistanceRefined :(double) distance
{
    // 100km 이상시 소수점 이하 1자리
    if (distance >= 100000)
        return [NSString stringWithFormat:@"%.0fkm", distance/1000];
    // 10~99km 경우 소수점 이하 1자리
    else if (distance >= 10000)
        return [NSString stringWithFormat:@"%.1fkm", distance/1000];
    // 1~9km 경우 소수점 이하 2자리
    else if (distance >= 1000)
        return [NSString stringWithFormat:@"%.2fkm", distance/1000];
    // m 단위일 경우 소숫점 없음
    else
        return [NSString stringWithFormat:@"%.0fm", distance];
}

- (NSString*) getTimeRefined :(double) time
{
    // 총소요시간이 시간단위를 넘어갈 경우
    if (time >= 60)
    {
        int hour, minute;
        hour = time / 60;
        minute = time - (hour * 60);
        return [NSString stringWithFormat:@"%d시 %d분", hour, minute];
    }
    // 총소요시간이 분단위 일경우 그대로 사용
    else
        return [NSString stringWithFormat:@"%.0f분", time];
}

- (NSString*) getTaxiFareRefined :(double) distance localCode :(int)localCode
{
    int baseFare = 2400;
    int distanceFare = (int)((distance - 2000)/144) * 100;
    int totalFare;
    if (distanceFare > 0)
    {
        // localCode  를 지역코드 대신 분으로 사용하고 있음.. (분*100원씩.. 추가요금)
        totalFare = baseFare + distanceFare + (localCode*100);
    }
    else totalFare = baseFare;
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *str = [NSString stringWithFormat:@"%@", [fmt stringFromNumber:[NSNumber numberWithInt:totalFare]]];
    [fmt release];
    return str;
}

- (NSString*) getAfterFareRefined :(double) fare
{
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *str = [NSString stringWithFormat:@"%@", [fmt stringFromNumber:[NSNumber numberWithInt:fare]]];
    [fmt release];
    return str;
}

#pragma mark -
#pragma mark - 교통옵션
- (void) redrawMarkerOptionOverlayOnFront
{
    // MIK.geun : :20120926
    // 마커옵션 오버레이를 제거했다가 다시 추가하는 방식으로 수정
    NSMutableArray *redrawOverlayList = [[NSMutableArray alloc] init];
    // 마커옵션 오버레이 탐색
    for (Overlay *overlay in [MapContainer sharedMapContainer_SearchRouteResult].kmap.getOverlays)
    {
        if ( [overlay isKindOfClass:[OMUserOverlayMarkerOption class]] )
            [redrawOverlayList addObject:overlay];
    }
    // 걸러낸 마커옵션 오버레이 다시그리기
    for (OMUserOverlayMarkerOption *overlay in redrawOverlayList)
    {
        [[MapContainer sharedMapContainer_SearchRouteResult].kmap removeOverlay:overlay];
        [[MapContainer sharedMapContainer_SearchRouteResult].kmap addOverlay:overlay];
    }
    [redrawOverlayList removeAllObjects];
    [redrawOverlayList release];
}

- (BOOL) isDuplicatePOI:(Coord)crd1 :(Coord)crd2 { return [self isDuplicatePOI:crd1 :crd2 :NO]; }
- (BOOL) isDuplicatePOI :(Coord)crd1 :(Coord)crd2 :(BOOL)wide
{
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    
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

- (void) pinPOIMarkerOption:(BOOL)isDisplay targetInfo:(NSDictionary *)targetInfo animated:(BOOL)animated
{
    [self pinPOIMarkerOption:isDisplay targetInfo:targetInfo duplicatedInfo:nil animated:animated];
}
- (void) pinPOIMarkerOption:(BOOL)isDisplay targetInfo:(NSDictionary *)targetInfo duplicatedInfo:(NSDictionary*)duplicatedInfo animated:(BOOL)animated
{
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
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
- (void) clearRealtimeTrafficTimeTable { [self clearRealtimeTrafficTimeTable :NO]; }
- (void) clearRealtimeTrafficTimeTable :(BOOL)withCheck
{
    
    // MIK.geun :: 20121008
    // 오버레이를 체크해서 현재 실시간정보창이 활성화되어 있으면서, 실제 선택된 오버레이도 존재하는 경우
    // 클리어하지 않도록 한다.
    if (withCheck)
    {
        if ( !_vwRealtimeTrafficTimeTableContainer.hidden )
            for (Overlay *overlay in [MapContainer sharedMapContainer_SearchRouteResult].kmap.getOverlays)
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
// 교통옵션/테마 검색용 타이머 콜백함수
- (void) callbackThemesRequest :(NSTimer*)timer
{
    // 타이머 validcheck, 타이머 정보, 테마검색요청 정보 확인.
    if ( !timer || !timer.isValid |!timer.userInfo || !_themesRequestInfo ) return;
    
    MapContainer *mc = [MapContainer sharedMapContainer_SearchRouteResult];
    
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
    // 타이머 해제
    [timer invalidate];
}

#pragma mark -
#pragma mark - UIScrollView Delegate
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
    else
    {
        CGFloat pageWidth = _scrollView.frame.size.width;
        _pageControl.currentPage = floor((_scrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1;
        
        CGFloat pageWidthPub = _scrollViewPub.frame.size.width;
        _pageControlPub.currentPage = floor((_scrollViewPub.contentOffset.x - pageWidthPub / 3) / pageWidthPub) + 1;
    }
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    if([scrollView isKindOfClass:[CarScrollView class]])
    {
        if(_scrollView.contentOffset.x == 0)
        {
            if(_currentRouteDetailPathIndex > -1)
            {
                [self onCarRoutePathPrev:nil];
            }
            else
            {
                [_scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
            }
        }
        else if (_scrollView.contentOffset.x == 640)
        {
            int maxIndexCount = [OllehMapStatus sharedOllehMapStatus].searchRouteData.routeCarPointCount-1;
            if ([OllehMapStatus sharedOllehMapStatus].searchResultRouteVisit.used) maxIndexCount++;
            
            NSLog(@"maxIndexCount : %d", maxIndexCount);
            //if (_currentRouteDetailPathIndex >= maxIndexCount)
            if(_currentRouteDetailPathIndex < maxIndexCount)
            {
                [self onCarRoutePathNext:nil];
            }
            else
            {
                [_scrollView setContentOffset:CGPointMake(320, 0) animated:YES];
            }
        }
    }
    else if([scrollView isKindOfClass:[PublicScrollView class]])
    {
        if(_scrollViewPub.contentOffset.x == 0)
        {
            if(_currentRouteDetailPathIndex > -1)
            {
                [self onPublicRoutePathPrev:nil];
            }
            else
            {
                [_scrollViewPub setContentOffset:CGPointMake(320, 0) animated:YES];
            }
        }
        else if (_scrollViewPub.contentOffset.x == 640)
        {
            
            NSDictionary *routeDic = [self getCurrentPublicRouteData];
            NSDictionary *routeGateDic = [routeDic objectForKeyGC:@"RouteGate"];
            
            
            if(_currentRouteDetailPathIndex != [[routeGateDic objectForKeyGC:@"RGCount"] intValue] + 1)
            {
                [self onPublicRoutePathNext:nil];
            }
            else
            {
                [_scrollViewPub setContentOffset:CGPointMake(320, 0) animated:YES];
            }
        }
        
    }
    
}

// **************
#pragma mark -
#pragma mark swipe Action

-(void)carSwipeLefting:(UIGestureRecognizer *)recognizer
{
    [self performSelector:@selector(onCarRoutePathNext:)];
}
- (void) carSwipeRighting:(UIGestureRecognizer *)recognizer
{
    [self performSelector:@selector(onCarRoutePathPrev:)];
    //[self onCarRoutePathNext:nil];
}

#pragma mark -
#pragma mark UIPageControl, ScrollView Delegate
- (void)pageChangeValue:(id)sender
{
    UIPageControl *pController    = (UIPageControl *)sender;
    [_scrollView setContentOffset:CGPointMake(pController.currentPage*320, 0) animated:YES];
}
- (void)pageChangeValuePub:(id)sender
{
    UIPageControl *pController    = (UIPageControl *)sender;
    [_scrollViewPub setContentOffset:CGPointMake(pController.currentPage*320, 0) animated:YES];
}

@end
