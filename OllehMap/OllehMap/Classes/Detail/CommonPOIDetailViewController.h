//
///  CommonPOIDetailViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 4..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "OllehMapStatus.h"
#import "QuartzCore/QuartzCore.h"
#import "DbHelper.h"
#import "OMMessageBox.h"
#import "ShareViewController.h"
#import "GTMDefines.h"
#import "GTMNSString+HTML.h"
#import "OMCustomView.h"

//#import "OllehMapAddress.h"
typedef enum {
    ParamType_MP = 1,
    ParamType_MV = 2,
    ParamType_OL = 3,
    ParamType_ADDR = 4,
    ParamType_TR_BUS = 5,
    ParamType_TR_BUSNO = 6,
    ParamType_TR = 7
    
} ParamType;

NSString* convertBISUniqueId (NSString *bisId);
NSString* refineBISUniqueId (NSString *bisId, BOOL withZero);

@protocol CommonPOIDetailViewControllerDelegate <NSObject>

- (void) freeCallRemoveFromSuperViewDelegate;

@end

@interface CommonPOIDetailViewController : UIViewController
<ABNewPersonViewControllerDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
    BOOL _displayMapBtn;
    
    BOOL _isPushBusStationAndLine;
    
    ParamType _dicType;
    id <CommonPOIDetailViewControllerDelegate> _delegate;
}

@property (nonatomic, assign) BOOL displayMapBtn;
@property (nonatomic, assign) id <CommonPOIDetailViewControllerDelegate> delegate;

// 타입 체크하자
- (void) typeChecker :(int)type;

// 전화버튼
- (void) telViewCallBtnClick:(NSString *)telString;
// 홈페이지 버튼
- (void) homeViewURLBtnClick:(NSString *)urlString;

// 출발버튼
- (void) btnViewStartBtnClick:(NSDictionary *)dic;
// 도착버튼
- (void) btnViewDestBtnClick:(NSDictionary *)dic;

// 위치공유버튼
- (void) btnViewShareBtnClick;

// 네비버튼
- (void) btnViewNaviBtnClick:(NSDictionary *)dic;

// 즐겨찾기추가버튼
- (void) bottomViewFavorite:(NSDictionary *)dic placeHolder:(NSString *)placeHolderStr;
// 연락처추가버튼
- (void)modalContact:(NSDictionary *)dic;
// 정보수정요청버튼
- (void)modalInfoModify:(NSDictionary *)dic;

//- (void)modalAddresBook2:(OllehMapAddress*)dic;
@end
