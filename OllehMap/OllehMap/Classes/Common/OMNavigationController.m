//
//  OMNavigationController.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 7..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "OMNavigationController.h"
#import <AddressBookUI/AddressBookUI.h>

// 버스 정류장/노선도 화면 카운트용 첨부
#import "BusNumberLineViewController.h"
#import "BusStationDetailViewController.h"


@interface OMNavigationController ()

@end

@implementation OMNavigationController
@synthesize lastNavigationViewAction = _lastNavigationViewAction;

- (id) initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if ( self )
    {
        [self initComponent];
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        [self initComponent];
    }
    return self;
}
- (void) initComponent
{
    _lastNavigationViewAction = NavigationViewAction_none;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // MIK.geun :: 20120605
    // 기본적으로 네비게이션바를 사용하지 않지만, 특별한 경우에 한해서는 나타나도록 조정한다.
    
    
    // 주소록일 경우 기본네비게이션바 사용
    if ([[[self viewControllers] objectAtIndexGC:self.viewControllers.count-1] isKindOfClass:[ABNewPersonViewController class]])
        [self setNavigationBarHidden:NO];
    // 공통적으로 기본네비게이션바 숨김
    else
        [self setNavigationBarHidden:YES];
}


- (void) dealloc
{
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    // 마지막 네비게이션 액션을 저장
    _lastNavigationViewAction = NavigationViewAction_push;
    
    // 화면 푸시하기전에 (버스정류장/버스노선도)인 경우 미리 카운트 체크를 한다.
    if ( [viewController isKindOfClass:[BusStationDetailViewController class]]
        || [viewController isKindOfClass:[BusNumberLineViewController class]] )
    {
        if ( [self getBusStationAndLineCount] >= 10 )
        {
            [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_Navigation_Push_Failed_BusStationLineOverMax", @"")];
            
            
            if ( [viewController isKindOfClass:[BusStationDetailViewController class]])
            {
                [[OllehMapStatus sharedOllehMapStatus].pushDataBusNumberArray removeLastObject];
            }
            else if ([viewController isKindOfClass:[BusNumberLineViewController class]])
            {
                [[OllehMapStatus sharedOllehMapStatus].pushDataBusStationArray removeLastObject];
                
                
            }
            return;
        }
    }
    
    if (animated)
    {
        [OMMessageBox showAlertMessage:@"" :@"화면전환 애니메이션이 적용되어 있습니다. 오류사항으로 알려주시기바랍니다."];
        animated = NO;
    }
    
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[OMNavigationController sharedNavigationController].view cache:NO];
    }
    
    [super pushViewController:viewController animated:NO];
    
    if (animated) [UIView commitAnimations];
}
- (UIViewController *) popViewControllerAnimated:(BOOL)animated
{
    
    // 마지막 네비게이션 액션을 저장
    _lastNavigationViewAction = NavigationViewAction_pop;
    
    if (animated)
    {
        [OMMessageBox showAlertMessage:@"" :@"화면전환 애니메이션이 적용되어 있습니다. 오류사항으로 알려주시기바랍니다."];
        animated = NO;
    }
    
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[OMNavigationController sharedNavigationController].view cache:NO];
    }
    
    UIViewController *vc = [super popViewControllerAnimated:NO];
    
    if (animated) [UIView commitAnimations];
    
    return vc;
}
- (NSArray *) popToRootViewControllerAnimated:(BOOL)animated
{
    if (animated)
    {
        [OMMessageBox showAlertMessage:@"" :@"화면전환 애니메이션이 적용되어 있습니다. 오류사항으로 알려주시기바랍니다."];
        animated = NO;
    }
    
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[OMNavigationController sharedNavigationController].view cache:NO];
    }
    
    NSArray *arr = [super popToRootViewControllerAnimated:NO];
    
    if (animated) [UIView commitAnimations];
    
    return arr;
}
- (NSArray *) popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (animated)
    {
        [OMMessageBox showAlertMessage:@"" :@"화면전환 애니메이션이 적용되어 있습니다. 오류사항으로 알려주시기바랍니다."];
        animated = NO;
    }
    
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[OMNavigationController sharedNavigationController].view cache:NO];
    }
    
    NSArray *arr = [super popToViewController:viewController animated:NO];
    
    if (animated) [UIView commitAnimations];
    
    return arr;
}




// ============================================
// [ Custom NavigationController class method ]
// ============================================

static OMNavigationController * _Instance = nil;
+ (OMNavigationController *) sharedNavigationController
{
    if (_Instance == nil)
    {
        _Instance = [[OMNavigationController alloc] init];
    }
    
    return _Instance;
}
+ (OMNavigationController *) setNavigationController:(UIViewController *)vc
{
    if (_Instance != nil)
    {
        [_Instance release];
        _Instance = nil;
    }
    
    _Instance = [[OMNavigationController alloc] initWithRootViewController:vc];
    return _Instance;
}

+ (void) closeNavigationController
{
    [_Instance release];
    _Instance = nil;
}

// ********************************************


// 상태 확인 메소드
- (int) getBusStationAndLineCount
{
    int count = 0;
    for (UIViewController *view in self.viewControllers)
    {
        if ( [view isKindOfClass:[BusStationDetailViewController class]] ) count++;
        else if ( [view isKindOfClass:[BusNumberLineViewController class]] ) count++;
    }
    return count;
}

@end
