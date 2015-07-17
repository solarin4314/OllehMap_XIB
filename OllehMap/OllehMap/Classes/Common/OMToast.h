//
//  OMToast.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 10. 17..
//
//

#import <Foundation/Foundation.h>

@interface OMToast : NSObject
{
    NSMutableArray *_toastContainerViews;
    
    BOOL _themeToastShowing;
}
@property (atomic, readonly) NSMutableArray *toastContainerViews;

+ (OMToast*) sharedToast;


// ================
// [ 토스트 처리 메소드 ]
// ================

// 공통 토스트 팝업
- (void) showToastMessagePopup :(NSString*)message superView:(UIView*)superView maxBottomPoint:(float)maxBottomPoint autoClose:(BOOL)autoClose;

- (void) showToastCadaStralPopup :(NSString *)message superView:(UIView *)superView maxBottomPoint:(float)maxBottomPoint autoClose:(BOOL)autoClose;

@end
