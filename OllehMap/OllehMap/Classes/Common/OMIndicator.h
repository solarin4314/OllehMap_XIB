//
//  OMIndicator.h
//  OllehMap
//
//  Created by 이 제민 on 12. 5. 8..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface OMIndicator : UIView
{
	UIActivityIndicatorView		*_activityIndicator;
    int _countIndicator;
}

// 인디게이터 싱글턴 처리
+ (OMIndicator *) sharedIndicator;

// 인디케이터 활성화
- (void)startAnimating;

// 인디케이터 비활성화
- (void)stopAnimating;

// 인디케이터 강제 비활성화
- (void) forceStopAnimation;

// 인디케이터 활성화여부
- (BOOL)isAnimating;


@end

