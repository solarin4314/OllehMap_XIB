//
//  SearchViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 4. 19..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OllehMapStatus.h"
#import "FavoriteViewController.h"
#import "VoiceSearchViewController.h"
#import "ContactViewController.h"
#import "OMMessageBox.h"
#import "ServerConnector.h"
#import "JSON.h"
#import "recentCell.h"
#import "SearchResultViewController2.h"


// iPhone5
#import "uiviewcontroller+is4inch.h"

@interface RecentTableView : UITableView
@end
@interface RecommandTableView : UITableView
@end

@interface SearchViewController : UIViewController < UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UITextFieldDelegate>
{
    NSLock *_lockSearchInit;
    
    NSInteger _state;
 
    // 네비바 이름, 그림자
    IBOutlet UILabel *_naviTitleLabel;
    IBOutlet UILabel *_naviTitleLabel2;
    
    // 키보드 입력 없을 때 서치필드배경
    UIImageView *_noSearchBackGround;
    // 키보드 입력 있을 때 서치필드 배경
    UIImageView *_searchBackGround;
    // 서치텍스트필드
    UITextField *_searchField;
    // X 버튼
    IBOutlet UIButton *_xBtn;
    // x버튼 체커
    BOOL _xClick;
    
    // 즐찾, 연락처, 음성검색 버튼
    IBOutlet UIButton *_favoriteBtn;
    IBOutlet UIButton *_contactBtn;
    IBOutlet UIButton *_voiceBtn;
    
    // 최근검색 테이블
    IBOutlet RecentTableView *_recentTable;
    // 최근검색 배열
    NSArray *recentList;
    // 최근검색 비었을 때 라벨
    UILabel *_recentListEmpty;
    
    // 추천검색
    IBOutlet RecommandTableView *_recommandTable;
    
    // 검색 오류여부
    BOOL searchFailed;
    
    // 검색대상 (출발/도착/경유)에 대한 내부 플래그 (전역 oms는 화면 전환간 변경될수있음)
    int _currentSearchTargetType;

    IBOutlet UIView *_emptyView;
    
    int resultType;
    bool _order;
    
}

@property (assign, nonatomic) int currentSearchTargetType;
@property (assign, nonatomic) int resultType;
@property (assign, nonatomic) bool order;
- (IBAction)popClick:(id)sender;

// 서치필드
@property (retain, nonatomic) IBOutlet UIView *SearchView;
@property (retain, nonatomic) IBOutlet UIImageView *noSearchBackGround;
@property (retain, nonatomic) IBOutlet UIImageView *searchBackGround;
@property (retain, nonatomic) IBOutlet UITextField *searchField;
@property (retain, nonatomic) IBOutlet UIImageView *searchFieldBg;

- (IBAction)xClick:(id)sender;


- (IBAction)goFavorite:(id)sender;
- (IBAction)goContact:(id)sender;
- (IBAction)goVoice:(id)sender;


// 최근검색
@property (nonatomic, retain) NSArray *recentList;
@property (retain, nonatomic) IBOutlet UILabel *recentListEmpty;

// 검색
- (void)onSearch;

// 버스번호는 버스상세로 
- (void)didFinishRequestBusNumDetail:(id)request;
@end
