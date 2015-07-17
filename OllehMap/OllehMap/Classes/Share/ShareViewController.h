//
//  ShareViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 2..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMMessageBox.h"
#import "OMDimmedView.h"
#import "OMNavigationController.h"
#import <MessageUI/MessageUI.h>
#import "OllehMapStatus.h"
#import "KakaoLinkCenter.h"
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import "Tweet.h"
#import "SNSSendViewController.h"
#import "FBConnect.h"
#import "AccountSettingViewController.h"

#define kOAuthConsumerKey		@"uhxY4WBgfVn3Hk2rhSiOMQ"
#define kOAuthConsumerSecret	@"wn45DWVYU9B01qPu1xOvjmFwtOnehvJ0tssHkCypnQ"
//#define kOAuthConsumerKey   @"pC74SSn7RiJdKgWsEcMSEQ"
//#define kOAuthConsumerSecret    @"TTpdYLfMAIhFiF6rUfkPOfuhmgOEHaIvF7hzgwz9sk"


@interface ShareViewController : UIViewController
<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate,
UIAlertViewDelegate,
FBRequestDelegate, FBDialogDelegate, FBSessionDelegate,
SA_OAuthTwitterControllerDelegate, SA_OAuthTwitterEngineDelegate,
SNSSendViewDelegate,
AccountSettingViewControllerDelegate>
{
    
    Coord _poiCoord;
    
    NSString *_poiName;
    
    SA_OAuthTwitterEngine *_engine;
    
    NSMutableArray *_tweets;
    
    Facebook				*_facebook;
    
    AccountSettingViewController *_snsAccountView;
    
    NSMutableString            *_snsSaveString;                          ///< 보내기 문자 정보 저장하고있는다
    int                         _snsSaveType;                            ///< 보내기 타입정보를 저장하고 있는다
    
    UIScrollView *_scrollView;
    
}


#pragma mark -
#pragma mark @property
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, assign) Coord poiCoord;
@property (nonatomic, retain) NSString *poiName;


#pragma mark -
#pragma mark ShareViewController
+ (ShareViewController *)instVC;

+ (void) sharePopUpView :(UIView *)pView;
+ (void) ollehNaviAlertView;


#pragma mark -
#pragma mark IBAction
- (IBAction)messageBtnClick:(id)sender;
- (IBAction)emailBtnClick:(id)sender;
- (IBAction)kakaoTalkBtnClick:(id)sender;
- (IBAction)twitterBtnClick:(id)sender;
- (IBAction)faceBookBtnClick:(id)sender;


- (IBAction)infoCopyBtnClick:(id)sender;
- (IBAction)cancelBtnClick:(id)sender;


@end
