//
//  NoticeListViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 10..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OllehMapStatus.h"
#import "OMNavigationController.h"
#import "ServerConnector.h"
#import "NoticeDetailViewController.h"
#import "DbHelper.h"
#import "SettingViewController2.h"
@interface NoticeListViewController : UIViewController
{
    UIScrollView *_scrollView;
    NSMutableArray *_notiArr;
    
    NSInteger _scrollViewHeight;
}

- (IBAction)popBtnClick:(id)sender;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;


@end
