//
//  OMMessageBox.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 19..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "OMMessageBox.h"

@implementation TelAlertView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
@end

@implementation HomeAlertView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
@end

@implementation FavoAlertView

@synthesize textField = _textField;
@synthesize place = _place;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)initWriteFrame
{
    
    UIImageView *alertBg = [[UIImageView alloc] init];
    [alertBg setImage:[UIImage imageNamed:@"search_bar_bg.png"]];
    [alertBg setFrame:CGRectMake(19, 44, 245, 28)];
    [self addSubview:alertBg];
    [alertBg release];
    
    _textField = [[UITextField alloc] init];
    [_textField setDelegate:self];
    [_textField setTag:123123];
    _textField.layer.cornerRadius = 2;
    [_textField setFont:[UIFont systemFontOfSize:14]];
    [_textField setFrame:CGRectMake(24, 48, 232, 20)];
    [_textField setBackgroundColor:[UIColor clearColor]];
    [_textField becomeFirstResponder];
    [_textField setText:_place];
    [self addSubview:_textField];
    
}
- (void) show
{
    [self initWriteFrame];
    [super show];
}

- (void) dealloc
{
    [_place release];
    [_textField release];
    [super dealloc];
}

@end

@implementation OMMessageBox

+(void) showAlertMessage :(NSString *)title :(NSString *)message;
{
    
    UIAlertView * alertView = [[UIAlertView alloc]
                               initWithTitle: title
                               message: message
                               delegate: nil
                               cancelButtonTitle: @"확인"
                               otherButtonTitles: nil];
    [alertView show];
    [alertView release];
    
}

+(void) showAlertMessageWithInteger :(int)Integer Double:(double)Double;
{
    [OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"Integer : %d / Double : %f", Integer, Double]];
}

+ (void) showAlertMessageTwoButtonsWithTitle:(NSString *)title message:(NSString *)message target:(id)target firstAction:(SEL)firstAction secondAction:(SEL)secondAction firstButtonLabel:(NSString *)firstButtonLabel secondButtonLabel:(NSString *)secondButtonLabel
{
    OMMessageBox *alertView = [[OMMessageBox alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:firstButtonLabel otherButtonTitles:secondButtonLabel, nil];
    
    [alertView setDelegate:alertView];
    [alertView setAlertViewTargetAction:target :firstAction :secondAction];
    
    [alertView show];
    [alertView release];
}

+(void) writeConsoleLog :(NSString *)message
{
    NSLog(@"[LogMessage]\n%@", message);
    [message release];
    message = nil;
}

- (void) dealloc
{
    [_target release];
    _target = nil;
    
    [super dealloc];
}

- (void) setAlertViewTargetAction :(id)target :(SEL)firstAction :(SEL)secondAction
{
    _target = target;
    [_target retain];
    _firstAction = firstAction;
    _secondAction =  secondAction;
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
#ifdef DEBUG
    if ([_target retainCount] == 1) [OMMessageBox showAlertMessage:@"그화면 이미 죽어있다." :@"버튼포함 메세지 박스에서 버튼동작했을때, 이미 호출한 객체가 릴리즈당해서 앱이  죽었을 상황.."];
#endif
    
    if (buttonIndex == 0)
    {
        if ([_target respondsToSelector:_firstAction])
            [_target performSelector:_firstAction withObject:self];
    }
    else if (buttonIndex == 1)
    {
        if ([_target respondsToSelector:_secondAction])
            [_target performSelector:_secondAction withObject:self];
    }
    else
    {
    }
}


@end
