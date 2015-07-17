//
//  AccountSettingViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 8. 28..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMNavigationController.h"
#import "OllehMapStatus.h"
#import "SA_OAuthTwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import "Tweet.h"
#import "Facebook.h"
#import "ServerConnector.h"

// 트위터 인증키
#define kOAuthConsumerKey		@"uhxY4WBgfVn3Hk2rhSiOMQ"
#define kOAuthConsumerSecret	@"wn45DWVYU9B01qPu1xOvjmFwtOnehvJ0tssHkCypnQ"

@protocol AccountSettingViewControllerDelegate;

@interface AccountSettingViewController : UIViewController
<SA_OAuthTwitterControllerDelegate, SA_OAuthTwitterEngineDelegate,
FBRequestDelegate, FBDialogDelegate, FBSessionDelegate>
{
    id<AccountSettingViewControllerDelegate>  _delegate;
    
    SA_OAuthTwitterEngine	*_engine;                   ///< 트위터 엔진
    Facebook				*_facebook;
    // 트윗
    
    UILabel *_twitLbl;
    UIView *_twitView;
    UIButton *_twitBtn;
    UILabel *_twitBtnLbl;
    
    NSMutableArray *tweets;
    
    BOOL _twitterState;
    
    // 페북
    UILabel *_faceLbl;
    UIView *_faceView;
    UIButton *_faceBtn;
    UILabel *_faceBtnLbl;
    
    BOOL _facebookState;
    
    
    NSString *RequestKey;
    NSString *RequestSecret;
    
}


#pragma mark -
#pragma mark @property
@property (nonatomic, assign) SA_OAuthTwitterEngine *engine;
@property (nonatomic, assign) id<AccountSettingViewControllerDelegate>  delegate;


#pragma mark -
#pragma mark IBAction
- (IBAction)popBtn:(id)sender;


#pragma mark -
#pragma mark AccountSettingViewController
- (void)sendUpdate:(NSString *)data;
- (void)sendUpdate:(NSString*)_data setImageData:(UIImage*)_uploadimg;
@end


@protocol AccountSettingViewControllerDelegate <NSObject>
@required
@optional
/**
 @brief 트위터 리퀘스트 실패 정보 델리게이트 함수
 */
-(void)requiredAccountSettingViewControllerDelegateTwitterRequestFailed;
@end