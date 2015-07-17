//
//  SearchResultViewController2.h
//  OllehMap
//
//  Created by 이제민 on 13. 4. 4..
//
//

#import <UIKit/UIKit.h>
#import "OMMessageBox.h"
//#import "DetailCell.h"
#import "DetailCell2.h"
#import "OllehMapStatus.h"
#import "OMNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "CommonMapViewController.h"
#import "BusNumberLineViewController.h"
#import "LocalCell.h"
#import "AddressCell.h"
#import "BusStationCell.h"
#import "SubwayStationCell.h"
#import "TTTAttributedLabel.h"
// 상단
typedef enum {
    topWillSelectType_place = 1,
    topWillSelectType_address = 2,
    topWillSelectType_public = 3
} topWillButtonType;

typedef enum {
    topSelectedType_place = 1,
    topSelectedType_address = 2,
    topSelectedType_public = 3
} topButtonType;
// 라디오
typedef enum {
    commonRadioWillButtonType_accuracy = 11,
    commonRadioWillButtonType_distance = 12,
    commonRadioWillButtonType_busStation = 13,
    commonRadioWillButtonType_busNumber = 14,
    commonRadioWillButtonType_subWay = 15,
} commonRadioWillButtonType;

typedef enum {
    commonRadioButtonType_accuracy = 11,
    commonRadioButtonType_distance = 12,
    commonRadioButtonType_busStation = 13,
    commonRadioButtonType_busNumber = 14,
    commonRadioButtonType_subWay = 15,
} commonRadioButtonType;

typedef enum {
    addressSearchType_All = 0,
    addressSearchType_old = 1,
    addressSearchType_new = 2
} addressSearchType;

typedef enum {
    addressSectionType_old = 0,
    addressSectionType_new = 1
} addressSearchAllType;

typedef enum {
    addressTopSection = 0,
    addressBottomSection = 1
} addressSectionType;

@interface OMTableView : UITableView
@end

@interface UIPlaceTableView : OMTableView
@end
@interface UIAddressTableView : OMTableView
@end
@interface UIBusStationTableView : OMTableView
@end
@interface UIBusNumberTableView : OMTableView
@end
@interface UISubwayTableView : OMTableView
@end
@interface UIResearchTableView : UITableView
@end
// 리서치 셀 커스텀(고작 하이라이트 때매..)
@interface UIReSearchTableViewCell : UITableViewCell
@end

#define maxPage 100

@interface SearchResultViewController2 : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    
    IBOutlet UIButton *_multiMapBtn;
    
    topWillButtonType _topWillType;
    topButtonType _topType;
    commonRadioWillButtonType _commonRadioWillType;
    commonRadioButtonType _commonRadioType;
    
    addressSearchType _addressType;

    IBOutlet UIImageView *_topViewBackground;
    IBOutlet UIButton *_placeSearchBtn;
    IBOutlet UIButton *_addressSearchBtn;
    IBOutlet UIButton *_publicSearchBtn;
    
    
    IBOutlet UIView *_placeNAddressView;

    IBOutlet UIButton *_accuracyBtn;
    IBOutlet UIImageView *_accuracyImg;
    
    IBOutlet UIButton *_distanceBtn;
    IBOutlet UIImageView *_distanceImg;
    
    
    IBOutlet UIButton *_mapOrMyBtn;
    IBOutlet UILabel *_mapOrMyLabel;
    
    
    IBOutlet UIView *_publicView;
    
    IBOutlet UIButton *_busStationSearchBtn;
    
    IBOutlet UILabel *_busStationSearchLbl;
    IBOutlet UIImageView *_busStationImg;
    
    IBOutlet UIButton *_busNumSearchBtn;
    
    IBOutlet UILabel *_busNumSearchLbl;
    IBOutlet UIImageView *_busNumImg;
    
    IBOutlet UIButton *_subwaySearchBtn;
    IBOutlet UILabel *_subwaySearchLbl;
    IBOutlet UIImageView *_subwayImg;
    
    
    IBOutlet UIPlaceTableView *_placeTableView;
    IBOutlet UIAddressTableView *_addressTableView;
    
    addressSearchAllType _addressAllType;
    addressSectionType _addressTopBottomType;
    NSInteger _addressSection;
    
    BOOL _moreChecker;
    
    IBOutlet UIBusStationTableView *_busStationTableView;
    IBOutlet UIBusNumberTableView *_busNumTableView;
    IBOutlet UISubwayTableView *_subwayTableView;

    
    // 페이지 저장
    //int _pageSave;
    int _page;
    
    int                     _nSearchX;
    int                     _nSearchY;
    
    // 검색대상 타입 (출발/도착/경유)
    int _currentSearchTargetType;
    
    
    //검색쿼리변경
    int baseOption;
    
    // 검색어
    NSString *_searchKeyword;
    
    NSInteger _localIndex;
    NSInteger _addressIndex;
    NSInteger _busStationIndex;
    NSInteger _busNumberIndex;
    NSInteger _subwayIndex;
    
    // 페이징뷰
    IBOutlet UIView *_bottomView;
    IBOutlet UILabel *_pageLabel;
    IBOutlet UILabel *_totalPageLabel;
    IBOutlet UIButton *_prevBtn;
    IBOutlet UIButton *_nextBtn;
    
    // 재검색
    
    IBOutlet UIView *_searchControll;
    IBOutlet TTTAttributedLabel *_searchControllLbl;
    
    // 같은 이름 다른 지역 팝업창
    UIView *_vwreSearchContainer;
    
    UITableView *_reSearchTableView;
    // 같은 이름 다른 지역 카운트, 딕
    int _sameNameOtherPlaceCount;
    // 다른검색에서 더보기할 때 기존검색했던 100개를 담아놓는 그릇
    NSMutableArray *_reSearchDic;
    
    // 키워드 바뀐지 플래그(다른검색어로 검색)
    BOOL keywordChange;
    // 다른검색 플래그(다른검색어로 검색했을땐 검색쿼리변경 뷰가나오지않음)
    BOOL sameNameOtherPlaceCheck;
    // 마포갈비 처럼 예외로 들어오는 경우
    BOOL exceptioner;
    
    // 푸터
    UIControl *_moreView;
    NSInteger nPage;
    
    IBOutlet UIButton *_voiceBtn;
    
    // 음성선택 팝업 컨테이너
    UIView *_vwVoiceKeywordSelectorContainer;
    // 스크롤중 카테고리 변경을 위한 가림막 뷰
    UIView *_vwIndicatorByScroll;
}

@property (nonatomic, retain) NSString *searchKeyword;
// 검색 대상
@property (nonatomic, assign) int currentSearchTargetType;
@property (nonatomic, assign) int radioType;
@property (nonatomic, assign) int topType;
// 액션
- (IBAction)popBtnClick:(id)sender;
- (IBAction)multiMapClick:(id)sender;
- (IBAction)voiceBtnClick:(id)sender;



- (IBAction)topViewSelect:(id)sender;

- (IBAction)middleBtnClick:(id)sender;


- (IBAction)correctBtnSelect:(id)sender;
- (IBAction)distanceBtnSelect:(id)sender;
- (IBAction)busStationBtnSelect:(id)sender;
- (IBAction)busNumberBtnSelect:(id)sender;
- (IBAction)subwayBtnSelect:(id)sender;



- (IBAction)radioHightlightCancel:(id)sender;

- (IBAction)mapOrMyBtnClick:(id)sender;

- (IBAction)reSearchQuery:(id)sender;


// 페이징뷰
- (IBAction)prevBtnClick:(id)sender;
- (IBAction)nextBtnClick:(id)sender;

@end
