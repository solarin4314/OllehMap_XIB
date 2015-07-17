//
//  ContactViewController.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 24..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "ContactViewController.h"
#import "ServerConnector.h"
#import "MapContainer.h"
#import "MainMapViewController.h"

@implementation OMControlContact

@synthesize addresses = _addresses;
@synthesize name = _name;
- (void) dealloc
{
    //self.addresses = nil;
    //self.name = nil;
    [_addresses release];
    _addresses = nil;
    [_name release];
    _name = nil;
    
    [super dealloc];
}
@end

@interface ContactViewController ()

// ================
// [ 초기화 메소드 ]
// ================
- (void) initComponent;
// ****************

// =====================
// [ 공통 렌더링 메소드 ]
// =====================
- (void) renderNavigation;
- (void) renderSearchbar;
- (void) renderContact;
- (void) renderMultiAddressSelector :(NSString*)name :(NSArray*)addresses;
- (void) renderMultiSearchResultSelector :(BOOL)isAddress :(BOOL)isNewAddress;
- (void) onCellDown :(id)sender;
- (void) onCellUp:(id)sender;
// *********************

// =====================
// [ 연락처 제어 메소드 ]
// =====================
- (void) refineContact;
- (void) searchPersonAddress :(ABRecordRef)ref;
- (void) search :(NSString *)personName :(NSString*)personAddress;
- (void) didFinishSearch :(id)request;
// *********************

// ==============================
// [ 네비게이션 메소드 - private ]
// ==============================
- (void) onClose :(id)sender;
- (void) onCloseAddressList :(id)sender;
- (void) onSelectAddress :(id)sender;
- (void) onSelectSearchResult :(id)sender;
// ******************************

// =====================================================
// [ ABPeoplePickerNavigationController Delegate 메소드 ]
// =====================================================
- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person;
- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;
// *****************************************************

@end

@implementation ContactViewController

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
    
    [self.navigationController setNavigationBarHidden:YES];
    [self initComponent];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [_peoplePicker release]; _peoplePicker  = nil;
    
    [_vwMultiAddressSelector release]; _vwMultiAddressSelector = nil;
    
    [super dealloc];
}




// ===============
// 클래스 메소드
// ===============
+ (BOOL) checkAddressBookAuth
{
    if ( [ContactViewController checkAddressBookAuthWithoutMessage]  )
    {
        return YES;
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :@"올레 map이 연락처에 접근할 수 있는 권한이 없습니다."];
        return NO;
    }
}
+ (BOOL) checkAddressBookAuthWithoutMessage
{
    
    // 주소록 데이터 접근
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if ( version >= 6.0  ) // Version 6.0 이상부터는 연락처 접근시 승인여부를 확인해야 한다. (**예약)
    {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        
        // 접근권한 변수 생성
        __block BOOL accessGranted = NO;
        
        //  iOS 6 에만 존재하는 메소드 호출해야 한다. 혹시나 해서 널체크 해보고~
        if (ABAddressBookRequestAccessWithCompletion != NULL)
        {
            // 세마포어 생성
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            // 연락처 접근권한 받아오는 메세지박스 띄우는 메소드 호출
            ABAddressBookRequestAccessWithCompletion(addressBook,
                                                     ^(bool granted, CFErrorRef error) {
                                                         accessGranted = granted; // 사용자가 선택한 권한을 넘겨주도록
                                                         dispatch_semaphore_signal(sema); // 세마포어 락을 해제하는 시그널 전송
                                                     } );
            // 해제 명령이 들어오기 전까지 무한 대기하도록 한다.
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            // 세마포어 해제
            dispatch_release(sema);
        }
        
        if ( accessGranted == NO )
        {
            // 사용자가 접근권한을 제한한 경우
            return NO;
        }
        else
        {
            // 사용자가 접근 권한을 허용한 경우라도 다시 한번 권한이 있는지 체크한다.
            CFIndex addressbookAuth = ABAddressBookGetAuthorizationStatus();
            if ( addressbookAuth != kABAuthorizationStatusAuthorized )
            {
                return NO;
            }
        }
    }
    
    // 이단계까지 문제가 없었다면 연락처 사용가능하도록 리턴
    return YES;
}
// ****************



// ================
// [ 초기화 메소드 ]
// ================

- (void) initComponent
{
    // 다중 주소 선택 화면 초기화
    _vwMultiAddressSelector = [[UIView alloc]
                               initWithFrame:CGRectMake(0, 0,
                                                        [[UIScreen mainScreen] bounds].size.width,
                                                        [[UIScreen mainScreen] bounds].size.height - 20)];
    [_vwMultiAddressSelector setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
    
    // 네비게이션 렌더링
    [self renderNavigation];
    
    // 검색영역 렌더링
    [self renderSearchbar];
    
    // 연락처 설정
    [self refineContact];
    
    // 연락처 렌더링
    [self renderContact];
}

// ****************


// =====================
// [ 공통 렌더링 메소드 ]
// =====================

- (void) renderNavigation
{
    // 네비게이션 뷰 생성
    UIView *vwNavigation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
    
    // 배경 이미지
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_bg.png"]];
    [vwNavigation addSubview:imgvwBack];
    [imgvwBack release];
    
    // 버튼
    UIButton *btnPrev = [[UIButton alloc] initWithFrame:CGRectMake(7, 4, 47, 28)];
    [btnPrev setImage:[UIImage imageNamed:@"title_bt_before.png"] forState:UIControlStateNormal];
    [btnPrev addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [vwNavigation addSubview:btnPrev];
    [btnPrev release];
    
    // 타이틀 그림자
    UILabel *lblTitleShadow = [[UILabel alloc] initWithFrame:CGRectMake(61, (37-20)/2+2, 198, 20)];
    [lblTitleShadow setFont:[UIFont systemFontOfSize:20]];
    [lblTitleShadow setTextColor:convertHexToDecimalRGBA(@"00", @"00", @"00", 0.75f)];
    [lblTitleShadow setBackgroundColor:[UIColor clearColor]];
    [lblTitleShadow setTextAlignment:NSTextAlignmentCenter];
    [lblTitleShadow setText:@"연락처"];
    [vwNavigation addSubview:lblTitleShadow];
    [lblTitleShadow release];
    
    // 타이틀
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(61, (37-20)/2, 198, 20)];
    [lblTitle setFont:[UIFont systemFontOfSize:20]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setText:@"연락처"];
    [vwNavigation addSubview:lblTitle];
    [lblTitle release];
    
    // 네비게이션 뷰 삽입
    [self.view addSubview:vwNavigation];
    [vwNavigation release];
}

- (void) renderSearchbar
{
    // 검색바 뷰 생성
    UIView *vwSearchbar = [[UIView alloc] initWithFrame:CGRectMake(0, 37, 320, 46)];
    
    // 배경 이미지 삽입
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_contact_bg.png"]];
    [vwSearchbar addSubview:imgvwBack];
    [imgvwBack release];
    
    // 검색바 이미지
    UIImageView *imgvwSearchBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_bar_bg.png"]];
    [imgvwSearchBar setFrame:CGRectMake(12, 6, 296, 33)];
    [vwSearchbar addSubview:imgvwSearchBar];
    [imgvwSearchBar release];
    
    // 돋보기 아이콘
    UIImageView *imgvwSearch = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_search_icon.png"]];
    [imgvwSearch setFrame:CGRectMake(20, 12, 21, 21)];
    [vwSearchbar addSubview:imgvwSearch];
    [imgvwSearch release];
    
    // 검색 텍스트
    UITextField *txtSearch = [[UITextField alloc] initWithFrame:CGRectMake(45, 15, 252, 15)];
    [txtSearch setFont:[UIFont systemFontOfSize:14]];
    [txtSearch setPlaceholder:@"검색"];
    [vwSearchbar addSubview:txtSearch];
    [txtSearch release];
    
    // 검색바 뷰 삽입
    [self.view addSubview:vwSearchbar];
    [vwSearchbar release];
}

- (void) renderContact
{
    // 주소록 카운트 처리
    //CFIndex peopleCount = ABAddressBookGetPersonCount(_addressbook);
    
    // IOS 버전별로 주소록 생성이 달라짐.
    ABAddressBookRef addressbook = NULL;
    if ( [[[UIDevice currentDevice] systemVersion ] floatValue] < 6.0 )
        addressbook = ABAddressBookCreate();
    else
        addressbook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    CFIndex peopleCount = ABAddressBookGetPersonCount(addressbook);
    CFRelease(addressbook);
    
    // 연락처가 하나도 없을 경우
    if (peopleCount <= 0)
    {
        UIView *vwEmpty = [[UIView alloc] initWithFrame:CGRectMake(0, 37+46, 320, 470-37-46)];
        [vwEmpty setBackgroundColor:[UIColor whiteColor]];
        
        UILabel *lblEmpty = [[UILabel alloc] initWithFrame:CGRectMake(0, 166, 320, 15)];
        [lblEmpty setFont:[UIFont systemFontOfSize:15]];
        [lblEmpty setTextAlignment:NSTextAlignmentCenter];
        [lblEmpty setText:NSLocalizedString(@"Body_Search_Contact_Empty", @"")];
        [vwEmpty addSubview:lblEmpty];
        [lblEmpty release];
        
        [self.view addSubview:vwEmpty];
        [vwEmpty release];
    }
    // 연락처 존재할 경우
    else
    {
        _peoplePicker = [[OMPeoplePickerNavigationController alloc] init];
        [_peoplePicker setNavigationBarHidden:YES];
        [_peoplePicker setPeoplePickerDelegate:self];
        [self.view addSubview:_peoplePicker.view];
    }
    
}

- (void) renderMultiAddressSelector:(NSString*)name :(NSArray *)addresses
{
    //  딤드화면 클리어
    for (UIView *subview in _vwMultiAddressSelector.subviews)
    {
        [subview removeFromSuperview];
    }
    
    // 팝업 리스트 뷰 배경
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_bg_06.png"]];
    
    // 팝업 리스트 뷰 생성
    UIView *vwMultiPOISelector = [[UIView alloc]
                                  initWithFrame:CGRectMake(54/2,230/2,532/2,
                                                           imgvwBack.image.size.height)];
    
    
    [imgvwBack setFrame:CGRectMake(0, 0, imgvwBack.image.size.width, imgvwBack.image.size.height)];
    [vwMultiPOISelector addSubview:imgvwBack];
    [imgvwBack release];
    
    // 사용자 이름 노출
    UILabel *lblContactUserName = [[UILabel alloc] initWithFrame:CGRectMake(38/2, 48/2, 456/2, 30/2)];
    [lblContactUserName setFont:[UIFont boldSystemFontOfSize:15]];
    [lblContactUserName setTextColor:[UIColor blackColor]];
    [lblContactUserName setBackgroundColor:[UIColor clearColor]];
    [lblContactUserName setLineBreakMode:NSLineBreakByTruncatingTail];
    [lblContactUserName setTextAlignment:NSTextAlignmentCenter];
    [lblContactUserName setText:name];
    [vwMultiPOISelector addSubview:lblContactUserName];
    [lblContactUserName release];
    
    // 리스트 스크롤뷰 컨텐츠 높이
    float listContentsHeight = 0.0f;
    
    // 스크롤뷰 생성
    OMScrollView *svwList = [[OMScrollView alloc] initWithFrame:CGRectMake(18/2, 114/2, 496/2, (232+94)/2)];
    [svwList setDelegate:self];
    [svwList setScrollType:2];
    
    for (int i=0, maxi=addresses.count; i<maxi; i++)
    {
        NSString *address = [addresses objectAtIndexGC:i];
        
        // POI 뷰 생성
        CGRect rectCell = CGRectMake(0, listContentsHeight, svwList.frame.size.width, 46);
        OMControlContact *vwCell = [[OMControlContact alloc] initWithFrame:rectCell];
        [vwCell setTag:i];
        [vwCell addTarget:self action:@selector(onSelectAddress:) forControlEvents:UIControlEventTouchUpInside];
        [vwCell addTarget:self action:@selector(onCellDown:) forControlEvents:UIControlEventTouchDown];
        [vwCell addTarget:self action:@selector(onCellUp:) forControlEvents:UIControlEventTouchUpOutside];
        [vwCell setName:name];
        [vwCell setAddresses:addresses];
        
        // 라벨
        CGRect rectName = CGRectMake(78/2, 32/2, 398/2, 28/2);
        UILabel *lblName =[[UILabel alloc] initWithFrame:rectName];
        [lblName setFont:[UIFont systemFontOfSize:14]];
        [lblName setTextColor:[UIColor blackColor]];
        [lblName setBackgroundColor:[UIColor clearColor]];
        [lblName setTextAlignment:NSTextAlignmentLeft];
        [lblName setLineBreakMode:NSLineBreakByClipping];
        [lblName setText:address];
        
        // 라벨 텍스트에 최적화정보
        LabelResizeInfo labelNameResizeInfo = getLabelResizeInfo(lblName, 398/2);
        // 라벨 사이즈에 따른 라벨 높이 수정
        if (labelNameResizeInfo.numberOfLines > 1)
        {
            rectName.origin.y = labelNameResizeInfo.origin.y = 20/2;
            rectName.size = labelNameResizeInfo.newSize;
        }
        else
        {
            rectName.origin.y = labelNameResizeInfo.origin.y = 32/2;
            rectName.size = labelNameResizeInfo.newSize;
        }
        // 라벨 텍스트 변경사항 반영
        setLabelResizeWithLabelResizeInfo(lblName, labelNameResizeInfo);
        
        [vwCell addSubview:lblName];
        [lblName release];
        
        // 라벨에 따른 뷰 사이즈 수정
        if ( labelNameResizeInfo.numberOfLines > 1)
            rectCell.size.height = rectName.size.height + 20/2 + 20/2;
        else
            rectCell.size.height = rectName.size.height + 32/2 + 30/2;
        
        // 인덱스 아이콘
        UIImageView *imgvwIndexIconBalloon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_b_marker_poi.png"]];
        CGRect rectIndexIconBalloon = CGRectMake(18/2, 14/2, imgvwIndexIconBalloon.image.size.width, imgvwIndexIconBalloon.image.size.height);
        
        // 인덱스 아이콘도 텍스트 라벨 높이에 맞춰 높낮이가 달라진다.
        if ( labelNameResizeInfo.numberOfLines > 1 ) rectIndexIconBalloon.origin.y = 20/2;
        else  rectIndexIconBalloon.origin.y = 16/2;
        [imgvwIndexIconBalloon setFrame:rectIndexIconBalloon];
        
        [vwCell addSubview:imgvwIndexIconBalloon];
        [imgvwIndexIconBalloon release];
        
        // POI 뷰 삽입
        [vwCell setFrame:rectCell];
        [svwList addSubview:vwCell];
        [vwCell release];
        listContentsHeight += rectCell.size.height;
        
        // 라인 삽입
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, listContentsHeight, svwList.frame.size.width, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0f)];
        [svwList addSubview:vwLine];
        [vwLine release];
        listContentsHeight += 1;
    }
    [svwList setContentSize:CGSizeMake(svwList.frame.size.width, listContentsHeight)];
    [vwMultiPOISelector addSubview:svwList];
    [svwList release];
    
    // 닫기 버튼
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(196/2, (360+94)/2,  140/2, 62/2)];
    [btnClose setImage:[UIImage imageNamed:@"popup_btn_close.png"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(onCloseAddressList:) forControlEvents:UIControlEventTouchUpInside];
    [vwMultiPOISelector addSubview:btnClose];
    [btnClose release];
    
    // 팝업 리스트 뷰 삽입
    [_vwMultiAddressSelector addSubview:vwMultiPOISelector];
    [vwMultiPOISelector release];
    
    
    // 주소가 2개 이상일때 목록화면 노출
    [self.view addSubview:_vwMultiAddressSelector];
}

- (void) renderMultiSearchResultSelector:(BOOL)isAddress :(BOOL)isNewAddress
{
    //  딤드화면 클리어
    for (UIView *subview in _vwMultiAddressSelector.subviews)
    {
        [subview removeFromSuperview];
    }
    
    // 팝업 리스트 뷰 배경
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popup_bg_06.png"]];
    
    // 팝업 리스트 뷰 생성
    UIView *vwMultiPOISelector = [[UIView alloc]
                                  initWithFrame:CGRectMake(54/2,230/2,532/2,
                                                           imgvwBack.image.size.height)];
    
    [imgvwBack setFrame:CGRectMake(0, 0, imgvwBack.image.size.width, imgvwBack.image.size.height)];
    [vwMultiPOISelector addSubview:imgvwBack];
    [imgvwBack release];
    
    // 사용자 이름 노출
    UILabel *lblContactUserName = [[UILabel alloc] initWithFrame:CGRectMake( (18+20)/2, (12+36)/2, 456/2, 30/2 )];
    [lblContactUserName setFont:[UIFont boldSystemFontOfSize:15]];
    [lblContactUserName setTextColor:[UIColor blackColor]];
    [lblContactUserName setBackgroundColor:[UIColor clearColor]];
    [lblContactUserName setLineBreakMode:NSLineBreakByTruncatingTail];
    [lblContactUserName setTextAlignment:NSTextAlignmentCenter];
    [lblContactUserName setText:[OllehMapStatus sharedOllehMapStatus].keyword];
    [vwMultiPOISelector addSubview:lblContactUserName];
    [lblContactUserName release];
    
    // 리스트 스크롤뷰 컨텐츠 높이
    float listContentsHeight = 0.0f;
    
    // 스크롤뷰 생성
    OMScrollView *svwList = [[OMScrollView alloc] initWithFrame:CGRectMake(18/2, 114/2, 496/2, (232+94)/2)];
    [svwList setDelegate:self];
    [svwList setScrollType:2];
    
    NSArray *searchResultList = nil;
    if ( isAddress && isNewAddress) searchResultList = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataNewAddress"];
    else if (isAddress) searchResultList = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"];
    else searchResultList = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataPlace"];
    
    for (int i=0, maxi=searchResultList.count; i<maxi; i++)
    {
        // 검색결과 하나씩 가져온다.
        NSDictionary *poiDic = [searchResultList objectAtIndexGC:i];
        
        if (isAddress)
        {
            NSLog(@"연락처 - 주소 검색");
            // 솔성 가져오기
            NSString *strName = nil;
            if ( isNewAddress ) strName = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"NEW_ADDR")];
            else strName = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"ADDRESS")];
            NSString *strAddr = nil;
            if ( isNewAddress ) strAddr = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"NEW_ADDR")];
            else strAddr = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"ADDRESS")];
            
            // POI 뷰 생성
            CGRect rectCell = CGRectMake(0, listContentsHeight, svwList.frame.size.width, 45);
            OMControlContact *vwCell = [[OMControlContact alloc] initWithFrame:rectCell];
            vwCell.isAddress = isAddress;
            vwCell.isNewAddress = isNewAddress;
            [vwCell setTag:i];
            [vwCell addTarget:self action:@selector(onSelectSearchResult:) forControlEvents:UIControlEventTouchUpInside];
            [vwCell addTarget:self action:@selector(onCellDown:) forControlEvents:UIControlEventTouchDown];
            [vwCell addTarget:self action:@selector(onCellUp:) forControlEvents:UIControlEventTouchUpOutside];
            [vwCell setName:strName];
            [vwCell setAddresses:searchResultList];
            
            // 라벨
            CGRect rectName = CGRectMake(78/2, 33/2, 398/2, 28/2); // 한줄 기준
            UILabel *lblName =[[UILabel alloc] initWithFrame:rectName];
            [lblName setFont:[UIFont systemFontOfSize:28/2]];
            [lblName setTextColor:[UIColor blackColor]];
            [lblName setBackgroundColor:[UIColor clearColor]];
            [lblName setTextAlignment:NSTextAlignmentLeft];
            [lblName setLineBreakMode:NSLineBreakByClipping];
            [lblName setText:strAddr];
            
            // 라벨 텍스트에 최적화정보
            LabelResizeInfo labelNameResizeInfo = getLabelResizeInfo(lblName, 398/2);
            // 라벨 사이즈에 따른 라벨 높이 수정
            if (labelNameResizeInfo.numberOfLines > 1)
            {
                rectName.origin.y = labelNameResizeInfo.origin.y = 20/2;
                rectName.size = labelNameResizeInfo.newSize;
            }
            else
            {
                rectName.origin.y = labelNameResizeInfo.origin.y = 32/2;
                rectName.size = labelNameResizeInfo.newSize;
            }
            // 라벨 텍스트 변경사항 반영
            setLabelResizeWithLabelResizeInfo(lblName, labelNameResizeInfo);
            
            [lblName setFrame:rectName];
            [vwCell addSubview:lblName];
            [lblName release];
            
            // 라벨에 따른 뷰 사이즈 수정
            if ( labelNameResizeInfo.numberOfLines > 1 )
                rectCell.size.height = rectName.size.height + 20/2 + 20/2;
            else
                rectCell.size.height = rectName.size.height + 32/2 + 30/2;
            
            // 인덱스 아이콘 풍선
            UIImageView *imgvwIndexIconBalloon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_b_marker_poi.png"]];
            CGRect rectIndexIconBalloon = CGRectMake(16/2, 14/2, imgvwIndexIconBalloon.image.size.width, imgvwIndexIconBalloon.image.size.height);
            
            // 라벨 높이에 따른 아이콘 위치 변경
            if ( labelNameResizeInfo.numberOfLines > 1 )
                rectIndexIconBalloon.origin.y = 20/2;   // 원래 18/2
            else
                rectIndexIconBalloon.origin.y = 16/2;   // 원래 14/2
            
            [imgvwIndexIconBalloon setFrame:rectIndexIconBalloon];
            [vwCell addSubview:imgvwIndexIconBalloon];
            [imgvwIndexIconBalloon release];
            
            // POI 뷰 삽입
            [vwCell setFrame:rectCell];
            [svwList addSubview:vwCell];
            [vwCell release];
            listContentsHeight += rectCell.size.height;
            
        }
        // 장소검색 결과인 경우
        else
        {
            NSLog(@"연락처 - 장소 검색");
            // 솔성 가져오기
            NSString *strName = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"NAME"]];
            NSString *strAddr = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ADDR"]];
            
            // POI 뷰 생성
            CGRect rectCell = CGRectMake(0, listContentsHeight, svwList.frame.size.width, 45);
            OMControlContact *vwCell = [[OMControlContact alloc] initWithFrame:rectCell];
            vwCell.isAddress = isAddress;
            vwCell.isNewAddress = isNewAddress;
            [vwCell setTag:i];
            [vwCell addTarget:self action:@selector(onSelectSearchResult:) forControlEvents:UIControlEventTouchUpInside];
            [vwCell addTarget:self action:@selector(onCellDown:) forControlEvents:UIControlEventTouchDown];
            [vwCell addTarget:self action:@selector(onCellUp:) forControlEvents:UIControlEventTouchUpOutside];
            [vwCell setName:strName];
            [vwCell setAddresses:searchResultList];
            
            // 라벨 (장소)
            CGRect rectName = CGRectMake(78/2, 20/2, 398/2, 28/2);
            UILabel *lblName =[[UILabel alloc] initWithFrame:rectName];
            [lblName setFont:[UIFont boldSystemFontOfSize:28/2]];
            [lblName setTextColor:[UIColor blackColor]];
            [lblName setBackgroundColor:[UIColor clearColor]];
            [lblName setTextAlignment:NSTextAlignmentLeft];
            [lblName setLineBreakMode:NSLineBreakByTruncatingTail];
            [lblName setText:[NSString stringWithFormat:@"%@", strName]];
            [vwCell addSubview:lblName];
            [lblName release];
            
            // 라벨 (주소)
            CGRect rectAddress = CGRectMake(78/2, 56/2, 398/2, 28/2);
            UILabel *lblAddress =[[UILabel alloc] initWithFrame:rectAddress];
            [lblAddress setFont:[UIFont systemFontOfSize:28/2]];
            [lblAddress setTextColor:[UIColor blackColor]];
            [lblAddress setBackgroundColor:[UIColor clearColor]];
            [lblAddress setTextAlignment:NSTextAlignmentLeft];
            [lblAddress setLineBreakMode:NSLineBreakByClipping];
            [lblAddress setText:[NSString stringWithFormat:@"%@", strAddr]];
            [lblAddress setNumberOfLines:999];
            rectAddress.size = [lblAddress.text sizeWithFont:lblAddress.font constrainedToSize:CGSizeMake(rectAddress.size.width, FLT_MAX) lineBreakMode:lblAddress.lineBreakMode];
            
            // 라벨 높이 조정
            if (rectAddress.size.height < 28/2) rectAddress.size.height = 28/2;
            
            [lblAddress setFrame:rectAddress];
            [vwCell addSubview:lblAddress];
            [lblAddress release];
            
            
            // 라벨에 따른 뷰 사이즈 수정
            rectCell.size.height = rectName.size.height + 8/2 + rectAddress.size.height + 20/2 + 20/2;
            
            // 인덱스 아이콘 풍선
            UIImageView *imgvwIndexIconBalloon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_b_marker_poi.png"]];
            CGRect rectIndexIconBalloon = CGRectMake(18/2, 18/2, imgvwIndexIconBalloon.image.size.width, imgvwIndexIconBalloon.image.size.height);
            [imgvwIndexIconBalloon setFrame:rectIndexIconBalloon];
            [vwCell addSubview:imgvwIndexIconBalloon];
            [imgvwIndexIconBalloon release];
            
            // POI 뷰 삽입
            [vwCell setFrame:rectCell];
            [svwList addSubview:vwCell];
            [vwCell release];
            listContentsHeight += rectCell.size.height;
            
        }
        
        // 라인 삽입
        UIView *vwLine = [[UIView alloc] initWithFrame:CGRectMake(0, listContentsHeight, svwList.frame.size.width, 1)];
        [vwLine setBackgroundColor:convertHexToDecimalRGBA(@"DC", @"DC", @"DC", 1.0f)];
        [svwList addSubview:vwLine];
        [vwLine release];
        listContentsHeight += 1;
    }
    [svwList setContentSize:CGSizeMake(svwList.frame.size.width, listContentsHeight)];
    [vwMultiPOISelector addSubview:svwList];
    [svwList release];
    
    // 닫기 버튼
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(98, 183+47, 70, 31)];
    [btnClose setImage:[UIImage imageNamed:@"popup_btn_close.png"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(onCloseAddressList:) forControlEvents:UIControlEventTouchUpInside];
    [vwMultiPOISelector addSubview:btnClose];
    [btnClose release];
    
    // 팝업 리스트 뷰 삽입
    [_vwMultiAddressSelector addSubview:vwMultiPOISelector];
    [vwMultiPOISelector release];
    
    
    // 주소가 2개 이상일때 목록화면 노출
    [self.view addSubview:_vwMultiAddressSelector];
}

- (void) onCellDown :(id)sender
{
    UIControl *cell = (UIControl*)sender;
    [cell setBackgroundColor:convertHexToDecimalRGBA(@"D9", @"F4", @"FF", 1.0)];
}
- (void) onCellUp:(id)sender
{
    UIControl *cell = (UIControl*)sender;
    [cell setBackgroundColor:[UIColor whiteColor]];
}

// *********************

// =====================
// [ 연락처 제어 메소드 ]
// =====================

- (void) refineContact
{
    
}


- (void) searchPersonAddress :(ABRecordRef)ref
{
    CFStringRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
    CFStringRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
    //NSNumber *recordId = [NSNumber numberWithInteger: ABRecordGetRecordID(ref)];
    
    NSMutableArray *phoneAddressStringList = [NSMutableArray array];
    
    // 주소 구조체 및 카테고리 추출
    ABMultiValueRef phoneAddress = (ABMultiValueRef)ABRecordCopyValue(ref, kABPersonAddressProperty);
    for (CFIndex j = 0, maxj = ABMultiValueGetCount(phoneAddress); j < maxj; j++)
    {
        //CFStringRef label = ABMultiValueCopyLabelAtIndex(phoneAddress, j);
        CFTypeRef tempRef = ABMultiValueCopyValueAtIndex(phoneAddress, j);
        
        
        if (tempRef != nil)
        {
            NSMutableString *phoneAddressString = [NSMutableString string];
            
            NSDictionary *addressDic = (NSDictionary*)tempRef;
            //NSLog(@"%@", addressDic);
            
            if ([[addressDic allKeys] containsObject:@"State"] )
                [phoneAddressString appendFormat:@"%@ ", [addressDic objectForKeyGC:@"State"]]; // 서울시
            if ([[addressDic allKeys] containsObject:@"City"] )
                [phoneAddressString appendFormat:@"%@ ", [addressDic objectForKeyGC:@"City"]]; // 00구
            
            if ([[addressDic allKeys] containsObject:@"Street"] )
            {
                NSArray *streets = [[addressDic objectForKeyGC:@"Street"] componentsSeparatedByString:@"\n"];
                if ( streets.count > 0 )
                    for (NSString *street in streets)
                        [phoneAddressString appendFormat:@"%@ ", street]; // 00동 00번지
                else
                    [phoneAddressString appendFormat:@"%@ ", [addressDic objectForKeyGC:@"Street"]]; // 00동 00번지
            }
            
            //[phoneAddressString appendFormat:@"%@ ", [addressDic objectForKeyGC:@"Country"]];
            //[phoneAddressString appendFormat:@"%@ ", [addressDic objectForKeyGC:@"CountryCode"]];
            
            [phoneAddressStringList addObject: [phoneAddressString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ];
            
            //NSLog(@"이름 : %@ %@/ 주소 : %@", (NSString*)firstName, (NSString*)lastName, phoneAddressString);
        }
        
        //if (label) CFRelease(label);
        if (tempRef) CFRelease(tempRef);
    }
    CFRelease(phoneAddress);
    
    if (phoneAddressStringList.count <= 0)
    {
        [OMMessageBox showAlertMessage:@"" :@"주소가 없습니다."];
    }
    else if (phoneAddressStringList.count == 1)
    {
        
        NSMutableString *name = [NSMutableString string];
        if (lastName != nil) [name appendFormat:@"%@", (NSString*)lastName];
        if (firstName != nil) [name appendFormat:@" %@", (NSString*)firstName];
        NSString *name2 = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *addres = [phoneAddressStringList objectAtIndexGC:0];
        
        [self search:name2 :addres];
    }
    else if (phoneAddressStringList.count >= 2)
    {
        NSMutableString *name = [NSMutableString string];
        if (lastName != nil) [name appendFormat:@"%@", (NSString*)lastName];
        if (firstName != nil) [name appendFormat:@" %@", (NSString*)firstName];
        NSString *name2 = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [self renderMultiAddressSelector:name2 :phoneAddressStringList];
    }
    else
    {
    }
    
    if (firstName != nil) CFRelease(firstName);
    if (lastName != nil) CFRelease(lastName);
    
}

- (void) search :(NSString *)personName :(NSString*)personAddress;
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    //oms.keyword = personName;
    oms.keyword = personAddress;
    
    [oms resetLocalSearchDictionary:@"Place"];
    [oms resetLocalSearchDictionary:@"Address"];
    [oms resetLocalSearchDictionary:@"NewAddress"];
    [oms resetLocalSearchDictionary:@"PublicBusStation"];
    [oms resetLocalSearchDictionary:@"PublicBusNumber"];
    [oms resetLocalSearchDictionary:@"PublicSubwayStation"];
    
    // 주소검색 실행
    Coord searchCrd = [MapContainer sharedMapContainer_Main].kmap.centerCoordinate;
    [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearch:) key:personAddress mapX:searchCrd.x mapY:searchCrd.y s:@"an" sr:@"RANK" p_startPage:0 a_startPage:0 n_startPage:0 indexCount:5 option:1];
}

- (void) didFinishSearch :(id)request
{
    
    // 검색결과를 받아서 처리한다.
    if ([request finishCode] == OMSRFinishCode_Completed)
    {
        @try
        {
            OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
            
            // 주소검색결과
            if ( [[request userString] isEqualToString:@"an"] )
            {
                // 검색결과 카운트 계산
                int countNewAddress = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountNewAddress"] intValue];
                int countAddress = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountAddress"] intValue];
                
                // 새주소 검색결과가 한개일 경우
                if ( countNewAddress == 1)
                {
                    // 지도화면 전환
                    NSMutableDictionary *dicAddress = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataNewAddress"] objectAtIndexGC:0];
                    
                    Coord poiCrd = CoordMake([[dicAddress objectForKeyGC:@"X"] doubleValue], [[dicAddress objectForKeyGC:@"Y"] doubleValue]);
                    NSString *addressName = [dicAddress objectForKeyGC:@"NEW_ADDR"];
                    
                    [oms.searchResult reset]; // 검색결과 리셋
                    [oms.searchResult setUsed:YES];
                    [oms.searchResult setIsCurrentLocation:NO];
                    //[oms.searchResult setStrLocationName:oms.keyword];
                    [oms.searchResult setStrLocationName:addressName];
                    [oms.searchResult setStrLocationAddress:addressName];
                    [oms.searchResult setCoordLocationPoint:poiCrd];
                    [oms.searchResult setStrID:@""];
                    [oms.searchResult setStrType:@"ADDR"];
                    [oms.searchResult setIndex:0];
                    
                    // 메인맵 컨테이너 생성
                    [MainMapViewController markingSinglePOI_RenderType:MainMap_SinglePOI_Type_Normal animated:NO];
                }
                // 새주소 검색결과가 여러개 있을 경우
                else if ( countNewAddress > 1)
                {
                    // 새주소의 경우 완전 동일한 주소는 존재하지 않는다는 가정하에 목록을 다 보여주도록 한다.
                    // 여러개 주소 렌더링
                    [self renderMultiSearchResultSelector:YES:YES];
                }
                // 주소 검색결과가 한개일경우
                else if (countAddress == 1 )
                {
                    // 지도화면 전환
                    NSMutableDictionary *dicAddress = [[[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"] objectAtIndexGC:0];
                    
                    Coord poiCrd = CoordMake([[dicAddress objectForKeyGC:@"X"] doubleValue], [[dicAddress objectForKeyGC:@"Y"] doubleValue]);
                    NSString *addressName = [dicAddress objectForKeyGC:@"ADDRESS"];
                    
                    [oms.searchResult reset]; // 검색결과 리셋
                    [oms.searchResult setUsed:YES];
                    [oms.searchResult setIsCurrentLocation:NO];
                    //[oms.searchResult setStrLocationName:oms.keyword];
                    [oms.searchResult setStrLocationName:addressName];
                    [oms.searchResult setStrLocationAddress:addressName];
                    [oms.searchResult setCoordLocationPoint:poiCrd];
                    [oms.searchResult setStrID:@""];
                    [oms.searchResult setStrType:@"ADDR"];
                    [oms.searchResult setIndex:0];
                    
                    // 메인맵 컨테이너 생성
                    [MainMapViewController markingSinglePOI_RenderType:MainMap_SinglePOI_Type_Normal animated:NO];
                }
                // 주소 검색결과가 여러개일 경우
                else if (countAddress > 1)
                {
                    // 주소검색결과가 여러개라도 최초 검색어와 동일한케이스가 존재하면 바로 이동한다.
                    NSArray *searchResultList = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"];
                    for (int i=0, maxi=searchResultList.count; i<maxi; i++)
                    {
                        // 검색결과 하나씩 가져온다.
                        NSDictionary *poiDic = [searchResultList objectAtIndexGC:i];
                        // 솔성 가져오기
                        NSString *strName = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ADDRESS"]];
                        NSString *strAddr = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ADDRESS"]];
                        
                        NSLog(@"|%@|  |%@|", strAddr, oms.keyword);
                        
                        if ([strAddr isEqualToString:[OllehMapStatus sharedOllehMapStatus].keyword])
                        {
                            
                            Coord poiCrd = CoordMake([[poiDic objectForKeyGC:@"X"] doubleValue], [[poiDic objectForKeyGC:@"Y"] doubleValue]);
                            
                            [oms.searchResult reset]; // 검색결과 리셋
                            [oms.searchResult setUsed:YES];
                            [oms.searchResult setIsCurrentLocation:NO];
                            //[oms.searchResult setStrLocationName:oms.keyword];
                            [oms.searchResult setStrLocationName:strName];
                            [oms.searchResult setStrLocationAddress:strAddr];
                            [oms.searchResult setCoordLocationPoint:poiCrd];
                            [oms.searchResult setStrID:@""];
                            [oms.searchResult setStrType:@"ADDR"];
                            [oms.searchResult setIndex:0];
                            
                            // 메인맵 컨테이너 생성
                            [MainMapViewController markingSinglePOI_RenderType:MainMap_SinglePOI_Type_Normal animated:NO];
                            return;
                        }
                    }
                    
                    // 여러개 주소 렌더링
                    [self renderMultiSearchResultSelector:YES:NO];
                }
                // 주소 검색결과가 없으면
                else
                {
                    // 장소 검색 시도
                    // 주소검색 실행
                    Coord searchCrd = [MapContainer sharedMapContainer_Main].kmap.centerCoordinate;
                    [[ServerConnector sharedServerConnection] requestSearchPlaceAndAddress:self action:@selector(didFinishSearch:) key:oms.keyword mapX:searchCrd.x mapY:searchCrd.y s:@"p" sr:@"RANK" p_startPage:0 a_startPage:0 n_startPage:0 indexCount:5 option:1];
                    
                }
            }
            // 장소검색결과
            else if ( [[request userString] isEqualToString:@"p"] )
            {
                // 검색결과 카운트 계산
                int countPlace = [[oms.searchLocalDictionary objectForKeyGC:@"TotalCountPlace"] intValue];
                
                // 장소 검색결과 존재하면 처리
                if (countPlace == 1 )
                {
                    //[OMMessageBox showAlertMessage:@"" :@"연락처 - 장소검색 - 결과 한개 존재"];
                    [self renderMultiSearchResultSelector:NO:NO];
                }
                // 장소 검색결과가 여러개일 경우
                else if (countPlace > 1)
                {
                    //[OMMessageBox showAlertMessage:@"" :@"연락처 - 장소검색 - 결과 여러개 존재"];
                    [self renderMultiSearchResultSelector:NO:NO];
                }
                // 장소 검색 결과마저 없으면 메세지 처리
                else
                {
                    // 오류없이 결과없음 메세지 처리
                    //[OMMessageBox showAlertMessage:NSLocalizedString(@"Msg_SearchFailed_InvalidAddress", @"") :[NSString stringWithFormat:@"\n\"%@\"", [request userObject]]];
                    [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailed_InvalidAddress", @"")];
                }
                
            }
        }
        
        @catch (NSException *ex)
        {
            NSLog(@"didFinishSearchInit 메소드 예외발생 : %@", [ex reason]);
        }
        
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
}


// *********************



// ==============================
// [ 네비게이션 메소드 - private ]
// ==============================

- (void) onClose :(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

- (void) onCloseAddressList:(id)sender
{
    for (UIView *subview in _vwMultiAddressSelector.subviews)
    {
        [subview removeFromSuperview];
    }
    
    [_vwMultiAddressSelector removeFromSuperview];
    
}

- (void) onSelectAddress:(id)sender
{
    // 호출한 셀 정보가져오기
    OMControlContact *cell = (OMControlContact*)sender;
    NSString *address = [[cell addresses] objectAtIndexGC:cell.tag];
    
    // 주소선택 팝업 제거
    [_vwMultiAddressSelector removeFromSuperview];
    
    // 검색시도
    [self search:cell.name :address];
    
}

- (void) onSelectSearchResult:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    // 호출한 셀 정보가져오기
    OMControlContact *cell = (OMControlContact*)sender;
    NSDictionary *poiDic = [[cell addresses] objectAtIndexGC:cell.tag];
    //BOOL isAddress = [[OllehMapStatus sharedOllehMapStatus].searchLocalDictionary objectForKeyGC:@"DataAddress"] == [cell addresses];
    BOOL isAddress = cell.isAddress;
    BOOL isNewAddress = cell.isNewAddress;
    
    if (isAddress)
    {
        NSString *strName = nil;
        if ( isNewAddress ) strName = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"NEW_ADDR")];
        else strName = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"ADDRESS")];
        NSString *strAddr = nil;
        if ( isNewAddress ) strAddr = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"NEW_ADDR")];
        else strAddr = [NSString stringWithFormat:@"%@", stringValueOfDictionary(poiDic, @"ADDRESS")];
        
        NSString *strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@""]];
        NSString *strType = [NSString stringWithFormat:@"ADDR"];
        Coord crd = CoordMake([[poiDic objectForKeyGC:@"X"] doubleValue], [[poiDic objectForKeyGC:@"Y"] doubleValue]);
        //NSString * strSTheme = @"";
        
        [oms.searchResult reset];
        [oms.searchResult setUsed:YES];
        [oms.searchResult setIsCurrentLocation:NO];
        [oms.searchResult setStrType:strType];
        [oms.searchResult setStrID:strID];
        [oms.searchResult setStrLocationName:strName];
        [oms.searchResult setStrLocationAddress:strAddr];
        [oms.searchResult setCoordLocationPoint:crd];
        
        [_vwMultiAddressSelector removeFromSuperview];
        
        [MainMapViewController markingSinglePOI_RenderType:MainMap_SinglePOI_Type_Normal animated:NO];
    }
    else
    {
        NSString *strName = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"NAME"]];
        NSString *strAddr = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ADDR"]];
        NSString *strID = nil;
        NSString *strType = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ORG_DB_TYPE"]];
        NSString *strSTheme = @"";
        if ([strType isEqualToString:@"TR"])
        {
            strType = @"TR_RAW";
            strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"DOCID"]];
        }
        else if ([strType isEqualToString:@"OL"])
        {
            strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"DOCID"]];
        }
        else if ([strType isEqualToString:@"MV"])
        {
            strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"DOCID"]];
        }
        else
        {
            strID = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"ORG_DB_ID"]];
        }
        
        if ([[poiDic allKeys] containsObject:@"STHEME_CODE"] && [[poiDic objectForKeyGC:@"STHEME_CODE"] isEqualToString:@"PG1201000000008"] )
            strSTheme = [NSString stringWithFormat:@"%@", [poiDic objectForKeyGC:@"STHEME_CODE"]];
        else
            strSTheme = @"";
        
        Coord crd = CoordMake([[poiDic objectForKeyGC:@"X"] doubleValue], [[poiDic objectForKeyGC:@"Y"] doubleValue]);
        
        [oms.searchResult reset];
        [oms.searchResult setUsed:YES];
        [oms.searchResult setIsCurrentLocation:NO];
        [oms.searchResult setStrType:strType];
        [oms.searchResult setStrID:strID];
        [oms.searchResult setStrLocationName:strName];
        [oms.searchResult setStrLocationAddress:strAddr];
        [oms.searchResult setCoordLocationPoint:crd];
        [oms.searchResult setStrSTheme:strSTheme];
        
        [_vwMultiAddressSelector removeFromSuperview];
        
        [MainMapViewController markingSinglePOI_RenderType:MainMap_SinglePOI_Type_Normal animated:NO];
    }
    
}

// ******************************


// =====================================================
// [ ABPeoplePickerNavigationController Delegate 메소드 ]
// =====================================================


- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    [self searchPersonAddress:person];
    return NO;
}

- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    [self searchPersonAddress:person];
    return NO;
}

- (void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    NSLog(@"peoplePickerNavigationControllerDidCancel");
}

// *****************************************************

@end













// 이미지 터치 회전값 구하기
double whellAngleFromPoint (CGPoint location, UIImage *image)
{
    double retAngle;
    
    // subtract center of whell
    location.x -= image.size.width / 2.0;
    location.y = image.size.height / 2.0 - location.y;
    
    // normalize vector
    double vector_length = sqrt(location.x * location.x + location.y * location.y);
    location.x = location.x / vector_length;
    location.y = location.y / vector_length;
    
    retAngle = acos(location.y);
    
    if (location.x<0)
        retAngle = -retAngle;    
    
    return retAngle;
}

