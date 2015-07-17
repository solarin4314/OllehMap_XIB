//
//  VersionInfoViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 2..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMNavigationController.h"
#import "OMMessageBox.h"
#import "InfoSupportViewController.h"
#import "lawNoticeViewController.h"
#import "ServiceRuleViewController.h"
#import "ServerConnector.h"
#import "CadastralLimitViewController.h"

//iPhone5
#import "uiviewcontroller+is4inch.h"

@interface VersionInfoViewController : UIViewController<UIAlertViewDelegate>
{
    UIImageView *_ollehLogo;        // 올레 로고
    
    UILabel *_thisVersion;          // 현재 버전
    UILabel *_recentVersion;        // 최신 버전
    
    UIButton *_updateButton;        // 최신 버전 업데이트
    UIButton *_lawNoticeButton;     // 법적공지
    UIButton *_serviceRuleButton;   // 이용약관
    UIButton *_infoSupportButton;   // 정보제공처
    
    UILabel *_ktLogo;               // KT 로고
}

- (IBAction)popBtnClick:(id)sender;
@property (retain, nonatomic) IBOutlet UIImageView *ollehLogo;
@property (retain, nonatomic) IBOutlet UILabel *thisVersion;
@property (retain, nonatomic) IBOutlet UILabel *recentVersion;
@property (retain, nonatomic) IBOutlet UIButton *updateButton;
@property (retain, nonatomic) IBOutlet UIButton *lawNoticeButton;
@property (retain, nonatomic) IBOutlet UIButton *serviceRuleButton;
@property (retain, nonatomic) IBOutlet UIButton *infoSupportButton;
@property (retain, nonatomic) IBOutlet UILabel *ktLogo;

- (IBAction)versionUpateBtnClick:(id)sender;
- (IBAction)lawNoticeClick:(id)sender;
- (IBAction)serviceRuleClick:(id)sender;
- (IBAction)infoSupportClick:(id)sender;
- (IBAction)cadastralLimitClick:(id)sender;


@end
