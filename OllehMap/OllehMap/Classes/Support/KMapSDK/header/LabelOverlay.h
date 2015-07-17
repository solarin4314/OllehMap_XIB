
/*
 *  LabelOverlay.h
 *  KMapSDK
 *
 *  Created by Song Hyun Seob on 10. 07. 19.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>
#import "KGeometry.h"
#import "Overlay.h"

/**
 * LabelOverlay: Label Overlay class.
 */
@interface LabelOverlay : Overlay
{
	
	UILabel* labelView;
	
	UIBaselineAdjustment baselineAdjustment;
	UITextAlignment      textAdjustment;
}

/**
 * LabelOverlay를 text와 font정보로 초기화 한다.
 * @param text :text
 * @param font :font.
 */
- (id)initWithText:(NSString *)text Font:(UIFont*)font;

/**
 * text
 */
- (void) setLabelText:(NSString*)text;

/**
 * LabelOverlay의 UIBaselineAdjustment
 */
@property (nonatomic) UIBaselineAdjustment baselineAdjustment;

/**
 * LabelOverlay의 UITextAlignment
 */
@property (nonatomic) UITextAlignment      textAdjustment;

/**
 * LabelOverlay의 UILabel class
 */
@property (nonatomic,readonly,retain) UILabel* labelView;

@end

