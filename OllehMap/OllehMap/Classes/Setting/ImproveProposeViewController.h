//
//  ImproveProposeViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 9. 18..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMNavigationController.h"
#import "ServerConnector.h"

#define vocIP @"app.voc.olleh.com:442"

@interface ImproveProposeViewController : UIViewController<UIWebViewDelegate>

@property (retain, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)popBtnClick:(id)sender;

@end
