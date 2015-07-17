//
//  OMCustomView.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 6. 29..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "OMCustomView.h"
#import "OMMessageBox.h"

// 텍스트 라벨 사이즈 조절
LabelResizeInfo getLabelResizeInfo (UILabel *label, CGFloat maxWidth)
{
    LabelResizeInfo info;
    // 위치
    info.origin = label.frame.origin;
    // 이전 최적사이즈
    [label  sizeToFit];
    info.preSize = label.frame.size;
    // 신규 최적사이즈
    info.newSize = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(maxWidth, FLT_MAX) lineBreakMode:label.lineBreakMode];
    // 라인수
    info.numberOfLines = info.newSize.height / info.preSize.height;
    
    return info;
}
void setLabelResizeWithLabelResizeInfo (UILabel *label, LabelResizeInfo info)
{
    // 프레임 설정
    [label setFrame:CGRectMake(info.origin.x, info.origin.y, info.newSize.width, info.newSize.height)];
    // 라인 설정
    [label setNumberOfLines:info.numberOfLines];
    
}

// 스크롤뷰 커스터마이징
@implementation OMScrollView : UIScrollView
@synthesize scrollType = _scrollType;
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _scrollType = 0;
    }
    return self;
}
@end
// 상세 오토리사이징 되있는 스크롤뷰
@implementation DetailScrollView : UIScrollView
-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        
    }
    return self;
}
- (id) init
{
    self = [super init];
    if(self)
    {
        self.AutoresizingMask = UIViewAutoresizingFlexibleHeight;
    }
    return self;
}
@end

// 뷰컨트롤러 커스터마이징
@implementation OMViewController
@end


// 추가정보를 담을 수 있는 커스텀 버튼 클래스를 정의한다.
@implementation OMButton

@synthesize additionalInfo = _additionalInfo;

- (id) init
{
    self = [super init];
    [self initComponentMain];
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self initComponentMain];
    return self;
    
}
- (void) initComponentMain
{
    _additionalInfo = [[NSMutableDictionary alloc] init];
}

- (void) dealloc
{
    [_additionalInfo removeAllObjects]; [_additionalInfo release]; _additionalInfo = nil;
    
    [super dealloc];
}

@end


// 추가정보를 담을 수 있는 커스텀 컨트롤 클래스를 정의한다.
@implementation OMControl

@synthesize additionalInfo = _additionalInfo;

- (id) init
{
    self = [super init];
    [self initComponentMain];
    return self;
}
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self initComponentMain];
    return self;
}

- (void) initComponentMain
{
    _additionalInfo = [[NSMutableDictionary alloc] init];
}

- (void) dealloc
{
    [_additionalInfo removeAllObjects]; [_additionalInfo release]; _additionalInfo = nil;
    
    [super dealloc];
}

@end