//
//  AppDelegate.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 17..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

// iOS SDK 기본 참조
#import <UIKit/UIKit.h>
// 공통/데이터 참조
#import "OllehMapStatus.h"
// 화면 참조
#import "MainMapViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MainMapViewController *_vcMainMap;
    
    UIWindow *_winDebugMemoryChecker;
    UILabel *_lblDebugMemoryChecker;
    
    
    
}

@property (retain, nonatomic) UIWindow *window;

@end

