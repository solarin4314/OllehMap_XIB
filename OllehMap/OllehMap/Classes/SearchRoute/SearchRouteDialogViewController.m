//
//  SearchRouteDialogViewController.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 7..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "SearchRouteDialogViewController.h"
#import "MainMapViewController.h"

@interface SearchRouteDialogViewController ()

@end

@implementation SearchRouteDialogViewController

- (id) init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        
        _vwSearchRouteContainer = [[UIControl alloc]
                                   initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,
                                                            [UIScreen mainScreen].bounds.size.height)];
        [_vwSearchRouteContainer setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.3f]];
        [_vwSearchRouteContainer addTarget:self action:@selector(onTouchBackground:) forControlEvents:UIControlEventTouchUpInside];
        
        // 검색 다이얼로그 그룹
        _vwSearchRouteDialog = [[UIView alloc] initWithFrame:CGRectMake(17, 120, 572/2, 526/2)];
        _imgvwSearchRouteDialogBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 572/2, 526/2)];
        
        // 출발지
        _lblStart = [[UILabel alloc] initWithFrame:CGRectMake(176/2, 32/2, 284/2, 30/2)];
        [_lblStart setFont:[UIFont systemFontOfSize:15]];
        [_lblStart setBackgroundColor:[UIColor clearColor]];
        
        // 경유지
        _imgvwVisitBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_list_plus_bg.png"]];
        [_imgvwVisitBackground setFrame:CGRectMake(0, 0, 268, 45)];
        _imgvwVisitIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20/2, 28/2, 30/2, 38/2)];
        _lblVisitTitle = [[UILabel alloc] initWithFrame:CGRectMake(58/2, 32/2, 96/2, 30/2)];
        [_lblVisitTitle setFont:[UIFont boldSystemFontOfSize:15]];
        [_lblVisitTitle setBackgroundColor:[UIColor clearColor]];
        [_lblVisitTitle setText:@"경유지"];
        _lblVisit = [[UILabel alloc] initWithFrame:CGRectMake(176/2, 32/2, 284/2, 30/2)];
        [_lblVisit setFont:[UIFont systemFontOfSize:15]];
        [_lblVisit setBackgroundColor:[UIColor clearColor]];
        _btnVisitAddRemoveButton = [[UIButton alloc] initWithFrame:CGRectMake(476/2, 20/2, 25, 26)];
        [_btnVisitAddRemoveButton addTarget:self action:@selector(onVisitAddRemove:) forControlEvents:UIControlEventTouchUpInside];
        [_btnVisitAddRemoveButton setImage:[UIImage imageNamed:@"popup_list_p_btn.png"] forState:UIControlStateNormal];
        [_btnVisitAddRemoveButton setImage:[UIImage imageNamed:@"popup_list_m_btn.png"] forState:UIControlStateSelected];
        
        // 도착지
        _lblDest = [[UILabel alloc] initWithFrame:CGRectMake(176/2, 32/2, 284/2, 30/2)];
        [_lblDest setFont:[UIFont systemFontOfSize:15]];
        [_lblDest setBackgroundColor:[UIColor clearColor]];
        
        // 버튼
        _btnReset = [[UIButton alloc] initWithFrame:CGRectMake(24, 162, 228/2, 74/2)];
        [_btnReset addTarget:self action:@selector(onReset:) forControlEvents:UIControlEventTouchUpInside];
        [_btnReset setImage:[UIImage imageNamed:@"popup_btn_reset_default.png"] forState:UIControlStateNormal];
        [_btnReset setImage:[UIImage imageNamed:@"popup_btn_reset_pressed.png"] forState:UIControlStateHighlighted];
        _btnRoute = [[UIButton alloc] initWithFrame:CGRectMake(148, 162, 228/2, 74/2)];
        [_btnRoute addTarget:self action:@selector(onRoute:) forControlEvents:UIControlEventTouchUpInside];
        [_btnRoute setImage:[UIImage imageNamed:@"popup_btn_route_default.png"] forState:UIControlStateNormal];
        [_btnRoute setImage:[UIImage imageNamed:@"popup_btn_route_pressed.png"] forState:UIControlStateHighlighted];
        [_btnRoute setImage:[UIImage imageNamed:@"popup_btn_route_disabled.png"] forState:UIControlStateDisabled];
        
    }
    return self;
}


- (void) dealloc
{
    [_vwSearchRouteContainer release];
    _vwSearchRouteContainer = nil;
    
    // 검색 다이얼로그 그룹
    [_vwSearchRouteDialog release];
    _vwSearchRouteDialog = nil;
    [_imgvwSearchRouteDialogBackground release];
    _imgvwSearchRouteDialogBackground = nil;
    
    // 출발지
    [_lblStart release];
    _lblStart = nil;
    
    // 경유지
    [_imgvwVisitBackground release];
    _imgvwVisitBackground = nil;
    [_imgvwVisitIcon release];
    _imgvwVisitIcon = nil;
    [_lblVisitTitle release];
    _lblVisitTitle = nil;
    [_lblVisit release];
    _lblVisit = nil;
    [_btnVisitAddRemoveButton release];
    _btnVisitAddRemoveButton = nil;
    
    // 도착지
    [_lblDest release];
    _lblDest = nil;
    
    // 버튼
    [_btnReset release];
    _btnReset = nil;
    [_btnRoute release];
    _btnRoute = nil;
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


// ===============================
// [ 길찾기 다이얼로그 호출 메소드 ]
// ===============================

static SearchRouteDialogViewController *_Instance = nil;
+ (SearchRouteDialogViewController *) sharedSearchRouteDialog
{
    if (_Instance == nil)
    {
        //_Instance = [[SearchRouteDialogViewController alloc] initWithNibName:@"SearchRouteDialogViewController" bundle:nil];
        _Instance = [[SearchRouteDialogViewController alloc] init];
    }
    return _Instance;
}

- (void) showSearchRouteDialog
{
    [self showSearchRouteDialogWithAnalytics:YES];
}

- (void) showSearchRouteDialogWithAnalytics :(BOOL)analytics
{
    //[OllehMapStatus sharedOllehMapStatus].currentMapLocationMode = MapLocationMode_None;
    MapContainer *mc = [MapContainer sharedMapContainer_Main];
    
    [[MapContainer sharedMapContainer_Main].kmap removeAllRouteOverlay];
    
    // 테마 클리어
    [[ThemeCommon sharedThemeCommon] clearThemeSearchResult];
    
    if (analytics)
    {
        // 버스 정류장/노선도 처리를 위한 배열 초기화
        [[OllehMapStatus sharedOllehMapStatus].pushDataBusNumberArray removeAllObjects];
        [[OllehMapStatus sharedOllehMapStatus].pushDataBusStationArray removeAllObjects];
        
        // 무조건 현재 뷰를 메인맵으로 이동처리한다.
        [[OMNavigationController sharedNavigationController] popToRootViewControllerAnimated:NO];
        //[[MapContainer sharedMapContainer_Main].kmap removeAllOverlays];
        [[MapContainer sharedMapContainer_Main].kmap removeAllOverlaysWithoutTraffic];
        [[MapContainer sharedMapContainer_Main].kmap selectPOIOverlay:nil];
    }
    
    // 메인맵 뷰컨트롤러 가져온다.
    UIViewController *vc = [[OMNavigationController sharedNavigationController].viewControllers lastObject];
    if ([vc isKindOfClass:[MainMapViewController class]])
    {
        // 메인맵 뷰가 맞다면 항상 노멀스크린으로 강제한다.
        MainMapViewController *mmvc = (MainMapViewController *)vc;
        [mmvc toggleScreenMode:MapScreenMode_NORMAL :NO];
        // 실시간 정보 활성화 되어 있을경우 해제힌다.
        [mmvc clearRealtimeTrafficTimeTableForce];
        // 테마버튼 비활성화처리한다.
        mmvc.btnBottomTheme.selected = mc.kmap.theme;
        
        
    }
    
    [self resetDialog];
    [vc.view addSubview:_vwSearchRouteContainer];
    
    // 통계처리
    if (analytics)
        [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/find_route"];
}


// 데이터에 맞춰서 UI초기화
- (void) resetDialog
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // SearchRoute 컨테이너 클리어
    for (UIView *subview in _vwSearchRouteContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    [_vwSearchRouteContainer removeFromSuperview];
    
    // 컨테이너에 다이이얼로그 삽입
    [_vwSearchRouteContainer addSubview:_vwSearchRouteDialog];
    
    // 다이얼로그 하단 말꼬리 영역에 닫기 이벤트 처리할 뷰 생성
    UIControl *vwCloseControl = [[UIControl alloc] initWithFrame:CGRectMake(34/2, 670/2, 572/2, 150/2)];
    [vwCloseControl addTarget:self action:@selector(onTouchBackground:) forControlEvents:UIControlEventTouchUpInside];
    [vwCloseControl setBackgroundColor:[UIColor clearColor]];
    [_vwSearchRouteContainer addSubview:vwCloseControl];
    [vwCloseControl release];
    
    
    // 다이얼로그 배경
    //OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    //UIViewController *vc = [nc.viewControllers objectAtIndexGC:nc.viewControllers.count-1];
    
    // MIK.geun :: 20120802 // 무조건 꼬리말 달린상태로 팝업 노출한다. 단, 메인지도에서도 항상 노멀스크린으로 강제하도록 한다.
    [_imgvwSearchRouteDialogBackground setImage:[UIImage imageNamed:@"popup_s_bg.png"]];
    /*
     if ( [vc isKindOfClass:[MainMapViewController class]] && oms.currentMapScreenMode == MapScreenMode_NORMAL )
     {
     [_imgvwSearchRouteDialogBackground setImage:[UIImage imageNamed:@"popup_s_bg.png"]];
     }
     else
     {
     [_imgvwSearchRouteDialogBackground setImage:[UIImage imageNamed:@"popup_s2_bg.png"]];
     }
     */
    
    [_vwSearchRouteDialog addSubview:_imgvwSearchRouteDialogBackground];
    
    // 첫번째 라인
    {
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(9, 14, 536/2, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0f)];
        [vwLine setHidden:YES];
        [_vwSearchRouteDialog addSubview:vwLine];
        [vwLine release];
    }
    
    // 출발지 초기화
    if (oms.searchResultRouteStart.used && !oms.searchResultRouteStart.isCurrentLocation)
    {
        [_lblStart setText:oms.searchResultRouteStart.strLocationName];
        //[self pinRouteStartPOIOverlay];
    }
    else
    {
        MapContainer *mc = [MapContainer sharedMapContainer_Main];
        
        // 출발지는 없을 경우 자동으로 내 위치로 처리
        [oms.searchResultRouteStart reset];
        [oms.searchResultRouteStart setUsed:YES];
        [oms.searchResultRouteStart setIsCurrentLocation:YES];
        [oms.searchResultRouteStart setStrLocationName:NSLocalizedString(@"Body_SR_AutoMyLoc_Start", @"")];
        // 내위치 서비스 비활성화 되어 있을 경우 "기본위치"를 사용하자..
        if ( [MapContainer CheckLocationServiceWithoutAlert] )
            [oms.searchResultRouteStart setCoordLocationPoint:[mc.kmap getUserLocation]];
        else
            [oms.searchResultRouteStart setCoordLocationPoint:OM_DefaultCoord];
        
        // 출발지 라벨 처리
        [_lblStart setText:oms.searchResultRouteStart.strLocationName];
    }
    
    // 출발지 렌더링
    {
        // 셀 생성
        UIControl *vwCell = [[UIControl alloc] initWithFrame:CGRectMake(9, 15, 536/2, 90/2)];
        [vwCell addTarget:self action:@selector(touchStart:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addTarget:self action:@selector(onCellDown:) forControlEvents:UIControlEventTouchDown];
        [vwCell addTarget:self action:@selector(onCellUp:) forControlEvents:UIControlEventTouchUpOutside];
        // 아이콘
        UIImageView *imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_list_r_icon.png"]];
        [imgvwIcon setFrame:CGRectMake(10, 14, 15, 19)];
        [vwCell addSubview:imgvwIcon];
        [imgvwIcon release];
        // 타이틀
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(58/2, 32/2, 96/2, 30/2)];
        [lblTitle setFont:[UIFont boldSystemFontOfSize:15]];
        [lblTitle setTextColor:convertHexToDecimalRGBA(@"F2", @"34", @"71", 1.0f)];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [lblTitle setText:@"출발지"];
        [vwCell addSubview:lblTitle];
        [lblTitle release];
        // 구분자
        UILabel *lblCol = [[UILabel alloc] initWithFrame:CGRectMake(142/2, 32/2-1, 10, 15)];
        [lblCol setFont:[UIFont systemFontOfSize:15]];
        [lblCol setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
        [lblCol setBackgroundColor:[UIColor clearColor]];
        [lblCol setTextAlignment:NSTextAlignmentCenter];
        [lblCol setText:@":"];
        [vwCell addSubview:lblCol];
        [lblCol release];
        // 키워드
        [vwCell addSubview:_lblStart];
        // 버튼
        UIButton *btnArrow = [[UIButton alloc] initWithFrame:CGRectMake(496/2, 29/2, 10, 16)];
        [btnArrow setImage:[UIImage imageNamed:@"popup_arrow_icon.png"] forState:UIControlStateNormal];
        [btnArrow addTarget:self action:@selector(touchStart:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addSubview:btnArrow];
        [btnArrow release];
        //셀 삽입
        [_vwSearchRouteDialog addSubview:vwCell];
        [vwCell release];
        
        
        
    }
    
    // 두번째 라인
    {
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(9, 60, 536/2, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0f)];
        [_vwSearchRouteDialog addSubview:vwLine];
        [vwLine release];
    }
    
    
    // 경유지 초기화
    if (oms.searchResultRouteVisit.used)
    {
        [_lblVisitTitle setTextColor:convertHexToDecimalRGBA(@"1A", @"68", @"C9", 1.0f)];
        [_lblVisit setTextColor:[UIColor blackColor]];
        [_lblVisit setText:oms.searchResultRouteVisit.strLocationName];
        [_btnVisitAddRemoveButton setSelected:YES];
        [_imgvwVisitIcon setImage:[UIImage imageNamed:@"popup_list_b_icon.png"]];
        [_imgvwVisitBackground setHidden:YES];
    }
    else
    {
        [_lblVisitTitle setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
        [_lblVisit setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
        [_lblVisit setText:NSLocalizedString(@"Body_SR_Require_Visit", @"")];
        [_btnVisitAddRemoveButton setSelected:NO];
        [_imgvwVisitIcon setImage:[UIImage imageNamed:@"popup_list_g_icon.png"]];
        [_imgvwVisitBackground setHidden:NO];
        
        //[self pinRouteVisitPOIOverlay];
    }
    
    // 경유지 렌더링
    {
        // 셀 생성
        UIControl *vwCell = [[UIControl alloc] initWithFrame:CGRectMake(9, 61, 536/2, 90/2)];
        [vwCell addTarget:self action:@selector(touchVisit:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addTarget:self action:@selector(onCellDown:) forControlEvents:UIControlEventTouchDown];
        [vwCell addTarget:self action:@selector(onCellUp:) forControlEvents:UIControlEventTouchUpOutside];
        // 배경
        [vwCell addSubview:_imgvwVisitBackground];
        // 아이콘
        [vwCell addSubview:_imgvwVisitIcon];
        // 타이틀
        [vwCell addSubview:_lblVisitTitle];
        // 구분자
        UILabel *lblCol = [[UILabel alloc] initWithFrame:CGRectMake(142/2, 32/2-1, 10, 15)];
        [lblCol setFont:[UIFont systemFontOfSize:15]];
        [lblCol setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
        [lblCol setBackgroundColor:[UIColor clearColor]];
        [lblCol setTextAlignment:NSTextAlignmentCenter];
        [lblCol setText:@":"];
        [vwCell addSubview:lblCol];
        [lblCol release];
        // 키워드
        [vwCell addSubview:_lblVisit];
        // 버튼
        [vwCell addSubview:_btnVisitAddRemoveButton];
        //셀 삽입
        [_vwSearchRouteDialog addSubview:vwCell];
        [vwCell release];
        
        
        //[self pinRouteDestPOIOverlay];
    }
    
    // 세번째 라인
    {
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(9, 106, 536/2, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0f)];
        [_vwSearchRouteDialog addSubview:vwLine];
        [vwLine release];
    }
    
    // 도착지 초기화
    if (oms.searchResultRouteDest.used)
    {
        [_lblDest setText:oms.searchResultRouteDest.strLocationName];
    }
    else
    {
        [_lblDest setText:NSLocalizedString(@"Body_SR_Require_Dest", @"")];
    }
    // 도착지 렌더링
    {
        // 셀 생성
        UIControl *vwCell = [[UIControl alloc] initWithFrame:CGRectMake(9, 107, 536/2, 90/2)];
        [vwCell addTarget:self action:@selector(touchDest:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addTarget:self action:@selector(onCellDown:) forControlEvents:UIControlEventTouchDown];
        [vwCell addTarget:self action:@selector(onCellUp:) forControlEvents:UIControlEventTouchUpOutside];
        // 아이콘
        UIImageView *imgvwIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_list_r_icon.png"]];
        [imgvwIcon setFrame:CGRectMake(10, 14, 15, 19)];
        [vwCell addSubview:imgvwIcon];
        [imgvwIcon release];
        // 타이틀
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(58/2, 32/2, 96/2, 30/2)];
        [lblTitle setFont:[UIFont boldSystemFontOfSize:15]];
        [lblTitle setTextColor:convertHexToDecimalRGBA(@"F2", @"34", @"71", 1.0f)];
        [lblTitle setBackgroundColor:[UIColor clearColor]];
        [lblTitle setText:@"도착지"];
        [vwCell addSubview:lblTitle];
        [lblTitle release];
        // 구분자
        UILabel *lblCol = [[UILabel alloc] initWithFrame:CGRectMake(142/2, 32/2-1, 10, 15)];
        [lblCol setFont:[UIFont systemFontOfSize:15]];
        [lblCol setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
        [lblCol setBackgroundColor:[UIColor clearColor]];
        [lblCol setTextAlignment:NSTextAlignmentCenter];
        [lblCol setText:@":"];
        [vwCell addSubview:lblCol];
        [lblCol release];
        // 키워드
        [vwCell addSubview:_lblDest];
        // 버튼
        UIButton *btnArrow = [[UIButton alloc] initWithFrame:CGRectMake(496/2, 29/2, 10, 16)];
        [btnArrow setImage:[UIImage imageNamed:@"popup_arrow_icon.png"] forState:UIControlStateNormal];
        [btnArrow addTarget:self action:@selector(touchDest:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addSubview:btnArrow];
        [btnArrow release];
        //셀 삽입
        [_vwSearchRouteDialog addSubview:vwCell];
        [vwCell release];
    }
    
    // 네번째 라인
    {
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(9, 151, 536/2, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0f)];
        [_vwSearchRouteDialog addSubview:vwLine];
        [vwLine release];
    }
    
    
    // 초기화 버튼 초기화
    [_vwSearchRouteDialog addSubview:_btnReset];
    
    // 경로탐색 버튼 초기화
    [_vwSearchRouteDialog addSubview:_btnRoute];
    
    // 경로탐색 "시작"-"도착" 정보가 둘다 존재할경우에만 버튼활성화 처리함.
    [_btnRoute setEnabled:oms.searchResultRouteStart.used && oms.searchResultRouteDest.used];
    
    MainMapViewController *mmvc = [[OMNavigationController sharedNavigationController].viewControllers lastObject];
    
    if(oms.searchResultRouteStart.used && !oms.searchResultRouteStart.isCurrentLocation)
    {
        [mmvc pinRouteStartPOIOverlay];
    }
    if (oms.searchResultRouteDest.used  && !oms.searchResultRouteDest.isCurrentLocation)
    {
        [mmvc pinRouteDestPOIOverlay];
    }
    if (oms.searchResultRouteVisit.used && !oms.searchResultRouteVisit.isCurrentLocation)
    {
        [mmvc pinRouteVisitPOIOverlay];
    }
    
    
}

- (void) closeSearchRouteDialog
{
    for (UIView *subview in _vwSearchRouteContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    if ( _vwSearchRouteContainer.superview )
        [_vwSearchRouteContainer removeFromSuperview];
}

// *******************************



// ======================
// [ 길찾기 Interaction ]
// ======================

- (void) openSearchViewController
{
    
    // 기존화면이 검색관련 화면일 경우 미리 제거함 (검색화면 중복방지)
    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    for (int i = nc.viewControllers.count-1; i >= 0; i--)
    {
        UIViewController *vc = [nc.viewControllers objectAtIndexGC:i];
        // 검색 & 검색결과 & 음성검색결과 뷰컨트롤러를 모두 제거한다.
        if (   ![vc isKindOfClass:[SearchResultViewController2 class]]
            && ![vc isKindOfClass:[SearchViewController class]]
            )
        {
            [nc popToViewController:vc animated:NO];
            break;
        }
    }
    
    // 검색뷰 컨트롤러 호출
    SearchViewController *svc = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
    [[OMNavigationController sharedNavigationController] pushViewController:svc animated:NO];
    [svc release];
    
}

- (void) touchStart:(id)sender
{
    // 현재 다이얼로그는 해제..
    // [_vwSearchRouteContainer removeFromSuperview];
    
    if ([sender isKindOfClass:[UIControl class]] )
    {
        [((UIControl*)sender) setBackgroundColor:[UIColor whiteColor]];
    }
    
    // 출발지 검색화면 옵션 설정
    [[OllehMapStatus sharedOllehMapStatus] setCurrentActionType: ActionType_SEARCHROUTE];
    [[OllehMapStatus sharedOllehMapStatus] setCurrentSearchTargetType: SearchTargetType_START];
    
    // 검색화면 호출
    [self openSearchViewController];
}
- (void) touchVisit:(id)sender
{
    
    if ([sender isKindOfClass:[UIControl class]] )
    {
        [((UIControl*)sender) setBackgroundColor:[UIColor whiteColor]];
    }
    
    // 현재 다이얼로그는 해제..
    //[_vwSearchRouteContainer removeFromSuperview];
    
    // 경유지 검색화면 옵션 설정
    [[OllehMapStatus sharedOllehMapStatus] setCurrentActionType: ActionType_SEARCHROUTE];
    [[OllehMapStatus sharedOllehMapStatus] setCurrentSearchTargetType: SearchTargetType_VISIT];
    
    // 검색화면 호출
    [self openSearchViewController];
    
    // 경유지 추가 횟수 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/find_route_add_via"];
    
}
- (void) touchDest:(id)sender
{
    
    if ([sender isKindOfClass:[UIControl class]] )
    {
        [((UIControl*)sender) setBackgroundColor:[UIColor whiteColor]];
    }
    
    // 현재 다이얼로그는 해제..
    // [_vwSearchRouteContainer removeFromSuperview];
    
    // 도착지 검색화면 옵션 설정
    [[OllehMapStatus sharedOllehMapStatus] setCurrentActionType: ActionType_SEARCHROUTE];
    [[OllehMapStatus sharedOllehMapStatus] setCurrentSearchTargetType: SearchTargetType_DEST];
    
    // 검색화면 호출
    [self openSearchViewController];
    
}
- (void) onVisitAddRemove:(id)sender
{
    [_btnVisitAddRemoveButton setSelected:!_btnVisitAddRemoveButton.selected];
    
    if (_btnVisitAddRemoveButton.selected)
    {
        // 현재 다이얼로그는 해제..
        [_vwSearchRouteContainer removeFromSuperview];
        
        // 경유지 검색화면 호출
        [[OllehMapStatus sharedOllehMapStatus] setCurrentActionType: ActionType_SEARCHROUTE];
        [[OllehMapStatus sharedOllehMapStatus] setCurrentSearchTargetType: SearchTargetType_VISIT];
        SearchViewController *svc = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
        [[OMNavigationController sharedNavigationController] pushViewController:svc animated:NO];
        [svc release];
        
        // 경유지 추가 횟수 통계
        [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/find_route_add_via"];
    }
    else
    {
        [[OllehMapStatus sharedOllehMapStatus].searchResultRouteVisit reset];
        [self showSearchRouteDialogWithAnalytics:NO];
    }
}
- (void) onReset:(id)sender
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 데이터 초기화
    [oms.searchResultRouteStart reset];
    [oms.searchResultRouteVisit reset];
    [oms.searchResultRouteDest reset];
    
    // 검색결과 초기화 (어짜피 검색하면 전부 초기화되겠지만 일단 메모리 확보차원에서라도 해보자..)
    [oms.searchRouteData reset];
    
    // Route POI 제거
    
    [[MapContainer sharedMapContainer_Main].kmap removeAllRouteOverlay];
    
    // 화면에서 제거했다가 재생성
    //   [self.view removeFromSuperview];
    [self showSearchRouteDialogWithAnalytics:NO];
    
}
- (void) onRoute:(id)sender
{
    // 길찾기 검색전 기존 검색 데이터 클리어
    [[OllehMapStatus sharedOllehMapStatus].searchRouteData reset];
    
    [[SearchRouteExecuter sharedSearchRouteExecuter] searchRoute_Car: SearchRoute_Car_SearchType_RealTime];
}

- (void) onCellDown:(id)sender
{
    UIControl *cell = (UIControl*)sender;
    [cell setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0)];
}
- (void) onCellUp:(id)sender
{
    UIControl *cell = (UIControl*)sender;
    [cell setBackgroundColor:[UIColor whiteColor]];
}

- (void) onTouchBackground:(id)sender
{
    [self closeSearchRouteDialog];
}

// **********************


@end
