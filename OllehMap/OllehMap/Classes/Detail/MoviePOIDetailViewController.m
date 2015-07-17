//
//  MoviePOIDetailViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 6. 8..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "MoviePOIDetailViewController.h"
#import "MapContainer.h"
#import "MainMapViewController.h"

@interface MoviePOIDetailViewController ()

@end

@implementation MoviePOIDetailViewController
@synthesize themeToDetailName = _themeToDetailName;
@synthesize underLine7 = _underLine7;
@synthesize trafficView = _trafficView;

@synthesize bottomView = _bottomView;
@synthesize detailView = _detailView;
@synthesize detailOptionView = _detailOptionView;
@synthesize reservationImg = _reservationImg;
@synthesize detailTrafficLabelView = _detailTrafficLabelView;
@synthesize detailTrafficLabelBg = _detailTrafficLabelBg;
@synthesize detailLabel = _detailLabel;
@synthesize trafficLabel = _trafficLabel;
@synthesize detailBtn = _detailBtn;
@synthesize trafficBtn = _trafficBtn;
@synthesize nullMovieView = _nullMovieView;
@synthesize underLine6 = _underLine6;
@synthesize movieView = _movieView;
@synthesize movieLabelView = _movieLabelView;
@synthesize supportLabel = _supportLabel;
@synthesize homePageBtn = _homePageBtn;
@synthesize underLine5 = _underLine5;
@synthesize mainInfoLabelView = _mainInfoLabelView;
@synthesize nullMainInfoView = _nullMainInfoView;
@synthesize mainInfoView = _mainInfoView;
@synthesize notExtendLabel = _notExtendLabel;
@synthesize extendLabel = _extendLabel;
@synthesize extendBtn = _extendBtn;
@synthesize extendBtnImg = _extendBtnImg;

@synthesize scrollView = _scrollView;
@synthesize mapBtn = _mapBtn;

- (void)dealloc
{
    [_scrollView release];
    [_themeToDetailName release];
    [_mainInfoLabelView release];
    [_nullMainInfoView release];
    [_mainInfoView release];
    [_notExtendLabel release];
    [_extendLabel release];
    [_extendBtn release];
    [_extendBtnImg release];
    [_underLine5 release];
    [_movieLabelView release];
    [_supportLabel release];
    [_movieView release];
    [_homePageBtn release];
    [_nullMovieView release];
    [_underLine6 release];
    [_detailTrafficLabelView release];
    [_detailTrafficLabelBg release];
    [_detailLabel release];
    [_trafficLabel release];
    [_detailBtn release];
    [_trafficBtn release];
    [_detailOptionView release];
    [_reservationImg release];
    [_detailView release];
    [_bottomView release];
    [_trafficView release];
    [_underLine7 release];
    [_mapBtn release];
    
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setMainInfoLabelView:nil];
    [self setNullMainInfoView:nil];
    [self setMainInfoView:nil];
    [self setNotExtendLabel:nil];
    [self setExtendLabel:nil];
    [self setExtendBtn:nil];
    [self setExtendBtnImg:nil];
    [self setUnderLine5:nil];
    [self setMovieLabelView:nil];
    [self setSupportLabel:nil];
    [self setMovieView:nil];
    [self setHomePageBtn:nil];
    [self setNullMovieView:nil];
    [self setUnderLine6:nil];
    [self setDetailTrafficLabelView:nil];
    [self setDetailTrafficLabelBg:nil];
    [self setDetailLabel:nil];
    [self setTrafficLabel:nil];
    [self setDetailBtn:nil];
    [self setTrafficBtn:nil];
    [self setDetailOptionView:nil];
    [self setReservationImg:nil];
    [self setDetailView:nil];
    [self setBottomView:nil];
    [self setTrafficView:nil];
    [self setUnderLine7:nil];
    [self setMapBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [_mapBtn setHidden:NO];
    [_mapBtn setEnabled:_displayMapBtn];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    _viewStartY = GeneralStartY;
    _expend = NO;
    [self saveRecentSearch];
    
    NSLog(@"영화관poi정보 : %@", oms.poiDetailDictionary);
    
    NSString *mId = [oms.poiDetailDictionary objectForKeyGC:@"ORG_DB_ID"];
    
    
    
    NSLog(@"mId : %@", mId);
    
    [oms.movieListDictionary removeAllObjects];
    
    [[ServerConnector sharedServerConnection] requestMovieInfo:self action:@selector(finishRequestMovieInfo:) mId:(NSString *)mId];
    
    //
    // 스크롤뷰 사이즈
    //_scrollView.contentSize = CGSizeMake(X_VALUE, _viewStartY);
}
- (void) saveRecentSearch
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *ujName = [oms.poiDetailDictionary objectForKeyGC:@"UJ_NAME"];
    // 최근리스트 저장
    
    NSMutableDictionary *generalPOIDic = [NSMutableDictionary dictionary];
    
    Coord poiCrd;
    
    poiCrd = CoordMake([[oms.poiDetailDictionary objectForKeyGC:@"X"] doubleValue], [[oms.poiDetailDictionary objectForKeyGC:@"Y"] doubleValue]);
    
    double xx = poiCrd.x;
    double yy = poiCrd.y;
    NSString *tel = [oms.poiDetailDictionary objectForKeyGC:@"TEL"];
    
    if(tel == nil)
        tel = @"";
    
    @try
    {
        
        NSString *recentName = _themeToDetailName;
        
        // ver3테스트2번버그(최근검색에서도 상세이름까지 나오도록...)
        if(!recentName || [recentName isEqualToString:@""])
        {
            recentName = [oms.poiDetailDictionary objectForKey:@"NAME"];
        }
        
        [generalPOIDic setObject:recentName forKey:@"NAME"];
        [generalPOIDic setObject:[oms ujNameSegment:ujName] forKey:@"CLASSIFY"];
        [generalPOIDic setValue:[NSNumber numberWithDouble:xx] forKey:@"X"];
        [generalPOIDic setValue:[NSNumber numberWithDouble:yy] forKey:@"Y"];
        [generalPOIDic setObject:@"MV" forKey:@"TYPE"];
        [generalPOIDic setObject:[oms.poiDetailDictionary objectForKeyGC:@"POI_ID"] forKey:@"ID"];
        [generalPOIDic setObject:tel forKey:@"TEL"];
        [generalPOIDic setObject:[oms.poiDetailDictionary objectForKeyGC:@"ADDR"] forKey:@"ADDR"];
        [generalPOIDic setObject:[NSNumber numberWithInt:Favorite_IconType_POI] forKey:@"ICONTYPE"];
        
        [oms addRecentSearch:generalPOIDic];
        
    }
    @catch (NSException *exception)
    {
        [OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@", exception]];
        
    }
    // 최근리스트 저장 끝
    
}
- (void) drawTopView
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 최상단 뷰(이름, 주소, 분류, 이미지)
    
    UIView *topView = [[UIView alloc] init];
    [topView setFrame:CGRectMake(0, 0, 320, 90)];
    [topView setBackgroundColor:[UIColor colorWithRed:217.0/255.0 green:244.0/255.0 blue:255.0/255.0 alpha:1]];
    
    UIImageView *poiImg = [[UIImageView alloc] init];
    [poiImg setFrame:CGRectMake(10, 10, 70, 70)];
    [poiImg setImage:[UIImage imageNamed:@"view_no_img_box.png"]];
    
    NSString *imageUrl = [oms.poiDetailDictionary objectForKeyGC:@"IMG_URL"];
    
    
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
    
    UILabel *poiName = [[UILabel alloc] init];
    [poiName setFrame:CGRectMake(90, 16, 220, 17)];
    [poiName setText:[oms.poiDetailDictionary objectForKeyGC:@"NAME"]];
    [poiName setFont:[UIFont boldSystemFontOfSize:17]];
    [poiName setAdjustsFontSizeToFitWidth:YES];
    [poiName setNumberOfLines:1];
    [poiName setBackgroundColor:[UIColor clearColor]];
    [topView addSubview:poiName];
    [poiName release];
    
    
    UILabel *poiAdd = [[UILabel alloc] init];
    [poiAdd setFrame:CGRectMake(90, 40, 220, 13)];
    [poiAdd setText:[oms.poiDetailDictionary objectForKeyGC:@"ADDR"]];
    [poiAdd setFont:[UIFont systemFontOfSize:13]];
    [poiAdd setAdjustsFontSizeToFitWidth:YES];
    [poiAdd setNumberOfLines:1];
    [poiAdd setBackgroundColor:[UIColor clearColor]];
    [topView addSubview:poiAdd];
    [poiAdd release];
    
    UILabel *poiUj = [[UILabel alloc] init];
    [poiUj setFrame:CGRectMake(90, 60, 220, 16)];
    [poiUj setText:[oms.poiDetailDictionary objectForKeyGC:@"UJ_NAME"]];
    [poiUj setFont:[UIFont systemFontOfSize:13]];
    [poiUj setAdjustsFontSizeToFitWidth:YES];
    [poiUj setNumberOfLines:1];
    [poiUj setBackgroundColor:[UIColor clearColor]];
    [poiUj setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1]];
    [topView addSubview:poiUj];
    [poiUj release];
    
    
    // 스크롤 뷰에 상단뷰 추가
    [_scrollView addSubview:topView];
    [topView release];
    
    
    
    _viewStartY += topView.frame.size.height;
    
    [self drawUnderLine1];
    
}
// 상단뷰 밑줄
- (void) drawUnderLine1
{
    // 스크롤뷰에 밑줄뷰 추가
    
    UIImageView *underLine = [[UIImageView alloc] init];
    [underLine setFrame:CGRectMake(0, _viewStartY, 320, 1)];
    [underLine setImage:[UIImage imageNamed:@"poi_list_line_01.png"]];
    [_scrollView addSubview:underLine];
    [underLine release];
    
    _viewStartY += underLine.frame.size.height;
    
    [self drawTelView];
}

- (void) drawTelView
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    UIView *telView = [[UIView alloc] init];
    [telView setFrame:CGRectMake(0, _viewStartY, 320, 40)];
    
    // 버튼
    UIButton *telBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [telBtn setFrame:CGRectMake(0, 0, 320, 40)];
    [telBtn setBackgroundImage:[UIImage imageNamed:@"poi_busstop_list_bg_pressed.png"] forState:UIControlStateHighlighted];
    [telBtn addTarget:self action:@selector(telBtnClickMv:) forControlEvents:UIControlEventTouchUpInside];
    [telView addSubview:telBtn];
    
    // 전번이미지
    UIImageView *telImg = [[UIImageView alloc] init];
    [telImg setFrame:CGRectMake(7, 10, 20, 20)];
    [telImg setImage:[UIImage imageNamed:@"view_list_b_call.png"]];
    [telView addSubview:telImg];
    [telImg release];
    
    // 전번라벨
    UILabel *telLabel = [[UILabel alloc] init];
    [telLabel setFrame:CGRectMake(35, 13, 260, 15)];
    [telLabel setText:[oms.poiDetailDictionary objectForKeyGC:@"TEL"]];
    [telLabel setBackgroundColor:[UIColor clearColor]];
    [telLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [telLabel setTextColor:[UIColor colorWithRed:26.0/255.0 green:104.0/255.0 blue:201.0/255.0 alpha:1]];
    [telView addSubview:telLabel];
    [telLabel release];
    
    // 애로우버튼
    UIImageView *arrowImg = [[UIImageView alloc] init];
    [arrowImg setFrame:CGRectMake(303, 14, 7, 12)];
    [arrowImg setImage:[UIImage imageNamed:@"view_list_arrow.png"]];
    [telView addSubview:arrowImg];
    [arrowImg release];
    
    // 전화번호가 없으면 히든
    if([oms.poiDetailDictionary objectForKeyGC:@"TEL"] == nil)
    {
        [telView setHidden:YES];
        [telView release];
        [self drawHomePageView];
    }
    else
    {
        // 스크롤뷰에 추가
        [_scrollView addSubview:telView];
        [telView release];
        _viewStartY += telView.frame.size.height;
        
        [self drawUnderLine2];
    }
    
    // 전화번호 뷰 끝
}

-(void) drawUnderLine2
{
    // 스크롤뷰에 추가
    
    UIImageView *underLine2 = [[UIImageView alloc] init];
    [underLine2 setFrame:CGRectMake(0, _viewStartY, 320, 1)];
    [underLine2 setImage:[UIImage imageNamed:@"poi_list_line_02.png"]];
    
    
    [_scrollView addSubview:underLine2];
    
    [underLine2 release];
    _viewStartY += underLine2.frame.size.height;
    
    [self drawHomePageView];
    
}

-(void) drawHomePageView
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    UIView *homeView = [[UIView alloc] init];
    [homeView setFrame:CGRectMake(0, _viewStartY, 320, 40)];
    
    
    // 홈피버튼
    UIButton *homeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeBtn setFrame:CGRectMake(0, 0, 320, 40)];
    [homeBtn setBackgroundImage:[UIImage imageNamed:@"poi_busstop_list_bg_pressed.png"] forState:UIControlStateHighlighted];
    [homeBtn addTarget:self action:@selector(homePageBtnClickMv:) forControlEvents:UIControlEventTouchUpInside];
    [homeView addSubview:homeBtn];
    
    // 홈피이미지
    UIImageView *homeImg = [[UIImageView alloc] init];
    [homeImg setFrame:CGRectMake(7, 10, 20, 20)];
    [homeImg setImage:[UIImage imageNamed:@"view_list_address.png"]];
    [homeView addSubview:homeImg];
    [homeImg release];
    
    // 홈피라벨
    
    UILabel *homeLabel = [[UILabel alloc] init];
    [homeLabel setBackgroundColor:[UIColor clearColor]];
    // y, 높이 -3 + 3
    [homeLabel setFrame:CGRectMake(35, 10, 260, 18)];
    
    
    NSString *url = [oms.poiDetailDictionary objectForKeyGC:@"URL"];

    [homeLabel setText:[oms urlValidCheck:url]];
        
    [homeLabel setTextColor:[UIColor colorWithRed:26.0/255.0 green:104.0/255.0 blue:201.0/255.0 alpha:1]];
    [homeLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [homeView addSubview:homeLabel];
    [homeLabel release];
    
    
    
    // 홈페이지가 없으면 히든
    if([oms.poiDetailDictionary objectForKeyGC:@"URL"] == nil)
    {
        [homeView setHidden:YES];
        [homeView release];
        
        [self drawBtnView];
    }
    else
    {
        
        [_scrollView addSubview:homeView];
        [homeView release];
        //NSLog(@"viewStartY : %d", _viewStartY);
        _viewStartY += homeView.frame.size.height;
        
        [self drawUnderLine3];
    }
    
}

- (void) drawUnderLine3
{
    
    UIImageView *underLine3 = [[UIImageView alloc] init];
    [underLine3 setFrame:CGRectMake(0, _viewStartY, 320, 1)];
    [underLine3 setImage:[UIImage imageNamed:@"poi_list_line_03.png"]];
    [_scrollView addSubview:underLine3];
    [underLine3 release];
    
    _viewStartY += underLine3.frame.size.height;
    
    [self drawBtnView];
    
}

// 버튼뷰 그리기
- (void) drawBtnView
{
    // 버튼 뷰
    
    UIView *btnView = [[UIView alloc] init];
    [btnView setFrame:CGRectMake(0, _viewStartY, 320, 56)];
    
    UIImageView *btnBg = [[UIImageView alloc] init];
    [btnBg setFrame:CGRectMake(0, 0, 320, 56)];
    [btnBg setImage:[UIImage imageNamed:@"poi_list_menu_bg.png"]];
    [btnView addSubview:btnBg];
    [btnBg release];
    
    // 각 버튼
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [startBtn setFrame:CGRectMake(10, 9, 81, 37)];
    [startBtn setImage:[UIImage imageNamed:@"poi_list_btn_start.png"] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:startBtn];
    
    UIButton *destBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [destBtn setFrame:CGRectMake(96, 9, 81, 37)];
    [destBtn setImage:[UIImage imageNamed:@"poi_list_btn_stop.png"] forState:UIControlStateNormal];
    [destBtn addTarget:self action:@selector(destBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:destBtn];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setFrame:CGRectMake(182, 9, 61, 37)];
    [shareBtn setImage:[UIImage imageNamed:@"poi_list_btn_share.png"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:shareBtn];
    
    UIButton *naviBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [naviBtn setFrame:CGRectMake(248, 9, 61, 37)];
    [naviBtn setImage:[UIImage imageNamed:@"poi_list_btn_navi.png"] forState:UIControlStateNormal];
    [naviBtn addTarget:self action:@selector(naviBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:naviBtn];
    
    
    [_scrollView addSubview:btnView];
    [btnView release];
    _viewStartY += btnView.frame.size.height;
    
    _nullStartY = _viewStartY;
    
    //[self drawUnderLine4];
    [self drawMainInfoLabelView];
    // 버튼 뷰 끝
    
}

// 주요정보 라벨 그리기
- (void) drawMainInfoLabelView
{
    
    [_mainInfoLabelView setFrame:CGRectMake(X_VALUE, _viewStartY, _mainInfoLabelView.frame.size.width, _mainInfoLabelView.frame.size.height)];
    [_scrollView addSubview:_mainInfoLabelView];
    
    //OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 너비, 높이
    
    
    _viewStartY = _viewStartY + _mainInfoLabelView.frame.size.height;
    
    [self drawMainInfoView];
}

- (void) drawMainInfoView
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *rawStr = [[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"HISTORY"];
    
    NSString *refindStr = [rawStr gtm_stringByUnescapingFromHTML];
    
    [_notExtendLabel setText:refindStr];
    
    CGFloat mainInfoViewWidth = CGRectGetWidth(_mainInfoView.bounds);
    CGFloat mainInfoViewHeight = CGRectGetHeight(_mainInfoView.bounds);
    
    _mainInfoViewNotExpendWidth = mainInfoViewWidth;
    _mainInfoViewNotExpendHeight = mainInfoViewHeight;
    
    if([[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"HISTORY"] == nil)
    {
        [_nullMainInfoView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, _nullMainInfoView.frame.size.height)];
        [_scrollView addSubview:_nullMainInfoView];
        
        [_mainInfoView setHidden:YES];
        
        _viewStartY += _nullMainInfoView.frame.size.height;
        
        
    }
    else {
        [_notExtendLabel setHidden:NO];
        [_extendBtn setHidden:NO];
        [_extendBtnImg setHidden:NO];
        
        [_mainInfoView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, _mainInfoView.frame.size.height)];
        
        [_scrollView addSubview:_mainInfoView];
        
        _expend = YES;
        
        _prevViewStartY = _viewStartY;
        _viewStartY += _mainInfoView.frame.size.height;
        
    }
    
    [self drawUnderLine5];
    
}

- (IBAction)extendBtnClick:(id)sender
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    if(_expend == YES)
    {
        [_notExtendLabel setHidden:YES];
        [_extendLabel setHidden:NO];
        
        // 너비, 높이
        CGRect mainInfoViewbounds = _mainInfoView.bounds;
        CGFloat mainInfoViewWidth = CGRectGetWidth(mainInfoViewbounds);
        CGFloat mainInfoViewHeight = 0; // mainInfoViewHeight 변수에 값을 할당한뒤에 한번도 사용하지 않고 있음.. 그럴땐 0으로 초기화 :: CGRectGetHeight(mainInfoViewbounds);
        
        
        NSString *rawStr = [[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"HISTORY"];
        
        NSString *refindStr = [rawStr gtm_stringByUnescapingFromHTML];
        
        [_extendLabel setText:refindStr];
        
        [_extendLabel setNumberOfLines:0];
        [_extendLabel setLineBreakMode:NSLineBreakByWordWrapping];
        
        CGSize extendLabelSize = [_extendLabel.text sizeWithFont:_extendLabel.font constrainedToSize:CGSizeMake(280, FLT_MAX) lineBreakMode:_extendLabel.lineBreakMode];
        
        CGRect newFrame = _extendLabel.frame;
        newFrame.size.height = extendLabelSize.height + 16;
        _extendLabel.frame = newFrame;
        
        mainInfoViewHeight = newFrame.size.height + 26;
        
        [_mainInfoView setFrame:CGRectMake(X_VALUE, _prevViewStartY, mainInfoViewWidth, mainInfoViewHeight)];
        [_extendBtn setFrame:CGRectMake(X_VALUE, mainInfoViewHeight - 26, X_WIDTH, 26)];
        [_extendBtnImg setFrame:CGRectMake(153, mainInfoViewHeight - 8 - 15, 15, 8)];
        [_extendBtnImg setImage:[UIImage imageNamed:@"view_list_up_icon.png"]];
        
        _expend = NO;
        
        _viewStartY = _prevViewStartY + mainInfoViewHeight;
        
        
        
        [self drawUnderLine5];
        
    }
    else if(_expend == NO)
    {
        [_notExtendLabel setHidden:NO];
        [_extendLabel setHidden:YES];
        
        [_mainInfoView setFrame:CGRectMake(X_VALUE, _prevViewStartY, _mainInfoViewNotExpendWidth, _mainInfoViewNotExpendHeight)];
        [_extendBtn setFrame:CGRectMake(X_VALUE, 32, X_WIDTH, 24)];
        [_extendBtnImg setFrame:CGRectMake(153, 39, 15, 8)];
        [_extendBtnImg setImage:[UIImage imageNamed:@"view_list_down_icon.png"]];
        
        _expend = YES;
        
        _viewStartY = _prevViewStartY + _mainInfoViewNotExpendHeight;
        
        [self drawUnderLine5];
    }
    
    //NSLog(@"뷰스타트 : %d", _viewStartY);
    
    
    
}

// 주요정보 뷰 밑줄
- (void) drawUnderLine5
{
    [_scrollView addSubview:_underLine5];
    //NSLog(@"뷰스타트 밑줄5 : %d", _viewStartY);
    if(_expend == YES)
    {
        [_underLine5 setFrame:CGRectMake(X_VALUE, _viewStartY, _underLine5.frame.size.width, _underLine5.frame.size.height)];
        
        _viewStartY = _viewStartY + _underLine5.frame.size.height;
        
        
    }
    
    else if(_expend == NO) {
        [_underLine5 setFrame:CGRectMake(X_VALUE, _viewStartY, _underLine5.frame.size.width, _underLine5.frame.size.height)];
        _viewStartY = _viewStartY + _underLine5.frame.size.height;
        
        
    }
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    NSString *mId = [oms.poiDetailDictionary objectForKeyGC:@"ORG_DB_ID"];
    
    //NSLog(@"dddddddd : %@", oms.movieListDictionary);
    
    if([oms.movieListDictionary count] > 0)
    {
        [self drawMovieListView];
        
    }
    else {
        [[ServerConnector sharedServerConnection] requestMovieList:self action:@selector(finishRequestMovieList:) mId:(NSString *)mId];
    }
    
    
    
}

- (void)finishRequestMovieInfo:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        //OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        //NSLog(@"영화상세성공");
        //NSLog(@"영화상세 : %@", oms.movieDetailDictionary);
        
        [self drawTopView];
        
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}

- (void) finishRequestMovieList:(id)request
{
    
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        [self drawMovieListView];
        
    }
    // 오류
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    
}
- (void) drawMovieListView
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    [_movieLabelView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 35)];
    [_movieLabelView setBackgroundColor:[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1]];
    [_scrollView addSubview:_movieLabelView];
    //NSLog(@"뷰스타트상영정보라벨 : %d", _viewStartY);
    _viewStartY = _viewStartY + _movieLabelView.frame.size.height;
    
    
    NSArray *listArr = [oms.movieListDictionary objectForKeyGC:@"PlayMovieList"];
    
    if(listArr == nil)
    {
        [_supportLabel setHidden:YES];
        [_homePageBtn setHidden:YES];
        [_movieView setHidden:YES];
        [_nullMovieView setHidden:NO];
        [_nullMovieView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, _nullMovieView.frame.size.height)];
        [_scrollView addSubview:_nullMovieView];
        
        _viewStartY = _viewStartY + _nullMovieView.frame.size.height;
    }
    else
    {
        
        
        //NSLog(@"영화리스트 : %@", listArr);
        
        int imgStartY = 13;
        int labelStartY = 14;
        
        UIColor *labelColor = [UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1];
        
        for (NSMutableDictionary *dic in listArr) {
            
            //NSLog(@"딕등급 : %@", [dic objectForKeyGC:@"GRADE"]);
            //NSLog(@"딕이름 : %@", [dic objectForKeyGC:@"MNAME"]);
            
            
            UIImageView *howOld = [[UIImageView alloc] initWithFrame:CGRectMake(10, imgStartY, 18, 15)];
            
            if([[dic objectForKeyGC:@"GRADE"] intValue] == 01)
            {
                [howOld setImage:[UIImage imageNamed:@"movie_age_all.png"]];
            }
            else if ([[dic objectForKeyGC:@"GRADE"] intValue] == 02) {
                [howOld setImage:[UIImage imageNamed:@"movie_age_12.png"]];
            }
            else if ([[dic objectForKeyGC:@"GRADE"] intValue] == 03) {
                [howOld setImage:[UIImage imageNamed:@"movie_age_15.png"]];
            }
            else if ([[dic objectForKeyGC:@"GRADE"] intValue] == 04) {
                [howOld setImage:[UIImage imageNamed:@"movie_age_18.png"]];
            }
            
            imgStartY += 21;
            
            UILabel *movieName = [[UILabel alloc] initWithFrame:CGRectMake(33, labelStartY, 277, 13)];
            
            [movieName setText:[dic objectForKeyGC:@"MNAME"]];
            [movieName setFont:[UIFont systemFontOfSize:13]];
            [movieName setTextColor:labelColor];
            
            labelStartY += 21;
            
            [_movieView addSubview:howOld];
            [_movieView addSubview:movieName];
            
            [howOld release];
            [movieName release];
            
        }
        
        // 경고라벨 Y축
        int waringLabelY = labelStartY + 15;
        
        UILabel *warning = [[UILabel alloc] init];
        
        
        [warning setText:@"(상영작 정보는 실제 상영정보와 다를 수 있으며, 버튼을 선택하면 맥스무비 홈페이지로 이동합니다.)"];
        [warning setFont:[UIFont systemFontOfSize:12]];
        [warning setTextColor:labelColor];
        [warning setLineBreakMode:NSLineBreakByWordWrapping];
        [warning setNumberOfLines:0];
        
        CGSize warnigSize = [warning.text sizeWithFont:warning.font constrainedToSize:CGSizeMake(300, FLT_MAX) lineBreakMode:warning.lineBreakMode];
        
        [warning setFrame:CGRectMake(10, waringLabelY, warnigSize.width, warnigSize.height)];
        
        [_movieView addSubview:warning];
        [warning release];
        
        CGRect tempRect = _movieView.frame;
        tempRect.size.height = warning.frame.origin.y + warning.frame.size.height + 21;
        _movieView.frame = tempRect;
        
        [_movieView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, _movieView.frame.size.height)];
        
        [_scrollView addSubview:_movieView];
        
        _viewStartY = _viewStartY + _movieView.frame.size.height;
        
        
    }
    
    
    
    [self drawUnderLine6];
}

- (void) drawUnderLine6
{
    
    // 스크롤뷰에 밑줄뷰 추가
    [_scrollView addSubview:_underLine6];
    
    [_underLine6 setFrame:CGRectMake(X_VALUE, _viewStartY, _underLine6.frame.size.width, _underLine6.frame.size.height)];
    _viewStartY = _viewStartY + _underLine6.frame.size.height;
    _detailY = _viewStartY;
    _trafficY = _viewStartY;
    
    [self drawDetailTrafficLabelView];
}

- (void) drawDetailTrafficLabelView
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    if(_detailBtn.selected)
    {
        [_trafficView setHidden:YES];
        [_detailOptionView setHidden:NO];
        [_detailView setHidden:NO];
        [_detailTrafficLabelBg setImage:[UIImage imageNamed:@"poi_2tab_01.png"]];
        [_detailLabel setTextColor:[UIColor blackColor]];
        [_trafficLabel setTextColor:[UIColor colorWithRed:89.0/255.0 green:89.0/255.0 blue:89.0/255.0 alpha:1]];
        
        [_scrollView addSubview:_detailTrafficLabelView];
        [_detailTrafficLabelView setFrame:CGRectMake(X_VALUE, _detailY, _detailTrafficLabelView.frame.size.width, _detailTrafficLabelView.frame.size.height)];
        _viewStartY = _detailY + _detailTrafficLabelView.frame.size.height;
        
        //[self drawdetailOptionView];
        
        
        //NSLog(@"예약? %@", [oms.poiDetailDictionary objectForKeyGC:@"RESERVATION_YN"]);
        
        if([oms.poiDetailDictionary objectForKeyGC:@"RESERVATION_YN"] == nil)
        {
            [_detailOptionView setHidden:YES];
            [self drawdetailView];
        }
        else
        {
            [self drawOptionView];
        }
        
    }
    else if (_trafficBtn.selected)
    {
        [_detailOptionView setHidden:YES];
        [_detailView setHidden:YES];
        [_trafficView setHidden:NO];
        [_detailTrafficLabelBg setImage:[UIImage imageNamed:@"poi_2tab_02.png"]];
        [_detailLabel setTextColor:[UIColor colorWithRed:89.0/255.0 green:89.0/255.0 blue:89.0/255.0 alpha:1]];
        [_trafficLabel setTextColor:[UIColor blackColor]];
        
        [_scrollView addSubview:_detailTrafficLabelView];
        [_detailTrafficLabelView setFrame:CGRectMake(X_VALUE, _trafficY, _detailTrafficLabelView.frame.size.width, _detailTrafficLabelView.frame.size.height)];
        _viewStartY = _trafficY + _detailTrafficLabelView.frame.size.height;
        
        [self drawTrafficView];
    }
    
    
    
    //[self drawScrollView];
}

-(void) drawOptionView
{
    
    // 리턴이 예약밖에 안옴....카드, 주차 이런거 안옴...
    [_scrollView addSubview:_detailOptionView];
    [_detailOptionView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, _detailOptionView.frame.size.height)];
    
    _viewStartY = _viewStartY + _detailOptionView.frame.size.height;
    
    [self drawUnderLine7];
}

-(void) drawUnderLine7
{
    [_scrollView addSubview:_underLine7];
    [_underLine7 setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, _underLine7.frame.size.height)];
    
    _viewStartY += _underLine7.frame.size.height;
    
    [self drawdetailView];
}

//상세정보 그려봄
-(void) drawdetailView
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    //제목라벨정의(폰트13, x:10, width:64, height:13)
    UIFont *labFont = [UIFont boldSystemFontOfSize:13];
    int lblX = 10;
    int lblWidth = 64;
    int lblHeight = 13;
    
    //내용라벨(글씨색, 폰트13, x:92, width:218, height = 13)
    UIColor *contentColor = [UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1];
    UIFont *contentFont = [UIFont systemFontOfSize:13];
    
    int contentX = 92;
    int contentWidth = 218;
    int contentHeight = 13;
    
    // 라벨 처음 Y축
    int startY = 14;
    // 라벨사이의 간격
    int tempHeight = 40;
    
    //규모정보[ 제목 : (10, 14, 64, 13 고정) 내용 : (92, 14, 218, 13)]
    UILabel *scaleInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(lblX, 14, lblWidth, lblHeight)];
    [scaleInfoLabel setText:@"규모정보"];
    [scaleInfoLabel setFont:labFont];
    
    UILabel *scaleInfo = [[UILabel alloc] initWithFrame:CGRectMake(contentX, 14, contentWidth, contentHeight)];
    [scaleInfo setText:@"1"];
    [scaleInfo setFont:contentFont];
    [scaleInfo setTextColor:contentColor];
    
    // 널이면 규모정보 라벨 히든
    //    if([scaleInfo.text isEqualToString:@"1"])
    //    {
    [scaleInfoLabel setHidden:YES];
    [scaleInfo setHidden:YES];
    
    //    }
    //    // 아니면 y축은 간격만큼 증가
    //    else {
    //        startY += tempHeight;
    //    }
    
    // 실시간예매[ 제목 : (10, 54, 64, 13 고정) 내용 : (92, 54, 218, 13)]
    UILabel *realTimeLabel = [[UILabel alloc] init];
    [realTimeLabel setText:@"실시간예매"];
    [realTimeLabel setFont:labFont];
    CGSize sizeRealTimeLabel = [realTimeLabel.text sizeWithFont:realTimeLabel.font constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX)];
    [realTimeLabel setFrame:CGRectMake(lblX, startY, sizeRealTimeLabel.width, lblHeight)];
    
    UILabel *realTime = [[UILabel alloc] initWithFrame:CGRectMake(contentX, startY, contentWidth, contentHeight)];
    
    // T 이면 실시간예매 가능
    if([[[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"IS_REALTIME"] isEqualToString:@"T"])
    {
        [realTime setText:@"가능"];
        [realTime setFont:contentFont];
        [realTime setTextColor:contentColor];
        
        startY += tempHeight;
    }
    // Y이면 불가능
    else if([[[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"IS_REALTIME"] isEqualToString:@"F"])
    {
        [realTime setText:@"불가능"];
        [realTime setFont:contentFont];
        [realTime setTextColor:contentColor];
        
        startY += tempHeight;
    }
    
    // 그 외의 값이 오면 히든
    else {
        [realTimeLabel setHidden:YES];
        [realTime setHidden:YES];
    }
    
    // 예매취소[ 제목 : (10, 94, 64, 13 고정) 내용 : (92, 94, 218, 13)]
    UILabel *cancelReservLabel = [[UILabel alloc] initWithFrame:CGRectMake(lblX, startY, lblWidth, lblHeight)];
    [cancelReservLabel setText:@"예매취소"];
    [cancelReservLabel setFont:labFont];
    
    UILabel *cancelReserv = [[UILabel alloc] initWithFrame:CGRectMake(contentX, startY, contentWidth, contentHeight)];
    NSString *cancelTime = [[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"RCTTIME"];
    [cancelReserv setText:[NSString stringWithFormat:@"%@ %@ %@", @"상영" ,cancelTime, @"까지"]];
    [cancelReserv setFont:contentFont];
    [cancelReserv setTextColor:contentColor];
    
    // 비었으면 히든 아니면 그대로 출력
    if([[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"RCTTIME"] == nil)
    {
        [cancelReservLabel setHidden:YES];
        [cancelReserv setHidden:YES];
    }
    else
    {
        startY += tempHeight;
    }
    
    // 좌석지정[ 제목 : (10, 134, 64, 13 고정) 내용 : (92, 134, 218, 13)]
    UILabel *selectSeatLabel = [[UILabel alloc] initWithFrame:CGRectMake(lblX, startY, lblWidth, lblHeight)];
    [selectSeatLabel setText:@"좌석지정"];
    [selectSeatLabel setFont:labFont];
    
    UILabel *selectSeat = [[UILabel alloc] initWithFrame:CGRectMake(contentX, startY, contentWidth, contentHeight)];
    
    // Y이면 좌석지정가능, N이면 불가, 그외는 히든
    if([[[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"SELSEAT_YN"] isEqualToString:@"Y"])
    {
        [selectSeat setText:@"가능"];
        [selectSeat setFont:contentFont];
        [selectSeat setTextColor:contentColor];
        startY += tempHeight;
    }
    else if([[[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"SELSEAT_YN"] isEqualToString:@"N"])
    {
        [selectSeat setText:@"불가능"];
        [selectSeat setFont:contentFont];
        [selectSeat setTextColor:contentColor];
        startY += tempHeight;
    }
    else
    {
        [selectSeatLabel setHidden:YES];
        [selectSeat setHidden:YES];
        startY += tempHeight;
    }
    
    // startY는 상세정보뷰의 높이가 됨
    
    // 뷰에 추가
    [_detailView addSubview:scaleInfoLabel];
    [_detailView addSubview:scaleInfo];
    [_detailView addSubview:realTimeLabel];
    [_detailView addSubview:realTime];
    [_detailView addSubview:cancelReservLabel];
    [_detailView addSubview:cancelReserv];
    [_detailView addSubview:selectSeatLabel];
    [_detailView addSubview:selectSeat];
    // 릴리즈
    [scaleInfoLabel release];
    [scaleInfo release];
    [realTimeLabel release];
    [realTime release];
    [cancelReservLabel release];
    [cancelReserv release];
    [selectSeatLabel release];
    [selectSeat release];
    // 스크롤뷰에 상세뷰 추가
    [_scrollView addSubview:_detailView];
    
    //NSLog(@"startY = %d", startY);
    
    // 상세정보내용 없나?(54이면 아무것도 출력안됨)
    if(startY == 54)
    {
        [_detailView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 80)];
        NSLog(@"없음굿");
        
        UILabel *nodataLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_VALUE, 33, X_WIDTH, 13)];
        [nodataLabel setText:@"등록된 정보가 없습니다"];
        [nodataLabel setFont:[UIFont systemFontOfSize:13]];
        [nodataLabel setTextAlignment:NSTextAlignmentCenter];
        [nodataLabel setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1]];
        [_detailView addSubview:nodataLabel];
        [nodataLabel release];
        
    }
    // 내용있으면
    else
    {
        [_detailView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, startY)];
    }
    
    _viewStartY += _detailView.frame.size.height;
    
    [self hiddenCheck];
    
    
}
// 교통정보 그리기
- (void) drawTrafficView
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    //    NSLog(@"버스정보 : %@", [[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"BUS"]);
    //    NSLog(@"지하철정보 : %@", [[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"SUBWAY"]);
    // 제목
    int startX = 10;
    int startY = 14;
    
    int labelWidth = 52;
    int labelHeight = 13;
    
    UIFont *lblFont = [UIFont boldSystemFontOfSize:13];
    
    // 내용
    int contentX = 80;
    int contentWidth = 230;
    
    // 간격
    int tempHeight = 27;
    int lastHeight = 19;
    
    // 데이터없을 때
    int trafficNodataViewHeight = 80;
    
    UIColor *contentColor = [UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1];
    UIFont *contentFont = [UIFont systemFontOfSize:13];
    
    if([[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"BUS"] == nil && [[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"SUBWAY"] == nil)
    {
        UILabel *trafficNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_VALUE, 33, X_WIDTH, 13)];
        [trafficNoLabel setText:@"등록된 정보가 없습니다"];
        [trafficNoLabel setFont:[UIFont systemFontOfSize:13]];
        [trafficNoLabel setTextAlignment:NSTextAlignmentCenter];
        [trafficNoLabel setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1]];
        [_trafficView addSubview:trafficNoLabel];
        [trafficNoLabel release];
        
        [_trafficView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, trafficNodataViewHeight)];
        [_scrollView addSubview:_trafficView];
        
        
        _viewStartY += trafficNodataViewHeight;
        
    }
    else
    {
        
        
        UILabel *subway = [[UILabel alloc] initWithFrame:CGRectMake(startX, startY, labelWidth, labelHeight)];
        [subway setText:@"지하철"];
        [subway setFont:lblFont];
        
        UILabel *subwayContent = [[UILabel alloc] init];
        
        NSString *rawStr1 = [[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"SUBWAY"];
        
        NSString *refindStr1 = [rawStr1 gtm_stringByUnescapingFromHTML];
        
        [subwayContent setText:refindStr1];
        [subwayContent setTextColor:contentColor];
        [subwayContent setFont:contentFont];
        //[subwayContent setBackgroundColor:[UIColor redColor]];
        [subwayContent setNumberOfLines:0];
        [subwayContent setLineBreakMode:NSLineBreakByWordWrapping];
        
        CGSize subwaySize = [subwayContent.text sizeWithFont:subwayContent.font constrainedToSize:CGSizeMake(contentWidth, FLT_MAX) lineBreakMode:subwayContent.lineBreakMode];
        
        [subwayContent setFrame:CGRectMake(contentX, startY, subwaySize.width, subwaySize.height)];
        
        if([rawStr1 isEqualToString:@""])
        {
            NSLog(@"지하철업서");
            
            [subway setHidden:YES];
        }
        else
        {
            startY = subwaySize.height + tempHeight;
        }
        
        UILabel *bus = [[UILabel alloc] initWithFrame:CGRectMake(startX, startY, labelWidth, labelHeight)];
        [bus setText:@"버스노선"];
        [bus setFont:lblFont];
        
        UILabel *busContent = [[UILabel alloc] init];
        
        NSString *rawStr = [[[oms.movieDetailDictionary objectForKeyGC:@"TheaterDetail"] objectAtIndexGC:0] objectForKeyGC:@"BUS"];
        
        NSString *refindStr = [rawStr gtm_stringByUnescapingFromHTML];
        [busContent setText:refindStr];
        [busContent setTextColor:contentColor];
        [busContent setFont:contentFont];
        [busContent setNumberOfLines:0];
        [busContent setLineBreakMode:NSLineBreakByWordWrapping];
        
        CGSize busSize = [busContent.text sizeWithFont:subwayContent.font constrainedToSize:CGSizeMake(contentWidth, FLT_MAX) lineBreakMode:busContent.lineBreakMode];
        
        [busContent setFrame:CGRectMake(contentX, startY, busSize.width, busSize.height)];
        
        
        
        if([rawStr isEqualToString:@""])
        {
            NSLog(@"버스업서");
            
            [bus setHidden:YES];
            
        }
        else
        {
            startY += busSize.height + lastHeight;
        }
        
        if(bus.hidden == YES && subway.hidden == YES)
        {
            UILabel *nullLbl = [[UILabel alloc] init];
            [nullLbl setFrame:CGRectMake(0, 0, 320, 80)];
            [nullLbl setText:@"등록된 정보가 없습니다"];
            [nullLbl setTextAlignment:NSTextAlignmentCenter];
            [nullLbl setFont:[UIFont systemFontOfSize:13]];
            [nullLbl setTextColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1)];
            
            [_trafficView addSubview:nullLbl];
            
            [nullLbl release];
            startY = 80;
            
        }
        else
        {
            
            [_trafficView addSubview:subway];
            [_trafficView addSubview:subwayContent];
            [_trafficView addSubview:bus];
            [_trafficView addSubview:busContent];
        }
        [subway release];
        [subwayContent release];
        [bus release];
        [busContent release];
        
        [_scrollView addSubview:_trafficView];
        [_trafficView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, startY)];
        
        _viewStartY = _viewStartY + startY;
    }
    [self hiddenCheck];
    
}
// 히든체크
- (void) hiddenCheck
{
    if(_movieView.hidden == YES && _mainInfoView.hidden == YES)
    {
        [_mainInfoLabelView setHidden:YES];
        [_nullMainInfoView setHidden:YES];
        [_movieLabelView setHidden:YES];
        [_nullMovieView setHidden:YES];
        [_underLine5 setHidden:YES];
        [_underLine6 setHidden:YES];
        [_detailTrafficLabelView setHidden:YES];
        [_detailView setHidden:YES];
        
        int allNullHeight = self.view.frame.size.height -_nullStartY-37-37;
        UIView *allNull = [[UIView alloc] init];
        //[allNull setBackgroundColor:[UIColor redColor]];
        [allNull setFrame:CGRectMake(0, _nullStartY, 320, allNullHeight)];
        
        UILabel *allNullLbl = [[UILabel alloc] init];
        [allNullLbl setFrame:CGRectMake(0, (allNullHeight / 2) - 6, 320, 13)];
        [allNullLbl setText:@"등록된 정보가 없습니다"];
        [allNullLbl setTextAlignment:NSTextAlignmentCenter];
        [allNullLbl setFont:[UIFont systemFontOfSize:13]];
        [allNullLbl setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1]];
        //[allNullLbl setBackgroundColor:[UIColor blueColor]];
        
        [allNull addSubview:allNullLbl];
        
        [allNullLbl release];
        
        [_scrollView addSubview:allNull];
        
        [allNull release];
        
        _viewStartY = _nullStartY + allNullHeight;
    }
    [self drawBottomView];
    
}
// 최하단 버튼
- (void) drawBottomView
{
    
    [_scrollView addSubview:_bottomView];
    [_bottomView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, _bottomView.frame.size.height)];
    
    _viewStartY = _viewStartY + _bottomView.frame.size.height;
    
    [self drawScrollView];
    
}
// 스크롤뷰 사이즈
- (void) drawScrollView
{
    _scrollView.contentSize = CGSizeMake(X_VALUE, _viewStartY);
}

- (IBAction)popBtnClick:(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}
// 지도버튼
- (IBAction)mapBtnClick:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    [oms.searchResult reset]; // 검색결과 리셋
    [oms.searchResult setUsed:YES];
    [oms.searchResult setIsCurrentLocation:NO];
    [oms.searchResult setStrLocationName:[oms.poiDetailDictionary objectForKeyGC:@"NAME"]];
    [oms.searchResult setStrLocationAddress:[oms.poiDetailDictionary objectForKeyGC:@"ADDR"]];
    
    Coord poiCrd = CoordMake([[oms.poiDetailDictionary objectForKeyGC:@"X"] doubleValue], [[oms.poiDetailDictionary objectForKeyGC:@"Y"] doubleValue]);
    
    
    double xx = poiCrd.x;
    double yy = poiCrd.y;
    
    [oms.searchResult setCoordLocationPoint:CoordMake(xx, yy)];
    
    // SinglePOI 렌더링
    [MainMapViewController markingSinglePOI_RenderType:MainMap_SinglePOI_Type_Normal animated:NO];
}

- (void)telBtnClickMv:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];

    NSString *telNum = [oms.poiDetailDictionary objectForKeyGC:@"TEL"];
    
    [self typeChecker:2];
    [self telViewCallBtnClick:telNum];
}
- (void)homePageBtnClickMv:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    
    NSString *homeURL = [oms.poiDetailDictionary objectForKeyGC:@"URL"];
    
    [self typeChecker:2];
    [self homeViewURLBtnClick:[oms urlValidCheck:homeURL]];
    
    return;
    HomeAlertView *alert = [[HomeAlertView alloc] initWithTitle:homeURL message:@"웹페이지로 이동하시겠습니까?" delegate:self cancelButtonTitle:@"아니오" otherButtonTitles:@"예", nil];
    [alert setTag:2];
    [alert show];
    [alert release];
}
- (void)startBtnClick:(id)sender
{
    [self typeChecker:2];
    [self btnViewStartBtnClick:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary];
}

- (void)destBtnClick:(id)sender
{
    [self typeChecker:2];
    [self btnViewDestBtnClick:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary ];
  
}

- (void)shareBtnClick:(id)sender
{
    [self typeChecker:2];
    [self btnViewShareBtnClick];
}
- (void)naviBtnClick:(id)sender
{
    [self typeChecker:2];
    [self btnViewNaviBtnClick:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary ];
}

- (IBAction)movieHomepageBtnClick:(id)sender
{
    HomeAlertView *alert = [[HomeAlertView alloc] initWithTitle:@"http://m.maxmovie.com" message:@"홈페이지로 이동하시겠습니까?" delegate:self cancelButtonTitle:@"아니오" otherButtonTitles:@"예", nil];
    [alert setTag:3];
    [alert show];
    [alert release];
}
- (IBAction)detailBtnClick:(id)sender
{
    [_detailBtn setSelected:YES];
    [_trafficBtn setSelected:NO];
    [self drawDetailTrafficLabelView];
}

- (IBAction)trafficBtnClick:(id)sender
{
    [_trafficBtn setSelected:YES];
    [_detailBtn setSelected:NO];
    [self drawDetailTrafficLabelView];
}

- (IBAction)favoriteBtnClick:(id)sender
{
    
    // 즐겨찾기 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail/favorite"];
    
    DbHelper *dh = [[[DbHelper alloc] init] autorelease];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    NSString *ujName = [oms.poiDetailDictionary objectForKeyGC:@"UJ_NAME"];
    
    NSMutableDictionary *fdic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Local title1:[oms.poiDetailDictionary objectForKeyGC:@"NAME"] title2:[oms ujNameSegment:ujName] title3:@"" iconType:Favorite_IconType_POI coord1x:[[oms.poiDetailDictionary objectForKeyGC:@"X"] doubleValue] coord1y:[[oms.poiDetailDictionary objectForKeyGC:@"Y"] doubleValue] coord2x:0 coord2y:0 coord3x:0 coord3y:0 detailType:@"MV" detailID:[oms.poiDetailDictionary objectForKeyGC:@"POI_ID"] shapeType:@"" fcNm:@"" idBgm:@""];
    
    if([dh favoriteValidCheck:fdic])
    {
        // ver3테스트3번버그
        NSString *favoName = _themeToDetailName;
        if(!favoName || [favoName isEqualToString:@""])
        {
            favoName = [oms.poiDetailDictionary objectForKey:@"NAME"];
        }
        [self typeChecker:2];
        [self bottomViewFavorite:fdic placeHolder:favoName];
        
    }

}

- (IBAction)contactBtnClick:(id)sender
{
    [self modalContact:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary];
}
- (IBAction)infoModifyAskBtnClick:(id)sender
{
    [self typeChecker:2];
    [self modalInfoModify:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary];

}

@end