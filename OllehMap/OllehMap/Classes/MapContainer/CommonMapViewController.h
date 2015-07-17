//
//  CommonMapViewController.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 4..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

// iOS SDK 참조
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreGraphics/CoreGraphics.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
// KMap 참조
#import "KMapView.h"
#import "KGeometry.h"
#import "KMapTypes.h"
#import "ReverseGeocoding.h"
// 올레맵 개발사양 참조
#import "OllehMapStatus.h"
#import "OMIndicator.h"
#import "OMMessageBox.h"
#import "OMNavigationController.h"
#import "MapContainer.h"
#import "SearchViewController.h"
#import "OMCustomView.h"


@interface CommonMapViewController : UIViewController <UIApplicationDelegate>
{
    // 지도옵션(교통량/POI테마) 을 위한 컨테이너 뷰
    UIControl *_vwMapViewOptionContainer;
}

// =======================================
// [ 지도옵션 메소드  ]
// =======================================
- (void) showMapTrafficOptionView :(BOOL)show currentMapContainer:(MapContainer*)currentMapContainer currentMapViewController:(CommonMapViewController*)currentMapViewController;
- (void) showMapTrafficOptionView :(BOOL)show currentMapContainer:(MapContainer*)currentMapContainer currentMapViewController:(CommonMapViewController*)currentMapViewController trafficOptionEnabled:(bool)trafficOptionEnabled;
- (void) onOptionViewCloseButton :(id)sender;
- (void) onOPtionViewUseTrafficAddress:(id)sender;
- (void) onOptionViewUseTrafficInfo :(id)sender;
- (void) onOptionViewUseTrafficCCTV :(id)sender;
- (void) onOptionViewUseTrafficBusStation :(id)sender;
- (void) onOptionViewUseTrafficSubwayStation :(id)sender;
// ***************************************

// =======================================
// [ 공통 보조 메소드 시작 ]
// =======================================
- (void) JumpToSearchView :(BOOL)animated;
// ***************************************


@end
