//
//  NoticeDetailViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 11..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMNavigationController.h"
#import "NoticeListViewController.h"
@interface NoticeDetailViewController : UIViewController
{
    UIScrollView *_scrollView;
    
    NSInteger _viewStartY;
    
    
}

- (IBAction)popBtnClick:(id)sender;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@end
