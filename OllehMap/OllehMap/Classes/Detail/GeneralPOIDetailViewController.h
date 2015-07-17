//
//  GeneralPOIDetailViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 5. 31..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonPOIDetailViewController.h"
// iPhone5
#import "uiviewcontroller+is4inch.h"

// X 좌표
#define X_VALUE 0
// 너비
#define X_WIDTH 320
// 상세옵션 뷰 기본위치
#define DETAILOPTION_X 10
#define DETAILOPTION_Y 10
// 상세옵션 뷰 간격
//#define DETAILOPTION_DIST 5
// 상세옵션 뷰 높이
#define DETAILOPTION_HEIGHT 17

@interface GeneralPOIDetailViewController : CommonPOIDetailViewController<CommonPOIDetailViewControllerDelegate>

{
    //UITextField *_tf;
    
    NSString *_freeCalling;
    NSString *_shapeType;
    NSString *_fcNm;
    NSString *_idBgm;
    
    
    UIScrollView *_scrollView;
    
    
    // 무료통화일때 전화번호
    UILabel *_telLabel;
    
    
    UIView *_mainInfoLabelView;
    // 주요정보 뷰
    
    UIView *_mainInfoView;
    UIView *_mainInfoNoDataView;
    
    UILabel *_mainInfoText;
    UILabel *_expandMainInfoText;
    
    UIButton *_expandBtn;
    UIImageView *_expandBtnImg;
    UIView *_underLine5;
    
    // 상세 진짜
    UIView *_detailInfoLabelView;
    UIView *_detailInfoNoDataView;
    // 상세옵션뷰
    UIView *_detailOptionBtnView;
    UIImageView *_reservationYN;
    UIImageView *_cardYN;
    UIImageView *_parkingYN;
    UIImageView *_deliveryYN;
    UIImageView *_packingYN;
    UIImageView *_beerYN;
    UIView *_underLine6;
    
    // 영업시간 뷰
    UIView *_openingTimeView;
    UILabel *_openingText;
    
    // 휴일정보 뷰
    UIView *_closingTimeView;
    UILabel *_closingText;
    
    
    // 이용요금 뷰
    UIView *_chargeView;
    UILabel *_chargeText;
    
    
    // 주변식당 뷰
    UIView *_nearlyRestView;
    UILabel *_nearlyRestText;
    
    // 상세 끝
    
    // 하단 버튼 3개 뷰
    UIView *_bottomView;
    
    UIView *_blankPOIlabel;
    
    IBOutlet UILabel *blankPOIlbl;
    
    UIView *_callLinkView;
    UITextField *_myNumber;
    UIButton *_goFreeCall;
    UIView *_callLinkAlertView;
    
    // y축
    NSInteger _viewStartY;
    
    // y축 기억해놓기
    NSInteger  _prevViewStartY;
    
    // 블랭크POI y축기억
    NSInteger _blankStartY;
    
    
    // 확장상태 체크
    BOOL _expand;
    
    // 주요정보 널 체크
    BOOL _mainInfoNull;
    // 상세정보 널 체크
    BOOL _detailInfoNull;
    // 주요정보뷰(축소일때) 너비, 높이 저장(확장, 축소)
    CGFloat _mainInfoViewNotExpendWidth;
    CGFloat _mainInfoViewNotExpendHeight;
    
    UIButton *_mapBtn;
    
    NSString *_themeToDetailName;
}
@property (retain, nonatomic) NSString *themeToDetailName;

@property (retain, nonatomic) NSString *freeCalling;
@property (retain, nonatomic) NSString *shapeType;
@property (retain, nonatomic) NSString *fcNm;
@property (retain, nonatomic) NSString *idBgm;

@property (retain, nonatomic) IBOutlet UIButton *popBtn;
@property (retain, nonatomic) IBOutlet UIButton *mapBtn;

- (IBAction)popBtnClick:(id)sender;
- (IBAction)mapBtnClick:(id)sender;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

// 주요정보 뷰
@property (retain, nonatomic) IBOutlet UIView *mainInfoNoDataView;


@property (retain, nonatomic) IBOutlet UIView *mainInfoView;

@property (retain, nonatomic) IBOutlet UILabel *mainInfoText;
@property (retain, nonatomic) IBOutlet UILabel *expandMainInfoText;

@property (retain, nonatomic) IBOutlet UIButton *expandBtn;
@property (retain, nonatomic) IBOutlet UIImageView *expandBtnImg;
@property (retain, nonatomic) IBOutlet UIView *underLine5;


- (IBAction)expandClick:(id)sender;

// 상세정보 진짜

// 상세정보제목
@property (retain, nonatomic) IBOutlet UIView *detailInfoLabelView;
@property (retain, nonatomic) IBOutlet UIView *detailInfoNoDataView;


// 상세옵션뷰
@property (retain, nonatomic) IBOutlet UIView *detailOptionBtnView;
@property (retain, nonatomic) IBOutlet UIImageView *reservationYN;
@property (retain, nonatomic) IBOutlet UIImageView *cardYN;
@property (retain, nonatomic) IBOutlet UIImageView *parkingYN;
@property (retain, nonatomic) IBOutlet UIImageView *deliveryYN;
@property (retain, nonatomic) IBOutlet UIImageView *packingYN;
@property (retain, nonatomic) IBOutlet UIImageView *beerYN;
@property (retain, nonatomic) IBOutlet UIView *underLine6;


// 영업시간 뷰
@property (retain, nonatomic) IBOutlet UIView *openingTimeView;
@property (retain, nonatomic) IBOutlet UILabel *openingText;

// 휴일정보 뷰
@property (retain, nonatomic) IBOutlet UIView *closingTimeView;
@property (retain, nonatomic) IBOutlet UILabel *closingText;


// 이용요금 뷰
@property (retain, nonatomic) IBOutlet UIView *chargeView;
@property (retain, nonatomic) IBOutlet UILabel *chargeText;


// 주변식당 뷰
@property (retain, nonatomic) IBOutlet UIView *nearlyRestView;
@property (retain, nonatomic) IBOutlet UILabel *nearlyRestText;




// 하단 버튼 3개 뷰
@property (retain, nonatomic) IBOutlet UIView *bottomView;

- (IBAction)favoriteClick:(id)sender;
- (IBAction)contactClick:(id)sender;
- (IBAction)modifyClick:(id)sender;


@property (retain, nonatomic) IBOutlet UIView *blankPOIlabel;

// 콜링크뷰 관련
@property (retain, nonatomic) IBOutlet UIView *callLinkView;

@property (retain, nonatomic) IBOutlet UIView *callLinkAlertView;

@property (retain, nonatomic) IBOutlet UITextField *myNumber;
@property (retain, nonatomic) IBOutlet UIButton *goFreeCall;

- (IBAction)goFreeCallClick:(id)sender;
- (IBAction)touchBackGround:(id)sender;
- (IBAction)keyboardShow:(id)sender;
@end
