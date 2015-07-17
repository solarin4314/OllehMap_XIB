//
//  VersionInfoViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 2..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "VersionInfoViewController.h"

@interface VersionInfoViewController ()

@end

@implementation VersionInfoViewController
@synthesize ollehLogo = _ollehLogo;
@synthesize thisVersion = _thisVersion;
@synthesize recentVersion = _recentVersion;
@synthesize updateButton  = _updateButton;
@synthesize lawNoticeButton = _lawNoticeButton;
@synthesize serviceRuleButton = _serviceRuleButton;
@synthesize infoSupportButton = _infoSupportButton;
@synthesize ktLogo = _ktLogo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc
{
    [_ollehLogo release]; _ollehLogo = nil;
    [_thisVersion release]; _thisVersion = nil;
    [_recentVersion release]; _recentVersion = nil;
    [_updateButton release];_updateButton = nil;
    [_lawNoticeButton release]; _lawNoticeButton = nil;
    [_serviceRuleButton release]; _serviceRuleButton = nil;
    [_infoSupportButton release]; _infoSupportButton = nil;
    [_ktLogo release]; _ktLogo = nil;
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidUnload
{
    [self setOllehLogo:nil];
    [self setThisVersion:nil];
    [self setRecentVersion:nil];
    [self setUpdateButton:nil];
    [self setLawNoticeButton:nil];
    [self setServiceRuleButton:nil];
    [self setInfoSupportButton:nil];
    [self setKtLogo:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self drawVersionInfoView];
    
    
//    if (IS_4_INCH)
//    {
//        int uiMarginTop = 43;
//        
//        [_ollehLogo setFrame:CGRectMake(84, 89 + uiMarginTop, 152, 41)];
//        [_thisVersion setFrame:CGRectMake(0, 143 + uiMarginTop, 320, 21)];
//        [_recentVersion setFrame:CGRectMake(0, 164 + uiMarginTop, 320, 21)];
//        [_updateButton setFrame:CGRectMake(60, 227 + uiMarginTop, 200, 38)];
//        [_lawNoticeButton setFrame:CGRectMake(60, 271 + uiMarginTop, 200, 38)];
//        [_serviceRuleButton setFrame:CGRectMake(60, 315 + uiMarginTop, 200, 38)];
//        [_infoSupportButton setFrame:CGRectMake(60, 359 + uiMarginTop, 200, 38)];
//        [_ktLogo setFrame:CGRectMake(0, 417 + uiMarginTop + 35, 320, 15)];
//    }
    
    
    // Do any additional setup after loading the view from its nib.
}
- (void) drawVersionInfoView
{
    // plist 에서 빌드 버전 정보 가져오기
    NSString *versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    if ([versionStr isEqualToString:@""] || versionStr == nil)
    {
        [_thisVersion setText:[NSString stringWithFormat:@""]];
    } else {
        [_thisVersion setText:[NSString stringWithFormat:@"현재 버전 Ver.%@", versionStr]];
    }
    
    [[ServerConnector sharedServerConnection] requestAppVersion:self action:@selector(finishAppVersionCallBack:)];
}

- (void) finishAppVersionCallBack:(id)request
{
    
    if([request finishCode] == OMSRFinishCode_Completed)
    {
        //NSString *versionStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        
        OllehMapStatus *oms = [OllehMapStatus sharedOllehMapStatus];
        
        NSString *deviceVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
        
        NSArray *deviceVersionArray = [deviceVersion componentsSeparatedByString:@"."];
        NSString *deviceVersionMajor = [deviceVersionArray objectAtIndexGC:0];
        NSString *deviceVersionMinor = [deviceVersionArray objectAtIndexGC:1];
        NSString *deviceVersionBuild = [deviceVersionArray objectAtIndexGC:2];
        
        NSString *recentVersionMajor = [[oms.appVersionDictionary objectForKeyGC:@"VERSION"] objectForKeyGC:@"majorVersion"];
        NSString *recentVersionMinor = [[oms.appVersionDictionary objectForKeyGC:@"VERSION"] objectForKeyGC:@"minorVersion"];
        NSString *recentVersionBuild = [[oms.appVersionDictionary objectForKeyGC:@"VERSION"] objectForKeyGC:@"buildVersion"];
        NSString *recentVersion = [NSString stringWithFormat:@"%@.%@.%@", recentVersionMajor, recentVersionMinor, recentVersionBuild];
        
        [_recentVersion setText:[NSString stringWithFormat:@"최신 버전 Ver.%@", recentVersion]];
        
        int deviceVersionValue = [deviceVersionMajor intValue] * 100000 + [deviceVersionMinor intValue] * 1000 + [deviceVersionBuild intValue] * 1;
        int recentVersionValue = [recentVersionMajor intValue] * 100000 + [recentVersionMinor intValue] * 1000 + [recentVersionBuild intValue] * 1;
        BOOL requireUpdate = recentVersionValue > deviceVersionValue;
        
        // 업데이트가 필요한 경우
        if ( requireUpdate )
        {
            [self.updateButton setEnabled:YES];
        }
        else
        {
            [self.updateButton setEnabled:NO];
        }
        
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Msg_SearchFailedWithRetry", @"") delegate:self cancelButtonTitle:@"아니오" otherButtonTitles:@"예", nil];
        
        [alert setTag:1];
        [alert show];
        [alert release];
    }
    
}

- (IBAction)popBtnClick:(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

- (IBAction)versionUpateBtnClick:(id)sender
{
    //[OMMessageBox showAlertMessage:@"최신버전" :@"업데이트"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL]];
}
// 법적공지
- (IBAction)lawNoticeClick:(id)sender
{
    if ([[OllehMapStatus sharedOllehMapStatus] getNetworkStatus] == OMReachabilityStatus_disconnected )
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    else
    {
        lawNoticeViewController *lnvc = [[lawNoticeViewController alloc] initWithNibName:@"lawNoticeViewController" bundle:nil];
        
        [[OMNavigationController sharedNavigationController] pushViewController:lnvc animated:NO];
        
        [lnvc release];
    }
}
// 이용약관
- (IBAction)serviceRuleClick:(id)sender
{
    if ([[OllehMapStatus sharedOllehMapStatus] getNetworkStatus] == OMReachabilityStatus_disconnected )
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    else
    {
        
        
        ServiceRuleViewController *srvc = [[ServiceRuleViewController alloc] initWithNibName:@"ServiceRuleViewController" bundle:nil];
        
        [[OMNavigationController sharedNavigationController] pushViewController:srvc animated:NO];
        
        [srvc release];
    }
}
// 정보제공처
- (IBAction)infoSupportClick:(id)sender
{
    if ([[OllehMapStatus sharedOllehMapStatus] getNetworkStatus] == OMReachabilityStatus_disconnected )
    {
        [OMMessageBox showAlertMessage:@"" :NSLocalizedString(@"Msg_SearchFailedWithException", @"")];
    }
    else
    {
        
        
        InfoSupportViewController *isvc = [[InfoSupportViewController alloc] initWithNibName:@"InfoSupportViewController" bundle:nil];
        
        [[OMNavigationController sharedNavigationController] pushViewController:isvc animated:NO];
        
        [isvc release];
    }
    
}

- (IBAction)cadastralLimitClick:(id)sender
{
    CadastralLimitViewController *clc = [[CadastralLimitViewController alloc] initWithNibName:@"CadastralLimitViewController" bundle:nil];
    
    [[OMNavigationController sharedNavigationController] pushViewController:clc animated:NO];
    [clc release];
}

#pragma mark -
#pragma mark AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(alertView.tag == 1)
    {
        if(buttonIndex == 1)
        {
            [self drawVersionInfoView];
        }
    }
}



@end
