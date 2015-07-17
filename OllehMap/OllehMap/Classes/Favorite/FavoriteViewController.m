//
//  FavoriteViewController.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 24..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "FavoriteViewController.h"
#import "DbHelper.h"
#import "MainMapViewController.h"

#define _favoriteAllList getFavoriteAllList(Favorite_Category_All)

NSMutableArray* getFavoriteAllList(int category)
{
    NSMutableArray *list = nil;
    if (category == Favorite_Category_All)
    {
        list = [OllehMapStatus sharedOllehMapStatus].favoriteList;
    }
    else
    {
        list = [NSMutableArray array];
        for ( NSMutableDictionary *dic in [OllehMapStatus sharedOllehMapStatus].favoriteList )
        {
            if ( [[dic objectForKeyGC:@"Category"] intValue] == category )
                [list addObject:dic];
        }
    }
    return list;
}

UIImage* getFavoritImage(int iconType)
{
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
    
    return iconImage;
}

@implementation FavoriteCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        FavoriteCell *cell = self;
        
        _vwCustomCellBackground = [[UIView alloc] initWithFrame:cell.frame];
        [cell setBackgroundView:_vwCustomCellBackground];
        
        // 커스텀 셀 생성
        _vwCustomCell = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        [_vwCustomCell setBackgroundColor:[UIColor clearColor]];
        [_vwCustomCell setUserInteractionEnabled:NO];
        [_vwCustomCell addTarget:self action:@selector(onCheckCell:) forControlEvents:UIControlEventTouchUpInside];
        
        // 커스텀 셀 덧씌우기
        [cell addSubview:_vwCustomCell];
        
        // 체크버튼
        _btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(10, 17, 25, 25)];
        [_btnCheck setImage:[UIImage imageNamed:@"search_favorite_icon_default.png"] forState:UIControlStateNormal];
        [_btnCheck setImage:[UIImage imageNamed:@"search_favorite_icon_pressed.png"] forState:UIControlStateSelected];
        [_btnCheck setHidden:YES];
        
        if ( [reuseIdentifier isEqualToString:@"DeleteCell"] )
            [_btnCheck setSelected:YES];
        else
            [_btnCheck setSelected:NO];
        [_btnCheck addTarget:self action:@selector(onCheck:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:_btnCheck];
    }
    
    return self;
}


- (BOOL) setFavoriteDictionary:(NSMutableDictionary *)favoriteDic
{
    _currentFavoriteDictionary = favoriteDic;
    [_currentFavoriteDictionary retain];
    
    [self renderInCell:!_btnCheck.isHidden];
    
    return YES;
}

- (NSMutableDictionary*) getFavoriteDictionary
{
    return _currentFavoriteDictionary;
}


- (void) addTargetActionRefreshDeleteButton :(id)target :(SEL)action;
{
    _refreshDeleteButtonTarget = target;
    _refreshDeleteButtonAction = action;
}

- (void) dealloc
{
    if (_currentFavoriteDictionary)
        [_currentFavoriteDictionary release];
    
    [_btnCheck release];
    [_vwCustomCell release];
    
    [super dealloc];
}

- (void) willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    
    if (state & UITableViewCellStateShowingEditControlMask)
    {
        // 체크버튼 보이기
        [_btnCheck setHidden:NO];
        // 셀 유저인터렉션 활성화
        [_vwCustomCell setUserInteractionEnabled:YES];
        
        // 체크되어 있는 경우 배경 설정
        if (_btnCheck.selected)
            [_vwCustomCellBackground setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0f)];
        else
            [_vwCustomCellBackground setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        // 체크버트 숨기기
        [_btnCheck setHidden:YES];
        // 셀 유저인터렉션 비활성화
        [_vwCustomCell setUserInteractionEnabled:NO];
    }
    
    
    [self renderInCell:(state & UITableViewCellStateShowingEditControlMask)];
}

- (void) onCheck :(id)sender
{
    UIButton *btn = (UIButton*)sender;
    [btn setSelected:!btn.selected];
    
    if (btn.selected) [_vwCustomCellBackground setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0f)];
    else [_vwCustomCellBackground setBackgroundColor:[UIColor whiteColor]];
    
    NSNumber *selected = [NSNumber numberWithBool:btn.selected];
    [_currentFavoriteDictionary setObject:selected forKey:@"DeleteChecked"];
    
    
    if ([_refreshDeleteButtonTarget respondsToSelector:_refreshDeleteButtonAction])
        [_refreshDeleteButtonTarget performSelector:_refreshDeleteButtonAction withObject:self];
    
}

- (void) onCheckCell:(id)sender
{
    [self performSelector:@selector(onCheck:) withObject:_btnCheck];
}

- (void) renderInCell :(BOOL)isEdting
{
    // 기존 인셀 클리어
    for (UIView *subview in _vwCustomCell.subviews)
    {
        [subview removeFromSuperview];
    }
    
    int category = [[_currentFavoriteDictionary objectForKeyGC:@"Category"] intValue];
    int iconType = [[_currentFavoriteDictionary objectForKeyGC:@"IconType"] intValue];
    
    float edgeLeftPoint = 0.0f;
    if (_btnCheck.isHidden == NO) edgeLeftPoint = 10.0f + 25.0f;
    
    // 아이콘
    UIImage *iconImage = getFavoritImage(iconType);
    
    switch (category)
    {
            // 장소/주소 카테고리
        case Favorite_Category_Local:
        case Favorite_Category_Public:
        {
            // 아이콘
            UIImageView *imgvwIcon = [[UIImageView alloc] initWithImage:iconImage];
            [imgvwIcon setFrame:CGRectMake(edgeLeftPoint+9, 11 , iconImage.size.width, iconImage.size.height)];
            [_vwCustomCell addSubview:imgvwIcon];
            [imgvwIcon release];
            
            NSString *title1 = [_currentFavoriteDictionary objectForKeyGC:@"Title1"];
            NSString *title2 = [_currentFavoriteDictionary objectForKeyGC:@"Title2"];
            
            if ([title2 length] > 0)
            {
                UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(edgeLeftPoint+41, 11, 458/2, 16)];
                [lblTitle setFont:[UIFont systemFontOfSize:15]];
                [lblTitle setLineBreakMode:NSLineBreakByTruncatingTail];
                [lblTitle setBackgroundColor:[UIColor clearColor]];
                [lblTitle setText:title1];
                //rectLabel.size = [lblStart.text sizeWithFont:lblStart.font constrainedToSize:CGSizeMake(FLT_MAX, 15) lineBreakMode:lblStart.lineBreakMode];
                //[lblStart setFrame:rectLabel];
                [_vwCustomCell addSubview:lblTitle];
                [lblTitle release];
                UILabel *lblTitle2 = [[UILabel alloc] initWithFrame:CGRectMake(edgeLeftPoint+41, 33, 458/2, 13)];
                [lblTitle2 setFont:[UIFont systemFontOfSize:13]];
                [lblTitle2 setLineBreakMode:NSLineBreakByTruncatingTail];
                [lblTitle2 setBackgroundColor:[UIColor clearColor]];
                [lblTitle2 setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
                [lblTitle2 setText:title2];
                //rectLabel.size = [lblStart.text sizeWithFont:lblStart.font constrainedToSize:CGSizeMake(FLT_MAX, 15) lineBreakMode:lblStart.lineBreakMode];
                //[lblStart setFrame:rectLabel];
                [_vwCustomCell addSubview:lblTitle2];
                [lblTitle2 release];
            }
            else
            {
                UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(edgeLeftPoint+41, 21, 458/2, 15)];
                [lblTitle setFont:[UIFont systemFontOfSize:15]];
                [lblTitle setLineBreakMode:NSLineBreakByTruncatingTail];
                [lblTitle setBackgroundColor:[UIColor clearColor]];
                [lblTitle setText:title1];
                //rectLabel.size = [lblStart.text sizeWithFont:lblStart.font constrainedToSize:CGSizeMake(FLT_MAX, 15) lineBreakMode:lblStart.lineBreakMode];
                //[lblStart setFrame:rectLabel];
                [_vwCustomCell addSubview:lblTitle];
                [lblTitle release];
            }
            
            break;
        }
            
            // 경로 카테고리 셀 렌더링
        case Favorite_Category_Route:
        {
            // 아이콘
            UIImageView *imgvwIcon = [[UIImageView alloc] initWithImage:iconImage];
            [imgvwIcon setFrame:CGRectMake(edgeLeftPoint+9, 11, iconImage.size.width, iconImage.size.height)];
            [_vwCustomCell addSubview:imgvwIcon];
            [imgvwIcon release];
            
            float labelTopPoint = 11.0f;
            float labelDescTopPoint = 14.0f;
            
            CGRect rectLabel = CGRectZero;
            
            // 출발지
            rectLabel = CGRectMake(edgeLeftPoint+41, labelTopPoint, 30, 15);
            UILabel *lblStart = [[UILabel alloc] initWithFrame:rectLabel];
            [lblStart setFont:[UIFont systemFontOfSize:15]];
            [lblStart setLineBreakMode:NSLineBreakByClipping];
            [lblStart setBackgroundColor:[UIColor clearColor]];
            [lblStart setText:@"출발"];
            rectLabel.size = [lblStart.text sizeWithFont:lblStart.font constrainedToSize:CGSizeMake(FLT_MAX, 15) lineBreakMode:lblStart.lineBreakMode];
            [lblStart setFrame:rectLabel];
            [_vwCustomCell addSubview:lblStart];
            [lblStart release];
            UILabel *lblStartDesc = [[UILabel alloc] initWithFrame:CGRectMake(edgeLeftPoint+78, labelDescTopPoint, 192-edgeLeftPoint, 13)];
            [lblStartDesc setFont:[UIFont systemFontOfSize:13]];
            [lblStartDesc setBackgroundColor:[UIColor clearColor]];
            [lblStartDesc setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
            [lblStartDesc setText:[NSString stringWithFormat:@"%@", [_currentFavoriteDictionary objectForKeyGC:@"Title1"]]];
            [_vwCustomCell addSubview:lblStartDesc];
            [lblStartDesc release];
            
            // 경유지 존재시
            if ([[_currentFavoriteDictionary objectForKeyGC:@"Coord3x"] doubleValue] > 0 && [[_currentFavoriteDictionary objectForKeyGC:@"Coord3y"] doubleValue] > 0)
            {
                labelTopPoint += 20;
                labelDescTopPoint += 20;
                rectLabel = CGRectMake(edgeLeftPoint+41, labelTopPoint, 30, 15);
                UILabel *lblVisit = [[UILabel alloc] initWithFrame:rectLabel];
                [lblVisit setFont:[UIFont systemFontOfSize:15]];
                [lblVisit setLineBreakMode:NSLineBreakByClipping];
                [lblVisit setBackgroundColor:[UIColor clearColor]];
                [lblVisit setText:@"경유"];
                rectLabel.size = [lblVisit.text sizeWithFont:lblVisit.font constrainedToSize:CGSizeMake(FLT_MAX, 15) lineBreakMode:lblVisit.lineBreakMode];
                [lblVisit setFrame:rectLabel];
                [_vwCustomCell addSubview:lblVisit];
                [lblVisit release];
                UILabel *lblVisitDesc = [[UILabel alloc] initWithFrame:CGRectMake(edgeLeftPoint+78, labelDescTopPoint, 192-edgeLeftPoint, 13)];
                [lblVisitDesc setFont:[UIFont systemFontOfSize:13]];
                [lblVisitDesc setBackgroundColor:[UIColor clearColor]];
                [lblVisitDesc setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
                [lblVisitDesc setText:[NSString stringWithFormat:@"%@", [_currentFavoriteDictionary objectForKeyGC:@"Title3"]]];
                [_vwCustomCell addSubview:lblVisitDesc];
                [lblVisitDesc release];
            }
            
            // 도착
            labelTopPoint += 20;
            labelDescTopPoint += 20;
            rectLabel = CGRectMake(edgeLeftPoint+41, labelTopPoint, 30, 15);
            UILabel *lblDest = [[UILabel alloc] initWithFrame:rectLabel];
            [lblDest setFont:[UIFont systemFontOfSize:15]];
            [lblDest setLineBreakMode:NSLineBreakByClipping];
            [lblDest setBackgroundColor:[UIColor clearColor]];
            [lblDest setText:@"도착"];
            rectLabel.size = [lblDest.text sizeWithFont:lblDest.font constrainedToSize:CGSizeMake(FLT_MAX, 15) lineBreakMode:lblDest.lineBreakMode];
            [lblDest setFrame:rectLabel];
            [_vwCustomCell addSubview:lblDest];
            [lblDest release];
            UILabel *lblDestDesc = [[UILabel alloc] initWithFrame:CGRectMake(edgeLeftPoint+78, labelDescTopPoint, 192-edgeLeftPoint, 13)];
            [lblDestDesc setFont:[UIFont systemFontOfSize:13]];
            [lblDestDesc setBackgroundColor:[UIColor clearColor]];
            [lblDestDesc setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
            [lblDestDesc setText:[NSString stringWithFormat:@"%@", [_currentFavoriteDictionary objectForKeyGC:@"Title2"]]];
            [_vwCustomCell addSubview:lblDestDesc];
            [lblDestDesc release];
            
            
            break;
        }
            
    }
    
}

@end

@interface FavoriteViewController ()
@end

@implementation FavoriteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _renameTextField = [[UITextField alloc] init];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self initComponents];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [_vwNavigation release];
    
    [_vwFavoriteContainer release];
    [_tvwFavoriteList release];
    
    [_btnSelectAllFavorite release];
    [_btnDeleteSelectedFavorite release];
    [_lblSelectAllFavoriteShadow release];
    [_lblSelectAllFavorite release];
    [_lblDeleteSelectedFavorite release];
    [_lblDeleteSelectedFavoriteShadow release];
    [_lblRenameFovoriteShadow release];
    [_lblRenameFavorite release];
    
    [_btnRenameFavorite release];
    
    [_favoriteLocalList release];
    [_favoriteRouteList release];
    [_favoritePublicList release];
    [_renameTextField release];
    [super dealloc];
}


// ================
// [ 초기화 메소드 ]
// ================

- (void) initComponents
{
    // 네비게이션 뷰 생성
    _vwNavigation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
    [self.view addSubview:_vwNavigation];
    
    // 즐겨찾기 컨테이너 초기화
    _vwFavoriteContainer = [[UIView alloc]
                            initWithFrame:CGRectMake(0, 37,
                                                     [[UIScreen mainScreen] bounds].size.width,
                                                     [[UIScreen mainScreen] bounds].size.height-20-37)];
    [_vwFavoriteContainer setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_vwFavoriteContainer setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:_vwFavoriteContainer];
    
    // 즐겨찾기 테이블 초기화
    _tvwFavoriteList = [[UITableView alloc]
                        initWithFrame:CGRectMake(0, 36,
                                                 [[UIScreen mainScreen] bounds].size.width,
                                                 [[UIScreen mainScreen] bounds].size.height-20-37-36) style:UITableViewStylePlain];
    [_tvwFavoriteList setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tvwFavoriteList setDelegate:self];
    [_tvwFavoriteList setDataSource:self];
    [_tvwFavoriteList setEditing:NO];
    
    // 전체선택버튼 초기화
    _btnSelectAllFavorite = [[UIButton alloc] initWithFrame:CGRectMake(7, 11, 100, 37)];
    [_btnSelectAllFavorite setBackgroundColor:[UIColor clearColor]];
    //[_btnSelectAllFavorite.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    //[_btnSelectAllFavorite setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //[_btnSelectAllFavorite setTitle:@"전체선택" forState:UIControlStateNormal];
    //[_btnSelectAllFavorite setTitle:@"전체해제" forState:UIControlStateSelected];
    [_btnSelectAllFavorite addTarget:self action:@selector(onSeletAll:) forControlEvents:UIControlEventTouchUpInside];
    
    // 전체선택 쉐도우
    _lblSelectAllFavoriteShadow = [[UILabel alloc] initWithFrame:CGRectMake(7, 12, 100, 37)];
    [_lblSelectAllFavoriteShadow setBackgroundColor:[UIColor clearColor]];
    [_lblSelectAllFavoriteShadow setTextAlignment:NSTextAlignmentCenter];
    [_lblSelectAllFavoriteShadow setText:@"전체선택"];
    [_lblSelectAllFavoriteShadow setTextColor:convertHexToDecimalRGBA(@"ff", @"ff", @"ff", 0.6)];
    [_lblSelectAllFavoriteShadow setFont:[UIFont boldSystemFontOfSize:14]];
    
    
    // 전체선택 라벨
    _lblSelectAllFavorite = [[UILabel alloc] initWithFrame:CGRectMake(7, 11, 100, 37)];
    [_lblSelectAllFavorite setBackgroundColor:[UIColor clearColor]];
    [_lblSelectAllFavorite setText:@"전체선택"];
    [_lblSelectAllFavorite setTextAlignment:NSTextAlignmentCenter];
    [_lblSelectAllFavorite setFont:[UIFont boldSystemFontOfSize:14]];
    
    // 삭제버튼 초기화
    _btnDeleteSelectedFavorite = [[UIButton alloc] initWithFrame:CGRectMake(111, 11, 98, 37)];
    [_btnDeleteSelectedFavorite setBackgroundColor:[UIColor clearColor]];
    [_btnDeleteSelectedFavorite setTag:0];
    [_btnDeleteSelectedFavorite addTarget:self action:@selector(onDeleteSelectedFavorite:) forControlEvents:UIControlEventTouchUpInside];
    
    // 삭제쉐도우
    _lblDeleteSelectedFavoriteShadow = [[UILabel alloc] initWithFrame:CGRectMake(111, 12, 98, 37)];
    [_lblDeleteSelectedFavoriteShadow setBackgroundColor:[UIColor clearColor]];
    [_lblDeleteSelectedFavoriteShadow setTextAlignment:NSTextAlignmentCenter];
    [_lblDeleteSelectedFavoriteShadow setText:@"삭제 (0)"];
    [_lblDeleteSelectedFavoriteShadow setTextColor:convertHexToDecimalRGBA(@"ff", @"ff", @"ff", 0.6)];
    [_lblDeleteSelectedFavoriteShadow setFont:[UIFont boldSystemFontOfSize:14]];
    
    // 삭제텍스트
    _lblDeleteSelectedFavorite = [[UILabel alloc] initWithFrame:CGRectMake(111, 11, 98, 37)];
    [_lblDeleteSelectedFavorite setBackgroundColor:[UIColor clearColor]];
    [_lblDeleteSelectedFavorite setText:@"삭제 (0)"];
    
    [_lblDeleteSelectedFavorite setTextAlignment:NSTextAlignmentCenter];
    [_lblDeleteSelectedFavorite setFont:[UIFont boldSystemFontOfSize:14]];
    
    
    // 이름변경버튼 초기화
    _btnRenameFavorite = [[UIButton alloc] initWithFrame:CGRectMake(213, 11, 100, 37)];
    [_btnRenameFavorite addTarget:self action:@selector(onRenameFavorite:) forControlEvents:UIControlEventTouchUpInside];
    
    // 이름변경쉐도우
    _lblRenameFovoriteShadow = [[UILabel alloc] initWithFrame:CGRectMake(213, 12, 100, 37)];
    [_lblRenameFovoriteShadow setBackgroundColor:[UIColor clearColor]];
    [_lblRenameFovoriteShadow setTextAlignment:NSTextAlignmentCenter];
    [_lblRenameFovoriteShadow setText:@"이름변경"];
    [_lblRenameFovoriteShadow setTextColor:convertHexToDecimalRGBA(@"ff", @"ff", @"ff", 0.6)];
    [_lblRenameFovoriteShadow setFont:[UIFont boldSystemFontOfSize:14]];
    
    // 이름변경텍스트
    _lblRenameFavorite = [[UILabel alloc] initWithFrame:CGRectMake(213, 11, 100, 37)];
    [_lblRenameFavorite setBackgroundColor:[UIColor clearColor]];
    [_lblRenameFavorite setText:@"이름변경"];
    
    [_lblRenameFavorite setTextAlignment:NSTextAlignmentCenter];
    [_lblRenameFavorite setFont:[UIFont boldSystemFontOfSize:14]];
    
    // 즐겨찾기 메모리 초기화
    _favoriteLocalList = [[NSMutableArray alloc] init];
    _favoriteRouteList = [[NSMutableArray alloc] init];
    _favoritePublicList = [[NSMutableArray alloc] init];
    [self initFavorteListOnMemory :YES];
    
    // 네비게이션바 렌더링
    [self renderNavigation];
    
    // 즐겨찾기 렌더링
    [self renderCategory:_favoriteCategory];
    
}

- (void) initFavorteListOnMemory :(BOOL)fromDB
{
    // 즐겨찾기 가져오기
    if (fromDB)
    {
        DbHelper *dbHelper = [[DbHelper alloc] init];
        [dbHelper getFavoriteList];
        [dbHelper release];
    }
    
    // 카테고리별 리스트 클리어
    [_favoriteLocalList removeAllObjects];
    [_favoriteRouteList removeAllObjects];
    [_favoritePublicList removeAllObjects];
    
    // 카테고리별 분류
    for (NSMutableDictionary *dic in _favoriteAllList)
    {
        int category = [[dic objectForKeyGC:@"Category"] intValue];
        
        if ( category == Favorite_Category_Local )
            [_favoriteLocalList addObject:dic];
        else if (category == Favorite_Category_Route )
            [_favoriteRouteList addObject:dic];
        else if ( category == Favorite_Category_Public )
            [_favoritePublicList addObject:dic];
    }
    
}

- (NSMutableArray*) getCurrentCategoryFavoriteLIst
{
    if (_favoriteCategory == Favorite_Category_Local) return _favoriteLocalList;
    else if (_favoriteCategory == Favorite_Category_Route) return _favoriteRouteList;
    else if (_favoriteCategory == Favorite_Category_Public) return _favoritePublicList;
    else return _favoriteAllList;
}

// ****************

// ================
// [ 렌더링 메소드 ]
// ================

- (void) renderNavigation
{
    // 네비게이션 뷰 클리어
    for (UIView *subview in _vwNavigation.subviews)
    {
        [subview removeFromSuperview];
    }
    
    // 배경 이미지
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_bg.png"]];
    [_vwNavigation addSubview:imgvwBack];
    [imgvwBack release];
    
    // 버튼 -  이전
    UIButton *btnPrev = [[UIButton alloc] initWithFrame:CGRectMake(7, 4, 47, 28)];
    if (_tvwFavoriteList.isEditing)
        [btnPrev setImage:[UIImage imageNamed:@"title_bt_cancel.png"] forState:UIControlStateNormal];
    else
        [btnPrev setImage:[UIImage imageNamed:@"title_bt_before.png"] forState:UIControlStateNormal];
    [btnPrev addTarget:self action:@selector(onPrev:) forControlEvents:UIControlEventTouchUpInside];
    [_vwNavigation addSubview:btnPrev];
    [btnPrev release];
    
    // 버튼 - 편집
    UIButton *btnModify = [[UIButton alloc] initWithFrame:CGRectMake(271, 4, 42, 28)];
    if (_tvwFavoriteList.isEditing)
        [btnModify setImage:[UIImage imageNamed:@"title_btn_finish.png"] forState:UIControlStateNormal];
    else
        [btnModify setImage:[UIImage imageNamed:@"title_bt_edit.png"] forState:UIControlStateNormal];
    [btnModify setEnabled:_favoriteAllList.count>0];
    [btnModify addTarget:self action:@selector(onModify:) forControlEvents:UIControlEventTouchUpInside];
    [_vwNavigation addSubview:btnModify];
    [btnModify release];
    
    // 타이틀 그림자
    UILabel *lblTitleShadow = [[UILabel alloc] initWithFrame:CGRectMake(61, (37-20)/2+2, 198, 20)];
    [lblTitleShadow setFont:[UIFont systemFontOfSize:20]];
    [lblTitleShadow setTextColor:convertHexToDecimalRGBA(@"00", @"00", @"00", 0.75f)];
    [lblTitleShadow setBackgroundColor:[UIColor clearColor]];
    [lblTitleShadow setTextAlignment:NSTextAlignmentCenter];
    [lblTitleShadow setText:@"즐겨찾기"];
    [_vwNavigation addSubview:lblTitleShadow];
    [lblTitleShadow release];
    
    // 타이틀
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(61, (37-20)/2, 198, 20)];
    [lblTitle setFont:[UIFont systemFontOfSize:20]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setText:@"즐겨찾기"];
    [_vwNavigation addSubview:lblTitle];
    [lblTitle release];
}

- (void) renderCategory :(Favorite_Category)category
{
    _favoriteCategory = category;
    
    // 즐겨찾기 컨테이너 클리어
    for (UIView *subview in _vwFavoriteContainer.subviews)
    {
        [subview removeFromSuperview];
    }
    
    // 카테고리 뷰 생성
    UIView *vwCategory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 36)];
    
    // 카테고리 뷰 배경
    UIImageView *imgvwCategoryBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"search_favorite_bt_bg_%02d.png", category+1]]];
    // 데이터가 없을 경우 전부 비활성화처리
    if (_favoriteAllList.count <= 0) [imgvwCategoryBack setImage:[UIImage imageNamed:@"search_favorite_bt_bg_05.png"]];
    [vwCategory addSubview:imgvwCategoryBack];
    [imgvwCategoryBack release];
    
    // 카테고리 버튼
    NSArray *categories = [NSArray arrayWithObjects:@"전체", @"장소/주소", @"경로", @"버스/지하철", nil];
    for (int i=0, maxi=categories.count; i<maxi; i++)
    {
        NSString *title = [categories objectAtIndexGC:i];
        UIButton *btnCategory = [[UIButton alloc] initWithFrame:CGRectMake(i*80, 0, 80, 36)];
        [btnCategory setTitle:title forState:UIControlStateNormal];
        if (i == category)
            [btnCategory setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        else
            [btnCategory setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        if (i==Favorite_Category_All)
        {
            if (_favoriteAllList.count) [btnCategory addTarget:self action:@selector(onCategoryAll:) forControlEvents:UIControlEventTouchUpInside];
            else [btnCategory setTitleColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f) forState:UIControlStateNormal];
        }
        else if (i==Favorite_Category_Local)
        {
            if (_favoriteLocalList.count) [btnCategory addTarget:self action:@selector(onCategoryLocal:) forControlEvents:UIControlEventTouchUpInside];
            else [btnCategory setTitleColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f) forState:UIControlStateNormal];
        }
        else if (i==Favorite_Category_Route)
        {
            if (_favoriteRouteList.count) [btnCategory addTarget:self action:@selector(onCategoryRoute:) forControlEvents:UIControlEventTouchUpInside];
            else [btnCategory setTitleColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f) forState:UIControlStateNormal];
        }
        else if (i== Favorite_Category_Public)
        {
            if (_favoritePublicList.count) [btnCategory addTarget:self action:@selector(onCategoryPublic:) forControlEvents:UIControlEventTouchUpInside];
            else [btnCategory setTitleColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f) forState:UIControlStateNormal];
        }
        
        [btnCategory.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [vwCategory addSubview:btnCategory];
        [btnCategory release];
    }
    
    // 카테고리 뷰 삽입
    [_vwFavoriteContainer addSubview:vwCategory];
    [vwCategory release];
    
    // 카테고리 테이블 렌더링
    [self renderCategoryTable];
    // 하단 삭제 컨트롤 렌더링
    [self renderBottomDeletController];
}

- (void) renderCategoryTable
{
    if (_favoriteAllList.count == 0)
    {
        UILabel *lblEmpty = [[UILabel alloc] initWithFrame:CGRectMake(0, (int)(_vwFavoriteContainer.frame.size.height/2), 320, 15)];
        [lblEmpty setFont:[UIFont systemFontOfSize:15]];
        [lblEmpty setTextAlignment:NSTextAlignmentCenter];
        [lblEmpty setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1.0f)];
        [lblEmpty setText:NSLocalizedString(@"Body_Search_Favorite_Empty", @"")];
        [lblEmpty setBackgroundColor:[UIColor clearColor]];
        [_vwFavoriteContainer addSubview:lblEmpty];
        [lblEmpty release];
        // 배경
        [_vwFavoriteContainer setBackgroundColor:convertHexToDecimalRGBA(@"F2", @"F2", @"F2", 1.0f)];
        return;
    }
    else
    {
        // 배경
        [_vwFavoriteContainer setBackgroundColor:[UIColor whiteColor]];
    }
    
    // 즐겨찾기 테이블 뷰 사이즈 조절 (일반/편집모드)
    CGRect rectFavoriteList = _tvwFavoriteList.frame;
    int tableHeight = self.view.bounds.size.height;
    if (_tvwFavoriteList.isEditing)
    {
        // 전체높이-네비게이션높이-카테고리높이-하단버튼그룹높이
        rectFavoriteList.size.height = tableHeight-37-36-57;
    }
    else
    {   // 전체높이-네비게이션높이-카테고리높이
        rectFavoriteList.size.height = tableHeight-37-36;
    }
    [_tvwFavoriteList setFrame:rectFavoriteList];
    
    // 즐겨찾기 테이블뷰 삽입
    [_vwFavoriteContainer addSubview:_tvwFavoriteList];
    [_tvwFavoriteList reloadData];
}

- (void) renderBottomDeletController
{
    if (_tvwFavoriteList.isEditing)
    {
        // 컨트롤 뷰 생성
        UIView *vwController = [[UIView alloc] initWithFrame:CGRectMake(0, _tvwFavoriteList.frame.size.height + 37, 320, 57)];
        [vwController setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        
        // 배경
        UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom_bg.png"]];
        [vwController addSubview:imgvwBack];
        [imgvwBack release];
        
        // 선택된 셀 카운트
        int selectedCount = 0;
        for (NSDictionary *dic in _favoriteAllList)
            if ( [[dic objectForKeyGC:@"DeleteChecked"] boolValue] )
                selectedCount++;
        
        
        // 전체선택 버튼
        UIImageView *imgvwSelectAll = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom_btn_01.png"]];
        [imgvwSelectAll setFrame:_btnSelectAllFavorite.frame];
        [vwController addSubview:imgvwSelectAll];
        [imgvwSelectAll release];
        [vwController addSubview:_btnSelectAllFavorite];
        
        // 전체선택 쉐도우랑 라벨
        [vwController addSubview:_lblSelectAllFavoriteShadow];
        [vwController addSubview:_lblSelectAllFavorite];
        if (selectedCount == [self getCurrentCategoryFavoriteLIst].count)
        {
            [_btnSelectAllFavorite setSelected:YES];
            [_lblSelectAllFavoriteShadow setText:@"전체해제"];
            [_lblSelectAllFavorite setText:@"전체해제"];
        }
        else
        {
            [_btnSelectAllFavorite setSelected:NO];
            [_lblSelectAllFavoriteShadow setText:@"전체선택"];
            [_lblSelectAllFavorite setText:@"전체선택"];
        }
        
        
        
        // 삭제 버튼
        UIImageView *imgvwDeleteSelectedFavorite = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom_btn_02.png"]];
        [imgvwDeleteSelectedFavorite setFrame:_btnDeleteSelectedFavorite.frame];
        [vwController addSubview:imgvwDeleteSelectedFavorite];
        [imgvwDeleteSelectedFavorite release];
        [vwController addSubview:_btnDeleteSelectedFavorite];
        //[_btnDeleteSelectedFavorite setTitle:@"삭제 (0)" forState:UIControlStateNormal];
        //[_btnDeleteSelectedFavorite setTitle:[NSString stringWithFormat:@"삭제 (%d)", selectedCount] forState:UIControlStateNormal];
        
        // 삭제쉐도우
        [_lblDeleteSelectedFavoriteShadow setText:[NSString stringWithFormat:@"삭제 (%d)", selectedCount]];
        [vwController addSubview:_lblDeleteSelectedFavoriteShadow];
        // 삭제라벨
        [_lblDeleteSelectedFavorite setText:[NSString stringWithFormat:@"삭제 (%d)", selectedCount]];
        [vwController addSubview:_lblDeleteSelectedFavorite];
        
        
        // 이름변경 버튼
        UIImageView *imgvwRenamedFavorite = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom_btn_01.png"]];
        [imgvwRenamedFavorite setFrame:_btnRenameFavorite.frame];
        [vwController addSubview:imgvwRenamedFavorite];
        [vwController addSubview:_btnRenameFavorite];
        [imgvwRenamedFavorite release];
        
        if(selectedCount == 1)
        {
            [_btnRenameFavorite setEnabled:YES];
        }
        else
        {
            [_btnRenameFavorite setEnabled:NO];
        }
        
        // 이름변경 쉐도우
        [vwController addSubview:_lblRenameFovoriteShadow];
        [vwController addSubview:_lblRenameFavorite];
        
        // 컨트롤 뷰 삽입
        [_vwFavoriteContainer addSubview:vwController];
        [vwController release];
        
        [self onRefreshDeleteButtonText:nil];
        
    }
}

// ****************


// ==================
// [ 테이블뷰 메소드 ]
// ==================


- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
    return [self getCurrentCategoryFavoriteLIst].count > 1;
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // 한개의 셀을 자체이동한경우
    if (sourceIndexPath == destinationIndexPath) return;
    
    NSMutableArray *list = [self getCurrentCategoryFavoriteLIst];
    int sourceFavoriteID = [[[list objectAtIndexGC:sourceIndexPath.row] objectForKeyGC:@"FavoriteID"] intValue];
    int destinationFavoriteID = [[[list objectAtIndexGC:destinationIndexPath.row] objectForKeyGC:@"FavoriteID"] intValue];
    
    // 이동하려는 객체 보관
    NSDictionary *sourceDic = nil;
    for (NSDictionary *dic in _favoriteAllList)
    {
        //if ( [[dic objectForKeyGC:@"SortOrder"] intValue] == sourceFavoriteTotalIndex )
        if ( [[dic objectForKeyGC:@"FavoriteID"] intValue] == sourceFavoriteID )
        {
            sourceDic = dic;
            [_favoriteAllList  removeObject:dic];
            break;
        }
    }
    
    // 이동대상에 위치한 객체 찾아서 해당자리에 이동객체 삽입
    for (int i=0,maxi=_favoriteAllList.count; i<maxi; i++)
    {
        NSDictionary *currentDic = [_favoriteAllList objectAtIndexGC:i];
        int favoriteID = [[currentDic objectForKeyGC:@"FavoriteID"] intValue];
        
        if (favoriteID == destinationFavoriteID)
        {
            int insertIndex = sourceIndexPath.row < destinationIndexPath.row ? i+1 : i;
            [_favoriteAllList insertObject:sourceDic atIndex: insertIndex ];
            break;
        }
    }
    
    // 즐겨찾기 데이터 처리
    [self initFavorteListOnMemory:NO];
    
    //[OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%d %d", sourceFavoriteTotalIndex, destinationFavoriteTotalIndex]];
    
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *list = [self getCurrentCategoryFavoriteLIst];
    return list.count;
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *list = [self getCurrentCategoryFavoriteLIst];
    
    if ( [[[list objectAtIndexGC:indexPath.row] objectForKeyGC:@"Category"] intValue] == Favorite_Category_Route && [[[list objectAtIndexGC:indexPath.row] objectForKeyGC:@"Coord3x"] doubleValue] > 0 )
        return 77;
    else
        return 58;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // MIK.geun :: 20121116 // 설정에서 즐겨찾기 진입한 경우 렌더링방식이 달라짐
    // 설정에서 들어온 즐겨찾기는 결과화면 지도로 이동하지 않는다.
    OMNavigationController *nc = [OMNavigationController sharedNavigationController];
    UIViewController *vc = [nc.viewControllers objectAtIndexGC:nc.viewControllers.count-2];
    // 설정화면 즐겨찾기 여부
    BOOL isSettingFavorite = [vc isKindOfClass:[SettingViewController2 class]];
    
    
    // 이제부터 즐겨찾기 셀 터치시 이동 처리
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    FavoriteCell *cell = (FavoriteCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    [cell setSelected:NO animated:NO];
    
    NSMutableDictionary *favoriteDic = [cell getFavoriteDictionary];
    if (favoriteDic == nil)
    {
        [OMMessageBox showAlertMessage:@"" :@"잘못된 정보가 들어있습니다."];
        return;
    }
    
    int category =[[favoriteDic objectForKeyGC:@"Category"] intValue];
    //int inconType = [[favoriteDic objectForKeyGC:@"IconType"] intValue];
    
    NSString *title1 = [favoriteDic objectForKeyGC:@"Title1"];
    Coord coord1 = CoordMake( [[favoriteDic objectForKeyGC:@"Coord1x"] doubleValue], [[favoriteDic objectForKeyGC:@"Coord1y"] doubleValue] );
    NSString *title2 = [favoriteDic objectForKeyGC:@"Title2"];
    Coord coord2 = CoordMake( [[favoriteDic objectForKeyGC:@"Coord2x"] doubleValue], [[favoriteDic objectForKeyGC:@"Coord2y"] doubleValue] );
    NSString *title3 = [favoriteDic objectForKeyGC:@"Title3"];
    Coord coord3 = CoordMake( [[favoriteDic objectForKeyGC:@"Coord3x"] doubleValue], [[favoriteDic objectForKeyGC:@"Coord3y"] doubleValue] );
    
    NSString *detailType = [favoriteDic objectForKeyGC:@"DetailType"];
    NSString *detailID = [favoriteDic objectForKeyGC:@"DetailID"];
    
    NSString *shapeType = stringValueOfDictionary(favoriteDic, @"ShapeType");
    NSString *fcNm = stringValueOfDictionary(favoriteDic, @"FcNm");
    NSString *idBgm = stringValueOfDictionary(favoriteDic, @"IdBgm");
    if (category == Favorite_Category_Local || category == Favorite_Category_Public)
    {
        // SinglePOI 지도화면 처리
        [oms.searchResult reset];
        [oms.searchResult setUsed:YES];
        [oms.searchResult setIsCurrentLocation:NO];
        [oms.searchResult setStrLocationName:title1];
        if ([detailType isEqualToString:@"ADDR"])
            [oms.searchResult setStrLocationAddress:title2];
        else
            [oms.searchResult setStrLocationAddress:@""];
        [oms.searchResult setStrType:detailType];
        [oms.searchResult setStrID:detailID];
        [oms.searchResult setCoordLocationPoint:coord1];
        
        // 콜링크 등록
        if ( title3 )
            [oms.searchResult setStrSTheme:title3];
        else
            [oms.searchResult setStrSTheme:@""];
        
        // 버스노선 상세정보 이동
        if ( [detailType isEqualToString:@"TR_BUSNO"] )
        {
            // 길찾기용 검색일 경우, 빠져나가도록 한다.
            OMNavigationController *nc = [OMNavigationController sharedNavigationController];
            for (int i=nc.viewControllers.count-1; i >= 0; i--)
            {
                // 가장 위에 존재하는 검색창 화면 얻어오기
                UIViewController *vc = [nc.viewControllers objectAtIndexGC:i];
                if ([vc isKindOfClass:[SearchViewController class]])
                {
                    SearchViewController *svc = (SearchViewController*)vc;
                    if (svc.currentSearchTargetType != SearchTargetType_NONE
                        && svc.currentSearchTargetType != SearchTargetType_VOICENONE )
                    {
                        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Popup_ClickBusNumber", @"")];
                        return;
                    }
                    break;
                }
            }
            
            
            [[ServerConnector sharedServerConnection] requestBusNumberInfo:self action:@selector(didFinishRequestBusNumberDetail:) laneId:detailID];
        }
        else if (![shapeType isEqualToString:@""] && ![fcNm isEqualToString:@""] && ![idBgm isEqualToString:@""])
        {
            [[ServerConnector sharedServerConnection] requestPolygonSearch:self action:@selector(SearchfinishedPolygonInfo:) table:fcNm loadKey:idBgm];
        }
        // 그외 상세정보
        else
        {
            if ( !isSettingFavorite )
                [MainMapViewController markingSinglePOI_RenderType:MainMap_SinglePOI_Type_Favorite animated:NO];
            else
            {
                [[OMNavigationController sharedNavigationController] popToRootViewControllerAnimated:NO];
                MainMapViewController *mmvc = (MainMapViewController*)[[OMNavigationController sharedNavigationController].viewControllers lastObject];
                
                //[OllehMapStatus sharedOllehMapStatus].currentMapLocationMode = MapLocationMode_None;
                [mmvc toggleMyLocationMode:MapLocationMode_None];
                [mmvc pinFavoritePOIOverlay:YES];
                NSArray *allOverlays = [MapContainer sharedMapContainer_Main].kmap.getOverlays;
                for (Overlay *overlay in allOverlays)
                {
                    if ( [overlay isKindOfClass:[OMImageOverlayFavorite class]] )
                    {
                        [((OMImageOverlayFavorite*)overlay).additionalInfo setObject:[NSNumber numberWithBool:YES] forKey:@"LongtapClose"];
                        break;
                    }
                }
            }
            
        }
    }
    else if (category == Favorite_Category_Route)
    {
        // 길찾기용 검색일 경우, 빠져나가도록 한다.
        OMNavigationController *nc = [OMNavigationController sharedNavigationController];
        for (int i=nc.viewControllers.count-1; i >= 0; i--)
        {
            // 가장 위에 존재하는 검색창 화면 얻어오기
            UIViewController *vc = [nc.viewControllers objectAtIndexGC:i];
            if ([vc isKindOfClass:[SearchViewController class]])
            {
                SearchViewController *svc = (SearchViewController*)vc;
                if (svc.currentSearchTargetType != SearchTargetType_NONE
                    && svc.currentSearchTargetType != SearchTargetType_VOICENONE )
                {
                    [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Popup_ClickRoute", @"")];
                    return;
                }
                break;
            }
        }
        
        
        // 출발
        [oms.searchResultRouteStart reset];
        [oms.searchResultRouteStart setUsed:YES];
        [oms.searchResultRouteStart setIsCurrentLocation:NO];
        [oms.searchResultRouteStart setStrLocationName:title1];
        [oms.searchResultRouteStart setCoordLocationPoint:coord1];
        
        // 도착
        [oms.searchResultRouteDest reset];
        [oms.searchResultRouteDest setUsed:YES];
        [oms.searchResultRouteDest setIsCurrentLocation:NO];
        [oms.searchResultRouteDest setStrLocationName:title2];
        [oms.searchResultRouteDest setCoordLocationPoint:coord2];
        
        // 경유
        [oms.searchResultRouteVisit reset];
        if (coord3.x >0 && coord3.y > 0)
        {
            [oms.searchResultRouteVisit reset];
            [oms.searchResultRouteVisit setUsed:YES];
            [oms.searchResultRouteVisit setIsCurrentLocation:NO];
            [oms.searchResultRouteVisit setStrLocationName:title3];
            [oms.searchResultRouteVisit setCoordLocationPoint:coord3];
        }
        
        // 길찾기 검색전 기존 검색 데이터 클리어
        [[OllehMapStatus sharedOllehMapStatus].searchRouteData reset];
        
        [[SearchRouteExecuter sharedSearchRouteExecuter] searchRoute_Car:SearchRoute_Car_SearchType_RealTime];
    }
    
    //[OMMessageBox  showAlertMessage:@"" :[NSString stringWithFormat:@"출발 : %@\n경유 : %@\n도착 : %@", title1, title3, title2]];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dic = [[self getCurrentCategoryFavoriteLIst] objectAtIndexGC:indexPath.row];
    
    NSString *identifier = nil;
    if ( [[dic objectForKeyGC:@"DeleteChecked"] boolValue] )
        identifier = @"DeleteCell";
    else
        identifier = @"NormalCell";
    
    FavoriteCell *cell = [[[FavoriteCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier] autorelease];
    //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if( [identifier isEqualToString:@"NormalCell"] )
    {
        UIImageView *selectedBackgroundView = [[UIImageView alloc] init];
        [selectedBackgroundView setBackgroundColor:convertHexToDecimalRGBA(@"d9", @"f4", @"ff", 1)];
        cell.selectedBackgroundView = selectedBackgroundView;
        [selectedBackgroundView release];
        
        // 설정에서 들어왔을 경우 하이라이트 해제
        OMNavigationController *nc = [OMNavigationController sharedNavigationController];
        UIViewController *vc = [nc.viewControllers objectAtIndexGC:nc.viewControllers.count-2];
        if ( [vc isKindOfClass:[SettingViewController2 class]] ) [cell  setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    // 콜백등록 (삭제 체크)
    [cell addTargetActionRefreshDeleteButton:self :@selector(onRefreshDeleteButtonText:)];
    
    // 즐겨찾기 정보 설정
    [cell setFavoriteDictionary:dic];
    
    return cell;
}

// ******************

// ==============
// [ 액션 메소드 ]
// ==============

- (void) onPrev :(id)sender
{
    if (_tvwFavoriteList.isEditing)
    {
        CGRect rectTFavroiteList = _tvwFavoriteList.frame;
        rectTFavroiteList.size.height = [[UIScreen mainScreen] bounds].size.height - 20 - 37 - 36;
        [_tvwFavoriteList setFrame:rectTFavroiteList];
        
        // 편집 중단
        [_tvwFavoriteList setEditing:NO];
        
        // 메모리 초기화 (FromDB)
        [self initFavorteListOnMemory:YES];
        
        // 네비게이션, 테이블뷰 렌더링
        [self renderNavigation];
        [self renderCategory:_favoriteCategory];
    }
    else
    {
        [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
    }
}

- (void) onModify :(id)sender
{
    
    // 편집모드에서 실행된 경우 "완료"처리해주도록 한다.
    
    if (_tvwFavoriteList.isEditing)
    {
        // 변경된 데이터 저장
        DbHelper *dbh = [[DbHelper alloc] init];
        [dbh updateFavorite:_favoriteAllList];
        [dbh release];
    }
    else
    {
    }
    
    // 화면 전환
    [_tvwFavoriteList setEditing:!_tvwFavoriteList.isEditing animated:NO];
    [self renderNavigation];
    [self renderCategory:_favoriteCategory];
}

- (void) onCategoryAll :(id)sender
{
    // 즐겨찾기 삭제 선택 변수 클리어
    for (NSMutableDictionary *dic in _favoriteAllList)
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"DeleteChecked"];
    
    [self renderCategory:Favorite_Category_All];
}

- (void) onCategoryLocal :(id)sender
{
    // 즐겨찾기 삭제 선택 변수 클리어
    for (NSMutableDictionary *dic in _favoriteAllList)
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"DeleteChecked"];
    
    [self renderCategory:Favorite_Category_Local];
}

- (void) onCategoryRoute :(id)sender
{
    // 즐겨찾기 삭제 선택 변수 클리어
    for (NSMutableDictionary *dic in _favoriteAllList)
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"DeleteChecked"];
    
    [self renderCategory:Favorite_Category_Route];
}

- (void) onCategoryPublic :(id)sender
{
    // 즐겨찾기 삭제 선택 변수 클리어
    for (NSMutableDictionary *dic in _favoriteAllList)
        [dic setObject:[NSNumber numberWithBool:NO] forKey:@"DeleteChecked"];
    
    [self renderCategory:Favorite_Category_Public];
}

- (void) onSeletAll :(id)sender
{
    // 삭제체크 (전체체크된 경우 YES가 리턴됨)
    BOOL chekced = !_btnSelectAllFavorite.selected;
    
    // 전체 삭제체크
    for (NSMutableDictionary *dic in [self getCurrentCategoryFavoriteLIst])
    {
        [dic setObject:[NSNumber numberWithBool:chekced] forKey:@"DeleteChecked"];
    }
    
    [self onRefreshDeleteButtonText:nil];
    // 렌더링
    [self renderCategory:_favoriteCategory];
}
- (void) onDeleteSelectedFavorite :(id)sender
{
    // 제거대상 수집
    NSMutableArray *deleteList = [NSMutableArray array];
    for (NSMutableDictionary *delDic in _favoriteAllList)
    {
        if ( [[delDic objectForKeyGC:@"DeleteChecked"] boolValue] )
            [deleteList addObject:delDic];
    }
    
    // 제거
    for (NSMutableDictionary *delDic in deleteList)
    {
        [_favoriteAllList removeObject:delDic];
    }
    
    // 메모리 업데이트
    [self initFavorteListOnMemory:NO];
    
    // 삭제이후 현재 카테고리에 아이템이 없을 경우 전체로 이동
    if ( [self getCurrentCategoryFavoriteLIst].count > 0 )
        [self renderCategory:_favoriteCategory];
    else
        [self renderCategory:Favorite_Category_All];
}

- (void) onRefreshDeleteButtonText:(id)sender
{
    int selectedCount = 0;
    for (NSDictionary *dic in _favoriteAllList)
    {
        if ( [[dic objectForKeyGC:@"DeleteChecked"] boolValue] )
        {
            selectedCount++;
        }
    }
    
    [_lblDeleteSelectedFavorite setText:[NSString stringWithFormat:@"삭제 (%d)", selectedCount]];
    
    if(selectedCount > 0)
    {
        [_lblDeleteSelectedFavorite setTextColor:[UIColor blackColor]];
        
        if (selectedCount == 1)
        {
            [_lblRenameFavorite setTextColor:[UIColor blackColor]];
        }
        else
        {
            [_lblRenameFavorite setTextColor:convertHexToDecimalRGBA(@"9c", @"9c", @"9c", 1.0)];
        }
    }
    
    else
    {
        [_lblRenameFavorite setTextColor:convertHexToDecimalRGBA(@"9c", @"9c", @"9c", 1.0)];
        [_lblDeleteSelectedFavorite setTextColor:convertHexToDecimalRGBA(@"9c", @"9c", @"9c", 1.0)];
    }
    
    if (selectedCount == [self getCurrentCategoryFavoriteLIst].count)
    {
        [_btnSelectAllFavorite setSelected:YES];
        [_btnRenameFavorite setEnabled:NO];
        [_btnRenameFavorite setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_lblSelectAllFavorite setText:@"전체해제"];
        [_lblSelectAllFavoriteShadow setText:@"전체해제"];
        
        if(selectedCount == 1)
        {
            [_btnRenameFavorite setEnabled:YES];
            
        }
    }
    else if (selectedCount == 1)
    {
        [_btnRenameFavorite setEnabled:YES];
        
    }
    else
    {
        [_lblSelectAllFavorite setText:@"전체선택"];
        [_lblSelectAllFavoriteShadow setText:@"전체선택"];
        [_btnSelectAllFavorite setSelected:NO];
        [_btnRenameFavorite setEnabled:NO];
        
    }
}

// **************


// ===================
// [ 검색 콜백 메소드 ]
// ===================
- (void) didFinishRequestBusNumberDetail :(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        BusNumberLineViewController *bndvc = [[BusNumberLineViewController alloc] initWithNibName:@"BusNumberLineViewController" bundle:nil];
        [[OMNavigationController sharedNavigationController] pushViewController:bndvc animated:NO];
        [bndvc release];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}
// *******************
- (void) onRenameFavorite:(id)sender
{
    //[OMMessageBox showAlertMessage:@"" :@"바꿔"];
    //int i = ((UIButton *)sender).tag;
    NSLog(@"favorist : %@", _favoriteAllList);
    NSString *rename = nil;
    for (NSDictionary *dic in _favoriteAllList)
    {
        NSNumber *checkNum = numberValueOfDiction(dic, @"DeleteChecked");
        NSString *type = stringValueOfDictionary(dic, @"IconType");
        
        
        if([checkNum boolValue])
        {
            if([type isEqualToString:@"10003"])
            {
                break;
            }
            
            rename = stringValueOfDictionary(dic, @"Title1");
            
            
            
            break;
        }
        
    }
    if (!rename)
    {
        [OMMessageBox showAlertMessage:@"즐겨찾기 이름" :@"이름을 변경할 수 없습니다"];
        return;
    }
    
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"즐겨찾기 이름" message:@"\n" delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil] autorelease];
    //alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UIImageView *alertBg = [[UIImageView alloc] init];
    [alertBg setImage:[UIImage imageNamed:@"search_bar_bg.png"]];
    [alertBg setFrame:CGRectMake(19, 44, 245, 28)];
    [alert addSubview:alertBg];
    [alertBg release];
    
    _renameTextField.layer.cornerRadius = 2;
    [_renameTextField setFont:[UIFont systemFontOfSize:14]];
    [_renameTextField setFrame:CGRectMake(24, 48, 232, 20)];
    [_renameTextField setBackgroundColor:[UIColor clearColor]];
    [_renameTextField setText:rename];
    [_renameTextField becomeFirstResponder];
    [alert addSubview:_renameTextField];
    [alert show];
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        // 확인
        [OMMessageBox showAlertMessage:@"즐겨찾기" :@"변경되었습니다"];
        
        
        for (NSMutableDictionary *dic in _favoriteAllList)
        {
            NSNumber *checkNum = numberValueOfDiction(dic, @"DeleteChecked");
            
            if([checkNum boolValue])
            {
                [dic setObject:_renameTextField.text forKey:@"Title1"];
                break;
            }
            
        }
        
        [_tvwFavoriteList reloadData];
        
    }
    
}
- (void) SearchfinishedPolygonInfo:(id)request
{
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        [MainMapViewController markingLinePolygonPOI:@"라인폴리곤" animated:NO];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}

@end
