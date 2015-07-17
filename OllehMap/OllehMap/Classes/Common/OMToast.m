//
//  OMToast.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 10. 17..
//
//

#import "OMToast.h"

#import "OMMessageBox.h"

@implementation OMToast

@synthesize toastContainerViews = _toastContainerViews;

static OMToast *_Instance = nil;
+ (OMToast*) sharedToast
{
    if ( _Instance == nil )
    {
        _Instance = [[OMToast alloc] init];
    }
    return _Instance;
}

- (id) init
{
    self = [super init];
    if ( self )
    {
        _toastContainerViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) dealloc
{
    [_toastContainerViews release];
    _toastContainerViews = nil;
    
    [super dealloc];
}


// ================
// [ 토스트 처리 메소드 ]
// ================
- (void) showToastMessagePopup:(NSString *)message superView:(UIView *)superView maxBottomPoint:(float)maxBottomPoint autoClose:(BOOL)autoClose
{

    // 기존 토스트 숨김처리 (애니메이션도중 화면에서 사라지게위함...)
        for (UIView *toast in self.toastContainerViews)
        {
            [toast setHidden:YES];
        }

    NSString *toastMessage = [NSString stringWithFormat:@"%@", message];
    
    // 토스트 컨테이너 생성
    CGRect toastContainerFrame = CGRectMake(28, maxBottomPoint,264, 36);
    UIView *toastContainer = [[UIView alloc] initWithFrame:toastContainerFrame];
    [toastContainer setBackgroundColor:[UIColor clearColor]];
    [toastContainer setUserInteractionEnabled:NO];
    
    // 토스트 배경 이미지뷰 생성
    UIImageView *toastBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toast_popup.png"]];
    
    
    // 토스트 메세지 라벨 생성
    CGRect toastMessageLabelFrame = CGRectMake(0, 11, toastContainerFrame.size.width, 13);
    UILabel *toastMessageLabel = [[UILabel alloc] initWithFrame:toastMessageLabelFrame];
    [toastMessageLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [toastMessageLabel setLineBreakMode:NSLineBreakByClipping];
    [toastMessageLabel setNumberOfLines:NSIntegerMax];
    [toastMessageLabel setBackgroundColor:[UIColor clearColor]];
    [toastMessageLabel setTextColor:[UIColor whiteColor]];
    [toastMessageLabel setTextAlignment:NSTextAlignmentCenter];
    [toastMessageLabel setText:toastMessage];
    
    // 토스트 배경 이미지뷰 삽입
    [toastContainer addSubview:toastBackgroundImageView];
    // 토스트 메세지 라벨 삽입
    [toastContainer addSubview:toastMessageLabel];
    // 토스트 컨테이너 삽입
    [superView addSubview:toastContainer];
    
    [toastContainer setAlpha:0.0];
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // 애니메이션 대상 등록
                         [self.toastContainerViews addObject:toastContainer];
                         // 열리는 애니메이션 적용
                         [toastContainer setAlpha:1.0f];
                        
                         _themeToastShowing = YES;
                     }
                     completion:^(BOOL finished) {
                         // 열리는 애니메이션 종료 뒤에.. 닫히는 애니메이션 처리
                         [UIView animateWithDuration:0.7f delay:3.0f options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              // 닫는 애니메이션 적용
                                              [toastContainer setAlpha:0.0];
                                          }
                                          completion:^(BOOL finished) {
                                              // 닫는 애니메이션 종료뒤에는 아무작업 없음.
                                              [toastContainer removeFromSuperview];
                                              // 애니메이션 대상 해제
                                              [self.toastContainerViews removeObject:toastContainer];
                                              
                                              _themeToastShowing = NO;
                                              
                                          } ];
                     } ];
    
    // 자원해제
    [toastBackgroundImageView release];
    [toastMessageLabel release];
    [toastContainer release];
}
- (void) showToastCadaStralPopup:(NSString *)message superView:(UIView *)superView maxBottomPoint:(float)maxBottomPoint autoClose:(BOOL)autoClose
{
    if(_themeToastShowing)
    {
        maxBottomPoint -= 46;
    }
    else
    {
        // 기존 토스트 숨김처리 (애니메이션도중 화면에서 사라지게위함...)
        for (UIView *toast in self.toastContainerViews)
        {
            [toast setHidden:YES];
        }
    }
    
    NSString *toastMessage = [NSString stringWithFormat:@"%@", message];
    
    // 토스트 컨테이너 생성
    CGRect toastContainerFrame = CGRectMake(28, maxBottomPoint,264, 36);
    UIView *toastContainer = [[UIView alloc] initWithFrame:toastContainerFrame];
    [toastContainer setBackgroundColor:[UIColor clearColor]];
    [toastContainer setUserInteractionEnabled:NO];
    
    // 토스트 배경 이미지뷰 생성
    UIImageView *toastBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toast_popup.png"]];
    
    
    // 토스트 메세지 라벨 생성
    CGRect toastMessageLabelFrame = CGRectMake(0, 11, toastContainerFrame.size.width, 13);
    UILabel *toastMessageLabel = [[UILabel alloc] initWithFrame:toastMessageLabelFrame];
    [toastMessageLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [toastMessageLabel setLineBreakMode:NSLineBreakByClipping];
    [toastMessageLabel setNumberOfLines:NSIntegerMax];
    [toastMessageLabel setBackgroundColor:[UIColor clearColor]];
    [toastMessageLabel setTextColor:[UIColor whiteColor]];
    [toastMessageLabel setTextAlignment:NSTextAlignmentCenter];
    [toastMessageLabel setText:toastMessage];
    
    // 토스트 배경 이미지뷰 삽입
    [toastContainer addSubview:toastBackgroundImageView];
    // 토스트 메세지 라벨 삽입
    [toastContainer addSubview:toastMessageLabel];
    // 토스트 컨테이너 삽입
    [superView addSubview:toastContainer];
    
    [toastContainer setAlpha:0.0];
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // 애니메이션 대상 등록
                         [self.toastContainerViews addObject:toastContainer];
                         // 열리는 애니메이션 적용
                         [toastContainer setAlpha:1.0f];
                         
                         
                     }
                     completion:^(BOOL finished) {
                         // 열리는 애니메이션 종료 뒤에.. 닫히는 애니메이션 처리
                         [UIView animateWithDuration:0.7f delay:3.0f options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              // 닫는 애니메이션 적용
                                              [toastContainer setAlpha:0.0];
                                          }
                                          completion:^(BOOL finished) {
                                              // 닫는 애니메이션 종료뒤에는 아무작업 없음.
                                              [toastContainer removeFromSuperview];
                                              // 애니메이션 대상 해제
                                              [self.toastContainerViews removeObject:toastContainer];
                                              
                                              
                                          } ];
                     } ];
    
    // 자원해제
    [toastBackgroundImageView release];
    [toastMessageLabel release];
    [toastContainer release];
}

@end
