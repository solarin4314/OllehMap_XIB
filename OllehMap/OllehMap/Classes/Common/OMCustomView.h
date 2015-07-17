//
//  OMCustomView.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 6. 29..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

// 텍스트 라벨 사이즈 조절
typedef struct
{
    CGPoint origin;
    CGSize preSize;
    CGSize newSize;
    int numberOfLines;
} LabelResizeInfo;
LabelResizeInfo getLabelResizeInfo (UILabel *label, CGFloat maxWidth);
void setLabelResizeWithLabelResizeInfo (UILabel *label, LabelResizeInfo info);

// 스크롤뷰 커스터마이징 (일반 + 좌우스크롤 모드 지원)
@interface OMScrollView : UIScrollView
{
    int _scrollType; // 0 일반, 1 수평(좌우), 2 수직(상하)
}
@property (nonatomic, assign) int scrollType;
@end
// 스크롤뷰 커스텀(상세에서 오토리사이징 걸려있는)
@interface DetailScrollView : UIScrollView
@end

// 뷰컨트롤러 커스터마이징
@interface OMViewController : UIViewController
@end

// 추가정보를 담을 수 있는 커스텀 버튼 클래스를 정의한다.
@interface OMButton : UIButton
{
    NSMutableDictionary *_additionalInfo;
}
@property (nonatomic, readonly) NSMutableDictionary *additionalInfo;
@end
// 추가정보를 담을 수 있는 커스텀 컨트롤 클래스를 정의한다.
@interface OMControl : UIControl
{
    NSMutableDictionary *_additionalInfo;
}
@property (nonatomic, readonly) NSMutableDictionary *additionalInfo;
@end