/**
 @section Program 프로그램명
 - 프로그램명 :  OllehMap \n
 - 프로그램 내용 : 맵 정보 서비스 
 @section 개발 업체 정보 
 - 업체정보 :  KTH
 - 작성일 : 2011-12-07
 @file PointPin.m
 @class PointPin
 @brief 포인트 핀 뷰 클래스
 */ 

#import "PointPin.h"


@implementation PointPin

@synthesize delegate = _delegate;
@synthesize status = _status;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
        // Initialization code
		self.userInteractionEnabled = YES;
		
		_basePoint = self.center;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([_delegate respondsToSelector:@selector(moveTouchesBegan:withEvent:)]) [_delegate moveTouchesBegan:self withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([_delegate respondsToSelector:@selector(moveTouchesMoved:withEvent:)]) [_delegate moveTouchesMoved:self withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([_delegate respondsToSelector:@selector(moveTouchesEnded:withEvent:)]) [_delegate moveTouchesEnded:self withEvent:event];	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}	

- (void)setBasePoint
{
	self.center = _basePoint;
}

@end
