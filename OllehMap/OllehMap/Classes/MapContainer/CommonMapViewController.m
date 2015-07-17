//
//  CommonMapViewController.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 4..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "CommonMapViewController.h"

#import "MainMapViewController.h"
#import "SearchRouteResultMapViewController.h"

@interface CommonMapViewController ()

@end

@implementation CommonMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{ 
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _vwMapViewOptionContainer = [[UIControl alloc]
                                     initWithFrame:CGRectMake(0, 0,
                                                              [UIScreen mainScreen].bounds.size.width,
                                                              [UIScreen mainScreen].bounds.size.height - 20)];
        
        // Toggle In-Call StatusBar
        // [_vwMapViewOptionContainer setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        
        [_vwMapViewOptionContainer setBackgroundColor:convertHexToDecimalRGBA(@"00", @"00", @"00", 0.7)];
        [_vwMapViewOptionContainer addTarget:self action:@selector(onOptionViewCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
- (void) dealloc
{
    [_vwMapViewOptionContainer release];
    _vwMapViewOptionContainer  = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 모든 맵뷰에는 기본 UINavigationViewController를 숨김처리해야한다.
    [[OMNavigationController sharedNavigationController] setNavigationBarHidden:YES];
    
    // 현재 화면에 대한 액션타입과 검색관련 플래그 설정
    [[OllehMapStatus sharedOllehMapStatus] setCurrentActionType: ActionType_MAP];
    [[OllehMapStatus sharedOllehMapStatus] setCurrentSearchTargetType: SearchTargetType_NONE];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 맵뷰를 빠져나갈때는 다시 뷰컨트롤러를 표시한다.
    [[OMNavigationController sharedNavigationController] setNavigationBarHidden:NO];
}


// =======================================
// [ 지도옵션 메소드  ]
// =======================================
- (void) showMapTrafficOptionView :(BOOL)show currentMapContainer:(MapContainer *)currentMapContainer currentMapViewController:(CommonMapViewController *)currentMapViewController
{
    [self showMapTrafficOptionView:show currentMapContainer:currentMapContainer currentMapViewController:currentMapViewController trafficOptionEnabled:YES];
}
- (void) showMapTrafficOptionView:(BOOL)show currentMapContainer:(MapContainer *)currentMapContainer currentMapViewController:(CommonMapViewController *)currentMapViewController trafficOptionEnabled:(bool)trafficOptionEnabled
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 지도교통옵션 뷰 클리어
    for (UIView* subview in _vwMapViewOptionContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    
    int y = 90;
    // 길찾기 지도에서는 팝업을 위로 올림
    if(!trafficOptionEnabled)
    {
        y = 37 + 15 - 2;
    }
    
    // 지도교통옵션 뷰 디스플레이
    if (show)
    {
        // 옵션팝업 생성
        CGRect optionPopupViewFrame = CGRectMake(81, y, 460/2, 422/2);
        if ( oms.currentMapScreenMode == MapScreenMode_FULL ) optionPopupViewFrame.origin.y = 14.0f;
        UIView *optionPopupView = [[UIView alloc] initWithFrame:optionPopupViewFrame];
        [_vwMapViewOptionContainer addSubview:optionPopupView];
        
        // 옵션팝업 배경처리
        UIImageView *optionPopupBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_option_bg.png"]];
        [optionPopupBackgroundView setFrame:CGRectMake(0, 0, optionPopupBackgroundView.image.size.width, optionPopupBackgroundView.image.size.height)];
        [optionPopupView addSubview:optionPopupBackgroundView];

        // 닫기버튼
        UIButton *optionPopupCloseButton = [[UIButton alloc] initWithFrame:CGRectMake(194, 3, 58/2, 54/2)];
        [optionPopupCloseButton setImage:[UIImage imageNamed:@"map_option_close.png"] forState:UIControlStateNormal];
        [optionPopupCloseButton addTarget:self action:@selector(onOptionViewCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [optionPopupView addSubview:optionPopupCloseButton];
        
        // 교통정보 사용여부
        bool useTrafficInfo = currentMapContainer.kmap.trafficInfo;
        bool useTrafficCCTV = currentMapContainer.kmap.trafficCCTV;
        bool useTrafficBusStation = currentMapContainer.kmap.trafficBusStation;
        bool useTrafficSubwayStation = currentMapContainer.kmap.trafficSubwayStation;
        bool useTrafficAddress = currentMapContainer.kmap.CadastralInfo;
        
        // 지적도 버튼
        UIButton *trafficAddressBtn = [[UIButton alloc] initWithFrame:CGRectMake(11 + 126/2 + 9, 50 + 126/2 + 20, 126/2,126/2)];
        
        [trafficAddressBtn setImage:[UIImage imageNamed:@"map_option_btn05_off.png"] forState:UIControlStateNormal];
        [trafficAddressBtn setImage:[UIImage imageNamed:@"map_option_btn05_on.png"] forState:UIControlStateSelected];
        [trafficAddressBtn setImage:[UIImage imageNamed:@"map_option_btn05_on.png"] forState:UIControlStateHighlighted];
        [trafficAddressBtn addTarget:self action:@selector(onOPtionViewUseTrafficAddress:) forControlEvents:UIControlEventTouchUpInside];
        [trafficAddressBtn setSelected:useTrafficAddress];
        
        // 길찾기에선 지적도 OFF
        [trafficAddressBtn setEnabled:trafficOptionEnabled];
        
        [optionPopupView addSubview:trafficAddressBtn];
        
        // 교통량 사용 버튼
        UIButton *trafficInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(11, 50 + 126/2 + 20, 126/2, 126/2)];
        [trafficInfoButton setImage:[UIImage imageNamed:@"map_option_btn01_off.png"] forState:UIControlStateNormal];
        [trafficInfoButton setImage:[UIImage imageNamed:@"map_option_btn01_on.png"] forState:UIControlStateSelected];
        [trafficInfoButton setImage:[UIImage imageNamed:@"map_option_btn01_on.png"] forState:UIControlStateHighlighted];
        [trafficInfoButton addTarget:self action:@selector(onOptionViewUseTrafficInfo:) forControlEvents:UIControlEventTouchUpInside];
        
        // 길찾기에선 실시간교통 OFF
        //[trafficInfoButton setEnabled:trafficOptionEnabled];
        [trafficInfoButton setSelected:useTrafficInfo];
        [optionPopupView addSubview:trafficInfoButton];
        
        // CCTV 버튼
        UIButton *trafficCCTVButton = [[UIButton alloc] initWithFrame:CGRectMake(11, 50, 126/2, 126/2)];

        [trafficCCTVButton setImage:[UIImage imageNamed:@"map_option_btn02_off.png"] forState:UIControlStateNormal];
        [trafficCCTVButton setImage:[UIImage imageNamed:@"map_option_btn02_on.png"] forState:UIControlStateSelected];
        [trafficCCTVButton setImage:[UIImage imageNamed:@"map_option_btn02_on.png"] forState:UIControlStateHighlighted];
        //[trafficCCTVButton setImage:[UIImage imageNamed:@"map_option_btn02_off.png"] forState:UIControlStateDisabled];
        [trafficCCTVButton addTarget:self action:@selector(onOptionViewUseTrafficCCTV:) forControlEvents:UIControlEventTouchUpInside];
        
        // 길찾기에선 cctv off
        [trafficCCTVButton setEnabled:trafficOptionEnabled];
        [trafficCCTVButton setSelected:useTrafficCCTV];
        [optionPopupView addSubview:trafficCCTVButton];
        
        // 버스정류장 버튼
        UIButton *trafficBusStationButton = [[UIButton alloc] initWithFrame:CGRectMake(11 + 126/2 + 9, 50, 126/2, 126/2)];
        [trafficBusStationButton setImage:[UIImage imageNamed:@"map_option_btn03_off.png"] forState:UIControlStateNormal];
        [trafficBusStationButton setImage:[UIImage imageNamed:@"map_option_btn03_on.png"] forState:UIControlStateSelected];
        [trafficBusStationButton setImage:[UIImage imageNamed:@"map_option_btn03_on.png"] forState:UIControlStateHighlighted];
        //[trafficBusStationButton setImage:[UIImage imageNamed:@"map_option_btn03_off.png"] forState:UIControlStateDisabled];
        [trafficBusStationButton addTarget:self action:@selector(onOptionViewUseTrafficBusStation:) forControlEvents:UIControlEventTouchUpInside];
        
        // 길찾기에선 버스정류장 off
        [trafficBusStationButton setEnabled:trafficOptionEnabled];
        [trafficBusStationButton setSelected:useTrafficBusStation];
        [optionPopupView addSubview:trafficBusStationButton];
        
        // 지하철역 버튼
        UIButton *trafficSubwayStationButton = [[UIButton alloc] initWithFrame:CGRectMake(11 + 126/2 + 9 + 126/2 + 9, 50, 126/2, 126/2)];
        [trafficSubwayStationButton setImage:[UIImage imageNamed:@"map_option_btn04_off.png"] forState:UIControlStateNormal];
        [trafficSubwayStationButton setImage:[UIImage imageNamed:@"map_option_btn04_on.png"] forState:UIControlStateSelected];
        [trafficSubwayStationButton setImage:[UIImage imageNamed:@"map_option_btn04_on.png"] forState:UIControlStateHighlighted];
        //[trafficSubwayStationButton setImage:[UIImage imageNamed:@"map_option_btn04_off.png"] forState:UIControlStateDisabled];
        [trafficSubwayStationButton addTarget:self action:@selector(onOptionViewUseTrafficSubwayStation:) forControlEvents:UIControlEventTouchUpInside];
        
        // 길찾기에선 지하철역 off
        [trafficSubwayStationButton setEnabled:trafficOptionEnabled];
        [trafficSubwayStationButton setSelected:useTrafficSubwayStation];
        [optionPopupView addSubview:trafficSubwayStationButton];
        
        // 지도교통옵션 컨테이너 삽입
        [_vwMapViewOptionContainer addSubview:optionPopupView];
        [currentMapViewController.view addSubview:_vwMapViewOptionContainer];
        
        // 메모리 정리
        [optionPopupView release];
        [optionPopupBackgroundView release];
        [trafficAddressBtn release];
        [optionPopupCloseButton release];
        [trafficInfoButton release];
        [trafficCCTVButton release];
        [trafficBusStationButton release];
        [trafficSubwayStationButton release];
    }
    else
    {
        // 뷰 숨김처리
        [_vwMapViewOptionContainer removeFromSuperview];
    }
}
- (void) onOptionViewCloseButton :(id)sender
{
    [self showMapTrafficOptionView:NO currentMapContainer:nil currentMapViewController:nil];
}
// 지적도 보기 메서드
- (void) onOPtionViewUseTrafficAddress:(id)sender
{
}
- (void) onOptionViewUseTrafficInfo :(id)sender
{
    // 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/main/traffic_info"];
    // 상세구현은 각 맵뷰컨트롤러에서 처리한다.
}
- (void) onOptionViewUseTrafficCCTV:(id)sender
{
    // 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/traffictheme/cctv"];
    
    // 상세구현은 각 맵뷰컨트롤러에서 처리한다.
}
- (void) onOptionViewUseTrafficBusStation:(id)sender
{
    // 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/traffictheme/busstation"];
    // 상세구현은 각 맵뷰컨트롤러에서 처리한다.
}
- (void) onOptionViewUseTrafficSubwayStation:(id)sender
{
    // 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/traffictheme/subwaystation"];
    // 상세구현은 각 맵뷰컨트롤러에서 처리한다.
}
// ***************************************


// =======================================
// [ 공통 보조 메소드 시작 ]
// =======================================

- (void) JumpToSearchView:(BOOL)animated
{
    {
        //  검색액션 설정
        [[OllehMapStatus sharedOllehMapStatus] setCurrentActionType:ActionType_SEARCH];
        
        // 검색뷰 생성
        SearchViewController *searchView = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
        
        // 네비게이션 뷰컨트롤에 추가
        [[OMNavigationController sharedNavigationController] pushViewController:searchView animated:NO];
        
        if (animated)
        {
            // 검색뷰 상단영역으로 숨김처리
            [searchView.view setFrame:CGRectMake(0, -searchView.view.frame.size.height, searchView.view.frame.size.width, searchView.view.frame.size.height)];
            // 애니메이션 효과 설정
            [UIView beginAnimations:@"" context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
            // 검색뷰 정위치로 설정 (상단에서 정위치로 페이드 효과로 나타남)
            [searchView.view setFrame:CGRectMake(0, 0, searchView.view.frame.size.width, searchView.view.frame.size.height)];
            // 애니메이션 적용
            [UIView commitAnimations];
        }
        
        // 검색뷰 해제
        [searchView release];
    }
}

// ***************************************

@end
