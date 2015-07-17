//
//  RecentSearchViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 10..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "RecentSearchViewController.h"
#import "MainMapViewController.h"
#import "MapContainer.h"

@interface RecentSearchViewController ()

@end

@implementation RecentSearchViewController
@synthesize nullView = _nullbtnView;
@synthesize nullLbl = _nullLbl;
@synthesize recentTableView = _recentTableView;
@synthesize editView = _editView;
@synthesize allSelectLabel = _allSelectLabel;
@synthesize deleteLabel = _deleteLabel;
@synthesize prevBtn = _prevBtn;
@synthesize editBtn = _editBtn;

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
    [_nullView release];
    [_nullLbl release];
    [_editBtn release];
    [_recentTableView release];
    [_editView release];
    [_deleteLabel release];
    [_allSelectLabel release];
    [_recentList release];
    [_prevBtn release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setNullView:nil];
    [self setNullLbl:nil];
    [self setEditBtn:nil];
    [self setRecentTableView:nil];
    [self setEditView:nil];
    [self setDeleteLabel:nil];
    [self setAllSelectLabel:nil];
    [self setPrevBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void) viewDidAppear:(BOOL)animated
{
    [_editBtn setEnabled: [[OllehMapStatus sharedOllehMapStatus] getRecentSearchCount] > 0 ];
    [_recentTableView reloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    if([[OllehMapStatus sharedOllehMapStatus] getRecentSearchCount] == 0)
    {
        [_recentTableView setHidden:YES];
        
        _nullView = [[UIView alloc] init];
        
        [_nullView setFrame:CGRectMake(0, 37, 320, self.view.frame.size.height)];
        
        [_nullView setBackgroundColor:convertHexToDecimalRGBA(@"F2", @"F2", @"F2", 1.0f)];
        _nullLbl = [[UILabel alloc] init];
        [_nullLbl setText:@"저장된 목록이 없습니다"];
        [_nullLbl setBackgroundColor:[UIColor clearColor]];
        [_nullLbl setTextAlignment:NSTextAlignmentCenter];
        [_nullLbl setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
        [_nullLbl setFont:[UIFont systemFontOfSize:15]];
        [_nullLbl setFrame:CGRectMake(0, 202, 320, 15)];
        
        [_nullView addSubview:_nullLbl];
        
        [self.view addSubview:_nullView];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}
#pragma mark -
#pragma mark - 테이블뷰 딜리게이트
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rdic = [[[OllehMapStatus sharedOllehMapStatus] getRecentSearchList] objectAtIndexGC:indexPath.row];
    
    if([[rdic objectForKeyGC:@"TYPE"] isEqualToString:@"ROUTE"])
    {
        if( ![[rdic objectForKeyGC:@"VISIT_NAME"] isEqualToString:@""] )
        {
            return 78;
        }
        
    }
    
    return 58;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[OllehMapStatus sharedOllehMapStatus] getRecentSearchCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"CellIdentifier";
    
    // 세퍼레이터 설정
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.separatorColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1];
    
    recentCell *ccell = (recentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    
    if( ccell == nil )
    {
        NSBundle *nbd = [NSBundle mainBundle];
        NSArray *nib = [nbd loadNibNamed:@"recentCell" owner:self options:nil];
        for (id oneObject in nib) {
            if([oneObject isKindOfClass:[recentCell class]])
                ccell = (recentCell *)oneObject;
        }
    }
    
    
    
    NSDictionary *rdic = [[[OllehMapStatus sharedOllehMapStatus] getRecentSearchList] objectAtIndexGC:indexPath.row];
    //
    int iconType = [[rdic objectForKeyGC:@"ICONTYPE"] intValue];
    
    UIImage *iconImage = nil;
    if ( iconType == Favorite_IconType_BusStop )
        iconImage = [UIImage imageNamed:@"list_b_marker_busstop.png"];
    else if ( iconType == Favorite_IconType_CCTV )
        iconImage = [UIImage imageNamed:@"list_b_marker_cctv.png"];
    else if ( iconType == Favorite_IconType_Course )
        iconImage = [UIImage imageNamed:@"list_b_marker_course.png"];
    else if ( iconType == Favorite_IconType_None )
        iconImage = [UIImage imageNamed:@"list_b_marker.png"];
    else if ( iconType == Favorite_IconType_POI )
        iconImage = [UIImage imageNamed:@"list_b_marker_poi.png"];
    else if ( iconType == Favorite_IconType_Subway )
        iconImage = [UIImage imageNamed:@"list_b_marker_subway.png"];
    else
        iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"info_icon_%02d", iconType]];
    
    ccell.poiImage.image = iconImage;
    
    CGRect iconRect = ccell.poiImage.frame;
    
    iconRect.size = iconImage.size;
    iconRect.origin = CGPointMake(9, 12);
    
    [ccell.poiImage setFrame:iconRect];
    //
    if([[rdic objectForKeyGC:@"TYPE"] isEqualToString:@"TR_BUSNO"])
    {
        [ccell.poiImage setFrame:CGRectMake(6, 12, 29, 18)];
    }
    
    if([[rdic objectForKeyGC:@"TYPE"] isEqualToString:@"ROUTE"])
    {
        
        [ccell.placeName setHidden:YES];
        [ccell.classification setHidden:YES];
        
        [ccell.startLbl setHidden:NO];
        
        [ccell.destLbl setHidden:NO];
        
        [ccell.startContent setHidden:NO];
        
        [ccell.destContent setHidden:NO];
        
        ccell.startContent.text = [NSString stringWithFormat:@"%@", [rdic objectForKeyGC:@"START_NAME"]];
        
        ccell.destContent.text = [NSString stringWithFormat:@"%@", [rdic objectForKeyGC:@"STOP_NAME"]];
        
        [ccell.destLbl setFrame:CGRectMake(41, 31, 28, 15)];
        [ccell.destContent setFrame:CGRectMake(78, 32, 192, 13)];
        
        
        
        // 경유지 있나 판단
        if( ![[rdic objectForKeyGC:@"VISIT_NAME"] isEqualToString:@""] )
        {
            [ccell.visitLbl setHidden:NO];
            [ccell.visitContent setHidden:NO];
            ccell.visitContent.text = [NSString stringWithFormat:@"%@", [rdic objectForKeyGC:@"VISIT_NAME"]];
            
            [ccell.destLbl setFrame:CGRectMake(41, 51, 28, 15)];
            [ccell.destContent setFrame:CGRectMake(78, 52, 192, 13)];
            
            [ccell.radioBtn setImage:[UIImage imageNamed:@"search_edit_list_pressed_01.png"] forState:UIControlStateSelected];
        }
        
        
    }
    else
    {
        NSString *subName = [rdic objectForKeyGC:@"SUBNAME"];
        NSLog(@"subName : %@", subName);
        
        if(subName == nil)
        {
            ccell.placeName.text = [rdic objectForKeyGC:@"NAME"];
        }
        else
        {
            ccell.placeName.text = [NSString stringWithFormat:@"%@%@", [rdic objectForKeyGC:@"NAME"], [rdic objectForKeyGC:@"SUBNAME"]];
        }
        
        NSString *classify = stringValueOfDictionary(rdic, @"CLASSIFY");
        //[rdic objectForKeyGC:@"CLASSIFY"];
        
        if([classify isEqualToString:@""])
        {
            [ccell.placeName setFrame:CGRectMake(41, 21, 229, 15)];
            [ccell.classification setHidden:YES];
        }
        else
        {
            
            
            ccell.classification.text = classify;
            
        }
        
        
        //ccell.classification.text = [rdic objectForKeyGC:@"CLASSIFY"];
        [ccell.radioBtn setHidden:YES];
        
    }
    
    if(tableView.isEditing)
    {
        
        [self cellDrawEdit:ccell tableView:tableView cellForRowAtIndexPath:indexPath];
        
        
    }
    
    [ccell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return ccell;
    
    
}
// 편집 테이블 그리기
- (void)cellDrawEdit:(recentCell *)ccell tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *rdic = [[[OllehMapStatus sharedOllehMapStatus] getRecentSearchList] objectAtIndexGC:indexPath.row];
    
    [ccell.poiImage setFrame:CGRectMake(44, 11, 23, 34)];
    
    if([[rdic objectForKeyGC:@"TYPE"] isEqualToString:@"TR_BUSNO"])
    {
        [ccell.poiImage setFrame:CGRectMake(41, 12, 29, 18)];
    }
    
    
    
    // 넓이바꿈
    [ccell.placeName setFrame:CGRectMake(76, 11, 235, 15)];
    [ccell.classification setFrame:CGRectMake(76, 33, 235, 13)];
    [ccell.radioBtn setHidden:NO];
    
    
    
    NSString *classify = [rdic objectForKeyGC:@"CLASSIFY"];
    
    if([classify isEqualToString:@""])
    {
        [ccell.placeName setFrame:CGRectMake(76, 21, 235, 15)];
        [ccell.classification setHidden:YES];
    }
    else
    {
        
        
        ccell.classification.text = classify;
        
    }
    
    
    //ccell.startLbl   41 / 78   // 31
    //ccell.startContent 233
    CGRect rect;
    
    rect = ccell.startLbl.frame;
    rect.origin.x = 76;
    ccell.startLbl.frame = rect;
    
    rect = ccell.startContent.frame;
    rect.origin.x = ccell.startLbl.frame.origin.x + 31;
    rect.size.width = 233-31;
    ccell.startContent.frame = rect;
    
    rect = ccell.visitLbl.frame;
    rect.origin.x = 76;
    ccell.visitLbl.frame = rect;
    
    rect = ccell.visitContent.frame;
    rect.origin.x = ccell.visitLbl.frame.origin.x + 31;
    rect.size.width = 233-31;
    ccell.visitContent.frame = rect;
    
    rect = ccell.destLbl.frame;
    rect.origin.x = 76;
    ccell.destLbl.frame = rect;
    
    rect = ccell.destContent.frame;
    rect.origin.x = ccell.destLbl.frame.origin.x + 31;
    rect.size.width = 233-31;
    ccell.destContent.frame = rect;
    
    
    
    
    
    
    
    
    NSMutableArray *list = [[OllehMapStatus sharedOllehMapStatus] getRecentSearchList];
    
    NSMutableDictionary *dic = [list objectAtIndexGC:indexPath.row];
    
    if([[dic objectForKeyGC:@"TYPE"] isEqualToString:@"ROUTE"] && ![[dic objectForKeyGC:@"VISIT_NAME"] isEqualToString:@""])
    {
        [ccell.radioBtn setFrame:CGRectMake(0, 0, 320, 78)];
        [ccell.radioBtn setImage:[UIImage imageNamed:@"search_edit_list_default_01.png"] forState:UIControlStateNormal];
    }
    
    NSNumber *checkDelete = [dic objectForKeyGC:@"CheckDelete"];
    
    [ccell.radioBtn setSelected:[checkDelete boolValue]];
    
    [ccell.radioBtn setTag:indexPath.row];
    
    
    
    [ccell.radioBtn addTarget:self action:@selector(editCellSelected:) forControlEvents:UIControlEventTouchUpInside];
    
}
// 테이블선택
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // MIK.geun :: 20121116 // 설정에서 즐겨찾기 진입한 경우 렌더링방식이 달라짐
    // 설정에서 들어온 즐겨찾기는 결과화면 지도로 이동하지 않는다.
    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    UIViewController *vc = [nc.viewControllers objectAtIndexGC:nc.viewControllers.count-2];
    // 설정화면 즐겨찾기 여부
    BOOL isSettingRecent = [vc isKindOfClass:[SettingViewController2 class]];
    
    [_recentTableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // 최근검색 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/local_search/recent_POI"];
    NSDictionary *rdic = [[[OllehMapStatus sharedOllehMapStatus] getRecentSearchList] objectAtIndexGC:indexPath.row];
    
    
    NSLog(@"%d, rdic : %@", indexPath.row, rdic);
    if([[rdic objectForKeyGC:@"TYPE"] isEqualToString:@"TR_BUSNO"])
    {
        
        NSLog(@"버스다, %@", [rdic objectForKeyGC:@"ID"]);
        [_recentTableView deselectRowAtIndexPath:indexPath animated:NO];
        
        [[ServerConnector sharedServerConnection] requestBusNumberInfo:self action:@selector(didFinishRequestBusNumDetail:) laneId:[rdic objectForKeyGC:@"ID"]];
        
    }
    else if ([[rdic objectForKeyGC:@"TYPE"] isEqualToString:@"ROUTE"])
    {
        // 길찾기 데이터 채우기
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        // 출발지
        [oms.searchResultRouteStart reset];
        [oms.searchResultRouteStart setUsed:YES];
        [oms.searchResultRouteStart setIsCurrentLocation:NO];
        [oms.searchResultRouteStart setStrLocationName: [NSString stringWithFormat:@"%@", [rdic objectForKeyGC:@"START_NAME"]]];
        [oms.searchResultRouteStart setStrLocationAddress:@""];
        [oms.searchResultRouteStart setCoordLocationPoint:CoordMake( [[rdic objectForKeyGC:@"START_X"] doubleValue] , [[rdic objectForKeyGC:@"START_Y"] doubleValue] ) ];
        // 경유지
        [oms.searchResultRouteVisit reset];
        if ( ![[rdic objectForKeyGC:@"VISIT_NAME"] isEqualToString:@""] )
        {
            [oms.searchResultRouteVisit setUsed:YES];
            [oms.searchResultRouteVisit setIsCurrentLocation:NO];
            [oms.searchResultRouteVisit setStrLocationName: [NSString stringWithFormat:@"%@", [rdic objectForKeyGC:@"VISIT_NAME"]]];
            [oms.searchResultRouteVisit setStrLocationAddress:@""];
            [oms.searchResultRouteVisit setCoordLocationPoint:CoordMake( [[rdic objectForKeyGC:@"VISIT_X"] doubleValue] , [[rdic objectForKeyGC:@"VISIT_Y"] doubleValue] ) ];
        }
        // 도착지
        [oms.searchResultRouteDest reset];
        [oms.searchResultRouteDest setUsed:YES];
        [oms.searchResultRouteDest setIsCurrentLocation:NO];
        [oms.searchResultRouteDest setStrLocationName: [NSString stringWithFormat:@"%@", [rdic objectForKeyGC:@"STOP_NAME"]]];
        [oms.searchResultRouteDest setStrLocationAddress:@""];
        [oms.searchResultRouteDest setCoordLocationPoint:CoordMake( [[rdic objectForKeyGC:@"STOP_X"] doubleValue] , [[rdic objectForKeyGC:@"STOP_Y"] doubleValue] ) ];
        
        // 길찾기 검색전 기존 검색 데이터 클리어
        [[OllehMapStatus sharedOllehMapStatus].searchRouteData reset];
        
        // 길찾기 시도
        [[SearchRouteExecuter sharedSearchRouteExecuter] searchRoute_Car:SearchRoute_Car_SearchType_RealTime];
        
    }
    else
    {
        
        
        
        NSString *name = [rdic objectForKeyGC:@"NAME"];
        NSString *add = [rdic objectForKeyGC:@"ADDR"];
        //NSString *classify = [rdic objectForKeyGC:@"CLASSIFY"];
        NSNumber *xx = [rdic objectForKeyGC:@"X"];
        NSNumber *yy = [rdic objectForKeyGC:@"Y"];
        NSString *type = [rdic objectForKeyGC:@"TYPE"];
        NSString *detailid = [rdic objectForKeyGC:@"ID"];
        NSString *tel = stringValueOfDictionary(rdic, @"TEL");
        NSString *free = stringValueOfDictionary(rdic, @"FREE");
        //[rdic objectForKeyGC:@"FREE"];
        NSString *subName = stringValueOfDictionary(rdic, @"SUBNAME");
        //[rdic objectForKeyGC:@"SUBNAME"];
        
        //if(!free)
        //free = [NSString stringWithFormat:@""];
        
        
        double x = [xx doubleValue];
        double y = [yy doubleValue];
        
        //[OMMessageBox showAlertMessage:@"리스트정보" :detail];
        
        [_recentTableView deselectRowAtIndexPath:indexPath animated:YES];
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        [oms.searchResult reset]; // 검색결과 리셋
        [oms.searchResult setUsed:YES];
        [oms.searchResult setIsCurrentLocation:NO];
        [oms.searchResult setStrLocationName:[NSString stringWithFormat:@"%@%@", name, subName]];
        if([type isEqualToString:@"ADDR"])
            [oms.searchResult setStrLocationAddress:name];
        else
        {
            [oms.searchResult setStrLocationAddress:add];
        }
        
        [oms.searchResult setStrType:type];
        [oms.searchResult setStrID:detailid];
        [oms.searchResult setStrTel:tel];
        //[oms.searchResult setStrSTheme:free];
        
        [oms.searchResult setCoordLocationPoint:CoordMake(x, y)];
        
        [oms.searchResult setStrSTheme:free];
        [oms.searchLocalDictionary setObject:free forKey:@"LastExtendFreeCall"];
        
        if ( !isSettingRecent )
            [MainMapViewController markingSinglePOI_RenderType:MainMap_SinglePOI_Type_Recent animated:NO];
        else
        {
            [[OMNavigationController sharedNavigationController] popToRootViewControllerAnimated:NO];
            MainMapViewController *mmvc = (MainMapViewController*)[[OMNavigationController sharedNavigationController].viewControllers lastObject];
            
            [mmvc toggleMyLocationMode:MapLocationMode_None];
            [mmvc pinRecentPOIOverlay:YES];
            NSArray *allOverlays = [MapContainer sharedMapContainer_Main].kmap.getOverlays;
            for (Overlay *overlay in allOverlays)
            {
                if ( [overlay isKindOfClass:[OMImageOverlayRecent class]] )
                {
                    [((OMImageOverlayRecent*)overlay).additionalInfo setObject:[NSNumber numberWithBool:YES] forKey:@"LongtapClose"];
                    break;
                }
            }
        }
        
    }
}
//
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
// 에딧하는 동안 앞에 딜리트 인서트버튼
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark -
#pragma mark - 액션들
- (IBAction)popBtnClick:(id)sender
{
    if(_recentTableView.isEditing)
    {
        
        [[OllehMapStatus sharedOllehMapStatus] completeRecenSearchEdting:NO];
        
        [_editBtn setImage:[UIImage imageNamed:@"title_bt_edit.png"] forState:UIControlStateNormal];
        [_prevBtn setImage:[UIImage imageNamed:@"title_bt_before.png"] forState:UIControlStateNormal];
        
        
        [_editView removeFromSuperview];
        //[_btnView removeFromSuperview];
        
        [_recentTableView setFrame:CGRectMake(0, 37, 320, self.view.frame.size.height - 37)];
        [_recentTableView setEditing:NO animated:NO];
        [_recentTableView reloadData];
    }
    else
    {
        [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
    }
    
}

- (IBAction)editBtnClick:(id)sender
{
    
    if([_recentTableView isEditing])
    {
        [[OllehMapStatus sharedOllehMapStatus] completeRecenSearchEdting:YES];
        [_editBtn setEnabled: [[OllehMapStatus sharedOllehMapStatus] getRecentSearchCount] > 0 ];
        
        [_prevBtn setImage:[UIImage imageNamed:@"title_bt_before.png"] forState:UIControlStateNormal];
        
        [_editBtn setImage:[UIImage imageNamed:@"title_bt_edit.png"] forState:UIControlStateNormal];
        
        [_editView removeFromSuperview];
        //[_btnView removeFromSuperview];
        
        [_recentTableView setFrame:CGRectMake(0, 37, 320, self.view.frame.size.height - 37)];
        [_recentTableView setEditing:NO animated:NO];
        [_recentTableView reloadData];
        
        if([[OllehMapStatus sharedOllehMapStatus] getRecentSearchCount] == 0)
        {
            [_recentTableView setHidden:YES];
            
            _nullView = [[UIView alloc] init];
            
            [_nullView setFrame:CGRectMake(0, 37, 320, self.view.frame.size.height)];
            
            [_nullView setBackgroundColor:convertHexToDecimalRGBA(@"F2", @"F2", @"F2", 1.0f)];
            _nullLbl = [[UILabel alloc] init];
            [_nullLbl setText:@"저장된 목록이 없습니다"];
            [_nullLbl setBackgroundColor:[UIColor clearColor]];
            [_nullLbl setTextAlignment:NSTextAlignmentCenter];
            [_nullLbl setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
            [_nullLbl setFont:[UIFont systemFontOfSize:15]];
            [_nullLbl setFrame:CGRectMake(0, 202, 320, 15)];
            
            [_nullView addSubview:_nullLbl];
            
            [self.view addSubview:_nullView];
        }
        
    }
    
    else
    {
        [_prevBtn setImage:[UIImage imageNamed:@"title_bt_cancel.png"] forState:UIControlStateNormal];
        
        [_editBtn setImage:[UIImage imageNamed:@"title_btn_finish.png"] forState:UIControlStateNormal];
        
        [_editView setFrame:CGRectMake(0, self.view.frame.size.height - 57, 320, 57)];
        [self.view addSubview:_editView];
        
        [_recentTableView setFrame:CGRectMake(0, 37, 320, self.recentTableView.frame.size.height - 57)];
        [_recentTableView setEditing:YES animated:NO];
        [_recentTableView reloadData];
        
    }
}
#pragma mark -
#pragma mark - 편집 시 액션
// 편집시 셀 선택
- (void) editCellSelected:(id)sender
{
    
    UIButton *rBtn = (UIButton *)sender;
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    int index = rBtn.tag;
    
    
    
    NSMutableDictionary *rdic = [[[OllehMapStatus sharedOllehMapStatus] getRecentSearchList] objectAtIndexGC:index];
    
    NSLog(@"%d 번 행...%@", index, rdic);
    
    [rBtn setSelected:!rBtn.selected];
    
    [rdic setObject:[NSNumber numberWithBool:rBtn.selected] forKey:@"CheckDelete"];
    
    int checkCount = 0;
    
    for (NSDictionary *dic in oms.getRecentSearchList)
    {
        if([[dic objectForKeyGC:@"CheckDelete"] boolValue])
        {
            checkCount++;
            
        }
        
    }
    
    [_deleteLabel setText:[NSString stringWithFormat:@"삭제 (%d)", checkCount]];
    
    if(checkCount == oms.getRecentSearchCount)
    {
        [_allSelectLabel setText:@"전체해제"];
    }
    else
    {
        [_allSelectLabel setText:@"전체선택"];
    }
    
}

- (IBAction)allSelecetBtnClick:(id)sender
{
    
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    int preCount = 0;
    
    for (NSMutableDictionary *dic in oms.getRecentSearchList)
    {
        if([[dic objectForKeyGC:@"CheckDelete"] boolValue])
            preCount++;
    }
    
    BOOL isSelectedAll = NO;
    
    if(preCount == oms.getRecentSearchCount)
        isSelectedAll = YES;
    
    for (NSMutableDictionary *dic in oms.getRecentSearchList)
    {
        [dic setObject:[NSNumber numberWithBool:!isSelectedAll] forKey:@"CheckDelete"];
    }
    
    [_deleteLabel setText:[NSString stringWithFormat:@"삭제 (%d)", oms.getRecentSearchCount]];
    
    [_recentTableView reloadData];
    
    if(isSelectedAll == NO)
    {
        //[OMMessageBox showAlertMessage:@"전체선택" :@"전체선택"];
        [_allSelectLabel setText:@"전체해제"];
        
    }
    else
    {
        //[OMMessageBox showAlertMessage:@"전체해제" :@"전체해제"];
        [_allSelectLabel setText:@"전체선택"];
        [_deleteLabel setText:[NSString stringWithFormat:@"삭제 (0)"]];
        //preCount = 0;
    }
}

- (IBAction)deleteBtnClick:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    //UIButton *rBtn = (UIButton *)sender;
    
    [oms removeRecentSearchOnCheckDelete];
    
    [_deleteLabel setText:@"삭제 (0)"];
    
    [_recentTableView reloadData];
}
- (void)didFinishRequestBusNumDetail:(id)request
{
    //int state = 0;
    //[[OllehMapStatus sharedOllehMapStatus] setBisOrGW:state];
    
    BusNumberLineViewController *bndvc = [[BusNumberLineViewController alloc] initWithNibName:@"BusNumberLineViewController" bundle:nil];
    
    [[OMNavigationController sharedNavigationController] pushViewController:bndvc animated:NO];
    [bndvc release];
}

@end
