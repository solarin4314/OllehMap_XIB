//
//  lawNoticeViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 6..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMNavigationController.h"
#import "ServerConnector.h"
@interface lawNoticeViewController : UIViewController<UIWebViewDelegate>
{
    UIWebView *_webViewer;
}
- (IBAction)popBtnClick:(id)sender;

@property (retain, nonatomic) IBOutlet UIWebView *webViewer;


@end
