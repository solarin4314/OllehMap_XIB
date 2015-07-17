//
//  ThemeViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 9. 14..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "MapContainer.h"
#import "ServerConnector.h"
#import "ThemeCommon.h"
#import "MainMapViewController.h"

@interface ThemeViewController : UIViewController
{
    UIScrollView *_scrollView;
    
    NSInteger _viewHeight;
    
    // 확장뷰
    UIView *_folderView;
    UIView *_folderinView;
    UIImageView *_folderBg;
    UIImageView *_shadowTopBg;
    UIImageView *_shadowBottomBg;
    
    // 확장아래 스샷부분
    UIControl *_elseView;
    UIImageView *_elseViewBg;
    
    // 테마갯수
    double themeCount;
    // 테마상세갯수
    double themeDetailCount;
    // 테마높이
    int themeViewHeight;
    
    // 선택 테두리
    UIImageView *_selectImg;
    // 버튼센더 태그값
    int index;
    // 버튼좌표값 딕셔너리
    NSMutableDictionary *_btnCrdDictionary;
    // 클릭한 Rect 저장
    CGRect prevRect;
    // 블러뷰 배열
    NSMutableArray *_blurArr;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView *folderView;
@property (nonatomic, retain) IBOutlet UIControl *elseView;
@property (nonatomic, retain) IBOutlet UIImageView *elseViewBg;
@property (nonatomic, retain) IBOutlet UIImageView *folderBg;
@property (nonatomic, retain) IBOutlet UIImageView *shadowTopBg;
@property (nonatomic, retain) IBOutlet UIImageView *shadowBottomBg;

- (IBAction)popBtnClick:(id)sender;
-(IBAction) elseViewTab:(id)sender;
@end
