//
//  ResolutionViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 5..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "ResolutionViewController.h"
#import "MapContainer.h"

@interface ResolutionViewController ()

@end

@implementation ResolutionViewController

@synthesize hdBtn = _hdBtn;
@synthesize smallBtn = _smallBtn;
@synthesize bigBtn = _bigBtn;

- (void)dealloc
{
    [_hdBtn release];
    _hdBtn = nil;
    [_smallBtn release];
    _smallBtn = nil;
    [_bigBtn release];
    _bigBtn = nil;
    [_hdImg release];
    _hdImg = nil;
    [_smallImg release];
    _smallImg = nil;
    [_bigImg release];
    _bigImg = nil;
    
    [super dealloc];
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    [self setHdBtn:nil];
    [self setSmallBtn:nil];
    [self setBigBtn:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _viewStartY = 37;
    
    _hdBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _hdImg = [[UIImageView alloc] init];
    _smallBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _smallImg = [[UIImageView alloc] init];
    _bigBtn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    _bigImg = [[UIImageView alloc] init];
    
    int resolution = [[OllehMapStatus sharedOllehMapStatus] getDisplayMapResolution];
    _hdBtn.selected = resolution == KMapDisplayHD;
    _bigBtn.selected = resolution == KMapDisplayNormalBigText;
    _smallBtn.selected = resolution == KMapDisplayNormalSmallText;
    
    if(_hdBtn.selected)
    {
        _case = 1;
    }
    else if (_smallBtn.selected)
    {
        _case = 2;
    }
    else if (_bigBtn.selected)
    {
        _case = 3;
    }
    
    [self drawTopView];
}

- (void) drawTopView
{
    
    // 뷰 값
    int topViewHeight = 225;
    
    
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, _viewStartY, 320, topViewHeight)];
    [topView setBackgroundColor:[UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1]];
    
    
    // 라벨X
    int lblX = 21;
    // 첫라벨Y
    int lblY = 16;
    // 라벨너비
    int lblWidth = 279;
    
    
    UILabel *toplbl = [[UILabel alloc] init];
    [toplbl setNumberOfLines:2];
    [toplbl setText:@"고해상도 모드(HD)는 일반 모드보다 선명한 지도화질을 이용 할 수 있습니다"];
    [toplbl setBackgroundColor:[UIColor clearColor]];
    [toplbl setFont:[UIFont systemFontOfSize:13]];
    
    CGSize toplblSize = [toplbl.text sizeWithFont:toplbl.font constrainedToSize:CGSizeMake(lblWidth, FLT_MAX)];
    
    [topView addSubview:toplbl];
    [toplbl setFrame:CGRectMake(lblX, lblY, lblWidth, toplblSize.height)];
    [toplbl release];
    
    // 볼드체라벨과 아래라벨의 간격 10
    UILabel *middlelbl = [[UILabel alloc] initWithFrame:CGRectMake(lblX, lblY +toplblSize.height + 10, lblWidth, 11)];
    
    [middlelbl setText:@"- 고해상도 모드(HD)시 데이터 사용량이 늘어납니다."];
    [middlelbl setFont:[UIFont systemFontOfSize:11]];
    [middlelbl setBackgroundColor:[UIColor clearColor]];
    [middlelbl setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1]];
    [topView addSubview:middlelbl];
    [middlelbl release];
    
    // 볼드체라벨과 아래라벨의 간격 10, 아래라벨간격 6
    //    UILabel *bottomlbl = [[UILabel alloc] initWithFrame:CGRectMake(lblX, lblY +toplblSize.height + 10 + middlelbl.frame.size.height + 6, lblWidth, 11)];
    //
    //    [bottomlbl setText:@"- 저해상도 단말기는 지원되지 않습니다"];
    //    [bottomlbl setFont:[UIFont systemFontOfSize:11]];
    //    [bottomlbl setBackgroundColor:[UIColor clearColor]];
    //    [bottomlbl setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1]];
    //    [topView addSubview:bottomlbl];
    //    [bottomlbl release];
    
    
    // 각 뷰의 프레임
    int btnX = 10;
    int btnY = 78;
    int btnWidth = 300;
    int btnHeight = 45;
    
    
    // 고해상도
    
    // 뷰
    UIView *hdView = [[UIView alloc] initWithFrame:CGRectMake(btnX, btnY, btnWidth, btnHeight)];
    // 뷰배경
    UIImageView *hdBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, btnWidth, btnHeight)];
    [hdBg setImage:[UIImage imageNamed:@"setting_box_top.png"]];
    [hdView addSubview:hdBg];
    [hdBg release];
    
    // 뷰버튼
    [_hdBtn setFrame:CGRectMake(0, 0, btnWidth, btnHeight)];
    //[_hdBtn setBackgroundImage:[UIImage imageNamed:@"setting_box_top_pressed.png"] forState:UIControlStateHighlighted];
    [_hdBtn addTarget:self action:@selector(hdBtnHighlight:) forControlEvents:UIControlEventTouchDown];
    [_hdBtn addTarget:self action:@selector(btnTouchOutSide:) forControlEvents:UIControlEventTouchUpOutside];
    [_hdBtn addTarget:self action:@selector(hdBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [hdView addSubview:_hdBtn];
    
    // 뷰라벨
    UILabel *hdLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 16, 200, 14)];
    [hdLabel setText:@"고해상도 모드(HD)"];
    [hdLabel setBackgroundColor:[UIColor clearColor]];
    [hdLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [hdView addSubview:hdLabel];
    [hdLabel release];
    
    // 라디오버튼
    [_hdImg setFrame:CGRectMake(265, 10, 25, 25)];
    
    if(_case == 1)
        [_hdImg setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
    else {
        [_hdImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    }
    
    [hdView addSubview:_hdImg];
    
    
    btnY += btnHeight;
    
    // 밑줄
    UIImageView *underline1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, btnHeight, btnWidth, 1)];
    [underline1 setImage:[UIImage imageNamed:@"mapdpi_line.png"]];
    
    btnY += 1;
    [hdView addSubview:underline1];
    [underline1 release];
    
    
    [topView addSubview:hdView];
    
    [hdView release];
    
    // 일반모드(작)
    
    // 뷰
    UIView *smallView = [[UIView alloc] initWithFrame:CGRectMake(btnX, btnY, btnWidth, btnHeight)];
    // 뷰배경
    UIImageView *smallBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, btnWidth, btnHeight)];
    [smallBg setImage:[UIImage imageNamed:@"setting_box_center.png"]];
    [smallView addSubview:smallBg];
    [smallBg release];
    
    // 뷰버튼
    [_smallBtn setFrame:CGRectMake(0, 0, btnWidth, btnHeight)];
    //[_smallBtn setBackgroundImage:[UIImage imageNamed:@"setting_box_center_pressed.png"] forState:UIControlStateHighlighted];
    [_smallBtn addTarget:self action:@selector(smallBtnHighlight:) forControlEvents:UIControlEventTouchDown];
    [_smallBtn addTarget:self action:@selector(btnTouchOutSide:) forControlEvents:UIControlEventTouchUpOutside];
    [_smallBtn addTarget:self action:@selector(smallBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [smallView addSubview:_smallBtn];
    
    // 뷰라벨
    UILabel *smallLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 16, 200, 14)];
    [smallLabel setText:@"일반 모드(작은 글씨)"];
    [smallLabel setBackgroundColor:[UIColor clearColor]];
    [smallLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [smallView addSubview:smallLabel];
    [smallLabel release];
    
    // 라디오버튼
    [_smallImg setFrame:CGRectMake(265, 10, 25, 25)];
    if(_case == 2)
        [_smallImg setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
    else {
        [_smallImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    }
    [smallView addSubview:_smallImg];
    
    
    btnY += btnHeight;
    
    // 밑줄
    UIImageView *underline2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, btnHeight, btnWidth, 1)];
    [underline2 setImage:[UIImage imageNamed:@"mapdpi_line.png"]];
    
    btnY += 1;
    [smallView addSubview:underline2];
    [underline2 release];
    
    [topView addSubview:smallView];
    
    [smallView release];
    
    
    //
    
    // 일반모드(큰)
    
    // 뷰
    UIView *bigView = [[UIView alloc] initWithFrame:CGRectMake(btnX, btnY, btnWidth, btnHeight)];
    // 뷰배경
    UIImageView *bigBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, btnWidth, btnHeight)];
    [bigBg setImage:[UIImage imageNamed:@"setting_box_bottom.png"]];
    [bigView addSubview:bigBg];
    [bigBg release];
    
    // 뷰버튼
    [_bigBtn setFrame:CGRectMake(0, 0, btnWidth, btnHeight)];
    [_bigBtn addTarget:self action:@selector(bigBtnHighlight:) forControlEvents:UIControlEventTouchDown];
    [_bigBtn addTarget:self action:@selector(btnTouchOutSide:) forControlEvents:UIControlEventTouchUpOutside];
    //[_bigBtn setBackgroundImage:[UIImage imageNamed:@"setting_box_bottom_pressed.png"] forState:UIControlStateHighlighted];
    [_bigBtn addTarget:self action:@selector(bigBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [bigView addSubview:_bigBtn];
    
    // 뷰라벨
    UILabel *bigLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 16, 200, 14)];
    [bigLabel setText:@"일반 모드(큰 글씨)"];
    [bigLabel setBackgroundColor:[UIColor clearColor]];
    [bigLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [bigView addSubview:bigLabel];
    [bigLabel release];
    // 라디오버튼
    [_bigImg setFrame:CGRectMake(265, 10, 25, 25)];
    if(_case == 3)
        [_bigImg setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
    else {
        [_bigImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    }
    [bigView addSubview:_bigImg];
    
    
    [topView addSubview:bigView];
    
    [bigView release];
    
    _viewStartY += topViewHeight;
    
    
    [self.view addSubview:topView];
    
    [topView release];
    
    [self drawUnderLine];
    
}

- (void) drawUnderLine
{
    // 밑줄
    
    UIImageView *viewUnderLine = [[UIImageView alloc] init];
    [viewUnderLine setFrame:CGRectMake(0, _viewStartY, 320, 1)];
    [viewUnderLine setImage:[UIImage imageNamed:@"list_line.png"]];
    //[viewUnderLine setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:viewUnderLine];
    [viewUnderLine release];
    
    _viewStartY += 1;
    
    [self drawImg];
    
}

- (void) drawImg
{
    // 이미지 파일명
    NSString *mapImgName = nil;
    switch (_case)
    {
        case 1:
            if (IS_4_INCH)  mapImgName = @"map_img_01-568h.png";
            else            mapImgName = @"map_img_01.png";
            break;
        case 2:
            if (IS_4_INCH)  mapImgName = @"map_img_02-568h.png";
            else            mapImgName = @"map_img_02.png";
            break;
        case 3:
            if (IS_4_INCH)  mapImgName = @"map_img_03-568h.png";
            else            mapImgName = @"map_img_03.png";
            break;
    }
    
    // 이미지 사이즈
    CGRect mapImgSize = CGRectMake(0, _viewStartY, 320, 197);
    if (IS_4_INCH)
    {
        mapImgSize.size.height = 285;
    }
    
    UIImageView *mapImg = [[UIImageView alloc] init];
    
    [mapImg setFrame:mapImgSize];
    [mapImg setImage:[UIImage imageNamed:mapImgName]];
    
    [self.view addSubview:mapImg];
    
    [mapImg release];
}
- (void) hdBtnClick:(id)sender
{
    _case = 1;
    
    //[OMMessageBox showAlertMessage:@"hd" :@"hd모드"];
    [_hdImg setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
    [_smallImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    [_bigImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    
    [[OllehMapStatus sharedOllehMapStatus] setDisplayMapResolution:KMapDisplayHD];
    [MapContainer changeMapDisplayResolution:KMapDisplayHD];
    
    // HD지도는 지적도 지원안함
    [[MapContainer sharedMapContainer_Main].kmap setCadastralInfo:NO];
    
    [self drawImg];
    
    
}
- (void) hdBtnHighlight:(id)sender
{
    [_hdImg setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
    [_smallImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    [_bigImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
}
- (void) btnTouchOutSide:(id)sender
{
    if(_case == 1)
    {
        [_hdImg setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
        [_smallImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
        [_bigImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    }
    else if (_case == 2)
    {
        [_smallImg setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
        [_hdImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
        [_bigImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    }
    else if (_case == 3)
    {
        [_bigImg setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
        [_smallImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
        [_hdImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    }
}
- (void) smallBtnClick:(id)sender
{
    
    _case = 2;
    
    //[OMMessageBox showAlertMessage:@"small" :@"일반스몰모드"];
    
    [_smallImg setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
    [_hdImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    [_bigImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    
    [[OllehMapStatus sharedOllehMapStatus] setDisplayMapResolution:KMapDisplayNormalSmallText];
    [MapContainer changeMapDisplayResolution:KMapDisplayNormalSmallText];
    
    [self drawImg];
    
}
- (void) smallBtnHighlight:(id)sender
{
    [_smallImg setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
    [_hdImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    [_bigImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
}
- (void) bigBtnClick:(id)sender
{
    //[OMMessageBox showAlertMessage:@"big" :@"일반빅모드"];
    
    _case = 3;
    
    [_bigImg setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
    [_smallImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    [_hdImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    
    [[OllehMapStatus sharedOllehMapStatus] setDisplayMapResolution:KMapDisplayNormalBigText];
    [MapContainer changeMapDisplayResolution:KMapDisplayNormalBigText];
    
    [self drawImg];
}
- (void) bigBtnHighlight:(id)sender
{
    [_bigImg setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"]];
    [_smallImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
    [_hdImg setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"]];
}
- (IBAction)popBtnClick:(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

@end
