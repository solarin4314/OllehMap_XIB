
/*
 *  Overlay.h
 *  KMapSDK
 *
 *  Created by Song Hyun Seob on 10. 07. 19.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>
#import "KGeometry.h"
@class KMapViewInternal;

struct IDC;

@protocol OverlayDelegate;

/**
 * Overlay: Overlay class.
 */
@interface Overlay : NSObject
{
	Coord coord;
}

/**
 * Overlay delegate.
 */
@property (nonatomic, assign) id <OverlayDelegate> delegate;

/**
 * Overlay 위치 좌표 (UTMK)
 */
@property (nonatomic) Coord coord;

/**
 * title.
 */
@property (nonatomic,retain) NSString* title;

/**
 * sub title.
 */
@property (nonatomic,retain) NSString* subtitle;
/**
 * (overlap marker) 리스트에 보여질 데이터.
 */
@property (nonatomic,retain) NSArray* listData;
/**
 * (overlap marker) 반환되어질 리스트 인덱스.
 */
@property (nonatomic) int listIndex;
/**
 * (overlap marker) 리스트 배경화면 이미지.
 */
@property (nonatomic,retain) NSString* listDataBackgroundImage;

/**
 * overlay click 시에 balloone을 볼 것인지 여부.
 */
@property (nonatomic) BOOL canShowBalloon;
/**
 * overlay click 시에 listData을 볼 것인지 여부.
 */
@property (nonatomic) BOOL canShowlistData;
/**
 * coord로부터의 balloon offset.
 */
@property (nonatomic) CGPoint balloonOffset;

/**
 * clearOverlay를 실행하여도 삭제되지 않도록 설정함.
 */
@property (nonatomic) BOOL lock;

/**
 * overlay의 고유 tag(필요하다면 사용자가 임으로 설정하여 사용하여야 함).
 */
@property (nonatomic) int	tag;

/**
 * overlay의 고유 info(필요하다면 사용자가 임으로 설정하여 사용하여야 함).
 */
@property (nonatomic,retain) id		userInfo;

/**
 * overlay의 중심점을 반환한다.
 * @param defaultCenter :중심점을 계산할 수 없는 overlay의 경우 해당 값으로 리턴함.
 * @return overlay의 중심점.
 */
-(Coord) center:(Coord) defaultCenter;

/**
 * overlay에 view를 포함하고 있다면(UserOverlay,BalloonOverlay) 해당 view를 반환한다.
 * @return UIView class.
 */
-(UIView*) getOverlayView;

/**
 * overlay가 선택될 수 있는지 체크한다.
 * @param point :체크할 윈도우 좌표.
 * @param coord :체크할 지도 좌표.
 * @param tolerance :tolerance.
 * @return 선택 여부 반환.
 */
-(BOOL) hitTest:(CGPoint) point Coord:(Coord)coord Tolerance:(double)tolerance;

-(Coord)_checkCoord:(Coord)_coord Tolerance:(double)tolerance;//KML layer
/**
 * overlay가 vector type(CircleOverlay,PolygonOverlay,PolylineOverlay)인지 체크한다.
 * @return vectory 여부 반환.
 */
-(BOOL) isVector;

/**
 * tolerance를 계산한다 polyline을 제외한 overlay는 0을 반환한다.
 * @param upp :현재 지도의 unit per pixel 값.
 * @return tolerance 값 반환.
 */
-(double) calcTolerance:(double)upp;

/**
 * overlay의 bounds를 반환한다.
 * @return bounds 반환.
 */
-(KBounds) getBounds;

/**
 * 내부 사용함수: 사용자 사용 금지.
 */
-(void) draw:(struct IDC*) pDC;


@end

/**
 * OverlayDelegate: Overlay delegate protocol.
 */
@protocol OverlayDelegate <NSObject>
@optional

/**
 * overlay가 touch 되었을 때 호출.
 * @param overlay :target ovrlay.
 */
- (void)overlayTouched:(Overlay *)overlay;

/**
 * overlay가 double touch 되었을 때 호출.
 * @param overlay :target ovrlay.
 */
- (void)overlayDoubleTouched:(Overlay *)overlay;

/**
 * overlay의 balloon이 touch 되었을 때 호출.
 * @param overlay :target ovrlay.
 */
- (void)overlayBalloonTouched:(Overlay *)overlay;
/**
 * overlay의 listData가 touch 되었을 때 호출.
 * @param overlay :target ovrlay.
 */
- (void)overlayListDataTouched:(Overlay *)overlay;

@end


