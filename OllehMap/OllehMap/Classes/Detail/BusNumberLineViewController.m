//
//  BusNumberLineViewController.m
//  OllehMap
//
//  Created by 이제민 on 13. 4. 24..
//
//

#import "BusNumberLineViewController.h"
#import "MainMapViewController.h"
#import "MapContainer.h"

@interface BusNumberLineViewController ()

@end

@implementation BusNumberLineViewController
@synthesize busWhereView = _busWhereView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _busStationList = [[UITableView alloc] init];
        [_busStationList setAutoresizingMask:UIViewAutoresizingFlexibleHeight + UIViewAutoresizingFlexibleLeftMargin];
        [_busStationList setDelegate:self];
        [_busStationList setDataSource:self];

    }
    return self;
}
- (void)dealloc
{
    [_mapBtn release];
    [_busNumberWindow release];
    [_busStationList release];
    [_busWhereView release];
    [super dealloc];
}
- (void)viewDidUnload
{
    [_mapBtn release];
    _mapBtn = nil;
    [_busNumberWindow release];
    _busNumberWindow = nil;
    [self setBusWhereView:nil];
    [super viewDidUnload];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"bus : %@", [OllehMapStatus sharedOllehMapStatus].busNumberNewDictionary);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 위치서비스 활성화 (내주변 정류장 찾기 위해서..)
    [[MapContainer sharedMapContainer_Main].kmap restartUserLocationTracing];
    
    //NSLog(@"팝에서 왔는가? %s", _isPushBusStationAndLine ? "true" : "false");
    
    [_busNumberWindow setFrame:CGRectMake(0, 37, 320, [[UIScreen mainScreen] bounds].size.height - 20 - 37)];
    
    // 팝에서 왔으면 다시 그려
    if(_isPushBusStationAndLine == YES)
    {
        NSString *laneId = [[oms.pushDataBusNumberArray lastObject] objectForKeyGC:@"LANEID"];
        [[ServerConnector sharedServerConnection] requestBusNumberInfo:self action:@selector(busNumberStartCallBack:) laneId:laneId];
    }
    else
        [self drawingTop];
}
- (void) busStationStartCallBack:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        [self reDraw];
        
        [self drawingTop];
    }
    else
    {
        
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}
- (void) drawingTop
{
    _viewStartY = 0;
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    UIColor *labelBg = [UIColor clearColor];
    UIFont *labelFont = [UIFont systemFontOfSize:13];
    
    UIView *topView = [[UIView alloc] init];
    
    //버스종류
    UIImageView *busNumerImg = [[UIImageView alloc] init];
    NSString *busNumValue = [oms.busNumberNewDictionary objectForKeyGC:@"bl_BUSCLASS"];
    [busNumerImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", [oms getLaneIdToImgString:busNumValue]]]];
    
    int topViewTopY = 14;
    int busNumberImgWidth = 29;
    
    [busNumerImg setFrame:CGRectMake(10, topViewTopY, busNumberImgWidth, 18)];
    [topView addSubview:busNumerImg];
    [busNumerImg release];
    
    // 버스번호
    UILabel *busNumer = [[UILabel alloc] init];
    
    NSString *busStr = [oms.busNumberNewDictionary objectForKeyGC:@"bl_BUSNO"];
    
    [busNumer setText:busStr];
    
    [busNumer setFont:[UIFont boldSystemFontOfSize:17]];
    [busNumer setBackgroundColor:labelBg];
    
    CGSize busStrSize = [busNumer.text sizeWithFont:busNumer.font constrainedToSize:CGSizeMake(FLT_MAX, 18)];
    
    [busNumer setFrame:CGRectMake(10 + busNumberImgWidth + 8, topViewTopY, busStrSize.width, 18)];
    
    [topView addSubview:busNumer];
    [busNumer release];
    
    // 도시
    UILabel *cityLbl = [[UILabel alloc] init];
    
    NSInteger citycode2 = [[oms.busNumberNewDictionary objectForKeyGC:@"bl_CITYCODE"] intValue];
    NSString *cityname = [oms cityCodeToCityName:citycode2];
    
    int omsCityCode = 0;
    
    if(citycode2 == 1000)
    {
        omsCityCode = 1000;
    }
    else if(citycode2 > 1000 && citycode2 < 1311)
    {
        omsCityCode = 2000;
    }
    else
    {
        cityname = @"";
    }
    
    [cityLbl setText:cityname];
    [cityLbl setFont:[UIFont systemFontOfSize:17]];
    [cityLbl setBackgroundColor:[UIColor clearColor]];
    [cityLbl setFrame:CGRectMake(10 + busNumberImgWidth + 8 + busStrSize.width + 8, topViewTopY, 100, 18)];
    
    [topView addSubview:cityLbl];
    [cityLbl release];
    
    NSString *laneInfo = [oms.busNumberNewDictionary objectForKeyGC:@"bl_LANEINFO"];
    NSArray *arr = [laneInfo componentsSeparatedByString:@"-"];
    
    // 기점화살표종점
    
    NSString *startLbl = [arr objectAtIndexGC:0];
    NSString *destLbl = [arr objectAtIndexGC:1];
    
    // 물결적용
    NSString *totalLbl = [NSString stringWithFormat:@"%@ ⇔ %@", startLbl, destLbl];
    
    UILabel *startDestLabel = [[UILabel alloc] init];
    [startDestLabel setBackgroundColor:labelBg];
    [startDestLabel setText:totalLbl];
    [startDestLabel setFont:labelFont];
    [startDestLabel setFrame:CGRectMake(10, 42, 300, 13)];
    
    [topView addSubview:startDestLabel];
    [startDestLabel release];
    
    //운행라벨
    UILabel *runLabel = [[UILabel alloc] init];
    [runLabel setText:@"운행"];
    [runLabel setBackgroundColor:labelBg];
    [runLabel setFont:labelFont];
    
    CGSize runLabelSize = [runLabel.text sizeWithFont:runLabel.font];
    [runLabel setFrame:CGRectMake(10, 63, runLabelSize.width, 13)];
    
    [topView addSubview:runLabel];
    [runLabel release];
    
    //운행시간
    UILabel *runTime = [[UILabel alloc] init];
    
    NSString *firstTime = [oms.busNumberNewDictionary objectForKeyGC:@"bl_FIRSTTIME"];
    NSString *lastTime = [oms.busNumberNewDictionary objectForKeyGC:@"bl_LASTTIME"];
    
    [runTime setText:[NSString stringWithFormat:@" %@~%@", firstTime, lastTime]];
    [runTime setBackgroundColor:labelBg];
    [runTime setFont:[UIFont systemFontOfSize:13]];
    [runTime setTextColor:[UIColor colorWithRed:10.0/255.0 green:142.0/255.0 blue:184.0/255.0 alpha:1]];
    
    CGSize runTimeSize = [runTime.text sizeWithFont:runTime.font];
    [runTime setFrame:CGRectMake(10+runLabelSize.width, 63, runTimeSize.width, 13)];
    
    [topView addSubview:runTime];
    [runTime release];
    
    //세그먼트2
    
    int segment2Width = 15;
    
    UIImageView *segment2 = [[UIImageView alloc] init];
    [segment2 setImage:[UIImage imageNamed:@"info_text_line_02.png"]];
    [segment2 setFrame:CGRectMake(10+runLabelSize.width+runTimeSize.width, 63, segment2Width, 13)];
    
    [topView addSubview:segment2];
    [segment2 release];
    
    // 배차라벨
    UILabel *timePadding = [[UILabel alloc] init];
    [timePadding setText:@"배차"];
    [timePadding setFont:[UIFont systemFontOfSize:13]];
    [timePadding setBackgroundColor:labelBg];
    
    CGSize timePaddingSize = [timePadding.text sizeWithFont:timePadding.font];
    [timePadding setFrame:CGRectMake(10+runLabelSize.width+runTimeSize.width+segment2Width, 63, timePaddingSize.width, 13)];
    
    [topView addSubview:timePadding];
    [timePadding release];
    
    //배차시간
    UILabel *timePaddingTime = [[UILabel alloc] init];
    
    NSString *interval = [oms.busNumberNewDictionary objectForKeyGC:@"bl_BUSINTERVAL"];
    
    [timePaddingTime setText:[NSString stringWithFormat:@" %@분", interval]];
    [timePaddingTime setFont:labelFont];
    [timePaddingTime setTextColor:[UIColor colorWithRed:10.0/255.0 green:142.0/255.0 blue:184.0/255.0 alpha:1]];
    [timePaddingTime setBackgroundColor:labelBg];
    
    CGSize timePaddingTimeSize = [timePaddingTime.text sizeWithFont:timePaddingTime.font];
    
    [timePaddingTime setFrame:CGRectMake(10+runLabelSize.width+runTimeSize.width+segment2Width+timePaddingSize.width, 63, timePaddingTimeSize.width, 13)];
    [topView addSubview:timePaddingTime];
    [timePaddingTime release];
    
    [topView setFrame:CGRectMake(X_VALUE, _viewStartY, X_WIDTH, 90)];
    [topView setBackgroundColor:[UIColor colorWithRed:217.0/255.0 green:244.0/255.0 blue:255.0/255.0 alpha:1]];
    
    [_busNumberWindow addSubview:topView];
    [topView release];
    
    _viewStartY += 90;

    [self drawUnderLine1];
}
- (void) drawUnderLine1
{
    UIImageView *underLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, _viewStartY, 320, 1)];
    [underLine1 setImage:[UIImage imageNamed:@"poi_list_line_01.png"]];
    
    [_busNumberWindow addSubview:underLine1];
    [underLine1 release];
    
    _viewStartY = _viewStartY + underLine1.frame.size.height;
    
    [self drawNearBtn];
    
}
- (void) drawNearBtn
{
    UIView *nearBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, _viewStartY, 320, 55)];
    [nearBtnView setBackgroundColor:[UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1]];
    
    UIButton *nearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nearBtn setFrame:CGRectMake(10, 9, 300, 37)];
    [nearBtn setImage:[UIImage imageNamed:@"poi_btn_bus.png"] forState:UIControlStateNormal];
    [nearBtn addTarget:self action:@selector(myNearBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [nearBtnView addSubview:nearBtn];
    [_busNumberWindow addSubview:nearBtnView];
    [nearBtnView release];
    _viewStartY += 55;
    
    [self drawUnderLine2];
}

- (void) drawUnderLine2
{
    UIImageView *underLine2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, _viewStartY, 320, 1)];
    [underLine2 setImage:[UIImage imageNamed:@"poi_list_line_03.png"]];
    [_busNumberWindow addSubview:underLine2];
    [underLine2 release];
    
    
    _viewStartY += 1;
    
    NSLog(@"viewStartY : %d", _viewStartY);
    
    // 네비높이 +
    _viewStartY += 37;

    [self drawingList];
}
- (void) drawingList
{
    
    [_busStationList setFrame:CGRectMake(0, _viewStartY, 320, self.view.frame.size.height - _viewStartY)];
    [self.view addSubview:_busStationList];
    [_busWhereView setFrame:CGRectMake(170, 0, 150, _busStationList.contentSize.height)];
    [_busStationList addSubview:_busWhereView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _viewStartY, 320, 37)];
    
    UIButton *favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [favoriteBtn setFrame:CGRectMake(0, 0, 160, 37)];
    [favoriteBtn setImage:[UIImage imageNamed:@"poi_btn_01.png"] forState:UIControlStateNormal];
    [favoriteBtn addTarget:self action:@selector(favoBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:favoriteBtn];
    
    UIButton *infoModifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoModifyBtn setFrame:CGRectMake(160, 0, 160, 37)];
    [infoModifyBtn setImage:[UIImage imageNamed:@"poi_btn_02.png"] forState:UIControlStateNormal];
    [infoModifyBtn addTarget:self action:@selector(modifyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:infoModifyBtn];
    
    _busStationList.tableFooterView = bottomView;
    [bottomView release];
    
    [self drawingRealTime];
    
    //[busStationList release];
    
    if(_isPushBusStationAndLine == NO)
        [self saveRecentSearch];
    
}
- (void) drawingRealTime
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSArray *busStateArray = [[OllehMapStatus sharedOllehMapStatus].busNumberNewDictionary objectForKeyGC:@"busInfo"];
    
    if([busStateArray count] <= 0)
    {
        [_mapBtn setEnabled:NO];
    }
    
    for (int i=0; i<busStateArray.count; i++)
    {
        UIImageView *busNumberImg = [[UIImageView alloc] init];

        int busNumValue = [[oms.busNumberNewDictionary objectForKeyGC:@"bl_BUSCLASS"] intValue];
        
        [busNumberImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", [self busNumberImgString:busNumValue]]]];
        [_busWhereView addSubview:busNumberImg];
        
        
        int sectOrd = [[[busStateArray objectAtIndexGC:i] objectForKeyGC:@"sectord"] intValue];
        // 0이면 운행중 1이면 도착
        int stopFlag = [[[busStateArray objectAtIndexGC:i] objectForKeyGC:@"stopflag"] intValue];
        
        int busStateY;
        
        
        // (정류장번호 - 1 * 셀의높이) + 셀의 절반 - 이미지의 반
        if(stopFlag == 1)
            busStateY = ((sectOrd - 1) * BusCellHeight) + (BusCellHeight / 2) - 12;
        else
            busStateY = (sectOrd - 1) * BusCellHeight - 12;
            
        // 첫번째 정류장일땐 예외
        if(sectOrd == 1)
        {
            [busNumberImg setFrame:CGRectMake(119, busStateY + (BusCellHeight / 2), 25, 25)];
        }
        else
            [busNumberImg setFrame:CGRectMake(119, busStateY, 25, 25)];
        
        // 버스종류
                            int busType = [[[busStateArray objectAtIndexGC:i] objectForKeyGC:@"bustype"] intValue];
                            NSString *busTypeName;
        
                            if(busType == 0)
                            {
                                busTypeName = @"일반";
                            }
                           else if (busType == 1) {
                                busTypeName = @"저상";
                            }
                            else if (busType == 2) {
                                busTypeName = @"굴절";
                            }
                            else {
                                busTypeName = @"일반";
                            }
        
                            // 라벨 배경이미지
                            UIImageView *labelBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bus_layer.png"]];
                            [labelBg setFrame:CGRectMake(0, busStateY-2, 116, 30)];
                            [_busWhereView addSubview:labelBg];
        
                            // 라벨
                            UILabel *busNoLabel = [[UILabel alloc] init];
                        // PLAINNO : 버스 번호
                            [busNoLabel setText:[NSString stringWithFormat:@"%@ [%@]",[[busStateArray objectAtIndexGC:i] objectForKeyGC:@"plainno"], busTypeName]];
                            [busNoLabel setFont:[UIFont systemFontOfSize:10]];
                            [busNoLabel setBackgroundColor:[UIColor clearColor]];
                           [busNoLabel setTextAlignment:NSTextAlignmentCenter];
                            [busNoLabel setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1]];
                            [_busWhereView addSubview:busNoLabel];
        
                            [busNoLabel setFrame:CGRectMake(0, busStateY-2, 110, 30)];
        
        
        
                           [labelBg release];
                            [busNoLabel release];
        
        [busNumberImg release];

    }
    
    
    
}
#pragma mark -
#pragma mark - UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_busStationList deselectRowAtIndexPath:indexPath animated:YES];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSDictionary *cellDic = [[oms.busNumberNewDictionary objectForKeyGC:@"routeInfo"] objectAtIndexGC:indexPath.row];
    
    NSString *stationNo = stringValueOfDictionary(cellDic, @"stationno");
    NSString *stId = stringValueOfDictionary(cellDic, @"stid");
    
    NSString *cityCode = [oms.busNumberNewDictionary objectForKeyGC:@"bl_CITYCODE"];
    
    // STID가 없으면 uniqueId로 찾는다
    if([stId isEqualToString:@""])
    {
        [[ServerConnector sharedServerConnection] requestBusStationInfoUniqueId:self action:@selector(didfinishBusStationInfoCallBack:) uniqueId:stationNo cityCode:cityCode];
    }
    // STID가 있을경우 바로 고고
    else
    {
        [[ServerConnector sharedServerConnection] requestBusStationInfoStid:self action:@selector(didfinishBusStationInfoCallBack:) stId:stId];
    }
}
- (void) didfinishBusStationInfoCallBack:(id)request
{
    if([request finishCode] ==OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[oms.busNumberNewDictionary objectForKeyGC:@"laneid"]  forKey:@"LANEID"];
        
        [oms.pushDataBusNumberArray addObject:dic];
        
        [dic release];
        
        BusStationDetailViewController *bspdvc = [[BusStationDetailViewController alloc] initWithNibName:@"BusStationDetailViewController" bundle:nil];
        
        _isPushBusStationAndLine = YES;
        
        [[OMNavigationController sharedNavigationController] pushViewController:bspdvc animated:NO];
        [bspdvc release];
        
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return BusCellHeight;
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[OllehMapStatus sharedOllehMapStatus].busNumberNewDictionary objectForKeyGC:@"routeInfo"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    // 세퍼레이터
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
    
    BusLineInStationCell *cell = (BusLineInStationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if( cell == nil )
    {
        NSBundle *nbd = [NSBundle mainBundle];
        NSArray *nib = [nbd loadNibNamed:@"BusLineInStationCell" owner:self options:nil];
        for (id oneObject in nib) {
            if([oneObject isKindOfClass:[BusLineInStationCell class]])
                cell = (BusLineInStationCell *)oneObject;
            
        }
        
        UIImageView *selectedBackgroundView = [[UIImageView alloc] init];
        [selectedBackgroundView setBackgroundColor:convertHexToDecimalRGBA(@"d9", @"f4", @"ff", 1)];
        cell.selectedBackgroundView = selectedBackgroundView;
        [selectedBackgroundView release];
    }

    [cell.stationName setFont:[UIFont boldSystemFontOfSize:13]];
    [cell.stationName setFrame:CGRectMake(10, 11, 270, 13)];

    [cell.stationId setFont:[UIFont systemFontOfSize:13]];
    [cell.stationId setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1]];
    [cell.stationId setFrame:CGRectMake(10, 31, 270, 13)];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSDictionary *cellDic = [[oms.busNumberNewDictionary objectForKeyGC:@"routeInfo"] objectAtIndexGC:indexPath.row];
    
    NSString *stationName = stringValueOfDictionary(cellDic, @"stationnm");
    
    [cell.stationName setText:stationName];
    
    NSString *uniqueId = stringValueOfDictionary(cellDic, @"stationno");
    uniqueId = convertBISUniqueId(uniqueId);
    
    if([uniqueId isEqualToString:@""] || [uniqueId isEqualToString:@"0"])
    {
        [cell.stationId setHidden:YES];
        [cell.stationName setFrame:CGRectMake(10, 22, 270, 13)];
    }
    else
    {
        NSString *before = [uniqueId substringToIndex:2];
        NSString *after = [uniqueId substringFromIndex:2];
    
        [cell.stationId setText:[NSString stringWithFormat:@"[%@-%@]", before, after]];
    }
    
    NSArray *arr = [oms.busNumberNewDictionary objectForKeyGC:@"routeInfo"];
    
    if([[[arr objectAtIndexGC:indexPath.row] allKeys] containsObject:@"a"])
    {
        currentNearStation = indexPath;
        [cell.cellBg setBackgroundColor:[UIColor colorWithRed:217.0/255.0 green:244.0/255.0 blue:255.0/255.0 alpha:1]];
    }

    
    return cell;
}

- (void) saveRecentSearch
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 최근검색에 넣는다
    NSMutableDictionary *busNumDic = [[NSMutableDictionary alloc] init];
    
    NSInteger citycode2 = [[oms.busNumberNewDictionary objectForKeyGC:@"bl_CITYCODE"] intValue];
    
    NSString *busStr = [oms.busNumberNewDictionary objectForKeyGC:@"bl_BUSNO"];
    //busStr = [busStr stringByReplacingOccurrencesOfString:@"-0" withString:@""];
    
    [busNumDic setObject:busStr forKey:@"NAME"];
    [busNumDic setObject:[oms cityCodeToCityName:citycode2] forKey:@"SUBNAME"];
    [busNumDic setObject:@"TR_BUSNO" forKey:@"TYPE"];
    [busNumDic setObject:@"대중교통 > 버스노선" forKey:@"CLASSIFY"];
    [busNumDic setObject:[oms.busNumberNewDictionary objectForKeyGC:@"laneid"] forKey:@"ID"];
    [busNumDic setObject:[NSNumber numberWithInt:[oms getBusClassNumber:[[oms.busNumberNewDictionary objectForKeyGC:@"bl_BUSCLASS"] intValue]]] forKey:@"ICONTYPE"];
    
    
    [[OllehMapStatus sharedOllehMapStatus] addRecentSearch:busNumDic];
    [busNumDic release];
}

#pragma mark -
#pragma mark - action

- (IBAction)popBtnClick:(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

- (IBAction)mapBtnClick:(id)sender
{
    
    NSString *laneId = [[OllehMapStatus sharedOllehMapStatus].busNumberNewDictionary objectForKeyGC:@"laneid"];
    
    [[ServerConnector sharedServerConnection] requestBusRouteId:self action:@selector(didfinishedGetBusRouteIdCallBack:) arsId:laneId];
}
- (void) didfinishedGetBusRouteIdCallBack:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        _isPushBusStationAndLine = YES;
        
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[oms.busNumberNewDictionary objectForKeyGC:@"laneid"]  forKey:@"LANEID"];
        
        [oms.pushDataBusNumberArray addObject:dic];
        
        [dic release];
        //NSLog(@"oms.cityCode = %d, _bussRouteId = %@", oms.cityCode, _bussRouteId);
        NSLog(@"%@", oms.laneIdToBisIdDictionary);
        
        NSDictionary *laneToRouteDic = [[oms.laneIdToBisIdDictionary objectForKeyGC:@"BISID"] objectAtIndexGC:0];
        
        NSString *busRouteId = stringValueOfDictionary(laneToRouteDic, @"BUSROUTEID");
        
        int city = [[oms.busNumberNewDictionary objectForKeyGC:@"bl_CITYCODE"] intValue];
        if(city == 1000)
        {
            [[ServerConnector sharedServerConnection] requestBusLineDraw:self action:@selector(didFinishBusLineDrawCallBack:) busRouteId:busRouteId];
        }
        else if (city > 1000 && city < 1311)
        {
            [[ServerConnector sharedServerConnection] requestBusLineDraw_G:self action:@selector(didFinishBusLineDrawCallBack:) busRouteId:busRouteId];
        }
        else
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_BusNumber_NotDrawBusLine", @"")];
        }

    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }

}
- (void)didFinishBusLineDrawCallBack:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        NSString *busNamed = [oms.busNumberNewDictionary objectForKeyGC:@"bl_BUSNO"];
        
        if([[oms.busLineDrawingDictionary objectForKeyGC:@"BUSLINE"] count] == 0)
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_BusNumber_NotDrawBusLine", @"")];
        }
        else
        {
            [MainMapViewController markingBusLineRoute_BusName:busNamed animated:NO];
        }
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}

- (IBAction)reFreshBtnClick:(id)sender
{
    [self reFresh];
}
- (void) reFresh
{
    
    NSString *laneId = stringValueOfDictionary([OllehMapStatus sharedOllehMapStatus].busNumberNewDictionary, @"laneid");
    
    // 서버통신
    [[ServerConnector sharedServerConnection] requestBusNumberInfo:self action:@selector(finishedBusNumberSearched:) laneId:laneId];
    
}
- (void) finishedBusNumberSearched:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        [self reDraw];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    
}
- (void) reDraw
{
    for (UIView *subView in _busNumberWindow.subviews)
    {
        [subView removeFromSuperview];
    }
    for (UIView *subView in _busWhereView.subviews)
    {
        [subView removeFromSuperview];
    }
    
    [self drawingTop];
}

- (void)myNearBtnClick:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];

    // 내좌표
    Coord crd = [[MapContainer sharedMapContainer_Main] getCurrentUserLocation];
    // poi 좌표
    Coord poiCrd;

    // 처음 비교값
    double standard = 1000;
    // 내 위치와 정류장 위치사이의 거리
    double distance;
    // 증가
    int i=0;
    // 몇번째찾기
    int k=0;

    // 딕셔너리를 돌면서 각 정류장의 좌표와 내 좌표 사이 거리를 구한다
    // 구한 거리를 바로 전 값과 비교(처음엔 1000과 첫번째 정류장거리)하여 작은것을 가지고 다음 값과 비교
        for (NSDictionary *findStation in [oms.busNumberNewDictionary objectForKeyGC:@"routeInfo"])
        {

            poiCrd = CoordMake([[findStation objectForKeyGC:@"gpsx"] doubleValue], [[findStation objectForKeyGC:@"gpsy"] doubleValue]);

            // BIS 버정 좌표는 WGS84.....이기 때문...
           poiCrd = [[MapContainer sharedMapContainer_Main].kmap convertCoordinate:poiCrd inCoordType:KCoordType_WGS84 outCoordType:KCoordType_UTMK];

            distance = CoordDistance(poiCrd, crd);

            if(distance < standard)
            {
                standard = distance;
                k = i;
            }
            i++;
        }
        // 딕셔너리를 다 돌았는데 제일 가까운 것이 1000이라면 가까운정류장이 없다
        if(standard == 1000)
        {

            NSString *busStr = [oms.busNumberNewDictionary objectForKeyGC:@"bl_BUSNO"];

            [OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"주변 1km 내에\n%@번 버스정류장이 없습니다.", busStr]];
        }
        // 1000보다 가까운 곳이 있다
        else
        {
            [[[oms.busNumberNewDictionary objectForKeyGC:@"routeInfo"] objectAtIndexGC:k] setObject:@"a" forKey:@"a"];
            [_busStationList reloadData];
            [_busStationList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:k inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];

        }

}
- (void) modifyBtnClick:(id)sender
{
    [self typeChecker:6];
    [self modalInfoModify:[OllehMapStatus sharedOllehMapStatus].busNumberNewDictionary];
}
- (void) favoBtnClick:(id)sender
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 즐겨찾기 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail/favorite"];
    
    DbHelper *dh = [[[DbHelper alloc] init] autorelease];
    
    int citycode2 = [[oms.busNumberNewDictionary objectForKeyGC:@"bl_CITYCODE"] intValue];
    NSString *cityname = [NSString stringWithFormat:@"%@", [oms cityCodeToCityName:citycode2]];
    
    NSString *busTitle = [NSString stringWithFormat:@"%@%@", stringValueOfDictionary(oms.busNumberNewDictionary, @"bl_BUSNO"),
                          cityname];
    
    
    NSMutableDictionary *fdic = [OMDatabaseConverter makeFavoriteDictionary:-1
                                                                  sortOrder:-1
                                                                   category:Favorite_Category_Public
                                                                     title1:busTitle
                                                                     title2:@"대중교통 > 버스노선"
                                                                     title3:@""
                                                                   iconType:[oms getBusClassNumber:[[oms.busNumberNewDictionary objectForKeyGC:@"bl_BUSCLASS"] intValue]]
                                                                    coord1x:0
                                                                    coord1y:0
                                                                    coord2x:0
                                                                    coord2y:0
                                                                    coord3x:0
                                                                    coord3y:0
                                                                 detailType:@"TR_BUSNO"
                                                                   detailID:[oms.busNumberNewDictionary objectForKeyGC:@"laneid"] shapeType:@"" fcNm:@"" idBgm:@""];
    
    if([dh favoriteValidCheck:fdic])
    {
        [self typeChecker:6];
        [self bottomViewFavorite:fdic placeHolder:busTitle];
    }
    
}
- (NSString *) busNumberImgString :(int) a_IbusClass
{
    NSString *busNumberString = nil;

    // 일반
    if(a_IbusClass == 1)
    {
         busNumberString = @"bus_icon_s_27.png";
    }
    // 좌석
    else if (a_IbusClass == 2)
    {
        busNumberString = @"bus_icon_s_28.png";
    }
    // 마을
    else if (a_IbusClass == 3)
    {
        busNumberString = @"bus_icon_s_29.png";
    }
    // 직행좌석
    else if (a_IbusClass == 4)
    {
        busNumberString = @"bus_icon_s_30.png";
    }
    // 공항
    else if (a_IbusClass == 5)
    {
        busNumberString = @"bus_icon_s_31.png";
    }
    // 간선급행
    else if (a_IbusClass == 6)
    {
        busNumberString = @"bus_icon_s_32.png";
    }
    // 외곽
    else if (a_IbusClass == 10)
    {
        busNumberString = @"bus_icon_s_33.png";
    }
    // 간선
    else if (a_IbusClass == 11)
    {
        busNumberString = @"bus_icon_s_34.png";
    }
    // 지선
    else if (a_IbusClass == 12)
    {
        busNumberString = @"bus_icon_s_35.png";
    }
    //순환
    else if (a_IbusClass == 13)
    {
        busNumberString = @"bus_icon_s_36.png";
    }
    // 광역
    else if (a_IbusClass == 14)
    {
        busNumberString = @"bus_icon_s_37.png";
    }
    // 급행
    else if (a_IbusClass == 15)
    {
       busNumberString = @"bus_icon_s_38.png";
   }
  // 급행간선
    else if (a_IbusClass == 26)
    {
        busNumberString = @"bus_icon_s_39.png";
    }

    return busNumberString;

}

@end
