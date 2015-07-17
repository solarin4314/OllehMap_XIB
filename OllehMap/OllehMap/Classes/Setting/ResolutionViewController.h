//
//  ResolutionViewController.h
//  OllehMap
//
//  Created by 이 제민 on 12. 7. 5..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMMessageBox.h"
#import "OMNavigationController.h"
#include <sys/sysctl.h>

// iPhone 5
#import "uiviewcontroller+is4inch.h"

@interface ResolutionViewController : UIViewController
{
    NSInteger _viewStartY;
    
    int _case;
    
    UIImageView *_hdImg;
    UIImageView *_smallImg;
    UIImageView *_bigImg;
    
    UIButton *_hdBtn;
    UIButton *_smallBtn;
    UIButton *_bigBtn;
    
    
    
}

- (IBAction)popBtnClick:(id)sender;


@property (nonatomic, retain) UIButton *hdBtn;
@property (nonatomic, retain) UIButton *smallBtn;
@property (nonatomic, retain) UIButton *bigBtn;


@end
