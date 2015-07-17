//
//  SettingViewController2.m
//  OllehMap
//
//  Created by JiHyung on 12. 11. 15..
//
//

#import "SettingViewController2.h"

#define IS_RETINA   [OllehMapStatus sharedOllehMapStatus].isRetinaDisplay
#define IS_ARROW                1           // 화살표 이미지뷰 태그

#define CELL_WIDTH              300
#define CELL_HEIGHT             45
#define CELL_INTERVAL_MARGIN    1           // 셀 사이의 라인

#define SECTION_HEADER_HEIGHT   10
#define SECTION_FOOTER_HEIGHT   10
#define SECTION_SIDE_MARGIN     10          // 섹션 왼쪽,오른쪽 마진

#define CELL_TEXT_LEFT_TOP_X    11 + SECTION_SIDE_MARGIN     // Grouped Table Cell은 x좌표가 0부터 시작.
#define CELL_TEXT_LEFT_TOP_Y    16 - 2
#define CELL_TEXT_FONT_SIZE     14
#define CELL_TEXT_WIDTH         100


@interface SettingViewController2 ()

@end

@implementation SettingViewController2

@synthesize settingTableView = _settingTableView;
@synthesize notiImg = _notiImg, notiLabel = _notiLabel;
@synthesize notiArr = _notiArr;

// 셀의 모양
typedef enum {
    SettingCellTypeWithTop = 0,
    SettingCellTypeWithCenter,
    SettingCellTypeWithBottom,
    SettingCellTypeWithSingle,
    SettingCellTypeWithLine
} SettingCellType;

// 셀 옵션 UI
typedef enum {
    SettingCellOptionNone = -1,
    SettingCellOptionWithSwitch,
    SettingCellOptionWithArrow
} SettingCellOption;


#pragma mark -
#pragma mark Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _notiImg = [[UIImageView alloc] init];
        _notiLabel = [[UILabel alloc] init];
        _notiArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_settingTableView setBackgroundColor:[UIColor colorWithRed:242.0/255.0
                                                          green:242.0/255.0
                                                           blue:242.0/255.0
                                                          alpha:1]];
    [_settingTableView setBackgroundView:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.settingTableView reloadData];
    
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *deviceUnique = [oms generateUuidString];
    
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    
    if(![nd objectForKeyGC:@"PhoneUniqueId"])
    {
        [nd setObject:deviceUnique forKey:@"PhoneUniqueId"];
        [nd synchronize];
    }
    
    NSLog(@"notilistcount : %d, notilist : %@", [oms getNoticeCheckCount], [oms getNoticeCheckList]);
    self.notiArr = [oms.noticeListDictionary objectForKeyGC:@"NOTICELIST"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_notiArr release];         _notiArr = nil;
    [_notiImg release];         _notiImg = nil;
    [_notiLabel release];     _notiLabel = nil;
    
    [_myImgSettingSwitch release];  _myImgSettingSwitch = nil;
    [_myImgSettingCell  release];   _myImgSettingCell   = nil;
    
    [super dealloc];
}


#pragma mark -
#pragma mark SettingViewController2 [설정 테이블]
// 화면 꺼짐 방지, 지도 해상도
-(UITableViewCell *) makeCellAsDisplaySettingAtIndex:(int)index
{
    UITableViewCell *cell = nil;
    
    switch (index)
    {
        case 0:
        {
            cell = [self makeCellWithType:((IS_RETINA) ? SettingCellTypeWithTop : SettingCellTypeWithSingle)
                           cellTitleLabel:[self makeLabelWithDynamicLength:@"화면 꺼짐 방지" isBold:YES]
                     cellDescriptionLabel:nil
                                   option:SettingCellOptionWithSwitch];
            
            for (UIView *view in cell.subviews)
            {
                if ([view isKindOfClass:[UISwitch class]])
                {
                    // 스위치 이벤트 등록
                    [(UISwitch *)view addTarget:self
                                         action:@selector(preventScreenOffValueChanged:)
                               forControlEvents:UIControlEventValueChanged];
                    
                    // 스위치 초기화
                    NSString *idleTimer = [NSString stringWithFormat:@"%@",
                                           [[NSUserDefaults standardUserDefaults]
                                            objectForKeyGC:@"IdleTimerDisabled"]];
                    
                    if([idleTimer isEqualToString:@"YES"])  [(UISwitch *)view setOn:YES];
                    else                                    [(UISwitch *)view setOn:NO];
                    
                    break;
                }
            }
            break;
        }
        case 2:
        {
            // 해상도 상태
            UILabel *resolutionLabel = [[UILabel alloc]
                                        initWithFrame:CGRectMake(SECTION_SIDE_MARGIN + 153,    // 나중에 체크
                                                                 CELL_TEXT_LEFT_TOP_Y + 1,
                                                                 CELL_TEXT_WIDTH + 20,
                                                                 CELL_TEXT_FONT_SIZE)];
            
            [resolutionLabel setBackgroundColor:[UIColor clearColor]];
            [resolutionLabel setFont:[UIFont systemFontOfSize:CELL_TEXT_FONT_SIZE]];
            [resolutionLabel setTextColor:convertHexToDecimalRGBA(@"8B", @"8B", @"8B", 1)];
            [resolutionLabel setTextAlignment:NSTextAlignmentRight];
            
            // 현재 설정된 해상도
            int resolutionState = [[OllehMapStatus sharedOllehMapStatus] getDisplayMapResolution];
            NSString *resolutionStateStr = nil;
            
            if(resolutionState == KMapDisplayNormalSmallText)       resolutionStateStr = @"일반 모드(작은글씨)";
            else if (resolutionState == KMapDisplayNormalBigText)   resolutionStateStr = @"일반 모드(큰글씨)";
            else if (resolutionState == KMapDisplayHD)              resolutionStateStr = @"고해상도 모드(HD)";
            
            [resolutionLabel setText:resolutionStateStr];
            
            cell = [self makeCellWithType:SettingCellTypeWithBottom
                           cellTitleLabel:[self makeLabelWithDynamicLength:@"지도 해상도" isBold:YES]
                     cellDescriptionLabel:resolutionLabel
                                   option:SettingCellOptionWithArrow];
            
            [resolutionLabel release];
            break;
        }
        default:
            cell = [self makeCellWithType:SettingCellTypeWithLine
                           cellTitleLabel:nil
                     cellDescriptionLabel:nil
                                   option:SettingCellOptionNone];
            break;
    }
    
    return cell;
}

// 최근검색, 즐겨찾기, 계정설정
-(UITableViewCell *) makeCellAsMyPageAtIndex:(int)index
{
    UITableViewCell *cell = nil;
    
    switch (index)
    {
        case 0:
            cell = [self makeCellWithType:SettingCellTypeWithTop
                           cellTitleLabel:[self makeLabelWithDynamicLength:@"최근검색" isBold:YES]
                     cellDescriptionLabel:nil
                                   option:SettingCellOptionWithArrow];
            break;
        case 2:
            cell = [self makeCellWithType:SettingCellTypeWithCenter
                           cellTitleLabel:[self makeLabelWithDynamicLength:@"즐겨찾기" isBold:YES]
                     cellDescriptionLabel:nil
                                   option:SettingCellOptionWithArrow];
            break;
        case 4:
            cell = [self makeCellWithType:SettingCellTypeWithBottom
                           cellTitleLabel:[self makeLabelWithDynamicLength:@"계정설정" isBold:YES]
                     cellDescriptionLabel:nil
                                   option:SettingCellOptionWithArrow];
            break;
        default:
            cell = [self makeCellWithType:SettingCellTypeWithLine
                           cellTitleLabel:nil
                     cellDescriptionLabel:nil
                                   option:SettingCellOptionNone];
            break;
    }
    
    return cell;
}

// 지도 위 내 사진, 내 사진 설정
-(UITableViewCell *) makeCellAsMyImageSettingAtIndex:(int)index
{
    UITableViewCell *cell = nil;
    
    switch (index)
    {
        case 0:
        {
            cell = [self makeCellWithType:SettingCellTypeWithTop
                           cellTitleLabel:[self makeLabelWithDynamicLength:@"지도 위 내 사진" isBold:YES]
                     cellDescriptionLabel:nil
                                   option:SettingCellOptionWithSwitch];
            
            for (UIView *view in cell.subviews)
            {
                if ([view isKindOfClass:[UISwitch class]])
                {
                    // 전역변수로 참조할거니까 카운트 유지
                    self.myImgSettingSwitch = (UISwitch *)view;
                    
                    // 스위치 이벤트 등록
                    [_myImgSettingSwitch addTarget:self
                                            action:@selector(picSwitchValueChanged:)
                                  forControlEvents:UIControlEventValueChanged];
                    
                    // 스위치 초기화
                    BOOL valid = [[NSUserDefaults standardUserDefaults] boolForKey:@"UseMyImage"];
                    
                    if (valid)  [_myImgSettingSwitch setOn:YES];
                    else        [_myImgSettingSwitch setOn:NO];
                    
                    break;
                }
            }
            
            break;
        }
        case 2:
        {
            _myImgSettingCell = cell = [self makeCellWithType:SettingCellTypeWithBottom
                                               cellTitleLabel:[self makeLabelWithDynamicLength:@"내 사진 설정"
                                                                                        isBold:YES]
                                         cellDescriptionLabel:nil
                                                       option:SettingCellOptionWithArrow];
            
            // 내 사진 설정 셀 초기화
            [self picSwitchValueChanged:_myImgSettingSwitch];
            break;
        }
        default:
            cell = [self makeCellWithType:SettingCellTypeWithLine
                           cellTitleLabel:nil
                     cellDescriptionLabel:nil
                                   option:SettingCellOptionNone];
            break;
    }
    
    return cell;
}

// 공지사항 뱃지
-(void) setNoticeCountBadge:(UITableViewCell *)cell rightOf:(UILabel *)label
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSLog(@"returnCount : %d, omsCount : %d", _notiArr.count, [oms getNoticeCheckCount]);
    
    int notReadCount = _notiArr.count - [oms getNoticeCheckCount];
    int notiImgStartX = CELL_TEXT_LEFT_TOP_X + label.frame.size.width + 5;
    
    if(notReadCount < 1)
    {
        [_notiImg setHidden:YES];
        [_notiLabel setHidden:YES];
    }
    else if(notReadCount < 10)
    {
        [_notiImg setFrame:CGRectMake(notiImgStartX, CELL_TEXT_LEFT_TOP_Y, 17, 18)];
        [_notiImg setImage:[UIImage imageNamed:@"setting_box_icon_01.png"]];
        [_notiLabel setFrame:CGRectMake(notiImgStartX + 4, CELL_TEXT_LEFT_TOP_Y + 3, 9, 12)];
        [_notiLabel setText:[NSString stringWithFormat:@"%d", notReadCount]];
    }
    else
    {
        [_notiImg setFrame:CGRectMake(notiImgStartX, CELL_TEXT_LEFT_TOP_Y, 23, 18)];
        [_notiImg setImage:[UIImage imageNamed:@"setting_box_icon_02.png"]];
        [_notiLabel setFrame:CGRectMake(notiImgStartX + 4, CELL_TEXT_LEFT_TOP_Y + 3, 15, 12)];
        [_notiLabel setText:[NSString stringWithFormat:@"%d", notReadCount]];
    }
    [_notiLabel setTextAlignment:NSTextAlignmentCenter];
    [_notiLabel setFont:[UIFont systemFontOfSize:12]];
    [_notiLabel setBackgroundColor:[UIColor clearColor]];
    [_notiLabel setTextColor:[UIColor whiteColor]];
    
    [cell addSubview:_notiImg];
    [cell addSubview:_notiLabel];
}

// 공지사항, 고객문의/불만, 개선제안, 도움말
-(UITableViewCell *) makeCellAsHelperAtIndex:(int)index
{
    UITableViewCell *cell = nil;
    
    switch (index)
    {
        case 0:
        {
            UILabel *titleLabel = [self makeLabelWithDynamicLength:@"공지사항" isBold:YES];
            
            cell = [self makeCellWithType:SettingCellTypeWithTop
                           cellTitleLabel:titleLabel
                     cellDescriptionLabel:nil
                                   option:SettingCellOptionWithArrow];
            
            [self setNoticeCountBadge:cell rightOf:titleLabel];
            break;
        }
        case 2:
            cell = [self makeCellWithType:SettingCellTypeWithCenter
                           cellTitleLabel:[self makeLabelWithDynamicLength:@"고객문의/불만" isBold:YES]
                     cellDescriptionLabel:nil
                                   option:SettingCellOptionWithArrow];
            break;
        case 4:
            cell = [self makeCellWithType:SettingCellTypeWithCenter
                           cellTitleLabel:[self makeLabelWithDynamicLength:@"개선제안" isBold:YES]
                     cellDescriptionLabel:nil
                                   option:SettingCellOptionWithArrow];
            break;
        case 6:
            cell = [self makeCellWithType:SettingCellTypeWithBottom
                           cellTitleLabel:[self makeLabelWithDynamicLength:@"도움말" isBold:YES]
                     cellDescriptionLabel:nil
                                   option:SettingCellOptionWithArrow];
            break;
        default:
            cell = [self makeCellWithType:SettingCellTypeWithLine
                           cellTitleLabel:nil
                     cellDescriptionLabel:nil
                                   option:SettingCellOptionNone];
            break;
    }
    
    return cell;
}

// 프로그램 정보
-(UITableViewCell *) makeCellAsProgramInfo
{
    UILabel *titleLabel = [[UILabel alloc]
                           initWithFrame:CGRectMake(CELL_TEXT_LEFT_TOP_X,
                                                    CELL_TEXT_LEFT_TOP_Y + 2,
                                                    CELL_TEXT_WIDTH,
                                                    CELL_TEXT_FONT_SIZE)];
    
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:CELL_TEXT_FONT_SIZE]];
    [titleLabel setText:@"프로그램 정보"];
    
    UITableViewCell *cell = [self makeCellWithType:SettingCellTypeWithSingle
                                    cellTitleLabel:titleLabel
                              cellDescriptionLabel:nil
                                            option:SettingCellOptionWithArrow];
    
    [titleLabel release];
    
    return cell;
}

// 동적 길이를 가진 라벨
-(UILabel *) makeLabelWithDynamicLength:(NSString *)labelText
                                 isBold:(BOOL)bold
{
    UIFont *fontSize = nil;
    
    if (bold)   fontSize = [UIFont boldSystemFontOfSize:CELL_TEXT_FONT_SIZE];
    else        fontSize = [UIFont systemFontOfSize:CELL_TEXT_FONT_SIZE];
    
    CGSize labelSize = [labelText sizeWithFont:fontSize];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CELL_TEXT_LEFT_TOP_X,
                                                               CELL_TEXT_LEFT_TOP_Y,
                                                               labelSize.width,
                                                               labelSize.height)];
    
    [label setText:labelText];
    [label setFont:fontSize];
    [label setBackgroundColor:[UIColor clearColor]];
    
    return [label autorelease];
}

// 셀 생성
-(UITableViewCell *) makeCellWithType:(SettingCellType)type
                       cellTitleLabel:(UILabel *)titleLabel
                 cellDescriptionLabel:(UILabel *)descriptionLabel
                               option:(SettingCellOption)option
{
    UITableViewCell *cell = [[[UITableViewCell alloc]
                              initWithFrame:CGRectMake(0, 0, CELL_WIDTH, CELL_HEIGHT)] autorelease];
    
    // 셀렉션 적용
    [self applyCellSelectionImageView:cell cellType:type];
    
    [cell addSubview:titleLabel];
    [cell addSubview:descriptionLabel];
    [cell addSubview:[self makeOptionViewWithCellOption:option]];
    
    return cell;
}

// 셀 배경
-(void) applyCellSelectionImageView:(UITableViewCell *)cell cellType:(SettingCellType)type
{
    UIImageView *cellBg = [UIImageView new];
    UIImageView *cellBgForTouch = [UIImageView new];
    NSString *cellBgImageName = nil;
    NSString *cellBgImageNameForTouch = nil;
    
    switch (type)
    {
        case SettingCellTypeWithTop:
            cellBgImageName         = @"setting_box_top.png";
            cellBgImageNameForTouch = @"setting_box_top_pressed.png";
            break;
        case SettingCellTypeWithCenter:
            cellBgImageName         = @"setting_box_center.png";
            cellBgImageNameForTouch = @"setting_box_center_pressed.png";
            break;
        case SettingCellTypeWithBottom:
            cellBgImageName         = @"setting_box_bottom.png";
            cellBgImageNameForTouch = @"setting_box_bottom_pressed.png";
            break;
        case SettingCellTypeWithSingle:
            cellBgImageName         = @"setting_box_01.png";
            cellBgImageNameForTouch = @"setting_box_01_pressed.png";
            break;
        case SettingCellTypeWithLine:
            cellBgImageName = @"setting_box_line.png";
            break;
    }
    
    [cellBg setImage:[UIImage imageNamed:cellBgImageName]];
    [cellBgForTouch setImage:[UIImage imageNamed:cellBgImageNameForTouch]];
    
    [cell setBackgroundView:cellBg];
    [cell setSelectedBackgroundView:cellBgForTouch];
    
    [cellBg release];
    [cellBgForTouch release];
}

// 셀 옵션(화살표 또는 스위치)
-(UIView *) makeOptionViewWithCellOption:(SettingCellOption)option
{
    UIView *optionView = nil;
    
    switch (option)
    {
        case SettingCellOptionWithArrow:
        {
            optionView = [[UIImageView alloc] initWithFrame:CGRectMake(SECTION_SIDE_MARGIN + 280, 16, 9, 14)];
            [(UIImageView *)optionView setImage:[UIImage imageNamed:@"setting_arrow_btn.png"]];
            
            // 다른 곳에서 접근하기 위해
            [optionView setTag:IS_ARROW];
            break;
        }
        case SettingCellOptionWithSwitch:
        {
            // 스위치(5.0 보다 작으면 스위치가 옛날껄로...옛날껀 width가 더 큼
            optionView = [UISwitch new];
            CGRect optionViewFrame = optionView.frame;
            
            float version = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (version < 5.0f) optionViewFrame.origin = CGPointMake(205, 19 / 2.0);    // 왜 19로 적용이 안되는지.
            else                optionViewFrame.origin = CGPointMake(222, 19 / 2.0);
            
            [optionView setFrame:optionViewFrame];
            break;
        }
        case SettingCellOptionNone:
            break;
    }
    
    return [optionView autorelease];
}


#pragma mark -
#pragma mark UITableViewDataSource [설정 테이블]
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

-(NSInteger) tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // '-(라인)' 개수까지 포함
    int num = 0;
    
    switch (section)
    {
        case 0:
            // 화면꺼짐 방지, - , 지도해상도
            if (IS_RETINA)  num = 3;
            else            num = 1;   // 화면꺼짐 방지
            break;
        case 1:
            // 최근검색, - , 즐겨찾기, - , 계정설정
            num = 5;
            break;
        case 2:
            // 지도 위 내 사진, - , 내 사진 설정
            num = 3;
            break;
        case 3:
            // 공지사항, - , 고객문의/불만, - , 개선제안, - , 도움말
            num = 7;
            break;
        case 4:
            // 프로그램 정보
            num = 1;
            break;
    }
    
    return num;
}

-(UITableViewCell *) tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch (indexPath.section)
    {
        case 0:
            cell = [self makeCellAsDisplaySettingAtIndex:indexPath.row];
            break;
        case 1:
            cell = [self makeCellAsMyPageAtIndex:indexPath.row];
            break;
        case 2:
            cell = [self makeCellAsMyImageSettingAtIndex:indexPath.row];
            break;
        case 3:
            cell = [self makeCellAsHelperAtIndex:indexPath.row];
            break;
        case 4:
            cell = [self makeCellAsProgramInfo];
            break;
    }
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate [설정 테이블]
-(CGFloat) tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEADER_HEIGHT;
}

-(CGFloat) tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section
{
    return SECTION_FOOTER_HEIGHT;
}

-(CGFloat) tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row % 2) == 0)   return CELL_HEIGHT;             // 셀 높이
    else                            return CELL_INTERVAL_MARGIN;    // 셀 간격의 높이
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    SEL method = nil;
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 2:
                    method = @selector(resolutionCellClicked:);
                    break;
            }
            break;
        }
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                    method = @selector(recentSearchCellClicked:);
                    break;
                case 2:
                    method = @selector(favoriteCellClicked:);
                    break;
                case 4:
                    method = @selector(accountSettingCellClicked:);
            }
            break;
        }
        case 2:
        {
            switch (indexPath.row)
            {
                case 2:
                    method = @selector(myPicCellClicked:);
                    break;
            }
            break;
        }
        case 3:
        {
            switch (indexPath.row)
            {
                case 0:
                    method = @selector(noticeCellClicked:);
                    break;
                case 2:
                    method = @selector(customerCenterCellClicked:);
                    break;
                case 4:
                    method = @selector(improveProposeCellClicked:);
                    break;
                case 6:
                    method = @selector(helperCellClicked:);
                    break;
                default:
                    break;
            }
            break;
        }
        case 4:
            method = @selector(programInfoCellClicked:);
            break;
    }
    
    if (method != nil)
    {
        [self performSelector:method];
    }
}


#pragma mark -
#pragma mark IBAction
// 완료
- (IBAction)finishBtnClicked:(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

// 화면 꺼짐 방지
- (void)preventScreenOffValueChanged:(UISwitch *)tempSwitch
{
    if(tempSwitch.on)
    {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"IdleTimerDisabled"];
    }
    else
    {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"IdleTimerDisabled"];
    }
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 지도해상도
- (void)resolutionCellClicked:(id)sender
{
    ResolutionViewController *revc = [[ResolutionViewController alloc]
                                      initWithNibName:@"ResolutionViewController" bundle:nil];
    
    [[OMNavigationController sharedNavigationController] pushViewController:revc animated:NO];
    [revc release];
}

// 최근검색
- (void)recentSearchCellClicked:(id)sender
{
    RecentSearchViewController *rsvc = [[RecentSearchViewController alloc]
                                        initWithNibName:@"RecentSearchViewController" bundle:nil];
    
    [[OMNavigationController sharedNavigationController] pushViewController:rsvc animated:NO];
    [rsvc release];
}

// 즐겨찾기
-(void)favoriteCellClicked:(id)sender
{
    FavoriteViewController *favc = [[FavoriteViewController alloc]
                                    initWithNibName:@"FavoriteViewController" bundle:nil];
    
    [[OMNavigationController sharedNavigationController] pushViewController:favc animated:NO];
    [favc release];
}

// 계정설정
-(void)accountSettingCellClicked:(id)sender
{
    AccountSettingViewController *asvc = [[AccountSettingViewController alloc]
                                          initWithNibName:@"AccountSettingViewController" bundle:nil];
    
    [[OMNavigationController sharedNavigationController] pushViewController:asvc animated:NO];
    [asvc release];
}

// 지도 위 내 사진
- (void)picSwitchValueChanged:(UISwitch *)tempSwitch
{
    NSUserDefaults *myPicture = [NSUserDefaults standardUserDefaults];
    //[_myImageSettingBtn retain];
    if(tempSwitch.on)
    {
        [myPicture setBool:YES forKey:@"UseMyImage"];
        [myPicture synchronize];
        
        for (UIView *view in _myImgSettingCell.subviews)
        {
            // 셀 타이틀
            if ([view isKindOfClass:[UILabel class]])
            {
                [(UILabel *)view setTextColor:[UIColor blackColor]];
            }
            // 화살표
            else if ([view isKindOfClass:[UIImageView class]])
            {
                if ([view tag] == IS_ARROW)
                {
                    [(UIImageView *)view setAlpha:1.0];
                }
            }
        }
        
        [_myImgSettingCell setUserInteractionEnabled:YES];
    }
    else
    {
        [myPicture setBool:NO forKey:@"UseMyImage"];
        [myPicture synchronize];
        
        for (UIView *view in _myImgSettingCell.subviews)
        {
            // 셀 타이틀
            if ([view isKindOfClass:[UILabel class]])
            {
                [(UILabel *)view setTextColor:convertHexToDecimalRGBA(@"a6", @"a6", @"a6", 1)];
            }
            // 화살표
            else if ([view isKindOfClass:[UIImageView class]])
            {
                if ([view tag] == IS_ARROW)
                {
                    [(UIImageView *)view setAlpha:0.35];
                }
            }
        }
        
        [_myImgSettingCell setUserInteractionEnabled:NO];
    }
    
    // 지도내 내이미지 바로 변경 // 알아서 제값 찾아서 변경해준다...~
    [MapContainer refreshMapLocationImage];
    
    NSLog(@"picState : %@",[myPicture dictionaryRepresentation]);
    
}

// 내 사진 설정
-(void)myPicCellClicked:(id)sender
{
    
    MyImageViewController *mivc = [[MyImageViewController alloc]
                                   initWithNibName:@"MyImageViewController" bundle:nil];
    
    [[OMNavigationController sharedNavigationController] pushViewController:mivc animated:NO];
    [mivc release];
}

// 공지사항
- (void)noticeCellClicked:(id)sender
{
    /**
     @MethodDescription
     공지사항 리스트
     @MethodParams
     
     @MethodMehotdReturn
     finishNoticeListUICallBack
     */
    
    // 기존(카운트가 0 조건으로 하면 다시 네트워크가 연결되어도 공지에 들어갈 수 없다
    //    if([[OllehMapStatus sharedOllehMapStatus].noticeListDictionary count] == 0)
    //
    //    {
    //        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    //    }
    //    else
    //    {
    //        NoticeListViewController *nlvc = [[NoticeListViewController alloc] initWithNibName:@"NoticeListViewController" bundle:nil];
    //
    //        [[OMNavigationController sharedNavigationController] pushViewController:nlvc animated:NO];
    //        [nlvc release];
    //    }
    
    // 변경 : 갯수를 세지말고 api한번더 호출!! 수정
    [[ServerConnector sharedServerConnection] requestNoticeList:self
                                                         action:@selector(finishNoticeListUICallBackSetting:)];
    
}

- (void)finishNoticeListUICallBackSetting:(id)request
{
    if ([request finishCode] == OMSRFinishCode_Completed)
	{
        NoticeListViewController *nlvc = [[NoticeListViewController alloc]
                                          initWithNibName:@"NoticeListViewController" bundle:nil];
        
        [[OMNavigationController sharedNavigationController] pushViewController:nlvc animated:NO];
        [nlvc release];
    }
    else
    {
        [OMMessageBox showAlertMessage:@""
                                      :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    
}

// 고객문의/불만
- (void)customerCenterCellClicked:(id)sender
{
    CustomerComplainViewController *ccvc = [[CustomerComplainViewController alloc]
                                            initWithNibName:@"CustomerComplainViewController" bundle:nil];
    
    [[OMNavigationController sharedNavigationController] pushViewController:ccvc animated:NO];
    [ccvc release];
}

// 개선제안
- (void)improveProposeCellClicked:(id)sender
{
    ImproveProposeViewController *ipvc = [[ImproveProposeViewController alloc]
                                          initWithNibName:@"ImproveProposeViewController" bundle:nil];
    
    [[OMNavigationController sharedNavigationController] pushViewController:ipvc animated:NO];
    [ipvc release];
}

// 도움말
- (void)helperCellClicked:(id)sender
{
    if ([[OllehMapStatus sharedOllehMapStatus] getNetworkStatus] == OMReachabilityStatus_disconnected )
    {
        [OMMessageBox showAlertMessage:@""
                                      :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    else
    {
        
        
        HelperViewController *hvc = [[HelperViewController alloc]
                                     initWithNibName:@"HelperViewController" bundle:nil];
        
        [[OMNavigationController sharedNavigationController] pushViewController:hvc animated:NO];
        [hvc release];
    }
}

// 프로그램 정보
- (void)programInfoCellClicked:(id)sender
{
    VersionInfoViewController *vivc = [[VersionInfoViewController alloc]
                                       initWithNibName:@"VersionInfoViewController" bundle:nil];
    
    [[OMNavigationController sharedNavigationController] pushViewController:vivc animated:NO];
    [vivc release];
}


@end
