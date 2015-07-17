//
//  lawNoticeViewController.m
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 6..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "lawNoticeViewController.h"

@interface lawNoticeViewController ()

@end

@implementation lawNoticeViewController
@synthesize webViewer = _webViewer;

- (void)dealloc
{
    [_webViewer release];
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
    [self setWebViewer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // MIK.geun :: 20121116 // 캐시사용안함으로 정책수정
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/setting/iphone/notice.html", COMMON_SERVER_IP]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [self.webViewer loadRequest:urlRequest];
    
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
