//
//  OMMessageBox.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 19..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuartzCore/QuartzCore.h"

// 전화걸기 알럿뷰 커스텀
@interface TelAlertView : UIAlertView
@end
// 홈페이지가기 알럿뷰 커스텀
@interface HomeAlertView : UIAlertView
@end
// 즐겨찾기 추가 알럿뷰 커스텀
@interface FavoAlertView : UIAlertView<UITextFieldDelegate>
{
    UITextField *_textField;
    NSString *_place;
}
@property (retain, nonatomic) NSString *place;
@property (retain, nonatomic) UITextField *textField;
@end

@interface OMMessageBox : UIAlertView <UIAlertViewDelegate>
{
    id _target;
    SEL _firstAction;
    SEL _secondAction;
}

+ (void) showAlertMessage :(NSString *)title :(NSString *)message;
+ (void) showAlertMessageWithInteger :(int)Integer Double:(double)Double;

+ (void) showAlertMessageTwoButtonsWithTitle:(NSString *)title message:(NSString *)message target:(id)target firstAction:(SEL)firstAction secondAction:(SEL)secondAction firstButtonLabel:(NSString *)firstButtonLabel secondButtonLabel:(NSString *)secondButtonLabel;

+ (void) writeConsoleLog :(NSString *)message;

- (void) setAlertViewTargetAction :(id)target :(SEL)firstAction :(SEL)secondAction;

@end
