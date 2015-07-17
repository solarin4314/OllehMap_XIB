/**
 @section Program 프로그램명
 - 프로그램명 :  OllehMap \n
 - 프로그램 내용 : 맵 정보 서비스 
 @section 개발 업체 정보 
 - 업체정보 :  KTH
 - 작성일 : 2011-12-07
 @file PointPin.h
 @class PointPin
 @brief 포인트 핀 뷰 클래스
 */ 

#import <UIKit/UIKit.h>

enum
{
	POINT_PIN_STATUS_READY = 0,
	POINT_PIN_STATUS_MOVE,
	POINT_PIN_STATUS_SET
};

@protocol PointPinDelegate;

@interface PointPin : UIImageView 
{
	id<PointPinDelegate>	_delegate;		///< 델리게이트
	
	int						_status;		///< 상태
	CGPoint					_basePoint;		///< 기준 좌표
}

@property (nonatomic, assign) id<PointPinDelegate> delegate;
@property (nonatomic, assign) int status;

- (void)setBasePoint;

@end

@protocol PointPinDelegate <NSObject>
@optional
- (void)moveTouchesBegan:(PointPin *)pointPin withEvent:(UIEvent *)event;		///< 이동 시작 이벤트
- (void)moveTouchesMoved:(PointPin *)pointPin withEvent:(UIEvent *)event;		///< 이동중 이벤트
- (void)moveTouchesEnded:(PointPin *)pointPin withEvent:(UIEvent *)event;		///< 이동 완료 이벤트
//- (void)moveTouchesCancelled:(PointPin *)pointPin withEvent:(UIEvent *)event;	///< 이동 취소 이벤트
@end
