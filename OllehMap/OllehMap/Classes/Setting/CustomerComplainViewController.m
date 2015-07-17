//
//  CustomerComplainViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 9. 14..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "CustomerComplainViewController.h"
@implementation SampleTxtView

- (UIEdgeInsets) contentInset { return UIEdgeInsetsZero; }

@end

@interface CustomerComplainViewController ()

@end

@implementation CustomerComplainViewController
@synthesize scrollView = _scrollView;
@synthesize txtLimitLbl = _txtLimitLbl;
@synthesize vocConnect = _vocConnect;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        float height = [UIApplication sharedApplication].statusBarFrame.size.height - 20;
        _scrollView = [[UIScrollView alloc] init];
        [_scrollView setFrame:CGRectMake(0, 37, 320, [[UIScreen mainScreen] bounds].size.height-20-37)];
        [_scrollView setContentSize:CGSizeMake(320, [[UIScreen mainScreen] bounds].size.height-20-37+height)];
        _scrollView.contentMode = UIViewContentModeBottom;
        [self.view addSubview:_scrollView];
        
    }
    return self;
}

- (void)statusBarFrameChanged:(NSNotification*)notification
{
    NSValue *rectValue = [[notification userInfo] valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    CGRect oldFrame;
    [rectValue getValue:&oldFrame];
    NSLog(@"statusBarFrameChanged: oldSize %f, %f", oldFrame.size.width, oldFrame.size.height);
    
    if(oldFrame.size.height == 20)
    {
        // 켜짐
        [_scrollView setContentSize:CGSizeMake(320, [[UIScreen mainScreen] bounds].size.height-37+20)];
        
        if([_txtView isFirstResponder])
            [_scrollView setContentOffset:CGPointMake(0, 215)];
    }
    else
    {
        // 꺼짐
        [_scrollView setContentSize:CGSizeMake(320, [[UIScreen mainScreen] bounds].size.height-37)];
        
        if([_txtView isFirstResponder])
            [_scrollView setContentOffset:CGPointMake(0, 215)];
    }
    
    
}

- (void)dealloc
{
    [_scrollView release];
    [_emailBtn release];
    [_twitterBtn release];
    [_checkBtn release];
    [_checkImg release];
    [_emailTxtField release];
    [_twitterTxtField release];
    
    [_contactBtn release];
    [_contactImg release];
    [_complainBtn release];
    [_complainImg release];
    [_txtView release];
    [_txtLimitLbl release];
    
    [_vocConnect release];
    
    [super dealloc];
}
- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setTxtLimitLbl:nil];
    //[self setVocConnect:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)viewWillAppear:(BOOL)aAnimated
{
    [super viewWillAppear:aAnimated];
    self.navigationController.navigationBarHidden = YES;
    
    [[self view] setFrame:[[UIScreen mainScreen] applicationFrame]];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameChanged:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    _vocConnect = [[SmartCommunicationLibrary alloc] init];
    
    [self drawTopView];
}

- (void) drawTopView
{
    
    UIControl *topControlView = [[UIControl alloc] init];
    [topControlView setFrame:CGRectMake(0, 0, 320, 238)];
    [topControlView addTarget:self action:@selector(backGroundTab:) forControlEvents:UIControlEventTouchDown];
    [_scrollView addSubview:topControlView];
    
    UILabel *topText = [[UILabel alloc] init];
    [topText setFrame:CGRectMake(10,15, 300, 15)];
    [topText setText:@"답변 받으실 방법을 선택해주세요"];
    [topText setBackgroundColor:[UIColor clearColor]];
    [topText setFont:[UIFont boldSystemFontOfSize:15]];
    [topControlView addSubview:topText];
    [topText release];
    
    UIImageView *underLine = [[UIImageView alloc] init];
    [underLine setFrame:CGRectMake(0, 45, 320, 1)];
    [underLine setImage:[UIImage imageNamed:@"poi_list_line_02.png"]];
    [topControlView addSubview:underLine];
    [underLine release];
    
    // 이메일버튼
    _emailCheck = NO;
    _emailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_emailBtn retain];
    [_emailBtn setFrame:CGRectMake(10, 61, 33, 33)];
    [_emailBtn setImage:[UIImage imageNamed:@"setting_check01_off.png"] forState:UIControlStateNormal];
    [_emailBtn addTarget:self action:@selector(emailBtnOn:) forControlEvents:UIControlEventTouchUpInside];
    [topControlView addSubview:_emailBtn];
    
    // 이메일 텍필배경
    UIImageView *emailTFBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_textfield_01.png"]];
    [emailTFBg setFrame:CGRectMake(48, 61, 262, 33)];
    [topControlView addSubview:emailTFBg];
    [emailTFBg release];
    
    // 이메일 텍필
    _emailTxtField = [[UITextField alloc] init];
    _emailTxtField.delegate = self;
    [_emailTxtField setFrame:CGRectMake(48+10, 61+6, 250, 18)];
    [_emailTxtField setFont:[UIFont systemFontOfSize:14]];
    [_emailTxtField setPlaceholder:@"e-Mail"];
    [_emailTxtField setEnabled:NO];
    [_emailTxtField setReturnKeyType:UIReturnKeyDone];
    [topControlView addSubview:_emailTxtField];
    
    
    // 트위터버튼
    _twitterCheck = NO;
    _twitterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_twitterBtn retain];
    [_twitterBtn setFrame:CGRectMake(10, 104, 33, 33)];
    [_twitterBtn setImage:[UIImage imageNamed:@"setting_check01_off.png"] forState:UIControlStateNormal];
    [_twitterBtn addTarget:self action:@selector(twitterBtnOn:) forControlEvents:UIControlEventTouchUpInside];
    [topControlView addSubview:_twitterBtn];
    
    // 트위터 텍필배경
    UIImageView *twitterTFBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_textfield_01.png"]];
    [twitterTFBg setFrame:CGRectMake(48, 104, 262, 33)];
    [topControlView addSubview:twitterTFBg];
    [twitterTFBg release];
    
    // 트위터 텍필
    _twitterTxtField = [[UITextField alloc] init];
    _twitterTxtField.delegate = self;
    [_twitterTxtField setFrame:CGRectMake(48+10, 104+6, 250, 18)];
    [_twitterTxtField setFont:[UIFont systemFontOfSize:14]];
    [_twitterTxtField setPlaceholder:@"twitter"];
    [_twitterTxtField setEnabled:NO];
    [_twitterTxtField setReturnKeyType:UIReturnKeyDone];
    [topControlView addSubview:_twitterTxtField];
    
    
    // 체크박스
    _privateCheck = NO;
    _checkImg = [[UIImageView alloc] init];
    [_checkImg setImage:[UIImage imageNamed:@"setting_check02_off.png"]];
    [_checkImg setFrame:CGRectMake(10, 152, 13, 13)];
    [topControlView addSubview:_checkImg];
    
    _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_checkBtn retain];
    [_checkBtn setFrame:CGRectMake(5, 152-5, 31, 31)];
    [_checkBtn addTarget:self action:@selector(privateCheck:) forControlEvents:UIControlEventTouchUpInside];
    [topControlView addSubview:_checkBtn];
    
    UILabel *agreeLbl = [[UILabel alloc] init];
    [agreeLbl setText:@"개인정보를 kt에 제공하는 것에 동의합니다. 보내주신 정보는 답변의 용도로만 사용됩니다."];
    [agreeLbl setTextColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1)];
    [agreeLbl setFont:[UIFont systemFontOfSize:12]];
    [agreeLbl setNumberOfLines:2];
    [agreeLbl setFrame:CGRectMake(10+13+4, 152, 320-((10+13+4)*2), 30)];
    [topControlView addSubview:agreeLbl];
    [agreeLbl release];
    
    
    // 밑줄
    UIImageView *underline2 = [[UIImageView alloc] init];
    [underline2 setFrame:CGRectMake(0, 200, 320, 1)];
    [underline2 setImage:[UIImage imageNamed:@"poi_list_line_02.png"]];
    [topControlView addSubview:underline2];
    [underline2 release];
    
    [topControlView release];
    
    [self drawDownView];
}

- (void) drawDownView
{
    // iPhone5 해상도 지원을 위한 상단 여백
    int uiMarginTop = (IS_4_INCH) ? 84 : 0;
    
    //컨트롤 뷰
    UIControl *controlView2 = [[UIControl alloc] init];
    [controlView2 setFrame:CGRectMake(0, 201, 320, 222 + uiMarginTop)];
    [controlView2 addTarget:self action:@selector(backGroundTab:) forControlEvents:UIControlEventTouchDown];
    //[controlView2 setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_scrollView addSubview:controlView2];
    
    // 문의버튼
    _contactBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_contactBtn setFrame:CGRectMake(10, 14, 60, 15)];
    [_contactBtn retain];
    [_contactBtn addTarget:self action:@selector(contactBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_contactBtn setSelected:YES];
    [controlView2 addSubview:_contactBtn];
    // 문의라디오
    _contactImg = [[UIImageView alloc] init];
    [_contactImg setImage:[UIImage imageNamed:@"radio_btn_on.png"]];
    [_contactImg setFrame:CGRectMake(10, 14, 15, 15)];
    [controlView2 addSubview:_contactImg];
    
    // 문의텍스트
    UILabel *contactLbl = [[UILabel alloc] init];
    [contactLbl setFrame:CGRectMake(28, 15, 40, 14)];
    [contactLbl setText:@"문의"];
    [contactLbl setFont:[UIFont systemFontOfSize:14]];
    [controlView2 addSubview:contactLbl];
    [contactLbl release];
    
    // 불만버튼
    _complainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_complainBtn setFrame:CGRectMake(67, 14, 60, 15)];
    [_complainBtn retain];
    [_complainBtn addTarget:self action:@selector(complainBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [controlView2 addSubview:_complainBtn];
    // 불만라디오
    _complainImg = [[UIImageView alloc] init];
    [_complainImg setImage:[UIImage imageNamed:@"radio_btn_off.png"]];
    [_complainImg setFrame:CGRectMake(67, 14, 15, 15)];
    [controlView2 addSubview:_complainImg];
    // 불만텍스트
    UILabel *complainLbl = [[UILabel alloc] init];
    [complainLbl setFrame:CGRectMake(85, 15, 40, 14)];
    [complainLbl setText:@"불만"];
    [complainLbl setFont:[UIFont systemFontOfSize:14]];
    [controlView2 addSubview:complainLbl];
    [complainLbl release];
    
    // 글자수세기
    _txtLimitLbl = [[UILabel alloc] init];
    
    int len = _txtView.text.length;
    
    [_txtLimitLbl setFrame:CGRectMake(200, 17, 110, 12)];
    [_txtLimitLbl setText:[NSString stringWithFormat:@"(%d/1000)", len]];
    [_txtLimitLbl setFont:[UIFont systemFontOfSize:12]];
    [_txtLimitLbl setTextColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1)];
    [_txtLimitLbl setTextAlignment:NSTextAlignmentRight];
    [controlView2 addSubview:_txtLimitLbl];
    
    // 텍스트박스 배경
    UIImageView *tBoxBg = [[UIImageView alloc] init];
    [tBoxBg setFrame:CGRectMake(10, 39, 300, 116 + uiMarginTop)];
    
    if (IS_4_INCH)
    {
        [tBoxBg setImage:[UIImage imageNamed:@"setting_textfield_02-568h.png"]];
    }
    else
    {
        [tBoxBg setImage:[UIImage imageNamed:@"setting_textfield_02.png"]];
    }
    
    [controlView2 addSubview:tBoxBg];
    [tBoxBg release];
    
    // 텍스트박스
    _txtView = [[SampleTxtView alloc] init];
    _txtView.delegate = self;
    [_txtView setBackgroundColor:[UIColor clearColor]];
    [_txtView setFrame:CGRectMake(10+15-8, 39+14-8, 270+16, 102 + uiMarginTop)];
    //[_txtView setContentInset:UIEdgeInsetsMake(-8, -8, 0, 0)];
    [_txtView setText:NSLocalizedString(@"Msg_customerComplain_txtViewPlaceHolder", "")];
    [_txtView setFont:[UIFont systemFontOfSize:13]];
    [_txtView setTextColor:convertHexToDecimalRGBA(@"95", @"95", @"95", 1)];
    [controlView2 addSubview:_txtView];
    
    
    // 밑라인
    UIImageView *bottomLine = [[UIImageView alloc] init];
    [bottomLine setImage:[UIImage imageNamed:@"poi_list_line_02.png"]];
    [bottomLine setFrame:CGRectMake(0, 39+116+15 + uiMarginTop, 320, 1)];
    [controlView2 addSubview:bottomLine];
    [bottomLine release];
    
    // 등록버튼
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [submitBtn setFrame:CGRectMake(125, 181 + uiMarginTop, 70, 31)];
    [submitBtn setImage:[UIImage imageNamed:@"setting_btn_regist.png"] forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(submitBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [controlView2 addSubview:submitBtn];
    
    [controlView2 release];
    
    
}


- (void) backGroundTab:(id)sender
{
    
    if(_txtView.text.length == 0)
    {
        [_txtView setTextColor:convertHexToDecimalRGBA(@"95", @"95", @"95", 1)];
        [_txtView setText:NSLocalizedString(@"Msg_customerComplain_txtViewPlaceHolder", "")];
    }
    [_twitterTxtField resignFirstResponder];
    [_emailTxtField resignFirstResponder];
    [_txtView resignFirstResponder];
    
    [_scrollView setContentOffset:CGPointMake(0, 0)];
}
- (void) emailBtnOn:(id)sender
{
    if(_emailCheck == NO)
    {
        [_emailBtn setImage:[UIImage imageNamed:@"setting_check01_on.png"] forState:UIControlStateNormal];
        [_emailTxtField setEnabled:YES];
        _emailCheck = YES;
        
        [_twitterBtn setImage:[UIImage imageNamed:@"setting_check01_off.png"] forState:UIControlStateNormal];
        [_twitterTxtField setText:@""];
        [_twitterTxtField setEnabled:NO];
        _twitterCheck = NO;
    }
    else
    {
        [_emailBtn setImage:[UIImage imageNamed:@"setting_check01_off.png"] forState:UIControlStateNormal];
        [_emailTxtField setText:@""];
        [_emailTxtField setEnabled:NO];
        _emailCheck = NO;
        
        
    }
}
- (void) twitterBtnOn:(id)sender
{
    if(_twitterCheck == NO)
    {
        [_twitterBtn setImage:[UIImage imageNamed:@"setting_check01_on.png"] forState:UIControlStateNormal];
        [_twitterTxtField setEnabled:YES];
        _twitterCheck = YES;
        
        [_emailBtn setImage:[UIImage imageNamed:@"setting_check01_off.png"] forState:UIControlStateNormal];
        [_emailTxtField setText:@""];
        [_emailTxtField setEnabled:NO];
        _emailCheck = NO;
    }
    else
    {
        [_twitterBtn setImage:[UIImage imageNamed:@"setting_check01_off.png"] forState:UIControlStateNormal];
        [_twitterTxtField setText:@""];
        [_twitterTxtField setEnabled:NO];
        _twitterCheck = NO;
    }
    
}
- (void) privateCheck:(id)sender
{
    if(_privateCheck == NO)
    {
        [_checkImg setImage:[UIImage imageNamed:@"setting_check02_on.png"]];
        _privateCheck = YES;
    }
    else
    {
        [_checkImg setImage:[UIImage imageNamed:@"setting_check02_off.png"]];
        _privateCheck = NO;
    }
    
}
- (void)contactBtnClick:(id)sender
{
    [_contactBtn setSelected:YES];
    [_complainBtn setSelected:NO];
    [_contactImg setImage:[UIImage imageNamed:@"radio_btn_on.png"]];
    [_complainImg setImage:[UIImage imageNamed:@"radio_btn_off.png"]];
    
}
- (void) complainBtnClick:(id)sender
{
    
    [_contactBtn setSelected:NO];
    [_complainBtn setSelected:YES];
    [_complainImg setImage:[UIImage imageNamed:@"radio_btn_on.png"]];
    [_contactImg setImage:[UIImage imageNamed:@"radio_btn_off.png"]];
    
}
// 등록버튼
- (void)submitBtnClick:(id)sender
{
    
    //NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    NSString *deviceId = [[OllehMapStatus sharedOllehMapStatus] generateUuidString];
    ;
    
    // 내용
    NSDictionary *contentDic = nil;
    
    // 오늘날짜
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyyMMdd"];
    
    //
    NSDate *now = [NSDate date];
    NSString *todayStr = [formatter stringFromDate:now];
    
    if(_privateCheck == NO)
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_customerComplain_NotPrivateCheck", "")];
        return;
    }
    else if (_emailCheck == NO && _twitterCheck == NO)
    {
        
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_customerComplain_NotBtnCheck", "")];
        return;
    }
    
    else if ([_txtView.text isEqualToString:NSLocalizedString(@"Msg_customerComplain_txtViewPlaceHolder", "")] || [_txtView.text isEqualToString:@""])
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_customerComplain_NotContent", "")];
        return;
    }
    if(_twitterCheck == YES)
    {
        if(_twitterTxtField.text == nil || [_twitterTxtField.text isEqualToString:@""])
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_customerComplain_NotTwitterId", "")];
            return;
        }
        _twitterId = _twitterTxtField.text;
        _emailId = @"";
        
        if(_contactBtn.selected)
        {
            // 문의(트윗)
            contentDic = [NSDictionary dictionaryWithObjectsAndKeys:appId, @"APPID", deviceId, @"DEVICE_ID", @"테스트", @"IDEA_TITLE", _txtView.text, @"IDEA_DESC", todayStr, @"IDEA_REGDT", _twitterTxtField.text, @"USER_TWITTOR", @"0001", @"IDEA_RETURN_CODE", @"I", @"OS_GUBUN" , nil];
        }
        else if(_complainBtn.selected)
        {
            // 불만(트윗)
            contentDic = [NSDictionary dictionaryWithObjectsAndKeys:appId, @"APPID", deviceId, @"DEVICE_ID", @"테스트", @"VOC_TITLE", _txtView.text, @"VOC_DESC", todayStr, @"VOC_REGDT", _twitterTxtField.text, @"USER_TWITTOR", @"0001", @"VOC_RETURN_CODE", @"I", @"OS_GUBUN" , nil];
        }
        
    }
    
    else if (_emailCheck == YES)
    {
        if(_emailTxtField.text == nil || [_emailTxtField.text isEqualToString:@""] || ![[OllehMapStatus sharedOllehMapStatus] emailVaildCheck:_emailTxtField.text])
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_customerComplain_NotEmailId", "")];
            return;
        }
        
        
        _emailId = _emailTxtField.text;
        _twitterId = @"";
        
        if(_contactBtn.selected)
        {
            // 문의(메일)
            contentDic = [NSDictionary dictionaryWithObjectsAndKeys:appId, @"APPID", deviceId, @"DEVICE_ID", @"테스트", @"IDEA_TITLE", _txtView.text, @"IDEA_DESC", todayStr, @"IDEA_REGDT", _emailTxtField.text, @"USER_EMAIL", @"0010", @"IDEA_RETURN_CODE", @"I", @"OS_GUBUN" , nil];
        }
        else if(_complainBtn.selected)
        {
            // 불만(메일)
            contentDic = [NSDictionary dictionaryWithObjectsAndKeys:appId, @"APPID", deviceId, @"DEVICE_ID", @"테스트", @"VOC_TITLE", _txtView.text, @"VOC_DESC", todayStr, @"VOC_REGDT", _emailTxtField.text, @"USER_EMAIL", @"0010", @"VOC_RETURN_CODE", @"I", @"OS_GUBUN" , nil];
        }
        
    }
    
    //[OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"이메일 : %@, 트위터 : %@ 내용 : %@", _emailId, _twitterId, _txtView.text]];
    
    // 연결
    _vocConnect.serverName = vocServerIP;
    _vocConnect.interfaceName = @"interface";
    _vocConnect.successSelector = @selector(didReceiveFinished:);
    _vocConnect.errorSelector = @selector(didErrorFinished:);
    _vocConnect.responseType = SmartCommunicationResponseParserType;
    _vocConnect.target = self;
    _vocConnect.timeoutInterval = 5.0f;
    
    NSLog(@"voc상태 : %@, 내용 : %@", _vocConnect,contentDic);
    // 앱id, 디바이스ID, 제목, 내용, 날짜, 메일or트윗, 리턴코드(메일 : 0010, 트윗 : 0001)
    
    if(_contactBtn.selected)
        [_vocConnect request:@"VOC_IF104.asp" bodyObject:contentDic];
    else if (_complainBtn.selected)
        [_vocConnect request:@"VOC_IF102.asp" bodyObject:contentDic];
    
    
}
- (void)didReceiveFinished:(id)request
{
    NSLog(@"%@", request);
    [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_customerComplain_sendOK", @"")];
    [_txtView setText:@""];
    [_txtView resignFirstResponder];
    
}
- (void)didErrorFinished:(id)request
{
    [OMMessageBox showAlertMessage:@"" :@"VOC 연결에 실패하였습니다"];
}
// 뒤로가기
- (IBAction)naviBackBtnClick:(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark - TextView Delegate
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if(textView.text.length > 0 && textView.textColor == [UIColor blackColor])
        return YES;
    
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    int len = textView.text.length;
    self.txtLimitLbl.text = [NSString stringWithFormat:@"(%d/1000)",len];
    
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [_scrollView setContentOffset:CGPointMake(0, 215) animated:YES];
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *candidateString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    
    //길이 초과 점검
    if(text && [text length] && ([candidateString length] >= 1001)) {
        return NO;
    }
    
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}
- (void)centerViewDidBeginEditing:(UIView *)sender
{
    CGRect textFieldRect = [self.view.window convertRect:sender.bounds fromView:sender];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)centerViewDidEndEditing:(UIView *)sender
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark - TextField Deleagte

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    int maxLength = 40;
    
    //string은 현재 키보드에서 입력한 문자 한개를 의미한다.
    if([string length] && ([textField.text length] >= maxLength))
        return NO;
    
    return TRUE;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)animateView:(UITextView *)object
{
	CGFloat offsetY = 0;
	CGRect frameView = self.view.frame;
	// 버튼 좌표를 윈도우 스크린 좌표로 변환 시킴
	CGRect frame = [object convertRect:object.bounds toView:_scrollView];
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	
	if (object) {
		offsetY = frame.origin.y - 62;
		if (offsetY < 0.0f)
			offsetY = 0.0f;
	}
	
	frameView.origin.y = -offsetY;
    
	[self.view setFrame:frameView];
	[UIView commitAnimations];
}

@end
