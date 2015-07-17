//
//  ImproveProposeViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 9. 18..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "ImproveProposeViewController.h"

@interface ImproveProposeViewController ()

@end

@implementation ImproveProposeViewController
@synthesize webView;
- (void)dealloc
{
    [webView release];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    
    NSString *phoneUniqueId = [nd objectForKeyGC:@"PhoneUniqueId"];
    
    // MIK.geun :: 20121116 // 캐시사용안함으로 정책수정
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@/mobile/fr/web/fr01_list.asp?R_app_id=%@&R_phone_num=%@", vocIP, appId, phoneUniqueId]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [self.webView loadRequest:urlRequest];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (IBAction)popBtnClick:(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [[OMIndicator sharedIndicator] startAnimating];
}
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [[OMIndicator sharedIndicator] stopAnimating];
}
@end
