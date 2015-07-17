//
//  OilPOIDetailViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 6. 8..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OllehMapStatus.h"
#import "OMMessageBox.h"
#import "OMNavigationController.h"
#import "ServerConnector.h"
#import <MessageUI/MessageUI.h>
#import "CommonMapViewController.h"
#import "CommonPOIDetailViewController.h"
#import "DbHelper.h"

#define X_VALUE 0
#define Y_VALUE 0
#define X_WIDTH 320


@interface OilPOIDetailViewController : CommonPOIDetailViewController
{
    // 오토리사이징 설정된 커스텀 스크롤뷰
    DetailScrollView *_scrollView;
    
    NSInteger _oilViewStartY;
    
    IBOutlet UIView *_underline;
    
    UIView *_buttonView;
    
    UILabel *_support;
    
    UIButton *_mapBtn;
    
}

@property (retain, nonatomic) IBOutlet DetailScrollView *scrollView;

@property (retain, nonatomic) IBOutlet UIButton *mapBtn;

@property (retain, nonatomic) IBOutlet UIView *buttonView;


-(IBAction)popBtnClick:(id)sender;
-(IBAction)mapBtnClick:(id)sender;
-(void)finishRequestoilDetailAtPoiId2:(id)request;

- (IBAction)favoriteBtnClick:(id)sender;

- (IBAction)contactBtnClick:(id)sender;

- (IBAction)infoModifyAskBtnClick:(id)sender;



@end
