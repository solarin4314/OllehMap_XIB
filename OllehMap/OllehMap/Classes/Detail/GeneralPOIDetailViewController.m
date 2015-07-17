//
//  GeneralPOIDetailViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 5. 31..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "GeneralPOIDetailViewController.h"
#import "MapContainer.h"
#import "MainMapViewController.h"

@interface GeneralPOIDetailViewController ()

@end

@implementation GeneralPOIDetailViewController

@synthesize themeToDetailName = _themeToDetailName;

@synthesize freeCalling = _freeCalling;
@synthesize shapeType = _shapeType;
@synthesize fcNm = _fcNm;
@synthesize idBgm = _idBgm;
@synthesize blankPOIlabel = _blankPOIlabel;
@synthesize callLinkView = _callLinkView;
@synthesize callLinkAlertView = _callLinkAlertView;
@synthesize myNumber = _myNumber;
@synthesize goFreeCall = _goFreeCall;
@synthesize detailInfoLabelView = _detailInfoLabelView;
@synthesize detailInfoNoDataView = _detailInfoNoDataView;
@synthesize detailOptionBtnView = _detailOptionBtnView;
@synthesize reservationYN = _reservationYN;
@synthesize cardYN = _cardYN;
@synthesize parkingYN = _parkingYN;
@synthesize deliveryYN = _deliveryYN;
@synthesize packingYN = _packingYN;
@synthesize beerYN = _beerYN;
@synthesize underLine6 = _underLine6;
@synthesize openingTimeView = _openingTimeView;
@synthesize openingText = _openingText;
@synthesize closingTimeView = _closingTimeView;
@synthesize closingText = _closingText;
@synthesize chargeView = _chargeView;
@synthesize chargeText = _chargeText;
@synthesize nearlyRestView = _nearlyRestView;
@synthesize nearlyRestText = _nearlyRestText;


@synthesize bottomView = _bottomView;

@synthesize mainInfoNoDataView = _mainInfoNoDataView;
@synthesize mainInfoView = _mainInfoView;

@synthesize mainInfoText = _mainInfoText;
@synthesize expandMainInfoText = _expandMainInfoText;
@synthesize expandBtn = _expandBtn;
@synthesize expandBtnImg = _expandBtnImg;
@synthesize underLine5 = _underLine5;


@synthesize scrollView = _scrollView;
@synthesize popBtn = _popBtn;
@synthesize mapBtn = _mapBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    
    [_freeCalling release];
    [_shapeType release];
    [_fcNm release];
    [_idBgm release];
    [_telLabel release];
    [_scrollView release];
    [_popBtn release];
    [_mapBtn release];
    [_themeToDetailName release];
    [_mainInfoView release];
    [_bottomView release];
    [_mainInfoText release];
    
    
    [_expandBtn release];
    [_expandBtnImg release];
    [_expandMainInfoText release];
    
    
    
    [_detailInfoLabelView release];
    [_openingTimeView release];
    [_closingTimeView release];
    [_chargeView release];
    [_nearlyRestView release];
    [_detailOptionBtnView release];
    [_reservationYN release];
    [_cardYN release];
    [_parkingYN release];
    [_deliveryYN release];
    [_packingYN release];
    [_beerYN release];
    [_openingText release];
    [_closingText release];
    [_chargeText release];
    [_nearlyRestText release];
    [_detailInfoNoDataView release];
    
    
    [_underLine5 release];
    [_underLine6 release];
    [_mainInfoNoDataView release];
    [_blankPOIlabel release];
    [_callLinkView release];
    [_myNumber release];
    [_goFreeCall release];
    [_callLinkAlertView release];
    [blankPOIlbl release];
    //[_tf release];
    [super dealloc];
}
-(void) viewWillAppear:(BOOL)animated
{
    self.delegate = self;
    self.navigationController.navigationBarHidden = YES;
    //[_mapBtn setHidden:!_displayMapBtn];
    [_mapBtn setEnabled:_displayMapBtn];
}
- (void)viewDidUnload
{
    
    [self setFreeCalling:nil];
    [self setShapeType:nil];
    [self setFcNm:nil];
    [self setIdBgm:nil];
    [self setScrollView:nil];
    [self setPopBtn:nil];
    [self setMapBtn:nil];
    
    [self setMainInfoView:nil];
    [self setBottomView:nil];
    
    [self setMainInfoText:nil];
    
    [self setExpandBtn:nil];
    [self setExpandBtnImg:nil];
    [self setExpandMainInfoText:nil];
    
    
    
    [self setDetailInfoLabelView:nil];
    [self setOpeningTimeView:nil];
    [self setClosingTimeView:nil];
    [self setChargeView:nil];
    [self setNearlyRestView:nil];
    [self setDetailOptionBtnView:nil];
    [self setReservationYN:nil];
    [self setCardYN:nil];
    [self setParkingYN:nil];
    [self setDeliveryYN:nil];
    [self setPackingYN:nil];
    [self setBeerYN:nil];
    [self setOpeningText:nil];
    [self setClosingText:nil];
    [self setChargeText:nil];
    [self setNearlyRestText:nil];
    [self setDetailInfoNoDataView:nil];
    
    
    [self setUnderLine5:nil];
    [self setUnderLine6:nil];
    [self setMainInfoNoDataView:nil];
    [self setBlankPOIlabel:nil];
    [self setCallLinkView:nil];
    [self setMyNumber:nil];
    
    [self setGoFreeCall:nil];
    [self setCallLinkAlertView:nil];
    [blankPOIlbl release];
    blankPOIlbl = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mainInfoNull = NO;
    
    _detailInfoNull = NO;
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSLog(@"%@", oms.poiDetailDictionary);
    
    self.freeCalling = [NSString stringWithFormat:@"%@", [oms.searchLocalDictionary objectForKey:@"LastExtendFreeCall"]];
    NSLog(@"freeCalling : %@", self.freeCalling);
    self.shapeType = stringValueOfDictionary(oms.searchLocalDictionary, @"LastExtendShapeType");
    self.fcNm = stringValueOfDictionary(oms.searchLocalDictionary, @"LastExtendFCNM");
    self.idBgm = stringValueOfDictionary(oms.searchLocalDictionary, @"LastExtendIDBGM");
    NSLog(@"shape : %@, fcnm = %@, idBgm = %@", self.shapeType, self.fcNm, self.idBgm);
    _viewStartY = GeneralStartY;
    _expand = NO;
    
    [self saveRecentSearch];
    
    // 상단뷰 그리기
    [self drawTopView];
    
    // 주요정보 그리기
    [self drawMainInfoView];
    
    // 상세정보 라벨 그리기
    [self drawDetailInfoLabelView];
    
    // Do any additional setup after loading the view from its nib.
}

- (void) saveRecentSearch
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *ujName = [oms.poiDetailDictionary objectForKey:@"UJ_NAME"];
    
    // 최근리스트 저장
    
    NSMutableDictionary *generalPOIDic = [NSMutableDictionary dictionary];
    
    Coord poiCrd;
    
    poiCrd = CoordMake([[oms.poiDetailDictionary objectForKey:@"X"] doubleValue], [[oms.poiDetailDictionary objectForKey:@"Y"] doubleValue]);
    
    double xx = poiCrd.x;
    double yy = poiCrd.y;
    NSString *tel = stringValueOfDictionary(oms.poiDetailDictionary, @"TEL");
    
    NSLog(@"self.freecall : %@", self.freeCalling);
    
    // ver3테스트2번버그(최근검색에서도 상세이름까지 나오도록...)
    NSString *recentName = _themeToDetailName;
    
    if(!recentName || [recentName isEqualToString:@""])
    {
        recentName = [oms.poiDetailDictionary objectForKey:@"NAME"];
    }
    
    [generalPOIDic setObject:recentName forKey:@"NAME"];
    [generalPOIDic setObject:[oms ujNameSegment:ujName] forKey:@"CLASSIFY"];
    [generalPOIDic setValue:[NSNumber numberWithDouble:xx] forKey:@"X"];
    [generalPOIDic setValue:[NSNumber numberWithDouble:yy] forKey:@"Y"];
    [generalPOIDic setObject:@"MP" forKey:@"TYPE"];
    [generalPOIDic setObject:[oms.poiDetailDictionary objectForKey:@"POI_ID"] forKey:@"ID"];
    [generalPOIDic setObject:tel forKey:@"TEL"];
    [generalPOIDic setObject:[oms.poiDetailDictionary objectForKey:@"ADDR"] forKey:@"ADDR"];
    [generalPOIDic setObject:[NSString stringWithFormat:@"%@", self.freeCalling] forKey:@"FREE"];
    [generalPOIDic setObject:[NSString stringWithFormat:@"%@", self.shapeType] forKey:@"SHAPE_TYPE"];
    [generalPOIDic setObject:[NSString stringWithFormat:@"%@", self.fcNm] forKey:@"FCNM"];
    [generalPOIDic setObject:[NSString stringWithFormat:@"%@", self.idBgm] forKey:@"ID_BGM"];
    [generalPOIDic setObject:[NSNumber numberWithInt:Favorite_IconType_POI] forKey:@"ICONTYPE"];
    
    [oms addRecentSearch:generalPOIDic];
    
    
    // 최근리스트 저장 끝
    
}
- (void) drawTopView
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 최상단 뷰(이름, 주소, 분류, 이미지)
    int topViewHeight = 90;
    
    UIColor *labelBg = [UIColor clearColor];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, topViewHeight)];
    [topView setBackgroundColor:[UIColor colorWithRed:217.0/255.0 green:244.0/255.0 blue:255.0/255.0 alpha:1]];
    
    
    UILabel *poiName = [[UILabel alloc] initWithFrame:CGRectMake(90, 16, 220, 17)];
    [poiName setText:[oms.poiDetailDictionary objectForKey:@"NAME"]];
    [poiName setFont:[UIFont boldSystemFontOfSize:17]];
    [poiName setAdjustsFontSizeToFitWidth:YES];
    [poiName setNumberOfLines:1];
    [poiName setBackgroundColor:labelBg];
    [topView addSubview:poiName];
    [poiName release];
    
    UILabel *poiAdd = [[UILabel alloc] initWithFrame:CGRectMake(90, 40, 220, 13)];
    [poiAdd setText:[oms.poiDetailDictionary objectForKey:@"ADDR"]];
    [poiAdd setFont:[UIFont systemFontOfSize:13]];
    [poiAdd setAdjustsFontSizeToFitWidth:YES];
    [poiAdd setNumberOfLines:1];
    [poiAdd setBackgroundColor:labelBg];
    [topView addSubview:poiAdd];
    [poiAdd release];
    
    UILabel *poiUj = [[UILabel alloc] initWithFrame:CGRectMake(90, 60, 220, 13)];
    [poiUj setText:[oms.poiDetailDictionary objectForKey:@"UJ_NAME"]];
    [poiUj setFont:[UIFont systemFontOfSize:13]];
    [poiUj setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1]];
    [poiUj setAdjustsFontSizeToFitWidth:YES];
    [poiUj setNumberOfLines:1];
    [poiUj setBackgroundColor:labelBg];
    [topView addSubview:poiUj];
    [poiUj release];
    
    UIImageView *poiImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 70, 70)];
    [poiImg setImage:[UIImage imageNamed:@"view_no_img_box.png"]];
    NSString *imageUrl = [oms.poiDetailDictionary objectForKey:@"IMG_URL"];
    // 이미지가 있으면 이미지를 그린다
	if (imageUrl)
    {
        [poiImg setImage:[oms urlGetImage:imageUrl]];
	}
    [topView addSubview:poiImg];
    [poiImg release];
    
    UIImageView *poiImgBox = [[UIImageView alloc] init];
    [poiImgBox setFrame:CGRectMake(10, 10, 70, 70)];
    [poiImgBox setImage:[UIImage imageNamed:@"view_img_box.png"]];
    [topView addSubview:poiImgBox];
    [poiImgBox release];
    
    [_scrollView addSubview:topView];
    [topView release];
    
    _viewStartY += topViewHeight;
    
    NSLog(@"밑줄시작y : %d", _viewStartY);
    // 상단뷰 밑줄
    [self drawUnderLine1];
    
}

// 상단뷰 밑줄
- (void) drawUnderLine1
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    UIImageView *underLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 1)];
    [underLine1 setImage:[UIImage imageNamed:@"poi_list_line_01.png"]];
    // 스크롤뷰에 밑줄뷰 추가
    [_scrollView addSubview:underLine1];
    [underLine1 release];
    
    _viewStartY += 1;
    
    NSLog(@"전번시작y : %d", _viewStartY);
    
    self.freeCalling = [NSString stringWithFormat:@"%@", [oms.searchLocalDictionary objectForKey:@"LastExtendFreeCall"]];
    
    NSString *str = stringValueOfDictionary(oms.poiDetailDictionary, @"TEL");
    
    NSLog(@"freecalling : %d", self.freeCalling.retainCount);
    // 무료통화가 있으면 무료통화뷰를 그리고 없으면 일반 전화뷰
    if([self.freeCalling isEqualToString:@"PG1201000000008"] && ![str isEqualToString:@""])
    {
        [self drawFreeTelePhone];
    }
    else if(![str isEqualToString:@""])
    {
        [self drawTelePhone];
    }
    else
    {
        [self drawHomePage];
    }
}


// 전화번호 뷰
- (void) drawTelePhone
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    int telViewHeight = 40;
    NSLog(@"전번시작y : %d", _viewStartY);
    UIView *telView = [[UIView alloc] initWithFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, telViewHeight)];
    
    // 버튼
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 320, 40)];
    [button setBackgroundImage:[UIImage imageNamed:@"poi_busstop_list_bg_pressed.png"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goPhoneClick:) forControlEvents:UIControlEventTouchUpInside];
    [telView addSubview:button];
    
    // 전화이미지
    UIImageView *telImg = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 20, 20)];
    [telImg setImage:[UIImage imageNamed:@"view_list_b_call.png"]];
    [telView addSubview:telImg];
    [telImg release];
    
    NSString *telStr = stringValueOfDictionary(oms.poiDetailDictionary, @"TEL");
    
    // 전화번호라벨
    UILabel *telLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 13, 260, 15)];
    [telLabel setText:telStr];
    [telLabel setBackgroundColor:[UIColor clearColor]];
    [telLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [telLabel setTextColor:[UIColor colorWithRed:26.0/255.0 green:104.0/255.0 blue:201.0/255.0 alpha:1]];
    [telView addSubview:telLabel];
    [telLabel release];
    
    // 애로우버튼이미지
    UIImageView *arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(303, 14, 7, 12)];
    [arrowImg setImage:[UIImage imageNamed:@"view_list_arrow.png"]];
    [telView addSubview:arrowImg];
    [arrowImg release];
    
    // 전화번호가 없으면 히든
    if([telStr isEqualToString:@""])
    {
        [telView setHidden:YES];
        [telView release];
        [self drawHomePage];
    }
    else
    {
        // 스크롤뷰에 추가
        [_scrollView addSubview:telView];
        [telView release];
        
        _viewStartY = _viewStartY + telViewHeight;
        
        [self drawUnderLine2];
    }
    
    // 전화번호 뷰 끝
    
}

// 무료통화 뷰
- (void) drawFreeTelePhone
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    int freeCallViewHeight = 40;
    
    UIView *freeCallView = [[UIView alloc] initWithFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, freeCallViewHeight)];
    
    //일반전화버튼
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 159, 40)];
    [button setBackgroundImage:[UIImage imageNamed:@"poi_busstop_list_bg_pressed.png"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(fgoPhoneClick:) forControlEvents:UIControlEventTouchUpInside];
    [freeCallView addSubview:button];
    
    // 일반전화이미지
    UIImageView *telImg = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 20, 20)];
    [telImg setImage:[UIImage imageNamed:@"view_list_b_call.png"]];
    [freeCallView addSubview:telImg];
    [telImg release];
    
    NSString *telStr = stringValueOfDictionary(oms.poiDetailDictionary, @"TEL");
    
    // 일반전화라벨
    _telLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 13, 130, 15)];
    [_telLabel setText:telStr];
    [_telLabel setBackgroundColor:[UIColor clearColor]];
    [_telLabel setTextColor:[UIColor colorWithRed:26.0/255.0 green:104.0/255.0 blue:201.0/255.0 alpha:1]];
    [_telLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [freeCallView addSubview:_telLabel];
    
    
    // 일반전화애로우이미지
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(143, 14, 7, 12)];
    [arrow setImage:[UIImage imageNamed:@"view_list_arrow.png"]];
    [freeCallView addSubview:arrow];
    [arrow release];
    
    // 세그먼트
    UIImageView *segment = [[UIImageView alloc] initWithFrame:CGRectMake(159, 0, 1, 40)];
    [segment setImage:[UIImage imageNamed:@"list_bg_line.png"]];
    [freeCallView addSubview:segment];
    [segment release];
    
    //무료전화버튼
    UIButton *fButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [fButton setFrame:CGRectMake(160, 0, 160, 40)];
    [fButton setBackgroundImage:[UIImage imageNamed:@"poi_busstop_list_bg_pressed.png"] forState:UIControlStateHighlighted];
    [fButton addTarget:self action:@selector(fGoFreeCallClick:) forControlEvents:UIControlEventTouchUpInside];
    [freeCallView addSubview:fButton];
    
    // 무료전화이미지
    UIImageView *freeTelImg = [[UIImageView alloc] initWithFrame:CGRectMake(167, 10, 20, 20)];
    [freeTelImg setImage:[UIImage imageNamed:@"view_list_r_call.png"]];
    [freeCallView addSubview:freeTelImg];
    [freeTelImg release];
    
    // 무료전화라벨
    UILabel *freeTelLabel = [[UILabel alloc] initWithFrame:CGRectMake(195, 13, 130, 15)];
    [freeTelLabel setText:@"무료통화"];
    [freeTelLabel setBackgroundColor:[UIColor clearColor]];
    [freeTelLabel setTextColor:[UIColor colorWithRed:242.0/255.0 green:52.0/255.0 blue:113.0/255.0 alpha:1]];
    [freeTelLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [freeCallView addSubview:freeTelLabel];
    [freeTelLabel release];
    
    // 무료전화애로우이미지
    UIImageView *freeArrow = [[UIImageView alloc] initWithFrame:CGRectMake(302, 14, 7, 12)];
    [freeArrow setImage:[UIImage imageNamed:@"view_list_arrow.png"]];
    [freeCallView addSubview:freeArrow];
    [freeArrow release];
    
    _viewStartY += freeCallViewHeight;
    
    [_scrollView addSubview:freeCallView];
    [freeCallView release];
    
    [self drawUnderLine2];
    
}

// 전화번호와 홈페이지 사이의 밑줄
- (void) drawUnderLine2
{
    UIImageView *underLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 1)];
    [underLine2 setImage:[UIImage imageNamed:@"poi_list_line_02.png"]];
    [_scrollView addSubview:underLine2];
    // 밑줄 뷰 위치(0, y, 너비, 높이)
    [underLine2 release];
    
    _viewStartY += 1;
    
    [self drawHomePage];
}

// 홈페이지 뷰 그리기
- (void) drawHomePage
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    int homePageViewHeight = 40;
    
    UIView *homePageView = [[UIView alloc] initWithFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, homePageViewHeight)];
    
    // 홈피버튼
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 320, 40)];
    [button setBackgroundImage:[UIImage imageNamed:@"poi_busstop_list_bg_pressed.png"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goHomePageClick:) forControlEvents:UIControlEventTouchUpInside];
    [homePageView addSubview:button];
    
    // 홈피이미지
    UIImageView *homePageImg = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 20, 20)];
    [homePageImg setImage:[UIImage imageNamed:@"view_list_address.png"]];
    [homePageView addSubview:homePageImg];
    [homePageImg release];
    
    //홈피라벨
    // pqy 잘려서 y축 -3, 높이 3 증가
    UILabel *homePageLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, 260, 18)];
    [homePageLabel setBackgroundColor:[UIColor clearColor]];
    
    NSString *url = [oms.poiDetailDictionary objectForKey:@"URL"];
    [homePageLabel setText:[oms urlValidCheck:(NSString *)url]];
    [homePageLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [homePageLabel setTextColor:[UIColor colorWithRed:26.0/255.0 green:104.0/255.0 blue:201.0/255.0 alpha:1]];
    [homePageView addSubview:homePageLabel];
    [homePageLabel release];
    
    // 애로우버튼이미지
    UIImageView *arrowImg = [[UIImageView alloc] initWithFrame:CGRectMake(303, 14, 7, 12)];
    [arrowImg setImage:[UIImage imageNamed:@"view_list_arrow.png"]];
    [homePageView addSubview:arrowImg];
    [arrowImg release];
    
    // 홈페이지가 없으면 히든
    if([oms.poiDetailDictionary objectForKey:@"URL"] == nil)
    {
        [homePageView setHidden:YES];
        [homePageView release];
        
        [self drawBtnView];
    }
    else {
        
        [_scrollView addSubview:homePageView];
        [homePageView release];
        
        _viewStartY = _viewStartY + homePageViewHeight;
        
        [self drawUnderLine3];
    }
    
    
    
    
    
}

// 홈페이지뷰 밑줄 그리기

- (void) drawUnderLine3
{
    
    UIImageView *underLine3 = [[UIImageView alloc] initWithFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 1)];
    [underLine3 setImage:[UIImage imageNamed:@"poi_list_line_03.png"]];
    
    [_scrollView addSubview:underLine3];
    
    [underLine3 release];
    _viewStartY += 1;
    
    [self drawBtnView];
    
}

// 버튼뷰 그리기
- (void) drawBtnView
{
    int btnViewHeight = 56;
    
    UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, _viewStartY, 320, btnViewHeight)];
    UIImageView *btnBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, btnViewHeight)];
    
    [btnBg setImage:[UIImage imageNamed:@"poi_list_menu_bg.png"]];
    
    [btnView addSubview:btnBg];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(10, 9, 81, 37);
    
    [startBtn setImage:[UIImage imageNamed:@"poi_list_btn_start.png"] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:startBtn];
    
    UIButton *destBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    destBtn.frame = CGRectMake(96, 9, 81, 37);
    
    [destBtn setImage:[UIImage imageNamed:@"poi_list_btn_stop.png"] forState:UIControlStateNormal];
    [destBtn addTarget:self action:@selector(destClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:destBtn];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(182, 9, 61, 37);
    
    [shareBtn setImage:[UIImage imageNamed:@"poi_list_btn_share.png"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:shareBtn];
    
    UIButton *naviBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    naviBtn.frame = CGRectMake(248, 9, 61, 37);
    
    [naviBtn setImage:[UIImage imageNamed:@"poi_list_btn_navi.png"] forState:UIControlStateNormal];
    [naviBtn addTarget:self action:@selector(naviClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:naviBtn];
    
    
    [_scrollView addSubview:btnView];
    _viewStartY += btnViewHeight;
    
    [btnBg release];
    [btnView release];
    
    [self drawMainInfoLabelView];
    // 버튼 뷰 끝
    
}

// 주요정보 라벨 그리기
- (void) drawMainInfoLabelView
{
    int mainInfoLabelViewHeight = 36;
    
    _mainInfoLabelView = [[UIView alloc] initWithFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, mainInfoLabelViewHeight)];
    
    
    UILabel *mainInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 280, 14)];
    [mainInfoLabel setText:@"주요정보"];
    [mainInfoLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [_mainInfoLabelView addSubview:mainInfoLabel];
    [mainInfoLabel release];
    
    [_scrollView addSubview:_mainInfoLabelView];
    [_mainInfoLabelView release];
    
    _blankStartY = _viewStartY;
    _viewStartY = _viewStartY + mainInfoLabelViewHeight;
    
    
}

// 주요정보 그리기
- (void) drawMainInfoView
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *rawDesp = [oms.poiDetailDictionary objectForKey:@"DESP"];
    
    NSString *desp = [rawDesp gtm_stringByUnescapingFromHTML];
    
    //NSString *desp = @"ㅇㅇㅇ";
    
    //NSString *desp = @"aaaa=asdasasdasdda";
    [_mainInfoText setText:desp];
    
    
    
    //NSLog(@"desp : %@", [oms.poiDetailDictionary objectForKey:@"DESP"]);
    
    // 너비, 높이
    CGRect mainInfoViewbounds = _mainInfoView.bounds;
    CGFloat mainInfoViewWidth = CGRectGetWidth(mainInfoViewbounds);
    CGFloat mainInfoViewHeight = CGRectGetHeight(mainInfoViewbounds);
    //    mainInfoViewHeight = (IS_4_INCH) ? mainInfoViewHeight + 47 : mainInfoViewHeight;
    
    // 확장 전 너비와 높이 저장
    _mainInfoViewNotExpendWidth = mainInfoViewWidth;
    _mainInfoViewNotExpendHeight = mainInfoViewHeight;
    
    NSLog(@"desp.length : %d", desp.length);
    
    // 주요정보가 없으면 등록된 정보가 없다는 뷰(mainInfoNoDataView)를 띄움
    if ([oms.poiDetailDictionary objectForKey:@"DESP"] == nil) {
        
        _mainInfoNull = YES;
        // 너비, 높이
        CGRect mainInfoNoDataViewbounds = _mainInfoNoDataView.bounds;
        CGFloat mainInfoNoDataViewHeight = CGRectGetHeight(mainInfoNoDataViewbounds);
        
        //NSLog(@"zzzzzzzzzzz : %d", _viewStartY);
        [_mainInfoNoDataView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, mainInfoNoDataViewHeight)];
        
        [_scrollView addSubview:_mainInfoNoDataView];
        
        // 주요정보 뷰는 히든
        [_mainInfoView setHidden:YES];
        
        _viewStartY = _viewStartY + mainInfoNoDataViewHeight;
        
    }
    else
    {
        // 축소되었을때 주요정보 라벨
        [_mainInfoText setHidden:NO];
        // 확장버튼
        [_expandBtn setHidden:NO];
        // 축소버튼
        [_expandBtnImg setHidden:NO];
        
        
        [_mainInfoView setFrame:CGRectMake(X_VALUE, _viewStartY, mainInfoViewWidth, mainInfoViewHeight)];
        
        [_scrollView addSubview:_mainInfoView];
        
        _expand = YES;
        _prevViewStartY = _viewStartY;
        _viewStartY = _viewStartY + mainInfoViewHeight;
        
        
    }
    
    [self drawUnderLine5];
    
}

- (IBAction)expandClick:(id)sender
{
    // 확장되었을 때
    if(_expand == YES)
    {
        [_mainInfoText setHidden:YES];
        [_expandMainInfoText setHidden:NO];
        
        // 너비, 높이
        CGRect mainInfoViewbounds = _mainInfoView.bounds;
        CGFloat mainInfoViewWidth = CGRectGetWidth(mainInfoViewbounds);
        // mainInfoViewHeight 변수는 0으로 초기화해도 무방함, 실제로 아래라인에서 mainInfoViewHeight 변수에 다시 실제값을 할당하는 구조라
        // 이시점에서 메소드를 통해 값을 할당하는 액션은 리소스낭비로 볼수있음 ..  Dead store..
        CGFloat mainInfoViewHeight = 0; // CGRectGetHeight(mainInfoViewbounds);
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        // 바로 _expandMainInfoText에 넣으면 잘림....그리고 html 섞여있음 아놔
        // 그래서 스트링에 넣음
        
        NSString *rawDesp = [oms.poiDetailDictionary objectForKey:@"DESP"];
        
        NSString *desp = [rawDesp gtm_stringByUnescapingFromHTML];
        
        [_expandMainInfoText setText:desp];
        
        
        // 넘버라인 0이면 무한대로 늘어남
        // 텍스트가 라벨사이즈보다 초과되면 자동줄바꿈
        [_expandMainInfoText setNumberOfLines:0];
        [_expandMainInfoText setLineBreakMode:NSLineBreakByWordWrapping];
        
        // 라벨 사이즈 맞추기
        CGSize maximumLabelSize = CGSizeMake(280,9999);
        CGSize expectedLabelSize = [_expandMainInfoText.text sizeWithFont:_expandMainInfoText.font
                                                        constrainedToSize:maximumLabelSize
                                                            lineBreakMode:_expandMainInfoText.lineBreakMode];
        
        CGRect newFrame = _expandMainInfoText.frame;
        newFrame.size.height = expectedLabelSize.height + 16;
        _expandMainInfoText.frame = newFrame;
        
        // 라벨높이
        //NSLog(@"%f", newFrame.size.height);
        
        
        // 메인뷰의 높이(라벨크기 + 버튼높이(24고정))
        mainInfoViewHeight = newFrame.size.height + 26;
        
        [_mainInfoView setFrame:CGRectMake(X_VALUE, _prevViewStartY, mainInfoViewWidth, mainInfoViewHeight)];
        [_expandBtn setFrame:CGRectMake(X_VALUE, mainInfoViewHeight - 26, X_WIDTH, 26)];
        [_expandBtnImg setFrame:CGRectMake(153, mainInfoViewHeight - 8 - 15, 15, 8)];
        [_expandBtnImg setImage:[UIImage imageNamed:@"view_list_up_icon.png"]];
        
        _expand = NO;
        
        _viewStartY = _prevViewStartY + mainInfoViewHeight;
        
        [self drawUnderLine5];
        //[OMMessageBox showAlertMessage:@"확장" :@"확장해땅"];
    }
    
    // 축소되었을 때
    else if(_expand == NO) {
        
        [_mainInfoText setHidden:NO];
        [_expandMainInfoText setHidden:YES];
        
        
        [_mainInfoView setFrame:CGRectMake(X_VALUE, _prevViewStartY, _mainInfoViewNotExpendWidth, _mainInfoViewNotExpendHeight)];
        [_expandBtn setFrame:CGRectMake(X_VALUE, 32, X_WIDTH, 26)];
        [_expandBtnImg setFrame:CGRectMake(153, 39, 15, 8)];
        [_expandBtnImg setImage:[UIImage imageNamed:@"view_list_down_icon.png"]];
        
        _expand = YES;
        
        _viewStartY = _prevViewStartY + _mainInfoViewNotExpendHeight;
        
        [self drawUnderLine5];
        //[OMMessageBox showAlertMessage:@"축소" :@"축소해땅"];
    }
    
    //[self drawUnderLine5];
    [self drawDetailInfoLabelView];
    
}

// 주요정보 뷰 밑줄
- (void) drawUnderLine5
{
    [_scrollView addSubview:_underLine5];
    
    // 너비, 높이
    CGRect line2Viewbounds = _underLine5.bounds;
    CGFloat line2ViewWidth = CGRectGetWidth(line2Viewbounds);
    CGFloat line2ViewHeight = CGRectGetHeight(line2Viewbounds);
    if(_expand == YES)
    {
        [_underLine5 setFrame:CGRectMake(X_VALUE, _viewStartY, line2ViewWidth, line2ViewHeight)];
        _viewStartY = _viewStartY + line2ViewHeight;
    }
    
    else if(_expand == NO) {
        [_underLine5 setFrame:CGRectMake(X_VALUE, _viewStartY, line2ViewWidth, line2ViewHeight)];
        _viewStartY = _viewStartY + line2ViewHeight;
    }
    
}

// 상세정보 라벨 그리기
- (void) drawDetailInfoLabelView
{
    
    [_detailInfoLabelView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 36)];
    [_scrollView addSubview:_detailInfoLabelView];
    
    //OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 너비, 높이
    CGRect detailInfoLabelViewbounds = _detailInfoLabelView.bounds;
    CGFloat detailInfoLabelHeight = CGRectGetHeight(detailInfoLabelViewbounds);
    
    _viewStartY = _viewStartY + detailInfoLabelHeight;
    
    [self drawOptionView];
}

// 옵션정보뷰 그리기
- (void) drawOptionView
{
    [_detailOptionBtnView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 37)];
    [_scrollView addSubview:_detailOptionBtnView];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    CGRect detailOptionBtnViewbounds = _detailOptionBtnView.bounds;
    CGFloat detailOptionBtnViewHeight = CGRectGetHeight(detailOptionBtnViewbounds);
    
    // 각 이미지의 넓이를 저장
    CGRect reserv = _reservationYN.bounds;
    CGFloat reservWidth = CGRectGetWidth(reserv);
    CGRect pac = _packingYN.bounds;
    CGFloat pacWidth = CGRectGetWidth(pac);
    CGRect car = _cardYN.bounds;
    CGFloat carWidth = CGRectGetWidth(car);
    CGRect par = _parkingYN.bounds;
    CGFloat parkWidth = CGRectGetWidth(par);
    CGRect deliv = _deliveryYN.bounds;
    CGFloat delivWidth = CGRectGetWidth(deliv);
    
    // 포장이 안되면 포장이미지넓이는 0
    if([oms.poiDetailDictionary objectForKey:@"PACK_YN"] == nil)
    {
        [_packingYN setHidden:YES];
        pacWidth = 0;
    }
    
    //NSLog(@"pack Width = %f", pacWidth);
    
    // 배달 안되면 배달이미지넓이는 0
    if([oms.poiDetailDictionary objectForKey:@"DELIVERY_YN"] == nil)
    {
        [_deliveryYN setHidden:YES];
        delivWidth = 0;
    }
    
    
    //NSLog(@"deliver Width = %f", delivWidth);
    
    // 카드 안되면 카드이미지넓이는 0
    if([oms.poiDetailDictionary objectForKey:@"CARD_YN"] == nil)
    {
        [_cardYN setHidden:YES];
        carWidth = 0;
    }
    
    //NSLog(@"card Width = %f", carWidth);
    
    // 주차 안되면 주차이미지넓이는 0
    if([oms.poiDetailDictionary objectForKey:@"PARKING_YN"] == nil)
    {
        [_parkingYN setHidden:YES];
        parkWidth = 0;
    }
    
    //NSLog(@"park Width = %f", parkWidth);
    
    // 예약 안되면 예약이미지넓이는 0
    if([oms.poiDetailDictionary objectForKey:@"RESERVATION_YN"] == nil)
    {
        [_reservationYN setHidden:YES];
        reservWidth = 0;
    }
    
    //NSLog(@"reservation Width = %f", reservWidth);
    
    int distanceR = 5;
    int distanceC = 5;
    int distanceP = 5;
    int distanceD = 5;
    // 우선순위(예약, 카드, 주차, 배달, 포장)
    // 위치(10(고정값), 10(고정값), 예약넓이, 17(고정값))
    [_reservationYN setFrame:CGRectMake(DETAILOPTION_X, DETAILOPTION_Y, reservWidth, DETAILOPTION_HEIGHT)];
    
    if(_reservationYN.hidden == YES)
        distanceR = 0;
    
    // 위치(10(고정값) + 예약너비 + 5(고정값), 10(고정값), 카드너비 + 17(고정값)
    [_cardYN setFrame:CGRectMake(DETAILOPTION_X + reservWidth + distanceR, DETAILOPTION_Y, carWidth, DETAILOPTION_HEIGHT)];
    
    if(_cardYN.hidden == YES)
        distanceC = 0;
    
    [_parkingYN setFrame:CGRectMake(DETAILOPTION_X + reservWidth + distanceR + carWidth + distanceC, DETAILOPTION_Y, parkWidth, DETAILOPTION_HEIGHT)];
    
    if(_parkingYN.hidden == YES)
        distanceP = 0;
    
    [_deliveryYN setFrame:CGRectMake(DETAILOPTION_X + reservWidth + distanceR + carWidth + distanceC + parkWidth + distanceP, DETAILOPTION_Y, delivWidth, DETAILOPTION_HEIGHT)];
    
    if(_deliveryYN.hidden == YES)
        distanceD = 0;
    
    [_packingYN setFrame:CGRectMake(DETAILOPTION_X + reservWidth + distanceR + carWidth + distanceC + parkWidth + distanceP + delivWidth + distanceD, DETAILOPTION_Y, pacWidth, DETAILOPTION_HEIGHT)];
    
    NSLog(@"옵션들 %f %f %f %f %f", _reservationYN.frame.origin.x, _cardYN.frame.origin.x, _parkingYN.frame.origin.x, _deliveryYN.frame.origin.x, _packingYN.frame.origin.x);
    // 일단 주류는 히든
    [_beerYN setHidden:YES];
    
    
    // 전부다 히든이면 옵션뷰 히든
    if(_beerYN.hidden == YES && _reservationYN.hidden == YES && _parkingYN.hidden == YES && _cardYN.hidden == YES && _deliveryYN.hidden == YES && _packingYN.hidden == YES)
    {
        
        
        [_detailOptionBtnView setHidden:YES];
    }
    else
    {
        
        _viewStartY = _viewStartY + detailOptionBtnViewHeight;
        
        [self drawUnderLine6];
    }
    
    [self drawOpeningTimeView];
    
}

// 옵션뷰 밑줄 그리기
- (void) drawUnderLine6
{
    [_scrollView addSubview:_underLine6];
    
    // 너비, 높이
    CGRect line2Viewbounds = _underLine6.bounds;
    CGFloat line2ViewWidth = CGRectGetWidth(line2Viewbounds);
    CGFloat line2ViewHeight = CGRectGetHeight(line2Viewbounds);
    
    [_underLine6 setFrame:CGRectMake(X_VALUE, _viewStartY, line2ViewWidth, line2ViewHeight)];
    _viewStartY = _viewStartY + line2ViewHeight;
}

// 영업시간 그리기
- (void) drawOpeningTimeView
{
    [_openingTimeView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 30)];
    [_scrollView addSubview:_openingTimeView];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *str = [oms.poiDetailDictionary objectForKey:@"BUSINESS_HOUR"];
    
    [_openingText setText:str];
    
    NSLog(@"영업시가아아안~ : %@", [oms.poiDetailDictionary objectForKey:@"BUSINESS_HOUR"]);
    // 정보없으면 히든
    if([oms.poiDetailDictionary objectForKey:@"BUSINESS_HOUR"] == nil)
    {
        [_openingTimeView setHidden:YES];
    }
    else {
        
        // 넘버라인 0이면 무한대로 늘어남
        // 텍스트가 라벨사이즈보다 초과되면 자동줄바꿈
        [_openingText setNumberOfLines:0];
        [_openingText setLineBreakMode:NSLineBreakByWordWrapping];
        
        // 라벨 사이즈 맞추기
        //CGSize maximumLabelSize = CGSizeMake(280,9999);
        CGSize expectedLabelSize = [_openingText.text sizeWithFont:_openingText.font
                                                 constrainedToSize:CGSizeMake(230, FLT_MAX)
                                                     lineBreakMode:_openingText.lineBreakMode];
        
        
        CGRect tempRect = _openingText.frame;
        tempRect.size.height = expectedLabelSize.height;
        _openingText.frame = tempRect;
        
        [_openingTimeView setFrame:CGRectMake(X_VALUE, _viewStartY, 320, _openingText.frame.size.height)];
        
        _viewStartY = _viewStartY + 20 + tempRect.size.height;
        
    }
    [self drawClosingTimeView];
    
}

// 휴일정보 그리기
- (void) drawClosingTimeView
{
    [_closingTimeView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 30)];
    [_scrollView addSubview:_closingTimeView];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    [_closingText setText:[oms.poiDetailDictionary objectForKey:@"HOLIDAY_INFO"]];
    
    if([oms.poiDetailDictionary objectForKey:@"HOLIDAY_INFO"] == nil)
    {
        [_closingTimeView setHidden:YES];
    }
    else {
        CGRect closingTimeViewbounds = _closingTimeView.bounds;
        CGFloat closingTimeViewHeight = CGRectGetHeight(closingTimeViewbounds);
        
        _viewStartY = _viewStartY + closingTimeViewHeight;
    }
    
    
    [self drawChargeView];
}

// 이용요금 그리기
- (void) drawChargeView
{
    [_chargeView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 50)];
    [_scrollView addSubview:_chargeView];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *charge = [oms.poiDetailDictionary objectForKey:@"CHARGE_INFO"];
    
    UILabel *chargeTex = [[UILabel alloc] init];
    
    [chargeTex setText:charge];
    [chargeTex setFont:[UIFont systemFontOfSize:13]];
    [chargeTex setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1]];
    
    [_chargeView addSubview:chargeTex];
    
    if([oms.poiDetailDictionary objectForKey:@"CHARGE_INFO"] == nil)
    {
        [_chargeView setHidden:YES];
    }
    else
    {
        [chargeTex setNumberOfLines:0];
        
        CGSize chareSize = [chargeTex.text sizeWithFont:chargeTex.font constrainedToSize:CGSizeMake(230, FLT_MAX)];
        
        [chargeTex setFrame:CGRectMake(80, 20, 230, chareSize.height)];
        
        [_chargeView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 20 + chareSize.height + 20)];
        _viewStartY = _viewStartY + 20 + chareSize.height + 20;
        
    }
    
    [chargeTex release];
    
    
    //    [_chargeText setText:charge];
    //
    //    if([oms.poiDetailDictionary objectForKey:@"CHARGE_INFO"] == nil)
    //    {
    //        [_chargeView setHidden:YES];
    //    }
    //    else {
    //
    //        // 넘버라인 0이면 무한대로 늘어남
    //        // 텍스트가 라벨사이즈보다 초과되면 자동줄바꿈
    //        [_chargeText setNumberOfLines:0];
    //        [_chargeText setLineBreakMode:NSLineBreakByWordWrapping];
    //
    //        // 라벨 사이즈 맞추기
    //        //CGSize maximumLabelSize = CGSizeMake(280,FLT_MAX);
    //        CGSize expectedLabelSize = [_chargeText.text sizeWithFont:_chargeText.font
    //                                                constrainedToSize:CGSizeMake(280, FLT_MAX)
    //                                                    lineBreakMode:_chargeText.lineBreakMode];
    //
    ////        CGRect newFrame = _chargeText.frame;
    ////        newFrame.size.height = expectedLabelSize.height;
    ////        _chargeText.frame = newFrame;
    //
    //        NSLog(@"%f", expectedLabelSize.height);
    //
    //        //    CGRect chargeViewbounds = _chargeView.bounds;
    //        //    CGFloat chargeViewHeight = CGRectGetHeight(chargeViewbounds);
    //
    //        [_chargeView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 20 + expectedLabelSize.height + 20)];
    //        _viewStartY = _viewStartY + 20 + expectedLabelSize.height + 20;
    //
    //    }
    [self checkHidden];
    //[self drawNearlyRestView];
}

// 주변식다
- (void) drawNearlyRestView
{
    //    [_nearlyRestView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 30)];
    //    [_scrollView addSubview:_nearlyRestView];
    //
    //    _viewStartY = _viewStartY + 30;
    //
    
    
    
}

// 히든체크하기
- (void) checkHidden
{
    //상세정보가 모두 히든이면 상세정보없는뷰 그리기
    if(_detailOptionBtnView.hidden == YES && _openingTimeView.hidden == YES && _closingTimeView.hidden == YES && _chargeView.hidden == YES)
    {
        int remainY = (IS_4_INCH) ? 89 : 0;
        
        _detailInfoNull = YES;
        [_detailInfoNoDataView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 66 + remainY)];
        [_scrollView addSubview:_detailInfoNoDataView];
        _viewStartY = _viewStartY + 66 + remainY;
    }
    else if (_openingTimeView.hidden == YES && _closingTimeView.hidden == YES && _chargeView.hidden == YES)
    {
        [_underLine6 setHidden:YES];
    }
    
    //    //주요정보없음, 상세정보 없음이면 블랭크POI 뷰
    if(_detailInfoNull == YES && _mainInfoNull == YES)
    {
        _mainInfoLabelView.hidden = YES;
        _underLine5.hidden = YES;
        _detailInfoNoDataView.hidden = YES;
        _mainInfoNoDataView.hidden = YES;
        _detailInfoLabelView.hidden = YES;
        
        int remainY = [[UIScreen mainScreen] bounds].size.height - 20 - 37 - 37;
        
        int blankHeight = remainY - _blankStartY;
        
        [_blankPOIlabel setFrame:CGRectMake(X_VALUE, _blankStartY, X_WIDTH, blankHeight)];
        [blankPOIlbl setFrame:CGRectMake(0, 0, 320, blankHeight)];
        [blankPOIlbl setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        
        [_scrollView addSubview:_blankPOIlabel];
        _viewStartY = _blankStartY + blankHeight;
    }
    
    float currentScrollViewHeight = [[UIScreen mainScreen] bounds].size.height - 20 - 37;
    if(_viewStartY + 37 <= currentScrollViewHeight)
    {
        //_viewStartY = _scrollView.frame.size.height - 37;
        _viewStartY = currentScrollViewHeight - 37;
    }
    
    [self drawBottomView];
}

// 하단 버튼3개 뷰
- (void) drawBottomView
{
    [_bottomView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 37)];
    [_scrollView addSubview:_bottomView];
    
    _viewStartY = _viewStartY + 37;
    
    NSLog(@"버튼뷰 좌표 : %d", _viewStartY);
    [self drawScrollHeight];
}

// 스크롤 높이
- (void) drawScrollHeight
{
    _scrollView.contentSize = CGSizeMake(X_WIDTH, _viewStartY);
}

#pragma mark -
#pragma mark 버튼액션

// 이전버튼
- (IBAction)popBtnClick:(id)sender
{
    
    //NSLog(@"%d", self.freeCalling.retainCount);
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}
// 지도버튼
- (IBAction)mapBtnClick:(id)sender
{
    
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    [oms.searchResult reset]; // 검색결과 리셋
    [oms.searchResult setUsed:YES];
    [oms.searchResult setIsCurrentLocation:NO];
    [oms.searchResult setStrLocationName:[oms.poiDetailDictionary objectForKey:@"NAME"]];
    [oms.searchResult setStrLocationAddress:[oms.poiDetailDictionary objectForKey:@"ADDR"]];

    [oms.searchResult setStrSTheme:stringValueOfDictionary(oms.searchLocalDictionary, @"LastExtendFreeCall")];
    
    Coord poiCrd = CoordMake([[oms.poiDetailDictionary objectForKey:@"X"] doubleValue], [[oms.poiDetailDictionary objectForKey:@"Y"] doubleValue]);
    
    
    double xx = poiCrd.x;
    double yy = poiCrd.y;
    
    [oms.searchResult setCoordLocationPoint:CoordMake(xx, yy)];
    
    [MainMapViewController markingSinglePOI_RenderType:MainMap_SinglePOI_Type_Normal animated:NO];
}

// 전화걸기버튼
-(void)goPhoneClick:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    
    NSString *telNum = [oms.poiDetailDictionary objectForKey:@"TEL"];
    
    [self typeChecker:1];
    [self telViewCallBtnClick:telNum];
    
}

// 무료통화 걸기
- (void)fgoPhoneClick:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
//    
//    
    NSString *telNum = [oms.poiDetailDictionary objectForKey:@"TEL"];
    [self typeChecker:1];
    [self telViewCallBtnClick:telNum];
}
// 무료통화 클릭시 뷰
- (void)fGoFreeCallClick:(id)sender
{
    [self.view addSubview:_callLinkView];
    
}
- (IBAction)keyboardShow:(id)sender
{
    [_callLinkAlertView setFrame:CGRectMake(37, 47, 246, 194)];
}
// 무료통화 걸기
- (IBAction)goFreeCallClick:(id)sender
{
    
    // 무료통화 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail/call_link"];
    
    //BOOL Check_TelNumber = [self callLinkNumberCheck:_myNumber.text];

    if([self telNumberCheck:_myNumber.text])
    {
        
        [[ServerConnector sharedServerConnection] requestCallLink:self action:@selector(finishCallLinks:) mid:@"ollehmap" caller:_myNumber.text called:_telLabel.text];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_FreeCall_ErrorInput", @"")];
    }
    
}
- (void) finishCallLinks:(id)request
{
    
    //_myNumber.text = @"";
    
    if([request finishCode] == OMSRFinishCode_Completed)
    {

        NSString *msg = (NSString *)[request userObject];
        
        NSLog(@"MSG : %@", msg);
        // 전송실패 e80, 90
        if([msg isEqualToString:@"E80"] || [msg isEqualToString:@"E90"])
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_FreeCall_SendError", @"")];
        }
        // 전송실패 e01, e10, e20, e30
        else if ([msg isEqualToString:@"E01"] || [msg isEqualToString:@"E10"] || [msg isEqualToString:@"E20"] || [msg isEqualToString:@"E30"])
        {
            TelAlertView *alert = [[TelAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Msg_FreeCall_SendError_second", @"") delegate:self cancelButtonTitle:@"유료통화" otherButtonTitles:@"통화취소", nil];
            [alert setTag:5];
            [alert show];
            [alert release];
        }
        // 전송성공
        else
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_FreeCall_SendOK", @"")];
            
            [self touchBackGround:nil];
            
//            [_callLinkAlertView setFrame:CGRectMake(37, 131, 246, 194)];
//            [_callLinkView removeFromSuperview];
        }
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_FreeCall_SendError", @"")];
    }
}
- (BOOL)telNumberCheck:(NSString *)tele
{
    NSString *expression = @"^(01[016789]{1}|02|0[3-9]{1}[0-9]{1})?[0-9]{3,4}?[0-9]{4}$";
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:tele options:0 range:NSMakeRange(0, [tele length])];
    
    if (!match)
        return FALSE;
    else
        return TRUE;
}
// 무료통화 뷰 텍스트 체크(노가다 체크)
- (BOOL)callLinkNumberCheck:(NSString *)str
{
    BOOL checkResult=NO;
    NSString *checkStr = str;
    NSNumber *checkNumber;
    
    NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    // 빈값이면 no
    if ([checkStr isEqualToString:@""] || checkStr==nil)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_FreeCall_NoInput", @"")];
        
        checkResult=NO;
    }
    else
    {
        checkNumber = [numberFormatter numberFromString:checkStr];
        ///입력이 되어있다면... 입력된 값이 숫자인지 판단한다.
        if (checkNumber == nil)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_FreeCall_ErrorInput", @"")];
            
            checkResult=NO;
        }
        else {
            // 9자리 미만이면?
            if ([checkStr length] < 9)
            {
                
                [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_FreeCall_ErrorInput", @"")];
                
                checkResult = NO;
                
                return checkResult;
            }
            
            //입력한 번호 앞 3글자만 추출한다.
            NSString *tmpFirstNum = [checkStr substringToIndex : 3];
            //우리나라 지역번호 리스트 ( 070과 핸드폰 번호 포함)
            NSArray *areaCodeArr = [[[NSArray alloc] initWithObjects:@"02", @"051", @"053", @"032", @"062", @"042", @"052", @"031", @"033",@"043", @"041", @"063", @"061", @"054", @"055", @"064", @"070", @"010", @"011", @"016", @"017", @"018", @"019", nil] autorelease];
            BOOL areaCodeCheck = NO;
            int i;
            for (i=0; i<[areaCodeArr count]; ++i)
            {
                //입력한 번호 앞 3자리가 지역번호 리스트에 있는 번호와 일치하는지 판단한다.
                if ([tmpFirstNum isEqualToString:[areaCodeArr objectAtIndex:i]])
                {
                    areaCodeCheck=YES;
                    break;
                }
            }
            
            if (areaCodeCheck)          ///검색결과 일치하면...길이를 체크한다.
            {
                int numLen = [checkStr length];
                /// 전화번호 길이가 최소 9자 이상이고 최대 11자 이하일경우
                if (numLen >= 9 && numLen <= 11)
                {
                    checkResult = YES;
                    return checkResult;
                }
                else
                {
                    // 전송 실패 팝업
                    [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_FreeCall_ErrorInput", @"")];
                    
                    checkResult = NO;
                }
            }
            //검색결과 일치하는 코드가 없을경우...
            else
            {
                // 전송 실패 팝업
                [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_FreeCall_ErrorInput", @"")];
                checkResult = NO;
            }
            
        }
    }
    
    return checkResult;
    
}

- (IBAction)touchBackGround:(id)sender;
{
    [_callLinkAlertView setFrame:CGRectMake(37, 131, 246, 194)];
    [_callLinkView removeFromSuperview];
    
}

- (void) freeCallRemoveFromSuperViewDelegate
{
    [self touchBackGround:nil];
}

// 홈페이지 버튼
- (void)goHomePageClick:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *homeURL = [oms.poiDetailDictionary objectForKey:@"URL"];
    
    [self homeViewURLBtnClick:[oms urlValidCheck:homeURL]];
    
    return;
}

#pragma mark -
#pragma mark - 확장버튼 액션
// 출발지버튼
- (void)startClick:(id)sender
{
    [self typeChecker:1];
    [self btnViewStartBtnClick:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary];
}
// 도착지버튼
- (void)destClick:(id)sender
{
    [self typeChecker:1];
    [self btnViewDestBtnClick:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary ];
}
// 위치공유 버튼
- (void)shareClick:(id)sender
{
    [self typeChecker:1];
    [self btnViewShareBtnClick];
}
// 네비버튼
- (void)naviClick:(id)sender
{
    [self typeChecker:1];
    [self btnViewNaviBtnClick:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary];
}

#pragma mark -
#pragma mark - 하단 버튼뷰 액션
// 즐겨찾기 추가 버튼
- (IBAction)favoriteClick:(id)sender
{
    //
    // 즐겨찾기 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail/favorite"];
    
    DbHelper *dh = [[[DbHelper alloc] init] autorelease];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    NSString *ujName = [oms.poiDetailDictionary objectForKey:@"UJ_NAME"];
    
    NSMutableDictionary *fdic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Local title1:[oms.poiDetailDictionary objectForKey:@"NAME"] title2:[oms ujNameSegment:ujName] title3:[NSString stringWithFormat:@"%@", stringValueOfDictionary(oms.searchLocalDictionary, @"LastExtendFreeCall")] iconType:Favorite_IconType_POI coord1x:[[oms.poiDetailDictionary objectForKey:@"X"] doubleValue] coord1y:[[oms.poiDetailDictionary objectForKey:@"Y"] doubleValue] coord2x:0 coord2y:0 coord3x:0 coord3y:0 detailType:@"MP" detailID:[oms.poiDetailDictionary objectForKey:@"POI_ID"] shapeType:stringValueOfDictionary(oms.poiDetailDictionary, @"SHAPE_TYPE") fcNm:stringValueOfDictionary(oms.poiDetailDictionary, @"FC_NM") idBgm:stringValueOfDictionary(oms.poiDetailDictionary, @"ID_BGM")];
    
    // 중복인지 체크
    if([dh favoriteValidCheck:fdic])
    {
        // ver3테스트3번버그
        NSString *favoName = _themeToDetailName;
        
        if(!favoName || [favoName isEqualToString:@""])
        {
            favoName = [oms.poiDetailDictionary objectForKey:@"NAME"];
        }
        [self typeChecker:1];
        [self bottomViewFavorite:fdic placeHolder:favoName];
        
    }
    
}
// 연락처 추가 버튼
- (IBAction)contactClick:(id)sender
{
    [self modalContact:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary];
    
}
// 정보수정 버튼
- (IBAction)modifyClick:(id)sender
{
    [self typeChecker:1];
    [self modalInfoModify:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary];
}

@end
