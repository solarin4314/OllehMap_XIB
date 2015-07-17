//
//  CustomerComplainViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 9. 14..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerConnector.h"
#import "OMNavigationController.h"
#import "OMMessageBox.h"
#import "SmartCommunicationLibrary.h"
#import "OllehMapStatus.h"

//iPhone5
#import "uiviewcontroller+is4inch.h"

#define vocServerIP @"app.voc.olleh.com:442"

@interface SampleTxtView : UITextView
@end



static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 238;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@interface CustomerComplainViewController : UIViewController<UITextViewDelegate, UITextFieldDelegate>
{
    CGFloat                 animatedDistance;
    
    UIScrollView *_scrollView;
    
    UIButton *_emailBtn;
    BOOL _emailCheck;
    UITextField *_emailTxtField;
    
    UIButton *_twitterBtn;
    BOOL _twitterCheck;
    UITextField *_twitterTxtField;
    
    UIImageView *_checkImg;
    UIButton *_checkBtn;
    
    BOOL _privateCheck;
    
    UIButton *_contactBtn;
    UIImageView *_contactImg;
    UIButton *_complainBtn;
    UIImageView *_complainImg;
    
    SampleTxtView *_txtView;
    UILabel *_txtLimitLbl;
    
    NSString *_emailId;
    NSString *_twitterId;
    
    SmartCommunicationLibrary *_vocConnect;
    
}
- (IBAction)naviBackBtnClick:(id)sender;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UILabel *txtLimitLbl;
@property (nonatomic, retain) SmartCommunicationLibrary *vocConnect;

@end
