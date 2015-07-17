//
//  OilPOIDetailViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 6. 8..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "OilPOIDetailViewController.h"
#import "MapContainer.h"
#import "MainMapViewController.h"

@interface OilPOIDetailViewController ()

@end

@implementation OilPOIDetailViewController

@synthesize scrollView = _scrollView;
@synthesize mapBtn = _mapBtn;
@synthesize buttonView = _buttonView;

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
    [_scrollView release];
    [_buttonView release];
    [_mapBtn release];
    [super dealloc];
}
-(void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    //[_mapBtn setHidden:!_displayMapBtn];
    [_mapBtn setHidden:NO];
    [_mapBtn setEnabled:_displayMapBtn];
}
- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setButtonView:nil];
    
    [self setMapBtn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self saveRecentSearch];
    
    _oilViewStartY = GeneralStartY;
    [self.view addSubview:_scrollView];
    [self drawTopView];
    
    // Do any additional setup after loading the view from its nib.
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
    [generalPOIDic setObject:[oms.poiDetailDictionary objectForKeyGC:@"NAME"] forKey:@"NAME"];
    [generalPOIDic setObject:[oms ujNameSegment:ujName] forKey:@"CLASSIFY"];
    [generalPOIDic setValue:[NSNumber numberWithDouble:xx] forKey:@"X"];
    [generalPOIDic setValue:[NSNumber numberWithDouble:yy] forKey:@"Y"];
    [generalPOIDic setObject:@"OL" forKey:@"TYPE"];
    [generalPOIDic setObject:[oms.poiDetailDictionary objectForKeyGC:@"POI_ID"] forKey:@"ID"];
    [generalPOIDic setObject:tel forKey:@"TEL"];
    [generalPOIDic setObject:[oms.poiDetailDictionary objectForKeyGC:@"ADDR"] forKey:@"ADDR"];
    [generalPOIDic setObject:[NSNumber numberWithInt:Favorite_IconType_POI] forKey:@"ICONTYPE"];
    
    [oms addRecentSearch:generalPOIDic];
    
    
    // 최근리스트 저장 끝
    
}
// 탑뷰 그리기(뷰 진입 하고 위에서부터 차례로 그린다
- (void) drawTopView
{
    //탑뷰 높이
    int topViewHeight = 90;
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 탑뷰(처음이기 때문에 y축(_oilViewStartY)은 0
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(X_VALUE, _oilViewStartY, X_WIDTH, topViewHeight)];
    
    [topView setBackgroundColor:[UIColor colorWithRed:217.0/255.0 green:244.0/255.0 blue:255.0/255.0 alpha:1.0]];
    // 이미지
    UIImageView *pImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"view_no_img_box.png"]];
    
    [pImg setFrame:CGRectMake(10, 10, 70, 70)];
    
    NSString *imageUrl = [oms.poiDetailDictionary objectForKeyGC:@"IMG_URL"];
    
    // 이미지가 있으면 이미지를 그린다
	if (imageUrl)
    {
        [pImg setImage:[oms urlGetImage:imageUrl]];
	}
    
    UIImageView *poiImgBox = [[UIImageView alloc] init];
    [poiImgBox setFrame:CGRectMake(10, 10, 70, 70)];
    [poiImgBox setImage:[UIImage imageNamed:@"view_img_box.png"]];
    [topView addSubview:poiImgBox];
    [poiImgBox release];
    
    // 라벨의 x축, 너비, 높이
    int x_value = 90;
    int x_width = 220;
    
    // 상호명
    UILabel *pName = [[UILabel alloc] initWithFrame:CGRectMake(x_value, 16, x_width, 17)];
    [pName setText:[oms.poiDetailDictionary objectForKeyGC:@"NAME"]];
    [pName setFont:[UIFont boldSystemFontOfSize:17]];
    [pName setAdjustsFontSizeToFitWidth:YES];
    [pName setNumberOfLines:1];
    [pName setBackgroundColor:[UIColor clearColor]];
    
    // 주소
    UILabel *pAddress = [[UILabel alloc] initWithFrame:CGRectMake(x_value, 40, x_width, 13)];
    [pAddress setText:[oms.poiDetailDictionary objectForKeyGC:@"ADDR"]];
    [pAddress setFont:[UIFont systemFontOfSize:13]];
    [pAddress setAdjustsFontSizeToFitWidth:YES];
    [pAddress setNumberOfLines:1];
    [pAddress setBackgroundColor:[UIColor clearColor]];
    
    // 업종명
    UILabel *classify = [[UILabel alloc] initWithFrame:CGRectMake(x_value, 60, x_width, 13)];
    [classify setText:[oms.poiDetailDictionary objectForKeyGC:@"UJ_NAME"]];
    [classify setFont:[UIFont systemFontOfSize:13]];
    [classify setAdjustsFontSizeToFitWidth:YES];
    [classify setNumberOfLines:1];
    [classify setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1.0]];
    [classify setBackgroundColor:[UIColor clearColor]];
    
    // 탑뷰에 넣기
    [topView addSubview:pImg];
    [topView addSubview:pName];
    [topView addSubview:pAddress];
    [topView addSubview:classify];
    
    // 스크롤뷰에 탑뷰 넣기
    [_scrollView addSubview:topView];
    
    // 다음뷰의 y축시작점은 탑뷰의 높이만큼 +
    _oilViewStartY = _oilViewStartY + topViewHeight;
    
    [pImg release];
    [pName release];
    [classify release];
    [pAddress release];
    [topView release];
    
    [self drawUnderLine1];
}

// 탑뷰와 전화번호뷰 사이 밑줄
- (void) drawUnderLine1
{
    UIImageView *uline1 = [[UIImageView alloc] initWithFrame:CGRectMake(X_VALUE, _oilViewStartY, X_WIDTH, 1)];
    
    [uline1 setImage:[UIImage imageNamed:@"poi_list_line_01.png"]];
    
    [_scrollView addSubview:uline1];
    _oilViewStartY = _oilViewStartY + 1;
    [uline1 release];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *telStr = [oms.poiDetailDictionary objectForKeyGC:@"TEL"];
    
    NSLog(@"terStr : %@", telStr);
    if(telStr == nil)
    {
        [self drawBtnView];
    }
    else {
        [self drawTelView];
    }
    
}

// 전화번호뷰
- (void) drawTelView
{
    int telViewHeight = 40;
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 전화번호뷰
    UIView *telView = [[UIView alloc] initWithFrame:CGRectMake(X_VALUE, _oilViewStartY, X_WIDTH, telViewHeight)];
    
    // 전화버튼
    UIButton *telBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [telBtn setBackgroundImage:[UIImage imageNamed:@"poi_busstop_list_bg_pressed.png"] forState:UIControlStateHighlighted];
    [telBtn setFrame:CGRectMake(0, 0, 320, 40)];
    [telBtn addTarget:self action:@selector(telBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 전화이미지
    UIImageView *telImg = [[UIImageView alloc] initWithFrame:CGRectMake(7, 10, 20, 20)];
    
    [telImg setImage:[UIImage imageNamed:@"view_list_b_call.png"]];
    
    // 전화번호라벨
    UILabel *telLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 13, 260, 15)];
    
    [telLabel setText:[oms.poiDetailDictionary objectForKeyGC:@"TEL"]];
    [telLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [telLabel setBackgroundColor:[UIColor clearColor]];
    [telLabel setTextColor:[UIColor colorWithRed:26.0/255.0 green:104.0/255.0 blue:201.0/255.0 alpha:1.0]];
    
    // 전화버튼이미지
    UIImageView *telBtnImg = [[UIImageView alloc] initWithFrame:CGRectMake(303, 14, 7, 12)];
    
    [telBtnImg setImage:[UIImage imageNamed:@"view_list_arrow.png"]];
    
    [telView addSubview:telBtn];
    [telView addSubview:telImg];
    [telView addSubview:telLabel];
    [telView addSubview:telBtnImg];
    
    
    [_scrollView addSubview:telView];
    
    _oilViewStartY = _oilViewStartY + telViewHeight;
    [telLabel release];
    [telImg release];
    [telBtnImg release];
    [telView release];
    
    [self drawUnderLine2];
    
}
// 전번뷰와 버튼뷰 사이 밑줄

- (void) drawUnderLine2
{
    UIImageView *uline2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, _oilViewStartY, 320, 1)];
    
    
    [uline2 setBackgroundColor:[UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0]];
    [uline2 setImage:[UIImage imageNamed:@"poi_list_line_03.png"]];
    
    [_scrollView addSubview:uline2];
    _oilViewStartY = _oilViewStartY + 1;
    
    [uline2 release];
    
    [self drawBtnView];
    
}

// 버튼뷰
-(void) drawBtnView
{
    
    int btnViewHeight = 56;
    
    UIView *btnView = [[UIView alloc] initWithFrame:CGRectMake(0, _oilViewStartY, 320, btnViewHeight)];
    UIImageView *btnBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, btnViewHeight)];
    
    [btnBg setImage:[UIImage imageNamed:@"poi_list_menu_bg.png"]];
    
    [btnView addSubview:btnBg];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(10, 9, 81, 37);
    
    [startBtn setImage:[UIImage imageNamed:@"poi_list_btn_start.png"] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:startBtn];
    
    UIButton *destBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    destBtn.frame = CGRectMake(96, 9, 81, 37);
    
    [destBtn setImage:[UIImage imageNamed:@"poi_list_btn_stop.png"] forState:UIControlStateNormal];
    [destBtn addTarget:self action:@selector(destBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:destBtn];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(182, 9, 61, 37);
    
    [shareBtn setImage:[UIImage imageNamed:@"poi_list_btn_share.png"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:shareBtn];
    
    UIButton *naviBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    naviBtn.frame = CGRectMake(248, 9, 61, 37);
    
    [naviBtn setImage:[UIImage imageNamed:@"poi_list_btn_navi.png"] forState:UIControlStateNormal];
    [naviBtn addTarget:self action:@selector(oilNaviBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:naviBtn];
    
    
    [_scrollView addSubview:btnView];
    _oilViewStartY = _oilViewStartY + btnViewHeight;
    
    [btnBg release];
    [btnView release];
    
    //[self drawUnderLine3];
    [self drawOilInfoLabelIB];
    
}

- (void) drawOilInfoLabelIB
{
    UIView *oilInfoLblView = [[UIView alloc] init];
    [oilInfoLblView setBackgroundColor:[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0]];
    [oilInfoLblView setFrame:CGRectMake(0, _oilViewStartY, 320, 35)];
    
    UILabel *oilInfoLbl = [[UILabel alloc] init];
    [oilInfoLbl setText:@"유가정보"];
    [oilInfoLbl setFont:[UIFont boldSystemFontOfSize:14]];
    [oilInfoLbl setBackgroundColor:[UIColor clearColor]];
    [oilInfoLbl setTextAlignment:NSTextAlignmentCenter];
    CGSize oilLblSize = [oilInfoLbl.text sizeWithFont:oilInfoLbl.font constrainedToSize:CGSizeMake(FLT_MAX, 14)];
    
    [oilInfoLbl setFrame:CGRectMake(10, 10, oilLblSize.width, 14)];
    [oilInfoLblView addSubview:oilInfoLbl];
    
    //NSLog(@"유가정보 x, 너비 : %f, %f", oilInfoLbl.frame.origin.x, oilLblSize.width);
    [oilInfoLbl release];
    
    
    
    _support = [[UILabel alloc] init];
    [_support setText:@"(한국 석유공사 제공)"];
    [_support setBackgroundColor:[UIColor clearColor]];
    [_support setFont:[UIFont systemFontOfSize:11]];
    [_support setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1]];
    
    CGSize supportSize = [_support.text sizeWithFont:_support.font constrainedToSize:CGSizeMake(FLT_MAX, 11)];
    
    [_support setFrame:CGRectMake(70, 11, supportSize.width, 11)];
    [oilInfoLblView addSubview:_support];
    //[support release];
    
    [_scrollView addSubview:oilInfoLblView];
    [oilInfoLblView release];
    _oilViewStartY = _oilViewStartY + 35;
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *masterID = [oms.poiDetailDictionary objectForKeyGC:@"ORG_DB_ID"];
    
    NSLog(@"masterID : %@ 로 유가정보 API GO", masterID);
    [[ServerConnector sharedServerConnection] requestOilDetail:self action:@selector(finishRequestoilDetailAtPoiId2:) uId:masterID];
    
}

// UI 콜백(유가정보리스트뷰)
-(void)finishRequestoilDetailAtPoiId2:(id)request;
{
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        NSMutableDictionary *oilDic = [oms.oilDetailDictionary objectForKeyGC:@"Oil"];
        NSArray *oilPrice = [oilDic objectForKeyGC:@"Oil_price"];
        
        //NSLog(@"기름가격 : %@", oilPrice);
        
        // 유가정보가 있는지 판단
        if(oilPrice == nil)
        {
            [_support setHidden:YES];
            //NSLog(@"없다 ㅡㅡ");
            // 뷰의 높이(고정값)
            int oilInfoNullViewHeight = 163;
            // 유가정보리스트없는 뷰
            UIView *oilInfoNullView = [[UIView alloc] initWithFrame:CGRectMake(X_VALUE, _oilViewStartY, X_VALUE, oilInfoNullViewHeight)];
            
            // 등록된 정보가 없습니다 라벨
            UILabel *nullLabel = [[UILabel alloc] initWithFrame:CGRectMake(X_VALUE, Y_VALUE, X_WIDTH, oilInfoNullViewHeight)];
            
            [nullLabel setText:@"등록된 정보가 없습니다"];
            [nullLabel setTextAlignment:NSTextAlignmentCenter];
            [nullLabel setFont:[UIFont systemFontOfSize:13]];
            [nullLabel setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1.0]];
            
            // 라벨을 뷰에 넣음
            [oilInfoNullView addSubview:nullLabel];
            
            // 뷰를 스크롤뷰에 넣음
            [_scrollView addSubview:oilInfoNullView];
            
            // 시작Y좌표 뷰의 높이만큼 증가
            _oilViewStartY = _oilViewStartY + oilInfoNullViewHeight;
            
            [nullLabel release];
            [oilInfoNullView release];
        }
        
        else
        {
            // 라벨의 x좌표, 너비, 높이
            int x_value = 10;
            int y_value = 14;
            int x_width = 64;
            int y_height = 13;
            
            int y_interval = 40;
            // 유가정보리스트뷰
            UIView *oilInfoView = [[UIView alloc] init];
            
            
            // 라벨사이즈
            UIFont *labelFont = [UIFont boldSystemFontOfSize:13];
            
            // 내용사이즈, 컬러
            UIFont *contentFont = [UIFont systemFontOfSize:13];
            UIColor *contentColor = [UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1.0];
            
            // 내용라벨의 x좌표, 너비, 높이
            int content_x_value = 92;
            int content_x_width = 218;
            int content_y_height = 13;
            
            // 조사시간내용 텍스트
            NSString *tradeDT = nil;
            
            for (NSDictionary *dic in oilPrice)
            {
                NSString *procd = [dic objectForKeyGC:@"PRODCD"];
                NSString *price = [NSString stringWithFormat:@"%@원", [self getAfterFareRefined:[[dic objectForKeyGC:@"PRICE"] doubleValue]]];
                tradeDT = [dic objectForKeyGC:@"TRADE_DT"];
                
                NSLog(@"기름가격 : %@", oilPrice);
                
                if([procd isEqualToString:@"B027"])
                {
                    // 휘발유 라벨
                    UILabel *gasoline = [[UILabel alloc] init];
                    [gasoline setText:@"휘발유"];
                    [gasoline setFont:labelFont];
                    [gasoline setAdjustsFontSizeToFitWidth:YES];
                    [gasoline setFrame:CGRectMake(x_value, y_value, x_width, y_height)];
                    
                    
                    // 휘발유내용
                    UILabel *gasolineContent = [[UILabel alloc] init];
                    [gasolineContent setFont:contentFont];
                    [gasolineContent setTextColor:contentColor];
                    [gasolineContent setAdjustsFontSizeToFitWidth:YES];
                    [gasolineContent setFrame:CGRectMake(content_x_value, y_value, content_x_width, content_y_height)];
                    
                    [gasolineContent setText:price];
                    
                    [oilInfoView addSubview:gasolineContent];
                    [oilInfoView addSubview:gasoline];
                    
                    [gasoline release];
                    [gasolineContent release];
                    
                }
                
                else if ([procd isEqualToString:@"D047"]) {
                    
                    // 경유 라벨
                    UILabel *diesel = [[UILabel alloc] init];
                    [diesel setText:@"경유"];
                    [diesel setFont:labelFont];
                    [diesel setAdjustsFontSizeToFitWidth:YES];
                    [diesel setFrame:CGRectMake(x_value, y_value, x_width, y_height)];
                    
                    //경유내용
                    UILabel *dieselContent = [[UILabel alloc] init];
                    [dieselContent setFont:contentFont];
                    [dieselContent setTextColor:contentColor];
                    [dieselContent setAdjustsFontSizeToFitWidth:YES];
                    [dieselContent setFrame:CGRectMake(content_x_value, y_value, content_x_width, content_y_height)];
                    
                    [dieselContent setText:price];
                    
                    [oilInfoView addSubview:dieselContent];
                    [oilInfoView addSubview:diesel];
                    [diesel release];
                    [dieselContent release];
                    
                    
                }
                else if ([procd isEqualToString:@"B034"]) {
                    
                    
                    // 고급휘발유 라벨
                    UILabel *goodGasoline = [[UILabel alloc] init];
                    [goodGasoline setText:@"고급휘발유"];
                    [goodGasoline setFont:labelFont];
                    
                    CGSize sizeGoodGasoline = [goodGasoline.text sizeWithFont:goodGasoline.font constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX)];
                    [goodGasoline setAdjustsFontSizeToFitWidth:YES];
                    [goodGasoline setFrame:CGRectMake(x_value, y_value, sizeGoodGasoline.width, y_height)];
                    
                    //고급휘발유내용
                    UILabel *goodGasolineContent = [[UILabel alloc] init];
                    [goodGasolineContent setFont:contentFont];
                    [goodGasolineContent setTextColor:contentColor];
                    [goodGasolineContent setAdjustsFontSizeToFitWidth:YES];
                    [goodGasolineContent setFrame:CGRectMake(content_x_value, y_value, content_x_width, content_y_height)];
                    
                    [goodGasolineContent setText:price];
                    [oilInfoView addSubview:goodGasolineContent];
                    [oilInfoView addSubview:goodGasoline];
                    
                    [goodGasoline release];
                    [goodGasolineContent release];
                }
                else if ([procd isEqualToString:@"K015"])
                {
                    // LPG 라벨
                    UILabel *lpg = [[UILabel alloc] init];
                    [lpg setText:@"LPG"];
                    [lpg setFont:labelFont];
                    [lpg setAdjustsFontSizeToFitWidth:YES];
                    [lpg setFrame:CGRectMake(x_value, y_value, x_width, y_height)];
                    
                    
                    // LPG내용
                    UILabel *lpgContent = [[UILabel alloc] init];
                    [lpgContent setFont:contentFont];
                    [lpgContent setTextColor:contentColor];
                    [lpgContent setAdjustsFontSizeToFitWidth:YES];
                    [lpgContent setFrame:CGRectMake(content_x_value, y_value, content_x_width, content_y_height)];
                    
                    [lpgContent setText:price];
                    
                    [oilInfoView addSubview:lpgContent];
                    [oilInfoView addSubview:lpg];
                    
                    [lpg release];
                    [lpgContent release];
                    
                    
                }
                
                y_value += y_interval;
                
                NSLog(@"tradeDT = %@", tradeDT);
                
            }
            
            
            // 조사기간 라벨
            UILabel *researchTime = [[UILabel alloc] init];
            [researchTime setText:@"조사기간"];
            [researchTime setFont:labelFont];
            [researchTime setAdjustsFontSizeToFitWidth:YES];
            [researchTime setFrame:CGRectMake(x_value, y_value, x_width, y_height)];
            
            // 조사기간내용
            UILabel *researchTimeContent = [[UILabel alloc] init];
            [researchTimeContent setText:@"-"];
            [researchTimeContent setFont:contentFont];
            [researchTimeContent setTextColor:contentColor];
            [researchTimeContent setAdjustsFontSizeToFitWidth:YES];
            [researchTimeContent setFrame:CGRectMake(content_x_value, y_value, content_x_width, content_y_height)];
            
            y_value += 32;
            
            // 텍스트에 - 로 년월일 구분
            tradeDT = [NSString stringWithFormat:@"%@-%@-%@", [tradeDT substringToIndex:4],
                       [tradeDT substringWithRange:NSMakeRange(4,2)],
                       [tradeDT substringFromIndex:6]];
            // 다시 넣음
            [researchTimeContent setText:tradeDT];
            
            [oilInfoView addSubview:researchTimeContent];
            
            // 가격정보는 실제 판매 가격과 다를 수 있습니다
            UILabel *warning = [[UILabel alloc] init];
            [warning setText:@"(*가격 정보는 실제 판매 가격과 다를 수 있습니다.)"];
            [warning setFont:[UIFont systemFontOfSize:12]];
            [warning setAdjustsFontSizeToFitWidth:YES];
            [warning setTextColor:contentColor];
            [warning setFrame:CGRectMake(x_value, y_value, 300, 12)];
            
            y_value += 41;
            
            [oilInfoView addSubview:researchTime];
            [oilInfoView addSubview:warning];
            
            
            // 밑줄(구분선)
            // 너비, 높이
            CGRect line2Viewbounds = _underline.bounds;
            CGFloat line2ViewWidth = CGRectGetWidth(line2Viewbounds);
            CGFloat line2ViewHeight = CGRectGetHeight(line2Viewbounds);
            
            [_underline setFrame:CGRectMake(X_VALUE, y_value, line2ViewWidth, line2ViewHeight)];
            [oilInfoView addSubview:_underline];
            
            y_value += 20;
            
            // 세차장, 편의점, 경정비, 주유소 종류
            // 세차장 라벨
            UILabel *carWash = [[UILabel alloc] init];
            [carWash setText:@"세차장"];
            [carWash setFont:labelFont];
            [carWash setAdjustsFontSizeToFitWidth:YES];
            [carWash setFrame:CGRectMake(x_value, y_value, x_width, y_height)];
            
            
            // 세차장 내용(Y/N)
            UILabel *carWashContent = [[UILabel alloc] init];
            [carWashContent setFont:contentFont];
            [carWashContent setTextColor:contentColor];
            [carWashContent setAdjustsFontSizeToFitWidth:YES];
            [carWashContent setFrame:CGRectMake(content_x_value, y_value, content_x_width, content_y_height)];
            
            [carWashContent setText:[self convertToDescription:[oilDic objectForKeyGC:@"CAR_WASH_YN"]]];
            
            [oilInfoView addSubview:carWashContent];
            [oilInfoView addSubview:carWash];
            
            [carWash release];
            [carWashContent release];
            
            
            y_value += 40;
            
            // 편의점 라벨
            UILabel *cvs = [[UILabel alloc] init];
            [cvs setText:@"편의점"];
            [cvs setFont:labelFont];
            [cvs setAdjustsFontSizeToFitWidth:YES];
            [cvs setFrame:CGRectMake(x_value, y_value, x_width, y_height)];
            
            
            // 편의점 내용(Y/N)
            UILabel *cvsContent = [[UILabel alloc] init];
            [cvsContent setFont:contentFont];
            [cvsContent setTextColor:contentColor];
            [cvsContent setAdjustsFontSizeToFitWidth:YES];
            [cvsContent setFrame:CGRectMake(content_x_value, y_value, content_x_width, content_y_height)];
            
            [cvsContent setText:[self convertToDescription:[oilDic objectForKeyGC:@"CVS_YN"]]];
            
            [oilInfoView addSubview:cvsContent];
            [oilInfoView addSubview:cvs];
            
            [cvs release];
            [cvsContent release];
            
            
            y_value += 40;
            
            // 경정비 라벨
            UILabel *maint = [[UILabel alloc] init];
            [maint setText:@"경정비"];
            [maint setFont:labelFont];
            [maint setAdjustsFontSizeToFitWidth:YES];
            [maint setFrame:CGRectMake(x_value, y_value, x_width, y_height)];
            
            
            // 경정비 내용(Y/N)
            UILabel *maintContent = [[UILabel alloc] init];
            [maintContent setFont:contentFont];
            [maintContent setTextColor:contentColor];
            [maintContent setAdjustsFontSizeToFitWidth:YES];
            [maintContent setFrame:CGRectMake(content_x_value, y_value, content_x_width, content_y_height)];
            
            [maintContent setText:[self convertToDescription:[oilDic objectForKeyGC:@"MAINT_YN"]]];
            
            [oilInfoView addSubview:maintContent];
            [oilInfoView addSubview:maint];
            
            [maint release];
            [maintContent release];
            
            
            y_value += 40;
            
            // 주유소 종류 라벨
            UILabel *kindOfOil = [[UILabel alloc] init];
            [kindOfOil setText:@"주유소 종류"];
            [kindOfOil setFont:labelFont];
            [kindOfOil setAdjustsFontSizeToFitWidth:YES];
            [kindOfOil setFrame:CGRectMake(x_value, y_value, x_width, y_height)];
            
            
            // 주유소 종류 내용(Y=LPG/N=기름/C=공통)
            UILabel *kindOfOilContent = [[UILabel alloc] init];
            [kindOfOilContent setFont:contentFont];
            [kindOfOilContent setTextColor:contentColor];
            [kindOfOilContent setAdjustsFontSizeToFitWidth:YES];
            [kindOfOilContent setFrame:CGRectMake(content_x_value, y_value, content_x_width, content_y_height)];
            
            [kindOfOilContent setText:[self kindOfOil:[oilDic objectForKeyGC:@"LPG_YN"]]];
            
            [oilInfoView addSubview:kindOfOilContent];
            [oilInfoView addSubview:kindOfOil];
            
            [kindOfOil release];
            [kindOfOilContent release];
            
            y_value += 40;
            
            [oilInfoView setFrame:CGRectMake(X_VALUE, _oilViewStartY, X_WIDTH, y_value)];
            _oilViewStartY = _oilViewStartY + y_value;
            
            NSLog(@"스크롤뷰높이 : %f", _scrollView.frame.size.height);
            
            // 사이즈 작으면 버튼뷰를 스크롤뷰 아래에 붙임
            if(_oilViewStartY + 37 <= _scrollView.frame.size.height)
            {
                _oilViewStartY = _scrollView.frame.size.height - 37;
            }
            
            [_scrollView addSubview:oilInfoView];
            
            
            NSLog(@"_viewStartY = %d", _oilViewStartY);
            
            
            
            
            
            [researchTime release];
            [warning release];
            
            
            
            [researchTimeContent release];
            
            [oilInfoView release];
            
            
        }
        
        
        
        [self drawButtonView];
        
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    
}

- (NSString *) convertToDescription:(NSString *)value
{
    if ([@"Y" caseInsensitiveCompare:value])
    {
        return @"유";
    }
    else
    {
        // "null" & "N" 포함
        return @"무";
    }
}

- (NSString *) kindOfOil:(NSString *)value
{
    if ([@"Y" caseInsensitiveCompare:value] == 0)
    {
        return @"LPG";
    }
    else if ([@"N" caseInsensitiveCompare:value] == 0)
    {
        return @"기름";
    }
    else if ([@"C" caseInsensitiveCompare:value] == 0)
    {
        return @"LPG & 기름";
    }
    else
    {
        return @"입력된 정보 없음";
    }
}

// 최하단 버튼뷰
- (void) drawButtonView
{
    NSLog(@"_viewStartY = %d", _oilViewStartY);
    [_buttonView setFrame:CGRectMake(0, _oilViewStartY, 320, 37)];
    //    [_buttonView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_scrollView addSubview:_buttonView];
    _oilViewStartY = _oilViewStartY + 37;
    
    [self drawScrollView];
}

// 스크롤뷰 높이
- (void) drawScrollView
{
    _scrollView.contentSize = CGSizeMake(320, _oilViewStartY);
}

#pragma mark -
#pragma mark - 최하단버튼액션
// 즐겨찾기버튼
- (IBAction)favoriteBtnClick:(id)sender
{
    // 즐겨찾기 선택 통계
    [[OllehMapStatus sharedOllehMapStatus] trackPageView:@"/POI_detail/favorite"];
    
    DbHelper *dh = [[[DbHelper alloc] init] autorelease];
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    NSString *ujName = [oms.poiDetailDictionary objectForKeyGC:@"UJ_NAME"];
    
    NSMutableDictionary *fdic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Local title1:[oms.poiDetailDictionary objectForKeyGC:@"NAME"] title2:[oms ujNameSegment:ujName] title3:@"" iconType:Favorite_IconType_POI coord1x:[[oms.poiDetailDictionary objectForKeyGC:@"X"] doubleValue] coord1y:[[oms.poiDetailDictionary objectForKeyGC:@"Y"] doubleValue] coord2x:0 coord2y:0 coord3x:0 coord3y:0 detailType:@"OL" detailID:[oms.poiDetailDictionary objectForKeyGC:@"POI_ID"] shapeType:@"" fcNm:@"" idBgm:@""];
    
    if([dh favoriteValidCheck:fdic])
    {
        [self typeChecker:3];
        [self bottomViewFavorite:fdic placeHolder:[oms.poiDetailDictionary objectForKeyGC:@"NAME"]];
    }

}
// 연락처버튼
- (IBAction)contactBtnClick:(id)sender
{
    [self modalContact:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary];
}
// 정보수정버튼
- (IBAction)infoModifyAskBtnClick:(id)sender
{
    [self typeChecker:3];
    [self modalInfoModify:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary];

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

#pragma mark -
#pragma mark 출발~네비, 전화걸기 액션

- (void) telBtnClick:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    NSString *telNum = [oms.poiDetailDictionary objectForKeyGC:@"TEL"];
    
    [self typeChecker:3];
    [self telViewCallBtnClick:telNum];
}

- (void) startBtnClick:(id)sender
{
    [self typeChecker:3];
    [self btnViewStartBtnClick:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary];
}
- (void) destBtnClick:(id)sender
{
    [self typeChecker:3];
    [self btnViewDestBtnClick:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary ];
}

- (void) shareBtnClick:(id)sender
{
    [self typeChecker:3];
    [self btnViewShareBtnClick];
}
- (void) oilNaviBtnClick:(id)sender
{
    [self typeChecker:3];
    [self btnViewNaviBtnClick:[OllehMapStatus sharedOllehMapStatus].poiDetailDictionary ];
}
// 세자리 소숫점
- (NSString*) getAfterFareRefined :(double) fare
{
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *str = [NSString stringWithFormat:@"%@", [fmt stringFromNumber:[NSNumber numberWithInt:fare]]];    
    [fmt release];
    return str;
}


@end
