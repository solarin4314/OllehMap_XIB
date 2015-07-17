//
//  ThemeViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 9. 14..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "ThemeViewController.h"

@interface ThemeViewController (Private)

// 캡처이미지를 자른다
- (void)captureImageCropping:(CGRect)selectedRect;
// 폴더뷰
- (void)layoutFolderView:(CGRect)selectedRect;
// 폴더뷰 하단(스샷이 들어감)
- (void)layoutElseView;

@end

@implementation ThemeViewController (Private)


// 1 단계: 스샷을 불러와 마스크만큼 자른다
- (void)captureImageCropping:(CGRect)selectedRect
{
    // 저장된 스샷 불러옴
    NSString *filePath = [NSString stringWithFormat:@"%@/themeScreenShot.png",NSTemporaryDirectory()];
    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
    
    // 저장된 이미지
    UIImage *img = [UIImage imageWithData:pngData];
    
    
    CGRect maskRect = CGRectMake(0, 0, 320, [[UIScreen mainScreen] bounds].size.height - 20);
    maskRect.origin.y = selectedRect.origin.y + selectedRect.size.height + 20;
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        if ([[UIScreen mainScreen] scale] == 2.0)
        {
            maskRect = CGRectMake(0, 0, 640, 920);
            maskRect.origin.y = 2*(selectedRect.origin.y + selectedRect.size.height + 20);
        }
        
    }
    
    // 마스크만큼 자르긔
    CGImageRef imageRef = CGImageCreateWithImageInRect([img CGImage], maskRect);
    
    UIImage *modiImg = [UIImage imageWithCGImage:imageRef scale:[OllehMapStatus sharedOllehMapStatus].isRetinaDisplay ? 2.0f : 1.0f orientation:UIImageOrientationUp];
    
    CGImageRelease(imageRef);
    
    //
    
    NSData *imageData = UIImagePNGRepresentation(modiImg);
    NSString *path0 = [NSString stringWithFormat:@"%@/mask.png",NSTemporaryDirectory()];
    [imageData writeToFile:path0 atomically:YES];
    
    [_elseViewBg setImage:modiImg];
    
}

// 폴더뷰
- (void)layoutFolderView:(CGRect)selectedRect
{
    // 폴더 뷰
	CGRect folderViewFrame = [_folderView frame];
	//folderViewFrame.origin.y = floorf(selectedFolderPoint.y+12);
    
    folderViewFrame.origin.y = selectedRect.origin.y + selectedRect.size.height + 20 + 37;
    folderViewFrame.size.height = (ceil)(themeDetailCount / 2) * 39;
    [_folderView setFrame:folderViewFrame];
    
	// 폴더 뷰 배경
    CGRect folderViewImg = [_folderBg frame];
    NSLog(@"폴더뷰 높이 : %f", folderViewFrame.size.height);
    NSLog(@"폴더배경 y : %f", folderViewImg.origin.y);
    folderViewImg.size.height = folderViewFrame.size.height;
    
    [_folderBg setFrame:folderViewImg];
    
    // 폴더 뷰 쉐도우
    [_shadowBottomBg setFrame:CGRectMake(0, folderViewFrame.size.height - _shadowBottomBg.frame.size.height, 320, 15)];
}

// 폴더뷰 아래 스샷이미지 부분
- (void)layoutElseView
{
    
	CGRect maskFrame = _elseView.frame;
	maskFrame.origin.y = _folderView.frame.origin.y + _folderView.frame.size.height;
    //maskFrame.size.height = self.view.frame.size.height - maskFrame.origin.y;
    //maskFrame.size.height = [[UIScreen mainScreen] bounds].size.height - 20;
	_elseView.frame = maskFrame;
    
    CGRect maskFrameBg = _elseViewBg.frame;
    maskFrameBg.origin.y = 0;
    NSLog(@"%f, %f, %f, %f", maskFrame.origin.x, maskFrame.origin.y, maskFrame.size.width, maskFrame.size.height);
    NSLog(@"%f, %f, %f, %f", maskFrameBg.origin.x, maskFrameBg.origin.y, maskFrameBg.size.width, maskFrameBg.size.height);
    [_elseViewBg setFrame:maskFrameBg];
    [_elseViewBg setAlpha:0.5];
    
}

@end

@implementation ThemeViewController

@synthesize scrollView = _scrollView;
@synthesize folderView = _folderView;
@synthesize folderBg = _folderBg;
@synthesize elseView = _elseView;
@synthesize elseViewBg = _elseViewBg;
@synthesize shadowTopBg = _shadowTopBg;
@synthesize shadowBottomBg = _shadowBottomBg;

- (void)dealloc
{
    [_scrollView release];
    [_selectImg release];
    [_folderView release];
    [_folderinView release];
    [_folderBg release];
    [_elseView release];
    [_elseViewBg release];
    [_shadowTopBg release];
    [_shadowBottomBg release];
    
    [_btnCrdDictionary release];
    [_blurArr release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // 선택이미지
        _selectImg = [[UIImageView alloc] init];
        [_selectImg setImage:[UIImage imageNamed:@"theme_icon_s.png"]];
        
        // 폴더뷰 안에 뷰
        _folderinView = [[UIView alloc] init];
        
        // 버튼좌표 딕셔너리
        _btnCrdDictionary = [[NSMutableDictionary alloc] init];
        
        // 블러링뷰 어레이
        _blurArr = [[NSMutableArray alloc] init];
        
    }
    return self;
}
- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    [[ThemeCommon sharedThemeCommon] clearThemeSearchResult];
    
    // 테마뷰 높이
    _viewHeight = [[UIScreen mainScreen] bounds].size.height - 20 -37;
    
    // 테마갯수
    themeCount = [oms.themeInfoList count];
    
    [self drawTheme];
    
}
- (void) drawTheme
{
    
    // 테마 열갯수
    int themeRow = ceil(themeCount / 4);
    // 테마 행갯수
    int themeCols;
    // 카운터
    int forCount = 0;
    
    int viewY = 12;
    int viewHeight = 98;
    
    // 테마갯수가 4보다 작으면 열은 1개 행은 테마갯수
    if(themeCount < 4)
    {
        themeRow = 1;
        themeCols = themeCount;
    }
    // 아니면 무조건 행은 4개
    else
    {
        themeCols = 4;
    }
    
    
    // 세로 그리기
    for (int i = 0; i<themeRow; i++)
    {
        
        int themeX = 6;
        int themeWidth = 77;
        
        UIView *rowView = [[UIView alloc] init];
        [rowView setBackgroundColor:convertHexToDecimalRGBA(@"f2", @"f2", @"f2", 1)];
        [rowView setFrame:CGRectMake(0, viewY, 320, viewHeight)];
        [_scrollView addSubview:rowView];
        
        // 가로 그리기
        for (int j = 0; j<themeCols; j++)
        {
            
            NSDictionary *themeInfo = [ThemeCommon themeInfoByIndex:forCount];
            
            // 각 뷰
            UIView *itemView = [[UIView alloc] init];
            [itemView setBackgroundColor:convertHexToDecimalRGBA(@"f2", @"f2", @"f2", 1)];
            [itemView setFrame:CGRectMake(themeX, 0, themeWidth, 98)];
            [rowView addSubview:itemView];
            
            // 아이템뷰 기준에서 rect의 좌표를 스크롤뷰에서의 절대좌표로 변환
            CGRect rct = [itemView convertRect:CGRectMake(5, 8, 67, 67) toView:_scrollView];
            
            // 버튼
            UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [itemBtn setFrame:rct];
            [itemBtn setTag:forCount];
            [itemBtn setExclusiveTouch:YES];
            [itemBtn addTarget:self action:@selector(themeClick:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView insertSubview:itemBtn atIndex:100];
            
            // 배열에 버튼의 rect를 저장
            NSValue *rectObj = [NSValue valueWithCGRect:rct];
            NSString *cnt = [NSString stringWithFormat:@"%d", forCount];
            NSArray *arr = [NSArray arrayWithObjects:rectObj, nil];
            
            [_btnCrdDictionary setObject:arr forKey:cnt];
            
            // 버튼배경
            UIImageView *itemBg = [[UIImageView alloc] init];
            
            [itemBg setImage:[ThemeCommon imageByThemeCode:stringValueOfDictionary(themeInfo, @"code")]];
            
            [itemBg setFrame:CGRectMake(5, 8, 67, 67)];
            [itemView addSubview:itemBg];
            [itemBg release];
            
            // 라벨
            UILabel *itemLbl = [[UILabel alloc] init];
            [itemLbl setBackgroundColor:[UIColor clearColor]];
            [itemLbl setFrame:CGRectMake(0, 8+67+6-1, 77, 11+2)];
            [itemLbl setText:[NSString stringWithFormat:@"%@", stringValueOfDictionary(themeInfo, @"name")]];
            [itemLbl setFont:[UIFont boldSystemFontOfSize:11]];
            [itemLbl setTextAlignment:NSTextAlignmentCenter];
            [itemLbl setAdjustsFontSizeToFitWidth:YES];
            [itemView addSubview:itemLbl];
            [itemLbl release];
            
            [itemView release];
            
            themeX += themeWidth;
            
            forCount++;
            
        }
        // 한 행을 다 그리고 몇개가 남았는지 확인.. 4개보다 많으면 다음 열도 4개
        if(themeCount-forCount > 4)
        {
            themeCols = 4;
        }
        else
        {
            themeCols = themeCount - forCount;
        }
        
        
        [rowView release];
        
        
        
        viewY += viewHeight;
    }
    
    // new마크(뱃지) 그리기
    [self drawBatch];
    
    themeViewHeight = viewY;
    
    [_scrollView setContentSize:CGSizeMake(320, themeViewHeight)];
    
    [self themeSnapShot];
    
}
- (void) drawBatch
{
    // New마크 그리기
    
    int new_x = 0;
    int new_y = 0;
    
    for (int i=0; i<themeCount; i++)
    {
        
        NSDictionary *themeInfo = [ThemeCommon themeInfoByIndex:i];
        
        // new 마크
        // 업데이트날짜Str
        NSString *updateDateStr = [NSString stringWithFormat:@"%@", stringValueOfDictionary(themeInfo, @"update_date")];
        
        if ([self timeInterVal:updateDateStr] < 7)
        {
            UIImageView *itemNew = [[UIImageView alloc] init];
            [itemNew setImage:[UIImage imageNamed:@"new_icon.png"]];
            [itemNew setFrame:CGRectMake(6 + new_x, 12+3 + new_y, 24, 24)];
            
            [_scrollView addSubview:itemNew];
            
            
            [itemNew release];
        }
        
        
        // 블러링뷰 만들고 어레이에 ADD
        UIControl *blurView = [[[UIControl alloc] init] autorelease];
        [blurView setBackgroundColor:convertHexToDecimalRGBA(@"f2", @"f2", @"f2", 0.75)];
        [blurView setAlpha:0.75];
        [blurView setOpaque:YES];
        [blurView addTarget:self action:@selector(elseViewTab:) forControlEvents:UIControlEventTouchUpInside];
        [blurView setFrame:CGRectMake(6+new_x, 12+new_y, 67+10, 67+30)];
        
        [_blurArr addObject:blurView];
        
        new_x += 77;
        
        if(new_x >= 320-12)
        {
            new_x = 0;
        }
        
        if((i - 3) % 4 == 0)
        {
            new_y += 98;
        }
        
    }
    
}
- (void) themeSnapShot
{
    // 들어오면 일단 캡쳐한다
    CGFloat scale = 1.0;
    if([[UIScreen mainScreen]respondsToSelector:@selector(scale)])
    {
        CGFloat tmp = [[UIScreen mainScreen]scale];
        if (tmp > 1.5) {
            scale = 2.0;
        }
    }
    
    // 레티나인지 걍인지?
    scale > 1.5 ? UIGraphicsBeginImageContextWithOptions(self.scrollView.contentSize, NO, scale) : UIGraphicsBeginImageContext(self.scrollView.contentSize);
    
	// 메인 백그라운드 뷰 갭춰.
	[self.scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(backgroundImage);
    //UIGraphicsEndImageContext();
    NSString *path0 = [NSString stringWithFormat:@"%@/themeScreenShot.png",NSTemporaryDirectory()];
    
    //BOOL success = FALSE;
    //success = [imageData writeToFile:path0 atomically:YES];
    [imageData writeToFile:path0 atomically:YES];
    
    //
    [self drawScrollView];
    
}
- (void) drawScrollView
{
    [_scrollView setContentSize:CGSizeMake(320, _viewHeight)];
}
- (void) themeClick:(id)sender
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    // 태그값으로 무슨 버튼인지 판단
    index = ((UIButton *)sender).tag;
    
    NSDictionary *themeInfo = [ThemeCommon themeInfoByIndex:index];
    // 선택한 테마의 상세테마 수
    
    themeDetailCount = [[themeInfo objectForKeyGC:@"sub"] count];
    
    // 선택한 테마의 좌표값
    CGRect rect = [[[_btnCrdDictionary objectForKeyGC:[NSString stringWithFormat:@"%d", index]] objectAtIndexGC:0] CGRectValue];
    
    // 상세테마가 없으면 확장없이 바로 ㄲㄱ
    if(themeDetailCount == 0)
    {
        [self subThemeClick:sender];
        
        return;
    }
    // 만약 상세테마뷰가 열려있다면 닫아야지
    if(_folderView.hidden == NO)
    {
        [self elseViewTab:nil];
        return;
    }
    
    // 탭한 폴더의 센터
    CGRect selectedRect = rect;
    prevRect = selectedRect;
    
    if (_folderView.hidden) // 만약 폴더가 열려 있지 않으면...
    {
        // 서브테마 그리기
        [self drawSubTheme];
        
        CGRect elseFrame = CGRectMake(0, 37+ selectedRect.origin.y+selectedRect.size.height + 20, 320,
                                      [[UIScreen mainScreen] bounds].size.height - 20);
        [_folderView setFrame:elseFrame];
        [_elseView setFrame:elseFrame];
        
        // 저장된 스크린샷을 마스크로 짤라서 하단뷰에 붙임
        [self captureImageCropping:selectedRect];
        // 폴더뷰를 그림
        [self layoutFolderView:selectedRect];
        [UIView beginAnimations:@"FolderOpen" context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        _folderView.hidden = NO;
        _elseView.hidden = NO;
        
        // 폴더 열기 애니메이션.
        // 3 단계: 메인 뷰의 나머지 스크린샷 찍힌부분
        [self layoutElseView];
        
        [UIView commitAnimations];
        
        // 블러링뷰를 add한다
        [self blurringViewAddToScrollview:index];
        
        // n버튼 뚫린건지 그냥인지 체크
        NSString *updateDateStr = [NSString stringWithFormat:@"%@", [[oms.themeInfoList objectAtIndexGC:index] objectForKeyGC:@"update_date"]];
        if ([self timeInterVal:updateDateStr] < 7)
        {
            [_selectImg setImage:[UIImage imageNamed:@"theme_icon_s_open.png"]];
        }
        else
        {
            [_selectImg setImage:[UIImage imageNamed:@"theme_icon_s.png"]];
        }
        [_selectImg setFrame:rect];
        [_scrollView addSubview:_selectImg];
        
        
        // 나중에 넘어가게되면....
        CGRect folderRect = [_folderView frame];
        
        int viewMax = folderRect.origin.y + folderRect.size.height + 20;
        
        int limitMax = [[UIScreen mainScreen] bounds].size.height - 20;
        if(viewMax > limitMax)
        {
            int minus = viewMax - limitMax;
            
            [_scrollView setContentOffset:CGPointMake(0, minus)];
            
            folderRect.origin.y -= minus;
            
            [_folderView setFrame:folderRect];
        }
        
    }
    //    // 열려있을 때 닫음
    //    else
    //    {
    //        [UIView animateWithDuration:0.5 animations:^{
    //            [self closing:selectedRect];
    //        } completion:^(BOOL finished)
    //         {
    //             _folderView.hidden = YES;
    //             _elseView.hidden = YES;
    //             // 알파값 원상 복귀.
    //             self.scrollView.alpha = 1;
    //
    //             // 폴더인뷰의 add 객체 제거
    //             for (UIControl *addingView in _folderinView.subviews)
    //             {
    //                 [addingView removeFromSuperview];
    //             }
    //
    //             int cnt = 0;
    //             for (UIView *view in _blurArr)
    //             {
    //                 if(cnt != index)
    //                 {
    //                     view = [_blurArr objectAtIndexGC:cnt];
    //
    //                     [view removeFromSuperview];
    //                 }
    //                 cnt++;
    //             }
    //
    //             [_selectImg removeFromSuperview];
    //             [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    //         }];
    
    //    }
    
}
-(void) drawSubTheme
{
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    int themerow = ceil(themeDetailCount / 2);
    
    int counter = 0;
    int detailY = 0;
    int tagCount = 1000;
    
    // 서브테마 세로
    for (int i = 0; i<themerow; i++)
    {
        
        int detailX = 15;
        int detailBtnX = 0;
        int roof = 2;
        
        if(themeDetailCount - counter < 2)
        {
            roof = 1;
        }
        
        // 서브테마 가로
        UIView *detailView = [[UIView alloc] init];
        [detailView setFrame:CGRectMake(0, detailY, 320, 39)];
        [detailView setBackgroundColor:[UIColor clearColor]];
        
        for (int j = 0; j < roof; j++)
        {
            
            // 서브테마 버튼
            UIButton *detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [detailBtn setFrame:CGRectMake(detailBtnX, 0, 160, 39)];
            //if(j % 2 == 0)
            //[detailBtn setBackgroundColor:[UIColor redColor]];
            [detailBtn setImage:[UIImage imageNamed:@"theme_list_01_pressed.png"] forState:UIControlStateHighlighted];
            [detailBtn setTag:tagCount];
            [detailBtn setExclusiveTouch:YES];
            [detailBtn addTarget:self action:@selector(subThemeClick:) forControlEvents:UIControlEventTouchUpInside];
            [detailView addSubview:detailBtn];
            
            // 서브테마 라벨
            
            NSString *str = [NSString stringWithFormat:@"%@", [[[[oms.themeInfoList objectAtIndexGC:index] objectForKeyGC:@"sub"] objectAtIndexGC:counter] objectForKeyGC:@"name"]];
            
            UILabel *detailLbl = [[UILabel alloc] init];
            [detailLbl setBackgroundColor:[UIColor clearColor]];
            [detailLbl setFrame:CGRectMake(detailX, 10, 129, 15)];
            [detailLbl setFont:[UIFont systemFontOfSize:15]];
            [detailLbl setTextColor:convertHexToDecimalRGBA(@"e1", @"e1", @"e1", 1)];
            [detailLbl setText:str];
            [detailView addSubview:detailLbl];
            [detailLbl release];
            
            counter++;
            detailX += 160;
            detailBtnX += 160;
            tagCount++;
            
        }
        
        [_folderinView addSubview:detailView];
        [detailView release];
        
        detailY += 39;
        
        // 밑줄
        UIImageView *underLine = [[UIImageView alloc] init];
        [underLine setFrame:CGRectMake(0, detailY - 1, 320, 1)];
        [underLine setBackgroundColor:convertHexToDecimalRGBA(@"2c", @"2c", @"2c", 1)];
        [_folderinView addSubview:underLine];
        [underLine release];
        
        [_folderinView setFrame:CGRectMake(0, 0, 320, themerow * 39)];
        [_folderView addSubview:_folderinView];
    }
    
}
-(void) subThemeClick:(id)sender
{
    int tagIndex = ((UIButton *)sender).tag;
    
    tagIndex -= 1000;
    
    OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
    
    NSString *themeCode;
    if(themeDetailCount == 0)
    {
        themeCode = oms.themeInfoList [index] [@"code"];
    }
    else
    {
        themeCode = oms.themeInfoList [index] [@"sub"] [tagIndex] [@"code"];
        
    }
    
    // MIK.geun :: 20120929
    // maxRenderingZoomLevel 은 서버에서 받도록 수정~
    // themeCode 별도로 상위 코드인 mainThemeCode 도필요 (아이콘용.)
    [MainMapViewController markingThemePOI_ThemeCode:themeCode mainThemeCode:oms.themeInfoList [index] [@"code"] maxRenderingZoomLevel:[oms.themeInfoList [index] [@"scale"] intValue] animated:NO];
    
    
}
-(int) timeInterVal:(NSString *)serverTime
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // 오늘날짜
    NSDate *now = [NSDate date];
    // 업데이트Date
    NSDate *updateDate = [formatter dateFromString:serverTime];
    // 비교하기
    NSDateComponents *dcom = [[NSCalendar currentCalendar]components: NSDayCalendarUnit fromDate:updateDate toDate:now options:0];
    return [dcom day];
}
- (void) closingExpand:(CGRect)rect
{
    CGRect elseFrame = CGRectMake(0, 37+ rect.origin.y+rect.size.height + 20, 320,
                                  [[UIScreen mainScreen] bounds].size.height - 20);
    [_folderView setFrame:elseFrame];
    [_elseView setFrame:elseFrame];
    
}
- (void)blurringViewAddToScrollview:(int)indexing
{
    NSLog(@"블러링 배열 : %@", _blurArr);
    
    int cnt = 0;
    
    // 넘겨받은 인덱스값을 제외하고 나머지를 블러처리된 뷰로 add
    for (UIControl *view in _blurArr)
    {
        if(cnt != indexing)
        {
            view = [_blurArr objectAtIndexGC:cnt];
            
            [_scrollView addSubview:view];
        }
        
        cnt++;
    }
    
}
- (void) blurringViewRemoveToScrollview:(int)indexing
{
    NSLog(@"블러링 배열 : %@", _blurArr);
    
    int cnt = 0;
    for (UIView *view in _blurArr)
    {
        if(cnt != indexing)
        {
            view = [_blurArr objectAtIndexGC:cnt];
            
            [view removeFromSuperview];
        }
        cnt++;
    }
}
// 애니메이션
- (void)myAnimation:(NSString*)animation didFinish:(BOOL)finish context:(void *)context
{
    if ([animation isEqualToString:@"FolderClose"])
    {
        _folderView.hidden = YES;
        _elseView.hidden = YES;
        // 알파값 원상 복귀.
        self.scrollView.alpha = 1;
        
        // 폴더인뷰의 add 객체 제거
        for (UIControl *addingView in _folderinView.subviews)
        {
            [addingView removeFromSuperview];
        }
        // 블러링뷰 제거
        [self blurringViewRemoveToScrollview:index];
        
        [_selectImg removeFromSuperview];
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        //[_scrollView setContentSize:CGSizeMake(320, themeViewHeight)];
        
    }
}
- (IBAction)popBtnClick:(id)sender
{
    // 메인지도를 불러온다.
    MainMapViewController *mmvc = (MainMapViewController*)[[OMNavigationController sharedNavigationController].viewControllers objectAtIndexGC:0];
    // 위에서 불러온 메인지도 하단 테마버튼을 OFF처리한다.
    [mmvc.btnBottomTheme setSelected:NO];
    
    // 창닫기
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}
// 확장영역 하단 탭
-(IBAction) elseViewTab:(id)sender
{
    // 폴더 닫기 애니메이션.
    [UIView beginAnimations:@"FolderClose" context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDidStopSelector:@selector(myAnimation:didFinish:context:)];
    [UIView setAnimationDelegate:self];
    // 애니메이션 종료 후 레이아웃과 폴더 뷰 감추기.
    [self closingExpand:prevRect];
    [UIView commitAnimations];
    
}

@end
