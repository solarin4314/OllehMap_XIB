//
//  HelperViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 6..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMMessageBox.h"
#import "OMNavigationController.h"
#import "ServerConnector.h"

@interface HelperViewController : UIViewController<UIWebViewDelegate>

{
    UIWebView *_webVIewer;
}

@property (retain, nonatomic) IBOutlet UIWebView *webVIewer;

- (IBAction)popBtnClick:(id)sender;

@end
