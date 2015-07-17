//
//  SNSSendViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 8. 30..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OllehMapStatus.h"
//#import "CameraPickerController.h"
#import "OMMessageBox.h"
#import "OMIndicator.h"

// iPhone5
#import "uiviewcontroller+is4inch.h"
#import "OMCustomView.h"

@protocol  SNSSendViewDelegate;

@interface SNSSendViewController : UIViewController<UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    id<SNSSendViewDelegate> delegate;
    
    // 오토리사이징 설정된 커스텀 스크롤뷰
    DetailScrollView *_scrollView;
    // 타입(1 : 페북, 2 : 트윗)
    NSInteger       _type;
    
    // 상단
    UIControl *_shareView;
    
    // POI 이름, url
    UILabel *_nameLabel;
    NSString *_nameString;
    UILabel *_urlLabel;
    NSString *_urlString;
    
    // 텍스트뷰
    UITextView      *_textBox;
    
    NSInteger _photoAddLength;
    
    // 텍스트뷰 스트링
    NSString        *_textString;
    
    // 카메라버튼
    UIButton *_cameraBtn;
    UIButton *_albumBtn;
    
    // 하단
    UIView *_middleView;
    
    // 포토뷰
    UIView *_photoview;
    // 이미지 담긴 뷰
    UIImageView     *_photoimage;
    // 삭제버튼
    UIButton *_deleteBtn;
    
}

@property (nonatomic, assign) id<SNSSendViewDelegate> delegate;
@property (nonatomic, retain) DetailScrollView *scrollView;
/**
 @brief SendMessageView 클래스를 초기화합니다 , 이전 타이틀 문구를 설정한다.
 @param type 연결 타입 정보 (트위터 , 페이스북등)
 @param name 상호명 및 장소
 @param url URL 정보
 @param strData 추가 문구 데이터
 @return 자신을 리턴 합니다.
 */
//- (id)initWithType:(int)type url:(NSString*)url strData:(NSString*)strData;
- (id)initWithType:(int)type name:(NSString*)name url:(NSString*)url strData:(NSString*)strData;

@end



/**
 @brief 위치정보 보내기 추가 메세지 콜백을 지원 합니다.
 */
@protocol SNSSendViewDelegate <NSObject>
@required

/**
 @brief 입력된 문구를 넘깁니다.
 @param 입력된 문구
 @param 받는 쪽에 선택할 타입 정보입니다.
 */
-(void) SNSSendViewDelegateTextMessage:(NSString*)message type:(int)type;
@optional


@end
