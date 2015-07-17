//
//  MyImageModifyViewController.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 9. 26..
//
//

#import "MyImageModifyViewController.h"

#import "MyImage.h"

#import "OMNavigationController.h"
#import "OllehMapStatus.h"
#import "OMCustomView.h"
#import "OMMessageBox.h"
#import "MapContainer.h"
#import "OMIndicator.h"

@interface MyImageModifyViewController ()
{
    NSInteger _selectedImageIndex;
}

@end

@implementation MyImageModifyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        _selectedImageIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"MyImageIndex"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self redrawAllObjects];
}



- (void) redrawAllObjects
{
    for (UIView *subview in self.view.subviews)
    {
        [subview removeFromSuperview];
    }
    
    [self renderNavigation];
    [self renderBasicDecoration];
}

- (void) renderNavigation
{
    // 네비게이션 뷰 생성
    UIView *vwNavigation = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 37)];
    
    // 배경 이미지
    UIImageView *imgvwBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_bg.png"]];
    [vwNavigation addSubview:imgvwBack];
    [imgvwBack release];
    
    // 취소버튼
    UIButton *btnPrev = [[UIButton alloc] initWithFrame:CGRectMake(7, 4, 47, 28)];
    [btnPrev setImage:[UIImage imageNamed:@"title_bt_cancel.png"] forState:UIControlStateNormal];
    [btnPrev addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [vwNavigation addSubview:btnPrev];
    [btnPrev release];
    
    // 완료버튼
    UIButton *btnApply = [[UIButton alloc] initWithFrame:CGRectMake(271, 4, 47, 28)];
    [btnApply setImage:[UIImage imageNamed:@"title_btn_finish.png"] forState:UIControlStateNormal];
    [btnApply addTarget:self action:@selector(onApply:) forControlEvents:UIControlEventTouchUpInside];
    [vwNavigation addSubview:btnApply];
    [btnApply release];
    
    
    // 타이틀 그림자
    UILabel *lblTitleShadow = [[UILabel alloc] initWithFrame:CGRectMake(61, (37-20)/2+2, 198, 20)];
    [lblTitleShadow setFont:[UIFont systemFontOfSize:20]];
    [lblTitleShadow setTextColor:convertHexToDecimalRGBA(@"00", @"00", @"00", 0.75f)];
    [lblTitleShadow setBackgroundColor:[UIColor clearColor]];
    [lblTitleShadow setTextAlignment:NSTextAlignmentCenter];
    [lblTitleShadow setText:@"기본 이미지 설정"];
    [vwNavigation addSubview:lblTitleShadow];
    [lblTitleShadow release];
    
    // 타이틀
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(61, (37-20)/2, 198, 20)];
    [lblTitle setFont:[UIFont systemFontOfSize:20]];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setBackgroundColor:[UIColor clearColor]];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setText:@"기본 이미지 설정"];
    [vwNavigation addSubview:lblTitle];
    [lblTitle release];
    
    // 네비게이션 뷰 삽입
    [self.view addSubview:vwNavigation];
    [vwNavigation release];
}

- (void) renderBasicDecoration
{
    // ==============
    // Description Area
    // ==============
    
    UIView *descriptionAreaView = [[UIView alloc] initWithFrame:CGRectMake(0, 37, 320, 90)];
    
    // 섬네일뷰 버튼
    for (int i=0, maxi=3; i<=maxi; i++)
    {
        if ( _selectedImageIndex == i )
        {
            UIImage *myImageThumnailSelected = [UIImage imageNamed:@"my_img_pressed.png"];
            UIImageView *myImageThumnailBackgroundImageView = [[UIImageView alloc] initWithImage:myImageThumnailSelected];
            [myImageThumnailBackgroundImageView setFrame:CGRectMake(4 + 78*i, 6, 77, 78)];
            [descriptionAreaView addSubview:myImageThumnailBackgroundImageView];
            [myImageThumnailBackgroundImageView release];
        }
        UIButton *myImageThumnailButton = [[UIButton alloc] initWithFrame:CGRectMake( 10 + 78*i , 13, 130/2, 130/2)];
        UIImage *myImageThumnail = [UIImage imageNamed:[NSString stringWithFormat:@"my_img_default_0%d.png", i+1]];
        [myImageThumnailButton setImage:myImageThumnail forState:UIControlStateNormal];
        [myImageThumnailButton setTag:i];
        [myImageThumnailButton addTarget:self action:@selector(onMyDefaultImage:) forControlEvents:UIControlEventTouchUpInside];
        [descriptionAreaView addSubview:myImageThumnailButton];
        [myImageThumnailButton release];
    }
    
    [self.view addSubview:descriptionAreaView];
    [descriptionAreaView release];
    
    
    // ================
    // 미리보기 영역
    // ================
    
    UIView *previewAreaView = [[UIView alloc]
                               initWithFrame:CGRectMake(0, 37+90,
                                                        [UIScreen mainScreen].bounds.size.width,
                                                        [UIScreen mainScreen].bounds.size.height - 127)];
    // 지도
    NSString *previewMapImageName;
    UIImageView *previewMapImageView;
    
    if (IS_4_INCH)  previewMapImageName = @"preview_map-568h.png";
    else            previewMapImageName = @"preview_map.png";
    
    previewMapImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:previewMapImageName]];
    
    [previewAreaView addSubview:previewMapImageView];
    [previewMapImageView release];
    
    // 미리보기 타이틀 이미지
    UIImageView *previewMapTitleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"preview_img.png"]];
    [previewMapTitleImageView setFrame:CGRectMake(0, 0, 320, 35)];
    [previewAreaView addSubview:previewMapTitleImageView];
    [previewMapTitleImageView release];
    
    // 내이미지 아이콘
    UIImage *myImageIconImage = [MyImage merge: [UIImage imageNamed:[NSString stringWithFormat:@"map_location_default_0%d.png", _selectedImageIndex+1]] ];
    UIImageView *myImageIconImageView = [[UIImageView alloc]  initWithImage:myImageIconImage];
    [myImageIconImageView setFrame:CGRectMakeInteger(258/2, 216/2, myImageIconImage.size.width, myImageIconImage.size.height)];
    //[myImageIconImageView setFrame:CGRectMake(129, 108, myImageIconImage.size.width, myImageIconImage.size.height)];
    [previewAreaView addSubview:myImageIconImageView];
    [myImageIconImageView release];
    
    [self.view addSubview:previewAreaView];
    [previewAreaView release];
    
}

- (void) onClose :(id)sender
{
    // 창닫기
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

- (void) onApply :(id)sender
{
    // 창닫기 전에 변경된 이미지 처리
    if ( _selectedImageIndex != [[NSUserDefaults standardUserDefaults] integerForKey:@"MyImageIndex"] )
    {
        [[NSUserDefaults standardUserDefaults] setInteger:_selectedImageIndex forKey:@"MyImageIndex"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[OMIndicator sharedIndicator] startAnimating];
        [MapContainer refreshMapLocationImage];
        [[OMIndicator sharedIndicator] forceStopAnimation];
    }
    // 창닫기
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

- (void) onMyDefaultImage :(id)sender
{
    UIButton *imageButton  = (UIButton*)sender;
    
    //[[NSUserDefaults standardUserDefaults] setInteger:imageButton.tag forKey:@"MyImageIndex"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    _selectedImageIndex = imageButton.tag;
    
    [self redrawAllObjects];
}

@end
