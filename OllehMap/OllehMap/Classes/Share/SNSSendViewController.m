//
//  SNSSendViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 8. 30..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "SNSSendViewController.h"

@interface SNSSendViewController ()

@end

@implementation SNSSendViewController

@synthesize scrollView = _scrollView;
@synthesize delegate = _delegate;

- (void) dealloc
{
    [_scrollView release];
    [_shareView release];
    [_middleView release];
    [_deleteBtn release];
    [_delegate release];
    [_textString release];
    
    [_cameraBtn release];       ///< 카메라 버튼
    [_albumBtn release];
    
    [_nameLabel release];                 ///< 상단 상호명 라벨
    [_nameString release];                ///< 상호명 텍스트
    
    [_urlLabel release];                  ///< 상단 단축 url 라벨
    [_urlString release];                 ///< url 문자
    
    [_textBox release];                   ///< 텍스트 뷰
    
    [_photoview release];                 ///< 포토 뷰어 입니다.
    [_photoimage release];                ///< 포토 이미지를 가지는 이미지 뷰어 입니다
    
    [super dealloc];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:[[[NSUserDefaults standardUserDefaults] stringForKey:@"IdleTimerDisabled"] isEqualToString:@"YES"]];
}
- (id)initWithType:(int)type name:(NSString*)name url:(NSString*)url strData:(NSString*)strData
{
    self = [super init];
    if (self != nil)
    {
        
        _type = type;
        
        
        
        _nameString          =   [[NSString alloc] initWithString:name];
        _urlString           =   [[NSString alloc] initWithString:url];
        
        _textString                =   [[NSString alloc] initWithString:strData];
        
        _scrollView = [[DetailScrollView alloc] init];
        [_scrollView setFrame:CGRectMake(0, 37, 320, self.view.frame.size.height-37)];
        [_scrollView setContentSize:CGSizeMake(320, [[UIScreen mainScreen] bounds].size.height - 20 -37)];
        //_scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_scrollView];
        
        
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    
    [self renderNavigation];
}
- (void) renderNavigation
{
    // 네비게이션 뷰 생성
    UIView *vwNavigation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
    
    // 배경 이미지
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_bg.png"]];
    [vwNavigation addSubview:imgvwBack];
    [imgvwBack release];
    
    // 버튼
    UIButton *btnPrev = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPrev setFrame:CGRectMake(7, 4, 47, 28)];
    [btnPrev setImage:[UIImage imageNamed:@"title_bt_cancel.png"] forState:UIControlStateNormal];
    [btnPrev addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [vwNavigation addSubview:btnPrev];
    
    // 타이틀 그림자
    UILabel *lblTitleShadow = [[UILabel alloc] initWithFrame:CGRectMake(61, (37-20)/2+2, 198, 20)];
    [lblTitleShadow setFont:[UIFont systemFontOfSize:20]];
    [lblTitleShadow setTextColor:convertHexToDecimalRGBA(@"00", @"00", @"00", 0.75f)];
    [lblTitleShadow setBackgroundColor:[UIColor clearColor]];
    [lblTitleShadow setTextAlignment:NSTextAlignmentCenter];
    if(_type == 1)
    {
        [lblTitleShadow setText:@"facebook 공유하기"];
    }
    else
    {
        [lblTitleShadow setText:@"twitter 공유하기"];
    }
    [vwNavigation addSubview:lblTitleShadow];
    [lblTitleShadow release];
    
    // 타이틀
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(61, (37-20)/2, 198, 20)];
    [lblTitle setFont:[UIFont systemFontOfSize:20]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    if (_type == 1)
    {
        [lblTitle setText:@"facebook 공유하기"];
    }
    else
    {
        [lblTitle setText:@"twitter 공유하기"];
    }
    
    [vwNavigation addSubview:lblTitle];
    [lblTitle release];
    
    // 보내기버튼
    UIButton *btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSend setFrame:CGRectMake(271, 4, 42, 28)];
    [btnSend setImage:[UIImage imageNamed:@"title_btn_send.png"] forState:UIControlStateNormal];
    [btnSend addTarget:self action:@selector(onSend:) forControlEvents:UIControlEventTouchUpInside];
    [vwNavigation addSubview:btnSend];
    
    // 네비게이션 뷰 삽입
    [self.view addSubview:vwNavigation];
    [vwNavigation release];
}
- (void)onClose:(id)sender
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:[[[NSUserDefaults standardUserDefaults] stringForKey:@"IdleTimerDisabled"] isEqualToString:@"YES"]];
    
    [self dismissModalViewControllerAnimated:YES];
    
    [OllehMapStatus sharedOllehMapStatus].photoimg = nil;
    
}
- (void)onSend:(id)sender
{
    [_textBox resignFirstResponder];
    [_textBox.inputAccessoryView setHidden:YES];
    
    NSMutableString *nextStr = [NSMutableString string];
    
    // 델리게이트로 데이터 넘겨주기
    if ([self.delegate respondsToSelector:@selector(SNSSendViewDelegateTextMessage:type:)])
    {
        [nextStr appendFormat:@"%@", _nameString];
        [nextStr appendFormat:@"%@", _urlString];
        [nextStr appendFormat:@"%@", _textBox.text];
        
        [self.delegate SNSSendViewDelegateTextMessage:nextStr type:_type];
    }
    
    [self dismissModalViewControllerAnimated:YES];
    
    
    
    
}
- (void) backgroundClick:(id)sender
{
    [_textBox resignFirstResponder];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 버튼 밑 이미지 마진(iPhone5)
    int uiMarginTop = (IS_4_INCH) ? 88 : 0;
    
    // 쉐어뷰
    _shareView = [[UIControl alloc] init];
    [_shareView setFrame:CGRectMake(0, 0, 320, 209 + uiMarginTop)];
    [_shareView addTarget:self action:@selector(backgroundClick:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_shareView];
    
    // 타이틀
    _nameLabel = [[UILabel alloc] init];
    [_nameLabel setFrame:CGRectMake(41, 14, 259, 15)];
    [_nameLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [_nameLabel setText:_nameString];
    [_shareView addSubview:_nameLabel];
    
    // 상단 단축 url 라벨
    _urlLabel = [[UILabel alloc] init];
    [_urlLabel setFrame:CGRectMake(41, 32, 259, 17)];
    [_urlLabel setFont:[UIFont systemFontOfSize:15]];
    [_urlLabel setTextColor:convertHexToDecimalRGBA(@"8b", @"8b", @"8b", 1)];
    [_urlLabel setText:_urlString];
    [_shareView addSubview:_urlLabel];
    
    // 텍스트 라벨 설정
    _textBox = [[UITextView alloc] init];
    _textBox.delegate = self;
    [_textBox setFrame:CGRectMake(20, 66, 290, 90)];
    [_textBox setFont:[UIFont systemFontOfSize:13]];
    [_textBox setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [_textBox setKeyboardType:UIKeyboardTypeDefault];
    [_textBox setBackgroundColor:[UIColor clearColor]];
    [_textBox setScrollEnabled:YES];
    //_textBox.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"share_textfield.png"]];
    
    // 텍필 배경
    UIImageView *tBoxBg = [[UIImageView alloc] init];
    
    if (IS_4_INCH)
    {
        [tBoxBg setFrame:CGRectMake(10, 60, 300, 184)];
        [tBoxBg setImage:[UIImage imageNamed:@"share_textfield-568h.png"]];
    }
    else
    {
        [tBoxBg setFrame:CGRectMake(10, 60, 300, 96)];
        [tBoxBg setImage:[UIImage imageNamed:@"share_textfield.png"]];
    }
    
    [_shareView addSubview:tBoxBg];
    [tBoxBg release];
    
    [_textBox setEnablesReturnKeyAutomatically:NO];
    [_shareView addSubview:_textBox];
    
    [_textBox setText:_textString];
    
    // 키보드 활성화
    [_textBox becomeFirstResponder];
    
    
    // sns 별 이미지 넣기
    UIImage *faceimg = [UIImage imageNamed:@"copy_icon_facebook.png"];
    UIImage *twitterimg = [UIImage imageNamed:@"copy_icon_twitter.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 23, 23)];
    
    // 이미지 설정
    if (_type == 1)
        [imgView setImage:faceimg];
    else
        [imgView setImage:twitterimg];
    
    [_shareView addSubview:imgView];
    
    [imgView release];
    
    
    // 카메라 버튼
    _cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cameraBtn retain];
	[_cameraBtn addTarget:self action:@selector(cameraBtnClick:) forControlEvents:UIControlEventTouchUpInside];
	[_cameraBtn setFrame:CGRectMake(10, uiMarginTop + 166, 147, 31)];
    [_cameraBtn setImage:[UIImage imageNamed:@"share_btn_camera.png"] forState:UIControlStateNormal];
    [_shareView addSubview:_cameraBtn];
    
    // 앨범버튼
    _albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_albumBtn retain];
    [_albumBtn setFrame:CGRectMake(163, uiMarginTop + 166, 147, 31)];
    [_albumBtn setImage:[UIImage imageNamed:@"share_btn_album.png"] forState:UIControlStateNormal];
    [_albumBtn addTarget:self action:@selector(albumBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_shareView addSubview:_albumBtn];
    
    // 밑줄
    UIImageView *underLine = [[UIImageView alloc] init];
    [underLine setFrame:CGRectMake(0, uiMarginTop + 208, 320, 1)];
    [underLine setBackgroundColor:convertHexToDecimalRGBA(@"c2", @"c2", @"c2", 1)];
    [_shareView addSubview:underLine];
    [underLine release];
    
    // 미들뷰
    _middleView = [[UIView alloc] init];
    [_middleView setFrame:CGRectMake(0, uiMarginTop + 209, 320, 215)];
    [_middleView setBackgroundColor:convertHexToDecimalRGBA(@"f2", @"f2", @"f2", 1)];
    [_scrollView addSubview:_middleView];
    
    //.. 포토 뷰어 입니다.
    _photoview           =   [[UIView alloc] init];
    [_photoview setFrame:CGRectMake(75, 23, 170, 170)];
    [_photoview setBackgroundColor:[UIColor clearColor]];
    [_middleView addSubview:_photoview];
    
    //.. 사진첨부 이미지 뷰어
    _photoimage          =   [[UIImageView alloc] init];
    [_photoimage setFrame:CGRectMake(1, 1, 168, 168)];
    [_photoimage setImage:[UIImage imageNamed:@"share_no_image.png"]];
    //[_photoimage setContentMode:UIViewContentModeScaleAspectFit];
    [_photoimage setBackgroundColor:[UIColor clearColor]];
    [_photoview addSubview:_photoimage];
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteBtn setFrame:CGRectMake(1, 140, 168, 29)];
    [_deleteBtn setImage:[UIImage imageNamed:@"share_btn_delete.png"] forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(onPhotoEnable:) forControlEvents:UIControlEventTouchUpInside];
    [_deleteBtn setHidden:YES];
    [_photoview addSubview:_deleteBtn];
    
    
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewTapped:)] autorelease];
    [textView addGestureRecognizer:tap];
    
    return YES;
}

// 탭제스쳐 관련 이벤트 함수
-(void)textViewTapped:(id)sender
{
    if(_textBox.editable == NO)
    {
        _textBox.editable = YES;
        [_textBox becomeFirstResponder];
        [_textBox.inputAccessoryView setHidden:NO];
    }
}



/**
 @brief 첨부한 사진데이터 삭제
 */

-(void)onPhotoEnable:(id)sender
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 사진 데이터 삭제 및 플러그 변경
    if(oms.photoimg != nil){
        oms.photoimg = nil;
    }
    oms.isPhotosCheck = FALSE;
    
    // 뷰 이미지 삭제
    [_photoimage setImage:[UIImage imageNamed:@"share_no_image.png"]];
    
    
    // 첨부된 사진 및 뷰어 숨김
    [self showAndHideView:YES];
    
}

- (void) cameraBtnClick:(id)sender
{
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] )
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePicker.allowsEditing = YES;
        
        [self presentModalViewController:imagePicker animated:YES];
        [imagePicker release];    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :@"카메라를 사용할 수 없습니다."];
    }
    
}
- (void) albumBtnClick:(id)sender
{
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] )
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = YES;
        
        [self presentModalViewController:imagePicker animated:YES];
        [imagePicker release];
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :@"사진 보관함을 사용할 수 없습니다."];
    }
    
}
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    if(oms.photoimg != nil)
    {
        oms.photoimg = nil;
    }
    
    UIImage *img1 = [info objectForKey:UIImagePickerControllerEditedImage];
    
    oms.photoimg = img1;
    
    oms.isPhotosCheck = TRUE;
    [_photoimage setImage:img1];
    [_textBox setEditable:NO];
    [_textBox resignFirstResponder];
    [_textBox.inputAccessoryView setHidden:YES];
    [self showAndHideView:NO];
    
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)showAndHideView:(BOOL)show
{
    // 포토 뷰
    //[_photoview setHidden:show];
    
    // 사진첨부 이미지 뷰어
    //[_photoimage setHidden:show];
    
    [_deleteBtn setHidden:show];
    
    // 사진 첨부 삭제 버튼
    
}

#pragma mark -
#pragma mark - UITextViewDelegate 글자수제한

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    
    NSString *candidateString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    int maxLength;
    
    if(_type == 1)
    {
        maxLength = 200;
    }
    else
    {
        maxLength = 140;
    }
    
    
    //길이 초과 점검
    if(text && [text length] && ([candidateString length] >= maxLength)) {
        return NO;
    }
    
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

@end
