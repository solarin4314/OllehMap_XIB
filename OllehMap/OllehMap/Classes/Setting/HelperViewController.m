//
//  HelperViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 6..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "HelperViewController.h"

@interface HelperViewController ()

@end

@implementation HelperViewController

@synthesize webVIewer = _webVIewer;

- (void)dealloc
{
    [_webVIewer release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
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
    [self setWebVIewer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // MIK.geun :: 20121116 // 도움말 웹뷰 캐시정책 수정 ==> 캐시사용안함.
    //NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/setting/iphone/help.html", COMMON_SERVER_IP]]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/setting/iphone/help.html", COMMON_SERVER_IP]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [self.webVIewer loadRequest:urlRequest];
}

- (IBAction)popBtnClick:(id)sender
{
    // 현재 URL 이 Home이 아니면, 뒤로가기 버튼이 웹뷰 뒤로가기
    
    NSString *currentURL = _webVIewer.request.URL.absoluteString;
    
    NSLog(@"현재URL : %@", currentURL);
    if([currentURL isEqualToString:[NSString stringWithFormat:@"http://%@/setting/iphone/help.html", COMMON_SERVER_IP]])
    {
        [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
    }
    else
    {
        [_webVIewer goBack];
    }
    
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
