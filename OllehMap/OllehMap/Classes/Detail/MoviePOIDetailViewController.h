//
//  MoviePOIDetailViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 6. 8..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonPOIDetailViewController.h"

#define X_VALUE 0
#define X_WIDTH 320

@interface MoviePOIDetailViewController : CommonPOIDetailViewController

{
   
    UIScrollView *_scrollView;
    
    // 주요정보라벨뷰
    UIView *_mainInfoLabelView;
    
    // 주요정보없음
    UIView *_nullMainInfoView;
    
    // 주요정보뷰
    UIView *_mainInfoView;
    
    UILabel *_notExtendLabel;
    UILabel *_extendLabel;
    UIButton *_extendBtn;
    UIImageView *_extendBtnImg;
    
    
    // 밑줄5
    UIView *_underLine5;
    
    // 상영정보라벨뷰
    UIView *_movieLabelView;
    UILabel *_supportLabel;
    UIButton *_homePageBtn;
    // 상영정보뷰
    UIView *_movieView;
    // 상영정보없음뷰
    UIView *_nullMovieView;
    // 밑줄6
    UIView *_underLine6;
    // 상세/교통라벨 세그먼트
    UIView *_detailTrafficLabelView;
    UIImageView *_detailTrafficLabelBg;
    UILabel *_detailLabel;
    UILabel *_trafficLabel;
    
    UIButton *_detailBtn;
    UIButton *_trafficBtn;
    
    // 상세옵션뷰
    UIView *_detailOptionView;
    UIImageView *_reservationImg;
    
    // 옵션뷰 밑줄
    UIView *_underLine7;
    
    // 상세뷰
    UIView *_detailView;
    // 교통뷰
    UIView *_trafficView;
    
    // 하단버튼뷰
    UIView *_bottomView;
    
    
    NSInteger _viewStartY;
    NSInteger _prevViewStartY;
    
    // 상세y축기억
    NSInteger _detailY;
    // 교통y축기억
    NSInteger _trafficY;
    // 널 y축 기억
    NSInteger _nullStartY;
    
    CGFloat _mainInfoViewNotExpendWidth;
    CGFloat _mainInfoViewNotExpendHeight;
    
    BOOL _expend;
    
    UIButton *_mapBtn;
    
    NSString *_themeToDetailName;
}

@property (retain, nonatomic) NSString *themeToDetailName;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIButton *mapBtn;

-(IBAction)popBtnClick:(id)sender;
-(IBAction)mapBtnClick:(id)sender;



// 주요정보라벨뷰
@property (retain, nonatomic) IBOutlet UIView *mainInfoLabelView;

// 주요정보없음
@property (retain, nonatomic) IBOutlet UIView *nullMainInfoView;

// 주요정보뷰
@property (retain, nonatomic) IBOutlet UIView *mainInfoView;

@property (retain, nonatomic) IBOutlet UILabel *notExtendLabel;
@property (retain, nonatomic) IBOutlet UILabel *extendLabel;
@property (retain, nonatomic) IBOutlet UIButton *extendBtn;
@property (retain, nonatomic) IBOutlet UIImageView *extendBtnImg;

- (IBAction)extendBtnClick:(id)sender;

// 밑줄5
@property (retain, nonatomic) IBOutlet UIView *underLine5;

// 상영정보라벨뷰
@property (retain, nonatomic) IBOutlet UIView *movieLabelView;
@property (retain, nonatomic) IBOutlet UILabel *supportLabel;
@property (retain, nonatomic) IBOutlet UIButton *homePageBtn;
- (IBAction)movieHomepageBtnClick:(id)sender;

// 상영정보뷰

@property (retain, nonatomic) IBOutlet UIView *movieView;

// 상영정보없음뷰
@property (retain, nonatomic) IBOutlet UIView *nullMovieView;

@property (retain, nonatomic) IBOutlet UIView *underLine6;

// 상세/교통 세그먼트뷰
@property (retain, nonatomic) IBOutlet UIView *detailTrafficLabelView;
@property (retain, nonatomic) IBOutlet UIImageView *detailTrafficLabelBg;
@property (retain, nonatomic) IBOutlet UILabel *detailLabel;
@property (retain, nonatomic) IBOutlet UILabel *trafficLabel;

@property (retain, nonatomic) IBOutlet UIButton *detailBtn;
@property (retain, nonatomic) IBOutlet UIButton *trafficBtn;

- (IBAction)detailBtnClick:(id)sender;
- (IBAction)trafficBtnClick:(id)sender;

// 상세옵션뷰

@property (retain, nonatomic) IBOutlet UIView *detailOptionView;
@property (retain, nonatomic) IBOutlet UIImageView *reservationImg;

// 옵션뷰 밑줄
@property (retain, nonatomic) IBOutlet UIView *underLine7;


// 상세정보뷰
@property (retain, nonatomic) IBOutlet UIView *detailView;

// 교통정보뷰
@property (retain, nonatomic) IBOutlet UIView *trafficView;


// 하단버튼뷰
@property (retain, nonatomic) IBOutlet UIView *bottomView;



- (IBAction)favoriteBtnClick:(id)sender;
- (IBAction)contactBtnClick:(id)sender;
- (IBAction)infoModifyAskBtnClick:(id)sender;




- (void) finishRequestMovieList:(id)request;
@end
