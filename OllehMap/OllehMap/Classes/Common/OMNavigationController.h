//
//  OMNavigationController.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 7..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OMClassCategory.h"

#import "OllehMapStatus.h"
#import "OMMessageBox.h"

typedef enum  {
    NavigationViewAction_none = 0,
    NavigationViewAction_push = 1,
    NavigationViewAction_pop = 2
} NavigationViewAction;

@interface OMNavigationController : UINavigationController <UINavigationControllerDelegate, UINavigationBarDelegate>
{
    NavigationViewAction _lastNavigationViewAction;
}
@property (readonly) NavigationViewAction lastNavigationViewAction;

// ============================================
// [ Custom NavigationController class method ]
// ============================================
+ (OMNavigationController *) sharedNavigationController;
+ (OMNavigationController *) setNavigationController :(UIViewController *)vc;
+ (void) closeNavigationController;
// ********************************************

// 상태 확인 메소드
- (int) getBusStationAndLineCount;

@end
