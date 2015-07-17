//
//  SubwayPOIDetailViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 6. 5..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonPOIDetailViewController.h"
// X 좌표
#define X_VALUE 0
// 너비
#define X_WIDTH 320

@interface SubwayPOIDetailViewController : CommonPOIDetailViewController<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    
    // 열차시간표, 첫차막차, 출구정보라벨
    UIView *_timeFirstLastExitLabelView;
    UIImageView *_timeFisrtLastExitImg;
    
    UILabel *_trainTimeTableLabel;
    UIButton *_trainTimeTableBtn;
    UILabel *_firstLastLabel;
    UIButton *_firstLastBtn;
    UILabel *_exitInfoLabel;
    UIButton *_exitInfoBtn;
    //
    // 열차시간표뷰
    UIView *_trainTimeTableView;
    
    UIView *_trainTimeTableOptionView;
    
    UIView *_trainTimeTableTimeView;
    
    UIImageView *trainTimeTableTimeBG;
    
    
    UIImageView *_weekdayImg;
    UIImageView *_saturdayImg;
    UIImageView *_sundayImg;
    
    UIButton *_weekdayBtn;
    UIButton *_saturdayBtn;
    UIButton *_sundayBtn;
    // 라벨
    UILabel *_timeRange;
    // < > 버튼
    UIButton *_prevPageBtn;
    UIButton *_nextPageBtn;
    
    UILabel *_leftDirection;
    UILabel *_rightDirection;
    
    
    // 탑뷰
    UIView *_subTopView;
    UIScrollView *_smallScroll;
    UIPageControl *_pControl;
    int paging;
    // 첫차막차뷰
    
    UIView *_firstLastView;
    
    UIButton *_weekDayButton;
    UIButton *_saturDatButton;
    UIButton *_sunDayButton;
    
    UIImageView *_weekDayImage;
    UIImageView *_saturDayImage;
    UIImageView *_sunDayImage;
    
    UIView *_upperLabelView;
    UILabel *_upperLabel;
    
    UIView *_upperView;
    
    UIImageView *_upperBackGround;
    
    UILabel *_upperFirstTime;
    UILabel *_upperFirstDest;
    
    UILabel *_upperLastTime;
    UILabel *_upperLastDest;
    
    
    
    UIView *_downerLabelView;
    UILabel *_downerLabel;
    
    UIView *_downerView;
    
    UIImageView *_downerBackGround;
    
    UILabel *_downerFirstTime;
    UILabel *_downerFirstDest;
    UILabel *_downerLastTime;
    UILabel *_downerLastDest;
    
    NSInteger _prevFirstLastViewStartY;
    //
    
    // 출구정보뷰
    UIView *_exitInfoView;
    
    NSInteger _addViewNum;
    
    NSInteger _viewStartY;
    NSInteger _prevViewStartY;
    NSInteger _firstLastViewStartY;
    NSInteger _exitInfoStartY;
    NSInteger _prevExitInfoStartY;
    
    // 상세정보뷰
    UIView *_detailInfoView;
    
    // 환승모달뷰
    
    // 환승역 정보
    NSMutableArray *_translateListArray;
    
    UIView *_translatePopView;
    UIView *_translateModalView;
    UIImageView *_translateModalBg;
    UILabel *_translateModalLabel;
    UIButton *_cancelBtn;
    
    UIView *_translateCurrentStation;
    UIImageView *_currentStationRadioImg;
    UIImageView *_currentStationLine;
    UILabel *_currentStation;
    
    
    
    UIView *_translateFirstStation;
    UIImageView *_translate1RadioImg;
    UIImageView *_translate1StationLine;
    UILabel *_translate1Station;
    
    UIView *_translateSecondStation;
    UIImageView *_translate2RadioImg;
    UIImageView *_translate2StationLine;
    UILabel *_translate2Station;
    
    UIView *_translateThirdStation;
    UIImageView *_translate3RadioImg;
    UIImageView *_translate3Line;
    UILabel *_translate3Station;
    
    // 하단버튼뷰
    UIView *_bottomView;
    
    // 오늘요일은?
    int _today;
    // 평일? 토욜? 주말?
    int _typeDay;
    
    // 현재시간(24시)
    int _currentHour;
    // 현재 분
    int _currentMin;
    
    int _page;
    
    BOOL _isFisrt;
    
    UIButton *_mapBtn;
    
}

@property (retain, nonatomic) IBOutlet UIButton *popBtn;
@property (retain, nonatomic) IBOutlet UIButton *mapBtn;

-(IBAction)popBtnClick:(id)sender;
-(IBAction)mapBtnClick:(id)sender;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;


// 열차시간표, 첫차막차, 출구정보라벨뷰
@property (retain, nonatomic) IBOutlet UIView *timeFirstLastExitLabelView;
@property (retain, nonatomic) IBOutlet UIImageView *timeFisrtLastExitImg;

@property (retain, nonatomic) IBOutlet UILabel *trainTimeTableLabel;
@property (retain, nonatomic) IBOutlet UIButton *trainTimeTableBtn;
@property (retain, nonatomic) IBOutlet UILabel *firstLastLabel;
@property (retain, nonatomic) IBOutlet UIButton *firstLastBtn;
@property (retain, nonatomic) IBOutlet UILabel *exitInfoLabel;
@property (retain, nonatomic) IBOutlet UIButton *exitInfoBtn;

- (IBAction)tranTimeTableBtnClick:(id)sender;
- (IBAction)firstLastBtnClick:(id)sender;
- (IBAction)exitInfoBtnClick:(id)sender;
// 열차시간표뷰
@property (retain, nonatomic) IBOutlet UIView *trainTimeTableView;
@property (retain, nonatomic) IBOutlet UIView *trainTimeTableTimeView;
@property (retain, nonatomic) IBOutlet UIImageView *trainTimeTableTimeBG;




// 옵션뷰
@property (retain, nonatomic) IBOutlet UIView *trainTimeTableOptionView;

@property (retain, nonatomic) IBOutlet UIImageView *weekdayImg;
@property (retain, nonatomic) IBOutlet UIImageView *saturdayImg;
@property (retain, nonatomic) IBOutlet UIImageView *sundayImg;

@property (retain, nonatomic) IBOutlet UIButton *weekdayBtn;
@property (retain, nonatomic) IBOutlet UIButton *saturdayBtn;
@property (retain, nonatomic) IBOutlet UIButton *sundayBtn;

- (IBAction)weekdayBtnClick:(id)sender;
- (IBAction)saturdayBtnClick:(id)sender;
- (IBAction)sundayBtnClick:(id)sender;

- (IBAction)prevPageClick:(id)sender;
- (IBAction)nextPageClick:(id)sender;

// 라벨
@property (retain, nonatomic) IBOutlet UILabel *timeRange;
// < > 버튼
@property (retain, nonatomic) IBOutlet UIButton *prevPageBtn;
@property (retain, nonatomic) IBOutlet UIButton *nextPageBtn;

// 방향
@property (retain, nonatomic) IBOutlet UILabel *leftDirection;
@property (retain, nonatomic) IBOutlet UILabel *rightDirection;

@property (retain, nonatomic) IBOutlet UILabel *upperTime;
@property (retain, nonatomic) IBOutlet UILabel *upperDest;

@property (retain, nonatomic) IBOutlet UILabel *downerTime;
@property (retain, nonatomic) IBOutlet UILabel *downerDest;





// 첫차막차뷰

@property (retain, nonatomic) IBOutlet UIView *firstLastView;


@property (retain, nonatomic) IBOutlet UIButton *weekDayButton;
@property (retain, nonatomic) IBOutlet UIButton *saturDatButton;
@property (retain, nonatomic) IBOutlet UIButton *sunDayButton;

- (IBAction)weekDayButtonClick:(id)sender;
- (IBAction)saturDatButtonClick:(id)sender;
- (IBAction)sunDayButtonClick:(id)sender;

@property (retain, nonatomic) IBOutlet UIImageView *weekDayImage;
@property (retain, nonatomic) IBOutlet UIImageView *saturDayImage;
@property (retain, nonatomic) IBOutlet UIImageView *sunDayImage;

@property (retain, nonatomic) IBOutlet UIView *upperLabelView;
@property (retain, nonatomic) IBOutlet UILabel *upperLabel;

@property (retain, nonatomic) IBOutlet UIView *upperView;

@property (retain, nonatomic) IBOutlet UIImageView *upperBackGround;

@property (retain, nonatomic) IBOutlet UILabel *upperFirstTime;
@property (retain, nonatomic) IBOutlet UILabel *upperFirstDest;

@property (retain, nonatomic) IBOutlet UILabel *upperLastTime;
@property (retain, nonatomic) IBOutlet UILabel *upperLastDest;



@property (retain, nonatomic) IBOutlet UIView *downerLabelView;
@property (retain, nonatomic) IBOutlet UILabel *downerLabel;

@property (retain, nonatomic) IBOutlet UIView *downerView;

@property (retain, nonatomic) IBOutlet UIImageView *downerBackGround;

@property (retain, nonatomic) IBOutlet UILabel *downerFirstTime;
@property (retain, nonatomic) IBOutlet UILabel *downerFirstDest;
@property (retain, nonatomic) IBOutlet UILabel *downerLastTime;
@property (retain, nonatomic) IBOutlet UILabel *downerLastDest;



// 출구정보뷰
@property (retain, nonatomic) IBOutlet UIView *exitInfoView;


// 상세정보뷰

@property (retain, nonatomic) IBOutlet UIView *detailInfoView;


// 환승역뷰
@property (retain, nonatomic) IBOutlet UIView *translatePopView;
@property (retain, nonatomic) IBOutlet UIView *translateModalView;
@property (retain, nonatomic) IBOutlet UIImageView *translateModalBg;
@property (retain, nonatomic) IBOutlet UILabel *translateModalLabel;
@property (retain, nonatomic) IBOutlet UIButton *cancelBtn;

- (IBAction)cancelBtnClick:(id)sender;

// 현재역
@property (retain, nonatomic) IBOutlet UIView *translateCurrentStation;

@property (retain, nonatomic) IBOutlet UIImageView *currentStationRadioImg;

@property (retain, nonatomic) IBOutlet UIImageView *currentStationLine;

@property (retain, nonatomic) IBOutlet UILabel *currentStation;




// 환승역1
@property (retain, nonatomic) IBOutlet UIView *translateFirstStation;

@property (retain, nonatomic) IBOutlet UIImageView *translate1RadioImg;
@property (retain, nonatomic) IBOutlet UIImageView *translate1Line;
@property (retain, nonatomic) IBOutlet UILabel *translate1Station;

- (IBAction)translate1BtnClick:(id)sender;
- (IBAction)translate1BtnClickUp:(id)sender;


// 환승역2
@property (retain, nonatomic) IBOutlet UIView *translateSecondStation;

@property (retain, nonatomic) IBOutlet UIImageView *translate2RadioImg;
@property (retain, nonatomic) IBOutlet UIImageView *translate2Line;
@property (retain, nonatomic) IBOutlet UILabel *translate2Station;
@property (retain, nonatomic) IBOutlet UIImageView *tUnderline3;


- (IBAction)translate2BtnClick:(id)sender;

// 환승역3
@property (retain, nonatomic) IBOutlet UIView *translateThirdStation;
@property (retain, nonatomic) IBOutlet UIImageView *translate3RadioImg;
@property (retain, nonatomic) IBOutlet UIImageView *translate3Line;
@property (retain, nonatomic) IBOutlet UILabel *translate3Station;
@property (retain, nonatomic) IBOutlet UIImageView *tUnderLine4;

- (IBAction)translate3BtnClick:(id)sender;


// 하단버튼
@property (retain, nonatomic) IBOutlet UIView *bottomView;

- (IBAction)favoriteBtnClick:(id)sender;
- (IBAction)infoModifyAskBtnClick:(id)sender;
- (void)finishRequestTrafficSubwayDetailRefresh:(id)request;
- (void)finishRequestTrafficSubwayExitway:(id)request;
@end
