//
//  MyImageCropViewController.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 9. 27..
//
//

#import "MyImageCropViewController.h"

#include <sys/sysctl.h>
#include <stdint.h>
#include <stdio.h>

#import "MyImage.h"

#import "OMNavigationController.h"
#import "OllehMapStatus.h"
#import "OMCustomView.h"
#import "OMMessageBox.h"
#import "MapContainer.h"
#import "OMIndicator.h"
#import "OMCustomView.h"


@interface MyImageCropViewController (private)
@end

@implementation MyImageCropViewController

- (void) addimageview :(UIImage*)img
{
    UIView *a = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
    [self.view addSubview:a];
    [a setBackgroundColor:[UIColor yellowColor]];
    
    UIImageView *b = [[UIImageView alloc] initWithImage:img];
    [a addSubview:b];
    
    [b release];
    [a release];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        _cropImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_cropImageView setUserInteractionEnabled:YES];
        [_cropImageView setMultipleTouchEnabled:YES];
    }
    return self;
}

- (void) dealloc
{
    [_cropImageView release]; _cropImageView = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 탭 제스쳐 등록
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired =  2;
    [_cropImageView addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    // 핀치 제스쳐 등록
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [_cropImageView addGestureRecognizer:pinchGesture];
    [pinchGesture release];
    
    // 패닝 제스쳐 등록
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [_cropImageView addGestureRecognizer:panGesture];
    [panGesture release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) drawImageWithCameraRoll:(NSDictionary *)info
{
    if ( info )
    {
        // 동영상 URL
        NSURL *mediaUrl = (NSURL*)[info valueForKey:UIImagePickerControllerMediaURL];
        
        // 이미지 :: 동영상URL이 없는 경우 이미지로 판단.
        if (mediaUrl == nil)
        {
            // 이미지
            UIImage *image = nil;
            // 이미지 사이즈
            CGSize imageSize;// = CGSizeMake(0, 0);
            // 먼저 편집된 이미지 불러오기
            image = (UIImage*)[info valueForKey:UIImagePickerControllerEditedImage];
            // 편집된 이미지가 없으면 오리지널 이미지 처리..
            if ( image == nil )
            {
                image = (UIImage*)[info valueForKey:UIImagePickerControllerOriginalImage];
                imageSize = image.size;
            }
            // 편집된 이미지가 존재하면..
            else
            {
                CGRect rect = [[info valueForKey:UIImagePickerControllerCropRect] CGRectValue];
                imageSize = rect.size;
            }
            //  정리된 이미지 그리기
            [self drawModifyImage:image:imageSize];
        }
        // 동영상...
        else
        {
            [OMMessageBox showAlertMessage:@"" :@"동영상은 편집이 불가능합니다."];
            [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
        }
        
    }
    else
    {
        [OMMessageBox showAlertMessage:@"" :@"올바른 이미지 파일이 아닙니다."];
        [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
    }
}
- (void) drawModifyImage :(UIImage*)sourceImage :(CGSize)sourceImageSize
{
    
    // 클리어
    for (UIView *subview in self.view.subviews)
    {
        [subview removeFromSuperview];
    }
    
    // 사진편집창 영역
    UIView *myImageCropAreaView = [[UIView alloc]
                                   initWithFrame:CGRectMake(0, -20,
                                                            [[UIScreen mainScreen] bounds].size.width,
                                                            [[UIScreen mainScreen] bounds].size.height)];
    [myImageCropAreaView setBackgroundColor:[UIColor blackColor]];
    
    // 원본이미지 회전율 정제
    UIImage *refinedSourceImage = [MyImage rotateWithUp:sourceImage];
    // 원본이미지 사이즈 보정 (한화면에 나오도록.. 이미지가 아닌 이미지뷰에 적용)
    CGSize refinedSourceImageSize = refinedSourceImage.size;
    
    // 320 * 423 crop size
    if ( refinedSourceImageSize.width > 320 )
    {
        float ratio = refinedSourceImageSize.width / 320;
        refinedSourceImageSize.width = refinedSourceImageSize.width / ratio;
        refinedSourceImageSize.height = refinedSourceImageSize.height / ratio;
    }
    if ( refinedSourceImageSize.height > 423)
    {
        float ratio = refinedSourceImageSize.height / 423;
        refinedSourceImageSize.width = refinedSourceImageSize.width / ratio;
        refinedSourceImageSize.height = refinedSourceImageSize.height / ratio;
    }
    
    
    // 하지만... 원본 이미지가 마스크 이미지보다 작을경우 키워주도록 한다.
    // crop in size 230 * 260?
    if ( refinedSourceImageSize.width < 233.5)
    {
        float ratio = 233.5 / refinedSourceImageSize.width;
        refinedSourceImageSize.width *= ratio;
        refinedSourceImageSize.height *= ratio;
    }
    else if ( refinedSourceImageSize.height < 260 )
    {
        float ratio = 260 / refinedSourceImageSize.height;
        refinedSourceImageSize.width *= ratio;
        refinedSourceImageSize.height *= ratio;
    }
    
    // iPhone5 해상도일땐 높이가 더 길어지므로
    
    int retinaY = (IS_4_INCH) ? 148 : 0;

    
    
    // 원본 이미지 좌표 보정 ( 중앙에 오도록..)
    CGPoint refinedSourceImagePoint = {0,0};
    refinedSourceImagePoint.x = (320 - refinedSourceImageSize.width)/2.0f;
    refinedSourceImagePoint.y = (423+ retinaY -refinedSourceImageSize.height)/2.0f;
    
    // 사진들어갈 영역 && 사진회전상태 정제
    [_cropImageView setImage:refinedSourceImage];
    [_cropImageView setFrame: CGRectMake(refinedSourceImagePoint.x, refinedSourceImagePoint.y, refinedSourceImageSize.width, refinedSourceImageSize.height) ];
    [myImageCropAreaView addSubview:_cropImageView];
    
    NSLog(@"%@", NSStringFromCGRect(_cropImageView.frame));
    
    // 마스크 이미지뷰
    // 사이즈
    //  45 81 274 338
    // 3.5인치    : (45, 81), (275, 340) w 230, h 259
    //
    // 3.5인치(R) : (90, 160), (550, 678) w 460, h 518
    // 549 677
    // 4인치(R)   : (90 , 312), (550, 830)  w 460, h 518
    
    
    UIImageView *myImageMaskImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:OM_ImageName(@"img_crop.png", @"img_crop-568h.png")]];
    [myImageCropAreaView addSubview:myImageMaskImageView];
    [myImageMaskImageView release];
    
    // 사진편집창 영역 삽입
    [self.view addSubview:myImageCropAreaView];
    [myImageCropAreaView release];
    
    // 하단버튼 영역
    UIView *myImageBottomButtonsView = [[UIView alloc] initWithFrame:CGRectMake(0,  self.view.frame.size.height-57, 320, 57)];
    [myImageBottomButtonsView setBackgroundColor:[UIColor whiteColor]];
    
    // 적용버튼
    UIButton *applyButton = [[UIButton alloc] initWithFrame:CGRectMake(7, 10, 302/2, 74/2)];
    [applyButton setImage:[UIImage imageNamed:@"img_btn01_default.png"] forState:UIControlStateNormal];
    [applyButton setImage:[UIImage imageNamed:@"img_btn01_pressed.png"] forState:UIControlStateHighlighted];
    [applyButton addTarget:self action:@selector(onApply:) forControlEvents:UIControlEventTouchUpInside];
    [myImageBottomButtonsView addSubview:applyButton];
    [applyButton release];
    
    // 취소버튼
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(324/2, 10, 302/2, 74/2)];
    [cancelButton setImage:[UIImage imageNamed:@"img_btn02_default.png"] forState:UIControlStateNormal];
    [cancelButton setImage:[UIImage imageNamed:@"img_btn02_pressed.png"] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [myImageBottomButtonsView addSubview:cancelButton];
    [cancelButton release];
    
    // 하단버튼 영역 삽입
    [self.view addSubview:myImageBottomButtonsView];
    [myImageBottomButtonsView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [myImageBottomButtonsView release];
}

- (void) onApply :(id)sender
{
    [self createMyImageIconType];
    
    [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"MyImageIndex"];
    [MapContainer refreshMapLocationImage];
}
- (void) createMyImageIconType
{
    
    // 레티나여부
    BOOL isRetina = [OllehMapStatus sharedOllehMapStatus].isRetinaDisplay;
    float ratio = isRetina ? 2.0f : 1.0f;
    
    // 4인치여부
    BOOL isLongDisplay = OM_IsLongDisplay;
    
    // =============================
    // 마스크 이미지
    // =============================
    UIImage *maskImage = [UIImage imageNamed:OM_ImageName(@"img_crop_mask.png", @"img_crop_mask-568h.png")];
    
    // =============================
    // 베이스 이미지
    // =============================
    UIImage *baseImage = nil;
    // 이미지뷰에 표현된 이미지를 비트맵 컨텍스트에 좌표 맞춰서 그리기
    if ( !isLongDisplay )
        UIGraphicsBeginImageContext(CGSizeMake(320,423));
    else
        UIGraphicsBeginImageContext(CGSizeMake(320,1136/2));
    [_cropImageView.image drawInRect:_cropImageView.frame];
    baseImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    // =============================
    // 썸네일 이미지
    // =============================
    
    // 마스크 적용이전.. 썸네일 생성 (**레티나 여부 상관없이 동일한 사이즈로 넉넉하게 생성하자)
    UIImage *thumnailImage = [MyImage imageByCropping:baseImage toRect:CGRectMake(43, isLongDisplay ? 94+44 : 94, 235.5, 235.5)];
    // 썸네일 이미지 사이즈 조절
    thumnailImage = [MyImage resizeImage:thumnailImage width:65*ratio height:65*ratio];
    
    
    // == ===========================
    // 내이미지
    // =============================
    // 3.5인치    : (45, 81), (275, 340) w 230, h 259
    // 3.5인치(R) : (90, 160), (550, 678) w 460, h 518
    // 4인치(R)   : (90 , 312), (550, 830)  w 460, h 518
    // 마스크 이미지 적용
    UIImage *maskedImage = [MyImage mask:baseImage :maskImage];
    
    // 최종 마스킹 처리된 이미지에서 적당량 덜어내기 (94+44)
    UIImage *cropedMaskedImage = [MyImage imageByCropping:maskedImage toRect:CGRectMake(44, isLongDisplay ? 154 : 80, 230, 260)];
    
    //UIImage *cropedMaskedImage = [self maskImage:thumnailImage withMask:[UIImage imageNamed:@"last_img_crop_mask.png"]];
    
    // 230, 260은 마스크 사이즈 너비높이
    //UIImage *cropedMaskedImage = [MyImage imageByCropping:maskedImage toRect:CGRectMake(44, 107, 230, 260)];
    
    
    
    // 덜어낸 이미지를 마이이미지 사이즈에 맞추기
    //CGSize lastSize = CGSizeMake(37*ratio, 37*ratio);
    // MIK.geun :: 20121008 // 가이드상 37에 맞추면 실제 화면에서 하단이 약간 부족해보이는 현상,, 사이즈를 38로 늘려잡음..
    CGSize lastSize = CGSizeMake(39*ratio, 43*ratio);
    // 리사이징
    UIImage *resizingLastImage = [MyImage resizeImage:cropedMaskedImage width:lastSize.width height:lastSize.height];
    
    
    // =============================
    // 이미지 파일 처리
    // =============================
    
    // Documents 경로생성
	NSArray *documentsDirecotryPathArray = NSSearchPathForDirectoriesInDomains(
                                                                               NSDocumentDirectory,
                                                                               NSUserDomainMask,
                                                                               YES);
    // 내이미지 파일 경로
    NSString *documentImageFilePath = [NSString stringWithFormat:@"%@/MyImage%@.PNG", [documentsDirecotryPathArray objectAtIndexGC:0], isRetina ? @"@2x" : @""];
    // 썸네일이미지 파일 경로
    NSString *documentThumnailFilePath = [NSString stringWithFormat:@"%@/MyImageThumnail%@.PNG", [documentsDirecotryPathArray objectAtIndexGC:0], isRetina ? @"@2x" : @""];
    
    // 임시폴더 경로
    NSString *tempImageFilePath = [NSString stringWithFormat:@"%@/MyImage.PNG", NSTemporaryDirectory()];
    NSString *tempThumnailFilePath = [NSString stringWithFormat:@"%@/MyImageThumnail.PNG", NSTemporaryDirectory()];
    
    // 임시폴더에 파일 저장
    NSData *myImageData = [NSData dataWithData:UIImagePNGRepresentation(resizingLastImage)];
    [myImageData writeToFile:tempImageFilePath atomically:YES];
    NSData *thumnailImageData = [NSData dataWithData:UIImagePNGRepresentation(thumnailImage)];
    [thumnailImageData writeToFile:tempThumnailFilePath atomically:YES];
    
    // test
    // masked폴더에 파일 저장
//    NSString *maskFilePath = [NSString stringWithFormat:@"%@/mask.PNG", [documentsDirecotryPathArray objectAtIndexGC:0]];
//    NSData *mskedImageData = [NSData dataWithData:UIImagePNGRepresentation(maskedImage)];
//    [mskedImageData writeToFile:maskFilePath atomically:YES];
//    
//    // cropmasked폴더에 파일 저장
//    NSString *cropmaskFilePath = [NSString stringWithFormat:@"%@/cropmask.PNG", [documentsDirecotryPathArray objectAtIndexGC:0]];
//    NSData *cropmaskedImageData = [NSData dataWithData:UIImagePNGRepresentation(cropedMaskedImage)];
//    [cropmaskedImageData writeToFile:cropmaskFilePath atomically:YES];
    
    NSError *copyError = nil;
    // 도큐먼트 파일 삭제
    if ( [[NSFileManager defaultManager] fileExistsAtPath:documentImageFilePath]  && ! [[NSFileManager defaultManager] removeItemAtPath:documentImageFilePath error:&copyError] )
    {
        [OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@", copyError]];
    }
    // 임시파일 도큐먼트로 복사
    else if ( ! [[NSFileManager defaultManager] copyItemAtPath:tempImageFilePath toPath:documentImageFilePath error:&copyError] )
    {
        [OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@", copyError]];
    }
    // 임시파일 삭제
    else if (  ! [[NSFileManager defaultManager] removeItemAtPath:tempImageFilePath error:&copyError] )
    {
        [OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@", copyError]];
    }
    // 썸네일 도큐먼트 파일 삭제
    else if ( [[NSFileManager defaultManager] fileExistsAtPath:documentThumnailFilePath]  && ! [[NSFileManager defaultManager] removeItemAtPath:documentThumnailFilePath error:&copyError] )
    {
        [OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@", copyError]];
    }
    // 썸네일 임시파일 도큐먼트로 복사
    else if ( ! [[NSFileManager defaultManager] copyItemAtPath:tempThumnailFilePath toPath:documentThumnailFilePath error:&copyError] )
    {
        [OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@", copyError]];
    }
    // 썸네일 임시파일 삭제
    else if (  ! [[NSFileManager defaultManager] removeItemAtPath:tempThumnailFilePath error:&copyError] )
    {
        [OMMessageBox showAlertMessage:@"" :[NSString stringWithFormat:@"%@", copyError]];
    }
    // 여기까지와서 모두 성공
    else
    {
        // 창을 닫자~~
        [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
    }
    
}

- (void) onCancel :(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}


// 제스쳐 핸들러

- (void) handleTapGesture :(UITapGestureRecognizer*)recognizer
{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, 2.0f, 2.0f);
}

- (void) handlePinchGesture :(UIPinchGestureRecognizer*)recognizer
{
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    
    
    // 3.5인치    : (45, 81), (275, 340) w 230, h 259
    // 3.5인치(R) : (90, 160), (550, 678) w 460, h 518
    // 4인치(R)   : (90 , 312), (550, 830)  w 460, h 518
    
    // 제스쳐가 끝났을 때 변경된 이미지뷰의 사이즈가 허용범위내에 있는지 확인
    if ( recognizer.state == UIGestureRecognizerStateEnded )
    {
        CGRect viewFrame = recognizer.view.frame;
        // 기준범위보다 작을 경우..
        if ( viewFrame.size.width < 233.5 || viewFrame.size.height < 259 )
        {
            // 넓이 수정
            float ratio = 259 / MIN(viewFrame.size.width, viewFrame.size.height);
            viewFrame.size.width *= ratio;
            viewFrame.size.height *= ratio;
            // 좌표 고정
            viewFrame.origin.x = 45;
            viewFrame.origin.y = 80;
            // 이미지뷰 프레임 보정
            [recognizer.view setFrame:viewFrame];
        }
    }
}

- (void) handlePanGesture :(UIPanGestureRecognizer*)recognizer
{
    // 3.5인치    : (45, 81), (275, 340) w 230, h 259
    // 3.5인치(R) : (90, 160), (550, 678) w 460, h 518
    // 4인치(R)   : (90 , 312), (550, 830)  w 460, h 518
    int y= 80;
    if(OM_IsLongDisplay)
    {
        y = 156;
    }
    
    // 현재
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    
    // 제스쳐가 끝났을 때 이동한 이미지뷰의 위치가 허용범위 내에 있는지 체크
    if (recognizer.state == UIGestureRecognizerStateEnded )
    {
        CGRect viewFrame = recognizer.view.frame;
        KBounds viewBorder = BoundsMake(viewFrame.origin.x, viewFrame.origin.y, viewFrame.origin.x+viewFrame.size.width, viewFrame.origin.y+viewFrame.size.height);
        
        // 좌측 보정
        if ( viewBorder.minX > 43 )
        {
            viewFrame.origin.x = 43;
        }
        // 상단 보정
        if ( viewBorder.minY > y )
        {
            viewFrame.origin.y = y;
        }
        // 우측 보정
        if ( viewBorder.maxX < 43+233.5 )
        {
            viewFrame.origin.x = 43 + 233.5 - viewFrame.size.width;
        }
        // 하단 보정
        if ( viewBorder.maxY < y+259 )
        {
            viewFrame.origin.y = y + 259 - viewFrame.size.height;
        }
        
        [recognizer.view setFrame:viewFrame];
        
    }
    // 이미지 좌표 변경적용
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

@end

