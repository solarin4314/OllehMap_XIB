//
//  AddressPOIViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 25..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "AddressPOIViewController.h"
#import "MapContainer.h"
#import "MainMapViewController.h"

@interface AddressPOIViewController ()

@end

@implementation AddressPOIViewController

@synthesize scrollView = _scrollView;
@synthesize mapBtn = _mapBtn;
@synthesize poiCrd = _poiCrd;
@synthesize poiAddress = _poiAddress;
@synthesize poiSubAddress = _poiSubAddress;
@synthesize oldOrNew = _oldOrNew;


#pragma mark -
#pragma mark Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) dealloc
{
    [_poiAddress release];
    [_mapBtn release];
    [_scrollView release];
    [_poiSubAddress release];
    [_oldOrNew release];
    [super dealloc];
}
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    
    //[_mapBtn setHidden:!_displayMapBtn];
    //[_mapBtn setHidden:_mapBtnHidden];
    [_mapBtn setHidden:NO];
    [_mapBtn setEnabled:_displayMapBtn];
    
    // 좌표값이 0이면 disabled
    if(_poiCrd.x == 0 && _poiCrd.y == 0)
        [_mapBtn setEnabled:NO];
    
}
- (void)viewDidUnload
{
    [self setMapBtn:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[OMMessageBox showAlertMessage:@"구현중" :@"구현중...."];
    
    //_poiAddress = @"길음동 26-27";
    
    _viewStartY = GeneralStartY;
    // Do any additional setup after loading the view from its nib.
    
    // 일단 그리고 시작
    [self getDictionary];
    
    [self drawTopView];
}

// 딕셔너리를 만든다
- (void) getDictionary
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    [oms.addressPOIDictionary removeAllObjects];
    
    Coord poiCrd = _poiCrd;
    double x = poiCrd.x;
    double y = poiCrd.y;
    
    [oms.addressPOIDictionary setObject:_poiAddress forKey:@"NAME"];
    [oms.addressPOIDictionary setObject:_poiSubAddress forKey:@"ADDR"];
    [oms.addressPOIDictionary setValue:[NSNumber numberWithDouble:x] forKey:@"X"];
    [oms.addressPOIDictionary setValue:[NSNumber numberWithDouble:y] forKey:@"Y"];
    
}

#pragma mark -
#pragma mark AddressPOIViewController
- (void) saveRecentSearch
{
    NSString *addName = _poiAddress;
    NSString *newDetail = _poiSubAddress;
    //NSString *oldOrNew = self.oldOrNew;
    
    if([newDetail isEqualToString:@""] || !newDetail)
    {
        newDetail = @"";
    }
    else
        newDetail = _poiSubAddress;
    
    NSMutableDictionary *addPOIDic = [NSMutableDictionary dictionary];
    
    Coord addPOICrd = _poiCrd;
    
    double xx = addPOICrd.x;
    double yy = addPOICrd.y;
    
    [addPOIDic setObject:addName forKey:@"NAME"];
    [addPOIDic setObject:newDetail forKey:@"NEWADDRESS"];
    [addPOIDic setObject:self.oldOrNew forKey:@"OLDORNEW"];
    [addPOIDic setObject:@"" forKey:@"CLASSIFY"];
    [addPOIDic setValue:[NSNumber numberWithDouble:xx] forKey:@"X"];
    [addPOIDic setValue:[NSNumber numberWithDouble:yy] forKey:@"Y"];
    [addPOIDic setObject:@"ADDR" forKey:@"TYPE"];
    [addPOIDic setObject:@"" forKey:@"ID"];
    [addPOIDic setObject:@"" forKey:@"TEL"];
    [addPOIDic setObject:addName forKey:@"ADDR"];
    [addPOIDic setObject:[NSNumber numberWithInt:Favorite_IconType_POI] forKey:@"ICONTYPE"];
    
    NSLog(@"최근검색저장 : %@", addPOIDic);
    
    [[OllehMapStatus sharedOllehMapStatus] addRecentSearch:addPOIDic];
}

// 최상단 뷰(이름, 주소, 분류, 이미지)
- (void) drawTopView
{
    int topViewHeight = 90;
    
    UIColor *labelBg = [UIColor clearColor];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, _viewStartY, 320, topViewHeight)];
    [topView setBackgroundColor:[UIColor colorWithRed:217.0/255.0 green:244.0/255.0 blue:255.0/255.0 alpha:1]];
    
    // 주소이름
    UILabel *poiName = [[UILabel alloc] init];
    [poiName setText:_poiAddress];
    [poiName setFont:[UIFont boldSystemFontOfSize:13]];
    [poiName setBackgroundColor:labelBg];
    [poiName setNumberOfLines:0];
    
    CGSize poiNameSize = [poiName.text sizeWithFont:poiName.font constrainedToSize:CGSizeMake(220, FLT_MAX)];
    
    [poiName setFrame:CGRectMake(90, 16, poiNameSize.width, poiNameSize.height)];
    
    [topView addSubview:poiName];
    [poiName release];
    
    if([_poiSubAddress isEqualToString:@""])
    {
        
    }
    else
    {
        // 서브주소
        UILabel *subAddr = [[UILabel alloc] init];
        [subAddr setFont:[UIFont systemFontOfSize:13]];
        [subAddr setTextColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1)];
        [subAddr setText:self.poiSubAddress];
        [subAddr setNumberOfLines:0];
        [subAddr setBackgroundColor:[UIColor clearColor]];
        
        CGSize subAddSize = [_poiSubAddress sizeWithFont:subAddr.font constrainedToSize:CGSizeMake(183, FLT_MAX)];
        
        [subAddr setFrame:CGRectMake(127, 16 + poiNameSize.height + 4, 183, subAddSize.height)];
        [topView addSubview:subAddr];
        [subAddr release];
        
        // 서브주소이미지
        UIImageView *subImg = [[UIImageView alloc] init];
        
        if([self.oldOrNew isEqualToString:@"Old"])
        {
            [subImg setImage:[UIImage imageNamed:@"new_address_icon.png"]];
        }
        else
        {
            [subImg setImage:[UIImage imageNamed:@"old_address_icon.png"]];
        }
        
        [subImg setFrame:CGRectMake(90, 16 + poiNameSize.height + 6 - 1, 33, 15)];
        
        [topView addSubview:subImg];
        
        [subImg release];
        
    }
    
    
    
    
    UIImageView *poiImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 70, 70)];
    [poiImg setImage:[UIImage imageNamed:@"view_default_img_box.png"]];
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
    
    // 상단뷰 밑줄
    [self drawUnderLine1];
    
}

// 상단뷰 밑줄
- (void) drawUnderLine1
{
    UIImageView *underLine1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, _viewStartY, 320, 1)];
    [underLine1 setImage:[UIImage imageNamed:@"poi_list_line_01.png"]];
    // 스크롤뷰에 밑줄뷰 추가
    [_scrollView addSubview:underLine1];
    [underLine1 release];
    _viewStartY += 1;
    
    NSLog(@"전번시작y : %d", _viewStartY);
    
    // 일단 전번 없으니 바로 밑줄로 가겠어
    [self drawBtnView];
}

// 중간 버튼뷰 : 출발지, 도착지, 위치공유, 올레Navi
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
    [startBtn addTarget:self action:@selector(startClickAd:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:startBtn];
    
    UIButton *destBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    destBtn.frame = CGRectMake(96, 9, 81, 37);
    
    [destBtn setImage:[UIImage imageNamed:@"poi_list_btn_stop.png"] forState:UIControlStateNormal];
    [destBtn addTarget:self action:@selector(destClickAd:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:destBtn];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(182, 9, 61, 37);
    
    [shareBtn setImage:[UIImage imageNamed:@"poi_list_btn_share.png"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareClickAd:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:shareBtn];
    
    UIButton *naviBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    naviBtn.frame = CGRectMake(248, 9, 61, 37);
    
    [naviBtn setImage:[UIImage imageNamed:@"poi_list_btn_navi.png"] forState:UIControlStateNormal];
    [naviBtn addTarget:self action:@selector(naviClickAd:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnView addSubview:naviBtn];
    
    
    [_scrollView addSubview:btnView];
    
    _viewStartY += btnViewHeight;
    
    
    [btnBg release];
    [btnView release];
    
    [self drawNullLabel];
}
// 공백라벨
- (void) drawNullLabel
{
    // 높이
    _nullSizeY = ([UIScreen mainScreen].bounds.size.height
                  - 37
                  - 20) - _viewStartY;
    
    int nullLblY = ((_nullSizeY / 2) - 26) + _viewStartY;
    
    UILabel *nullLbl = [[UILabel alloc] init];
    
    [nullLbl setFrame:CGRectMake(0, nullLblY, 320, 13)];
    [nullLbl setText:@"등록된 정보가 없습니다"];
    [nullLbl setFont:[UIFont systemFontOfSize:13]];
    [nullLbl setTextColor:[UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1]];
    [nullLbl setTextAlignment:NSTextAlignmentCenter];
    
    [_scrollView addSubview:nullLbl];
    [nullLbl release];
    
    _viewStartY += _nullSizeY;
    
    [self drawBottomView];
}

// 버튼뷰 : 즐겨찾기 추가, 연락처 추가, 정보수정 요청
- (void) drawBottomView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _viewStartY - 37, 320, 37)];
    
    UIButton *favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [favoriteBtn setFrame:CGRectMake(0, 0, 107, 37)];
    [favoriteBtn setImage:[UIImage imageNamed:@"poi_botton_btn_01.png"] forState:UIControlStateNormal];
    [favoriteBtn addTarget:self action:@selector(favoBtnClickAd:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:favoriteBtn];

    UIButton *contactBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [contactBtn setFrame:CGRectMake(107, 0, 106, 37)];
    [contactBtn setImage:[UIImage imageNamed:@"poi_botton_btn_02.png"] forState:UIControlStateNormal];
    [contactBtn addTarget:self action:@selector(contactBtnClickAd:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:contactBtn];

    
    UIButton *infoModifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoModifyBtn setFrame:CGRectMake(213, 0, 107, 37)];
    [infoModifyBtn setImage:[UIImage imageNamed:@"poi_botton_btn_03.png"] forState:UIControlStateNormal];
    [infoModifyBtn addTarget:self action:@selector(modifyBtnClickAd:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:infoModifyBtn];
    
    [_scrollView addSubview:bottomView];
    
    [bottomView release];
    
    //_viewStartY += 37;
    
    [self drawScrollViewHeight];
}
- (void) drawScrollViewHeight
{
    _scrollView.contentSize = CGSizeMake(320, _viewStartY);
    //[_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_scrollView setAutoresizesSubviews:YES];
    
    [self saveRecentSearch];
}

#pragma mark -
#pragma mark IBAction
- (IBAction)popBtnClick:(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}
- (IBAction)mapBtnClick:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    [oms.searchResult reset]; // 검색결과 리셋
    [oms.searchResult setUsed:YES];
    [oms.searchResult setIsCurrentLocation:NO];
    [oms.searchResult setStrLocationName:_poiAddress];
    [oms.searchResult setStrLocationAddress:_poiAddress];
    
    Coord poiCrd = _poiCrd;
    
    double xx = poiCrd.x;
    double yy = poiCrd.y;
    [oms.searchResult setCoordLocationPoint:CoordMake(xx, yy)];

    [MainMapViewController markingSinglePOI_RenderType:MainMap_SinglePOI_Type_Normal animated:NO];
    
}
- (void) startClickAd:(id)sender
{
    [self typeChecker:4];
    [self btnViewStartBtnClick:[OllehMapStatus sharedOllehMapStatus].addressPOIDictionary];
}
- (void) destClickAd:(id)sender
{
    [self typeChecker:4];
    [self btnViewDestBtnClick:[OllehMapStatus sharedOllehMapStatus].addressPOIDictionary];
}
- (void) shareClickAd:(id)sender
{
    [self typeChecker:4];
    [self btnViewShareBtnClick];
}
- (void) naviClickAd:(id)sender
{
    [self typeChecker:4];
    [self btnViewNaviBtnClick:[OllehMapStatus sharedOllehMapStatus].addressPOIDictionary];
}

- (void) favoBtnClickAd:(id)sender
{
    DbHelper *dh = [[[DbHelper alloc] init] autorelease];
    
    NSMutableDictionary *fdic = [OMDatabaseConverter makeFavoriteDictionary:-1 sortOrder:-1 category:Favorite_Category_Local title1:_poiAddress title2:_poiAddress title3:@"" iconType:Favorite_IconType_POI coord1x:_poiCrd.x coord1y:_poiCrd.y coord2x:0 coord2y:0 coord3x:0 coord3y:0 detailType:@"ADDR" detailID:@"" shapeType:@"" fcNm:@"" idBgm:@""];
    
    if([dh favoriteValidCheck:fdic])
    {
        [self typeChecker:4];
        [self bottomViewFavorite:fdic placeHolder:stringValueOfDictionary([OllehMapStatus sharedOllehMapStatus].addressPOIDictionary, @"NAME")];
    }
    
}
- (void) contactBtnClickAd:(id)sender
{
    [self modalContact:[OllehMapStatus sharedOllehMapStatus].addressPOIDictionary];
}

- (void) modifyBtnClickAd:(id)sender
{
    [self typeChecker:4];
    [self modalInfoModify:[OllehMapStatus sharedOllehMapStatus].addressPOIDictionary];
    
}
@end
