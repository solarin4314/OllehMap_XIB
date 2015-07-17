//
//  CadastralLimitViewController.h
//  OllehMap
//
//  Created by 이제민 on 13. 9. 5..
//
//

#import <UIKit/UIKit.h>
#import "OMNavigationController.h"
#import "ServerConnector.h"
@interface CadastralLimitViewController : UIViewController<UIWebViewDelegate>
{
    UIWebView *_webView;
}
@property (retain, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)popBtnClick:(id)sender;

@end
