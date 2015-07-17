//
//  SearchRouteDialogViewController.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 7..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OMNavigationController.h"
#import "OMDimmedView.h"
#import "OMMessageBox.h"
#import "SearchRouteExecuter.h"
#import "MapContainer.h"

@interface SearchRouteDialogViewController :NSObject
{
    // 딤드창
    UIControl *_vwSearchRouteContainer;
    
    // 검색 다이얼로그 그룹
    UIView *_vwSearchRouteDialog;
    UIImageView *_imgvwSearchRouteDialogBackground;
    
    // 출발지
    UILabel *_lblStart;
    
    // 경유지
    UIImageView *_imgvwVisitBackground;
    UIImageView *_imgvwVisitIcon;
    UILabel *_lblVisitTitle;
    UILabel *_lblVisit;
    UIButton *_btnVisitAddRemoveButton;
    
    // 도착지
    UILabel *_lblDest;
    
    // 버튼
    UIButton *_btnReset;
    UIButton *_btnRoute;
}

// ===============================
// [ 길찾기 다이얼로그 호출 메소드 ]
// ===============================
+ (SearchRouteDialogViewController *) sharedSearchRouteDialog;
- (void) showSearchRouteDialog;
- (void) showSearchRouteDialogWithAnalytics :(BOOL)analytics;
- (void) resetDialog;
- (void) closeSearchRouteDialog;
// *******************************


// ======================
// [ 길찾기 Interaction ]
// ======================
- (void) touchStart:(id)sender;
- (void) touchVisit:(id)sender;
- (void) touchDest:(id)sender;
- (void) onVisitAddRemove:(id)sender;
- (void) onReset:(id)sender;
- (void) onRoute:(id)sender;
- (void) onCellDown:(id)sender;
- (void) onCellUp:(id)sender;

- (void) onTouchBackground:(id)sender;
// **********************

@end
