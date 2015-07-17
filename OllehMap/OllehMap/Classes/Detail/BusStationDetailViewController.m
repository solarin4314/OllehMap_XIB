//
//  BusStationDetailViewController.m
//  OllehMap
//
//  Created by 이제민 on 13. 4. 23..
//
//

#import "BusStationDetailViewController.h"
#import "MapContainer.h"
#import "MainMapViewController.h"

@interface BusStationDetailViewController ()

@end

@implementation BusStationDetailViewController

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
    [_bsScrollView release];
    [_mapBtn release];
    [_busStationWindow release];
    [super dealloc];
}
- (void)viewDidUnload
{
    [_mapBtn release];
    _mapBtn = nil;
    [_busStationWindow release];
    _busStationWindow = nil;
    [self setBsScrollView:nil];
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    //[_mapBtn setHidden:!_displayMapBtn];
    // 버스정류장 상세 이동 시(스택에 버스노선상세, 버정상세 뷰가 번갈아가며 쌓임) 꼬이게 되서 히든
    [_mapBtn setHidden:YES];
    [_mapBtn setEnabled:NO];

    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];

    if(_isPushBusStationAndLine == YES)
    {
        //NSLog(@"팝에서옴");
        
        NSString *stId = [[oms.pushDataBusStationArray lastObject] objectForKeyGC:@"STID"];

        [[ServerConnector sharedServerConnection] requestBusStationInfoStid:self action:@selector(busStationStartCallBack:) stId:stId];
    }
    // 아님 걍 그려
    else
    [self drawingTopView];
}
- (void) reFreshing
{
    NSString *stId = [[OllehMapStatus sharedOllehMapStatus].busStationNewDictionary objectForKeyGC:@"stid"];
    
    [[ServerConnector sharedServerConnection] requestBusStationInfoStid:self action:@selector(busStationStartCallBack:) stId:stId];
}
- (void) reDrawing
{
    for (UIView *subView in _busStationWindow.subviews)
    {
        [subView removeFromSuperview];
    }
    for (UIView *subView in _bsScrollView.subviews)
    {
        [subView removeFromSuperview];
    }
    [self drawingTopView];
}
- (void) busStationStartCallBack:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        [self reDrawing];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"%@", [OllehMapStatus sharedOllehMapStatus].busStationNewDictionary);

    
}
- (void) drawingTopView
{
    _viewStartY = 0;
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    if(_isPushBusStationAndLine == YES)
    {
        if([oms.pushDataBusStationArray count] > 0)
            [oms.pushDataBusStationArray removeLastObject];
    }
    
    
    // start
    
    
    int startX = 10;
    int startY = 16;
    
    UIView *topView = [[UIView alloc] init];
    [topView setBackgroundColor:convertHexToDecimalRGBA(@"d9", @"f4", @"ff", 1)];
    
    
    
    UILabel *stationLbl = [[UILabel alloc] init];
    
    [stationLbl setFont:[UIFont boldSystemFontOfSize:17]];
    [stationLbl setBackgroundColor:[UIColor clearColor]];
    [stationLbl setNumberOfLines:2];
    
    NSString *stationString = stringValueOfDictionary(oms.busStationNewDictionary, @"bst_NAME");
    NSString *stationUniqueId = stringValueOfDictionary(oms.busStationNewDictionary, @"arsid");
    
    if(![stationUniqueId isEqualToString:@""])
    {
            NSString *before2;
            NSString *after3;
            before2 = [stationUniqueId substringToIndex:2];
            after3 = [stationUniqueId substringFromIndex:2];
            
            stationUniqueId = [NSString stringWithFormat:@"[%@-%@]", before2, after3];

    }
    
    NSString *topViewString = [NSString stringWithFormat:@"%@ %@", stationString, stationUniqueId];
    [stationLbl setText:topViewString];
    
    
    CGSize stationSize = [stationLbl.text sizeWithFont:stationLbl.font constrainedToSize:CGSizeMake(300, FLT_MAX)];
    [stationLbl setFrame:CGRectMake(startX, startY, stationSize.width, stationSize.height)];
    [topView addSubview:stationLbl];
    [stationLbl release];
    
    
    startY += stationSize.height + 8;
    
    UILabel *add = [[UILabel alloc] init];
    [add setText:[NSString stringWithFormat:@"%@ %@ %@", stringValueOfDictionary(oms.busStationNewDictionary, @"bst_DO"), stringValueOfDictionary(oms.busStationNewDictionary, @"bst_GU"), stringValueOfDictionary(oms.busStationNewDictionary, @"bst_DONG")]];
    [add setFont:[UIFont systemFontOfSize:13]];
    [add setBackgroundColor:[UIColor clearColor]];
    CGSize addSize = [add.text sizeWithFont:add.font];
    [add setFrame:CGRectMake(startX, startY, addSize.width, addSize.height)];
    [topView addSubview:add];
    [add release];
    
    startY += addSize.height + 17;

    
    [topView setFrame:CGRectMake(0, _viewStartY, 320, startY)];
    [_busStationWindow addSubview:topView];
    
    
    _viewStartY += topView.frame.size.height;
    
    [topView release];
    [self drawUnderLine1];

}
- (void) drawUnderLine1
{
    UIImageView *underLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, _viewStartY, 320, 1)];
    [underLine1 setImage:[UIImage imageNamed:@"poi_list_line_01.png"]];
    
    [_busStationWindow addSubview:underLine1];
    
    [underLine1 release];
    
    _viewStartY += underLine1.frame.size.height;
    
    [self drawBtnView];
}
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
    [startBtn addTarget:self action:@selector(startBtnClickBS:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:startBtn];
    
    UIButton *destBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    destBtn.frame = CGRectMake(96, 9, 81, 37);
    
    [destBtn setImage:[UIImage imageNamed:@"poi_list_btn_stop.png"] forState:UIControlStateNormal];
    [destBtn addTarget:self action:@selector(destBtnClickBS:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:destBtn];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(182, 9, 61, 37);
    
    [shareBtn setImage:[UIImage imageNamed:@"poi_list_btn_share.png"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtnClickBS:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:shareBtn];
    
    UIButton *naviBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    naviBtn.frame = CGRectMake(248, 9, 61, 37);
    
    [naviBtn setImage:[UIImage imageNamed:@"poi_list_btn_navi.png"] forState:UIControlStateNormal];
    [naviBtn addTarget:self action:@selector(NaviBtnClickBS:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:naviBtn];
    
    [_busStationWindow addSubview:btnView];
    
    [btnBg release];
    [btnView release];
    
    _viewStartY += btnViewHeight;

    NSLog(@"viewStartY : %d", _viewStartY);
    
    // 네비높이 더함
    _viewStartY += 37;
    
    [_bsScrollView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, self.view.frame.size.height - _viewStartY)];
    
    NSLog(@"%@", NSStringFromCGRect(_bsScrollView.frame));
    
    [self busListDraw];
}
- (void) busListDraw
{

    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    int buslist = [[oms.busStationNewDictionary objectForKeyGC:@"buslane_LIST"] count];
    
    int busViewY = 0;
    
    NSArray *buslistArr = [oms.busStationNewDictionary objectForKeyGC:@"buslane_LIST"];
    
    for (int i=0; i<buslist; i++)
    {
        BOOL realTime1 = NO;
        BOOL realTime2 = NO;
        int second = 0;
        int minute = 0;
        int remainSecond = 0;
        
        NSDictionary *busRealTimeArr = [[buslistArr objectAtIndexGC:i] objectForKeyGC:@"currentTraffic"];
        
        UIView *busView = [[UIView alloc] init];
        
        // 버튼
        UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        // 이미지필요
        [selectBtn setBackgroundImage:[UIImage imageNamed:@"poi_busstop_list_bg_pressed.png"] forState:UIControlStateHighlighted];
        
        [selectBtn addTarget:self action:@selector(busSelecting:) forControlEvents:UIControlEventTouchUpInside];
        [busView addSubview:selectBtn];
        selectBtn.tag = [[[buslistArr objectAtIndexGC:i] objectForKeyGC:@"laneid"] intValue];
        
        UIImageView *busNumberImg = [[UIImageView alloc] init];
        NSString *numValue = [[buslistArr objectAtIndexGC:i]  objectForKeyGC:@"bl_BUSCLASS"];
        [busNumberImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", [oms getLaneIdToImgString:numValue]]]];
        [busNumberImg setFrame:CGRectMake(13, 11, 29, 18)];
        [busView addSubview:busNumberImg];
        [busNumberImg release];
        
        
        UILabel *busNumberLbl = [[UILabel alloc] init];
        NSString *busNumberStr = [[buslistArr objectAtIndexGC:i] objectForKeyGC:@"bl_BUSNO"];
        [busNumberLbl setText:busNumberStr];
        [busNumberLbl setBackgroundColor:[UIColor clearColor]];
        [busNumberLbl setFont:[UIFont boldSystemFontOfSize:15]];
        [busNumberLbl setTextAlignment:NSTextAlignmentCenter];
        
        CGSize busNumberSize = [busNumberLbl.text sizeWithFont:busNumberLbl.font constrainedToSize:CGSizeMake(FLT_MAX, 15)];
        
        
        [busNumberLbl setFrame:CGRectMake(48, 11, busNumberSize.width, 15)];
        [busView addSubview:busNumberLbl];
        [busNumberLbl release];
        
        UILabel *busCityLbl = [[UILabel alloc] init];
        int cityType = [[[buslistArr objectAtIndexGC:i] objectForKeyGC:@"bl_CITYCODE"] intValue];
        NSString *busNumberCityStr = [oms cityCodeToCityName:cityType];
        [busCityLbl setText:busNumberCityStr];
        [busCityLbl setFont:[UIFont systemFontOfSize:15]];
        [busCityLbl setBackgroundColor:[UIColor clearColor]];
        [busCityLbl setFrame:CGRectMake(48 + busNumberSize.width + 6, 11, 60, 15)];
        [busView addSubview:busCityLbl];
        [busCityLbl release];

        
        // 애로우버튼
        
        UIImageView *arrowBtn = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_btn_arrow.png"]];
        [arrowBtn setFrame:CGRectMake(298, 40, 13, 19)];
        [busView addSubview:arrowBtn];
        [arrowBtn release];
        
        
        // 종점 기점 쪼개기(arr objectAtIndexGC:0, 1)
        
        NSString *laneInfo = [[buslistArr objectAtIndexGC:i] objectForKeyGC:@"bl_LANEINFO"];
        
        NSArray *arr = [laneInfo componentsSeparatedByString:@"-"];

        // 기점화살표종점
        NSString *startLbl = [arr objectAtIndexGC:0];
        NSString *destLbl = [arr objectAtIndexGC:1];
        
        NSString *totalLbl = [NSString stringWithFormat:@"%@ ⇔ %@", startLbl, destLbl];
        
        UILabel *startDestLabel = [[UILabel alloc] init];
        [startDestLabel setNumberOfLines:0];
        [startDestLabel setBackgroundColor:[UIColor clearColor]];
        [startDestLabel setText:totalLbl];
        [startDestLabel setFont:[UIFont systemFontOfSize:13]];
        [startDestLabel setTextColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1)];
        [startDestLabel setFrame:CGRectMake(13, 36, 272, 13)];
        [busView addSubview:startDestLabel];
        [startDestLabel release];
        
        
        // 실시간 그린다
        // 첫번째 남은정류장
        UILabel *whenBefore1 = [[UILabel alloc] init];
        [whenBefore1 setBackgroundColor:[UIColor clearColor]];
        //
        [whenBefore1 setFont:[UIFont systemFontOfSize:13]];
        [whenBefore1 setTextColor:convertHexToDecimalRGBA(@"f2", @"34", @"71", 1)];
        
        int before1 = [numberValueOfDiction(busRealTimeArr, @"sectord1") intValue];
        
        // 첫번째 도착
        UILabel *whenDest1 = [[UILabel alloc] init];
        [whenDest1 setFont:[UIFont systemFontOfSize:13]];
        [whenDest1 setBackgroundColor:[UIColor clearColor]];
        [whenDest1 setFrame:CGRectMake(13, 57, 272, 13)];
        second = [numberValueOfDiction(busRealTimeArr, @"tratime1") intValue];
        
        minute = second / 60;
        remainSecond = second % 60;
        
        if(before1 <= 0)
        {
            [whenDest1 setText:@"실시간 정보가 없습니다"];
        }
        else
        {
            realTime1 = YES;
            if(minute <= 0)
            {
                [whenDest1 setText:[NSString stringWithFormat:@"약 %d초 후 도착", remainSecond]];
            }
            else
            {
                [whenDest1 setText:[NSString stringWithFormat:@"약 %d분 %d초 후 도착", minute, remainSecond]];
            }
            
        
        CGSize whenDest1Size = [whenDest1.text sizeWithFont:whenDest1.font constrainedToSize:CGSizeMake(FLT_MAX, 13)];
        [whenBefore1 setFrame:CGRectMake(whenDest1.frame.origin.x + whenDest1Size.width, whenDest1.frame.origin.y, 80, 13)];
        [whenBefore1 setText:[NSString stringWithFormat:@"(%d번째전)", [[busRealTimeArr objectForKeyGC:@"sectord1"] intValue]]];
        [busView addSubview:whenBefore1];
        

    }
        
        [whenBefore1 release];
        
        [busView addSubview:whenDest1];
        [whenDest1 release];
        
                
        // 두번째 남은정류장
        UILabel *whenBefore2 = [[UILabel alloc] init];
        [whenBefore2 setBackgroundColor:[UIColor clearColor]];
        [whenBefore2 setFont:[UIFont systemFontOfSize:13]];
        [whenBefore2 setTextColor:convertHexToDecimalRGBA(@"f2", @"34", @"71", 1)];
    
        int before2 = [numberValueOfDiction(busRealTimeArr, @"sectord2") intValue];
    
        // 두번째 도착
        UILabel *whenDest2 = [[UILabel alloc] init];
        [whenDest2 setFont:[UIFont systemFontOfSize:13]];
        [whenDest2 setBackgroundColor:[UIColor clearColor]];
        [whenDest2 setFrame:CGRectMake(13, 79, 272, 13)];
        second = [numberValueOfDiction(busRealTimeArr, @"tratime2") intValue];
        
        minute = second / 60;
        remainSecond = second % 60;
        
        if(before2 <= 0)
        {
            [whenDest2 setText:@"실시간 정보가 없습니다"];
        }
        else
        {
            realTime2 = YES;
            
            [whenDest2 setText:[NSString stringWithFormat:@"약 %d분 후 다음버스", minute]];
            
            CGSize whenDest2Size = [whenDest2.text sizeWithFont:whenDest2.font constrainedToSize:CGSizeMake(FLT_MAX, 13)];
            [whenBefore2 setFrame:CGRectMake(whenDest2.frame.origin.x + whenDest2Size.width, whenDest2.frame.origin.y, 80, 13)];
            [whenBefore2 setText:[NSString stringWithFormat:@"(%d번째전)", [[busRealTimeArr objectForKeyGC:@"sectord2"] intValue]]];


            [busView addSubview:whenBefore2];
            
            
        }
    
        [whenBefore2 release];
    
        [busView addSubview:whenDest2];
        [whenDest2 release];

        int buttonY = 0;
        if(realTime1 == NO && realTime2 == NO)
        {
            
            [whenDest2 setHidden:YES];
            
            [busView setFrame:CGRectMake(0, busViewY, 320, 81)];
            
            busViewY += 81;
            
            buttonY = 81;
        }
        else
        {
            [busView setFrame:CGRectMake(0, busViewY, 320, 98)];
            
            busViewY += 98;
            
            buttonY = 98;
        }
        [selectBtn setFrame:CGRectMake(0, 0, X_WIDTH, buttonY)];
        
        [_bsScrollView addSubview:busView];
        [busView release];
    
    // 밑줄
    UIImageView *underLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"poi_list_line_03.png"]];
    [underLine setFrame:CGRectMake(0, busViewY, 320, 1)];
    [_bsScrollView addSubview:underLine];
    [underLine release];
    busViewY += 1;
   
    }
    // 하단 버튼
    UIView *bottomView = [[UIView alloc] init];
    
    // 사이즈 작으면 버튼뷰를 스크롤뷰 아래에 붙임
    if(busViewY + 37 <= _bsScrollView.frame.size.height)
    {
        busViewY = _bsScrollView.frame.size.height - 37;
    }
    
    int btnWidth = 160;
    int btnHeight = 37;
    [bottomView setFrame:CGRectMake(X_VALUE, busViewY, X_WIDTH, btnHeight)];
    
    busViewY += btnHeight;
    
    UIButton *favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [favoriteBtn setFrame:CGRectMake(0, 0, btnWidth, btnHeight)];
    [favoriteBtn setImage:[UIImage imageNamed:@"poi_btn_01.png"] forState:UIControlStateNormal];
    [favoriteBtn addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:favoriteBtn];
    
    UIButton *infoModifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoModifyBtn setFrame:CGRectMake(btnWidth, 0, btnWidth, btnHeight)];
    [infoModifyBtn setImage:[UIImage imageNamed:@"poi_btn_02.png"] forState:UIControlStateNormal];
    [infoModifyBtn addTarget:self action:@selector(infoModifyClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:infoModifyBtn];
    
    [_bsScrollView addSubview:bottomView];
    [bottomView release];

    
    [_bsScrollView setContentSize:CGSizeMake(320, busViewY)];
    [self.view addSubview:_bsScrollView];
    
    
    scrollHeight = busViewY;
    
    // 푸시백이 아니면 최근검색 저장
    if(_isPushBusStationAndLine == NO)
        [self saveRecentSearch];
}

#pragma mark -
#pragma mark - action
- (IBAction)popBtnClick:(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

- (IBAction)reFreshBtnClick:(id)sender
{
    [self reFreshing];
}

- (IBAction)mapBtnClick:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    _isPushBusStationAndLine = YES;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:[oms.busStationNewDictionary objectForKeyGC:@"stid"] forKey:@"STID"];
    [oms.pushDataBusStationArray addObject:dic];
    
    [dic release];
    
    [oms.searchResult reset]; // 검색결과 리셋
    [oms.searchResult setUsed:YES];
    [oms.searchResult setIsCurrentLocation:NO];
    
    //NSLog(@"고유유 : %@", _uniqueId);
    
    NSString *uniqueId = stringValueOfDictionary(oms.busStationNewDictionary, @"arsid");
    
    if([uniqueId isEqualToString:@""])
    {
        [oms.searchResult setStrLocationName:[NSString stringWithFormat:@"%@", [oms.busStationNewDictionary objectForKeyGC:@"bst_NAME"]]];
    }
    else
    {
        
        
        NSString *preUni = [uniqueId substringToIndex:2];
        NSString *nextUni = [uniqueId substringFromIndex:2];
        
        [oms.searchResult setStrLocationName:[NSString stringWithFormat:@"%@ [%@-%@]", [oms.busStationNewDictionary objectForKeyGC:@"bst_NAME"], preUni, nextUni]];
    }
    [oms.searchResult setStrLocationAddress:[NSString stringWithFormat:@"%@ %@ %@",[oms.busStationNewDictionary objectForKeyGC:@"bst_DO"],[oms.busStationNewDictionary objectForKeyGC:@"bst_GU"],[oms.busStationNewDictionary objectForKeyGC:@"bst_DONG"]]];
    
    Coord poiCrd = CoordMake([[oms.busStationNewDictionary objectForKeyGC:@"bst_X"] doubleValue], [[oms.busStationNewDictionary objectForKeyGC:@"bst_Y"] doubleValue]);
    
    
    double xx = poiCrd.x;
    double yy = poiCrd.y;
    
    [oms.searchResult setCoordLocationPoint:CoordMake(xx, yy)];
    [oms.searchResult setStrID:[oms.busStationNewDictionary objectForKeyGC:@"stid"]];
    [oms.searchResult setStrType:@"TR_BUS"];
    
    [MainMapViewController markingSinglePOI_RenderType:MainMap_SinglePOI_Type_Normal animated:NO];

}
- (void)startBtnClickBS:(id)sender
{
    [self typeChecker:5];
    [self btnViewStartBtnClick:[OllehMapStatus sharedOllehMapStatus].busStationNewDictionary];
    
}
- (void)destBtnClickBS:(id)sender
{
    [self typeChecker:5];
    [self btnViewDestBtnClick:[OllehMapStatus sharedOllehMapStatus].busStationNewDictionary];
}
- (void)shareBtnClickBS:(id)sender
{
    [self typeChecker:5];
    [self btnViewShareBtnClick];
}
- (void)NaviBtnClickBS:(id)sender
{
    [self typeChecker:5];
    [self btnViewNaviBtnClick:[OllehMapStatus sharedOllehMapStatus].busStationNewDictionary];
}
- (void) favoriteClick:(id)sender
{ 
    // 즐겨찾기 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail/favorite"];
    
    DbHelper *dh = [[[DbHelper alloc] init] autorelease];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    NSString *uniqueId = stringValueOfDictionary(oms.busStationNewDictionary, @"arsid");
    if(![uniqueId isEqualToString:@""])
    {
        NSString *preUni = [uniqueId substringToIndex:2];
        NSString *nextUni = [uniqueId substringFromIndex:2];
        
        uniqueId = [NSString stringWithFormat:@"[%@-%@]", preUni, nextUni];
    }
    //NSLog(@"%@", _busStationId);
    NSString *busStationTitle = [NSString stringWithFormat:@"%@%@",
                                 [oms.busStationNewDictionary objectForKeyGC:@"bst_NAME"],
                                 uniqueId];
    
    NSMutableDictionary *fdic = [OMDatabaseConverter makeFavoriteDictionary:-1
                                                                  sortOrder:-1
                                                                   category:Favorite_Category_Public
                                                                     title1:busStationTitle
                                                                     title2:@"대중교통 > 버스정류장"
                                                                     title3:@""
                                                                   iconType:Favorite_IconType_BusStop
                                                                    coord1x:[[oms.busStationNewDictionary objectForKeyGC:@"bst_X"] doubleValue]
                                                                    coord1y:[[oms.busStationNewDictionary objectForKeyGC:@"bst_Y"] doubleValue]
                                                                    coord2x:0
                                                                    coord2y:0
                                                                    coord3x:0
                                                                    coord3y:0
                                                                 detailType:@"TR_BUS"
                                                                   detailID:[oms.busStationNewDictionary objectForKeyGC:@"stid"] shapeType:@"" fcNm:@"" idBgm:@""];
    
    if([dh favoriteValidCheck:fdic])
    {
        [self typeChecker:5];
        [self bottomViewFavorite:fdic placeHolder:busStationTitle];
    }
    
    
}
- (void) infoModifyClick:(id)sender
{
    [self typeChecker:5];
    [self modalInfoModify:[OllehMapStatus sharedOllehMapStatus].busStationNewDictionary];
    
}
- (void)busSelecting:(id)sender
{
    //
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    int index = ((UIButton *)sender).tag;
    
    //NSLog(@"버스클릭! index : %d", index);
    
    NSArray *dict = [oms.busStationNewDictionary objectForKeyGC:@"buslane_LIST"];
    
    
    for (NSDictionary *dic in dict)
    {
        
        //NSLog(@"dic %@", dic);
        // GW에 있는 딕셔너리
        if([[dic objectForKeyGC:@"laneid"] intValue] == index)
        {
            NSString *busLaneId = [dic objectForKeyGC:@"laneid"];
            
            //[OMMessageBox showAlertMessage:@"LANEID" :busLaneId];
            
            [[ServerConnector sharedServerConnection] requestBusNumberInfo:self action:@selector(finishBusNumberDetailCallBack:) laneId:busLaneId];
            
            break;
        }
        
    }
    
    
}

- (void) saveRecentSearch
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 최근리스트 저장
    
    NSMutableDictionary *busStationPOIDic = [[NSMutableDictionary alloc] init];
    
    Coord poiCrd = CoordMake([[oms.busStationNewDictionary objectForKeyGC:@"bst_X"] doubleValue], [[oms.busStationNewDictionary objectForKeyGC:@"bst_Y"] doubleValue]);
    
    double xx = poiCrd.x;
    double yy = poiCrd.y;
    
    //NSLog(@"originId : %@", _uniqueId);
    
    NSString *uId = stringValueOfDictionary(oms.busStationNewDictionary, @"arsid");
    
    // 고유아이디가 없으면  없이 저장
    if([uId isEqualToString:@""])
    {
        
    }
    else
    {
        NSString *before2;
        NSString *after3;
        NSString *busUniqueId;
        before2 = [uId substringToIndex:2];
        after3 = [uId substringFromIndex:2];
        
        busUniqueId = [NSString stringWithFormat:@"[%@-%@]", before2, after3];
        
        
        [busStationPOIDic setObject:busUniqueId forKey:@"SUBNAME"];
    }
    //NSString *add = [NSString stringWithFormat:@%@, %@, %@
    
    [busStationPOIDic setObject:[NSString stringWithFormat:@"%@",[oms.busStationNewDictionary objectForKeyGC:@"bst_NAME"]] forKey:@"NAME"];
    [busStationPOIDic setObject:@"대중교통 > 버스정류장" forKey:@"CLASSIFY"];
    [busStationPOIDic setValue:[NSNumber numberWithDouble:xx] forKey:@"X"];
    [busStationPOIDic setValue:[NSNumber numberWithDouble:yy] forKey:@"Y"];
    [busStationPOIDic setObject:@"TR_BUS" forKey:@"TYPE"];
    [busStationPOIDic setObject:stringValueOfDictionary(oms.busStationNewDictionary, @"stid") forKey:@"ID"];
    [busStationPOIDic setObject:[NSString stringWithFormat:@"%@ %@ %@", stringValueOfDictionary(oms.busStationNewDictionary,@"bst_DO"), stringValueOfDictionary(oms.busStationNewDictionary,@"bst_GU"), stringValueOfDictionary(oms.busStationNewDictionary,@"bst_DONG")] forKey:@"ADDR"];
    [busStationPOIDic setObject:[NSNumber numberWithInt:Favorite_IconType_BusStop] forKey:@"ICONTYPE"];
    
    [oms addRecentSearch:busStationPOIDic];
    [busStationPOIDic release];
    
    // 최근리스트 저장 끝
    
    
    // 최근리스트 저장 끝
}
// GW일 때
- (void)finishBusNumberDetailCallBack:(id)request
{

    if([request finishCode] == OMSRFinishCode_Completed)
    {
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        //[oms setPushPop:NO];
        
        _isPushBusStationAndLine = YES;
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        
        [dic setObject:[oms.busStationNewDictionary objectForKeyGC:@"stid"] forKey:@"STID"];
        [oms.pushDataBusStationArray addObject:dic];
        
        [dic release];
        
        
        //[[OllehMapStatus sharedOllehMapStatus] setBisOrGW:_state];
        BusNumberLineViewController *bndvc = [[BusNumberLineViewController alloc] initWithNibName:@"BusNumberLineViewController" bundle:nil];
        
        [[OMNavigationController sharedNavigationController] pushViewController:bndvc animated:NO];
        [bndvc release];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    
}

@end
