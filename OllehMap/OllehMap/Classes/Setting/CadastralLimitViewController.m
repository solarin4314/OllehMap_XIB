//
//  CadastralLimitViewController.m
//  OllehMap
//
//  Created by 이제민 on 13. 9. 5..
//
//

#import "CadastralLimitViewController.h"

@interface CadastralLimitViewController ()

@end

@implementation CadastralLimitViewController
@synthesize webView = _webView;

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
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/setting/iphone/cadastral.html", COMMON_SERVER_IP]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    [self.webView loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_webView release];
    [super dealloc];
}
- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
}
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [[OMIndicator sharedIndicator] startAnimating];
}
- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [[OMIndicator sharedIndicator] stopAnimating];
}
- (IBAction)popBtnClick:(id)sender
{
    [[OMNavigationController sharedNavigationController] popViewControllerAnimated:NO];
}
@end
