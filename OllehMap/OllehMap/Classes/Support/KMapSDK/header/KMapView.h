//
//  KMapSDK
//
//  Created by Song Hyun Seob on 10. 07. 19.
//  Copyright 2010
//

/**
 @mainpage   GIOP MapSDK API Documentation
 @section GIOP Map SDK 소개
 - 소개       :  GIOP TMS를 이용하여 IPhone, IPad등 iOS기기들에 쉽게 지도 기능을 구현할 수 있도록
                지도타일 이미지 표출, 터치에 의한 지도이동, Zoon In/Out, 지도 위에 이미지, 라인, 
                사각형, 원 등 각종 Overlay 추가등의 기본기능을 수행하는 개발도구 개발도구 이다.
 @section  CREATEINFO      작성정보
 - 작성자      :   GIOP MapSDK 개발팀
 - 작성일      :   2011/06/29
 @section  MODIFYINFO      수정정보
 - 수정자/수정일   : 수정내역
 - GIOP MapSDK 개발팀/2011/06/29    :   최초작성
 */

#import <UIKit/UIKit.h>
#import "KMapTypes.h"
#import "KGeometry.h"
#import "ImageOverlay.h"
#import "LabelOverlay.h"
#import "PolylineOverlay.h"
#import "PolygonOverlay.h"
#import "CircleOverlay.h"
#import "MarkerOverlay.h"
#import "UserOverlay.h"
#import "BalloonOverlay.h"
#import "MapLayer.h"

@class KMapViewInternal;

@protocol KMapViewDelegate;

/**
 OllehMapView : 지도 Control.
 */
@interface KMapView : UIView
{
@private
    KMapViewInternal *_internal;
}

/**
 * OllehMapView의 delegate.
 *@see OllehMapViewDelegate
 */
@property (nonatomic, assign) id <KMapViewDelegate> delegate;

/**
 * 지도 사용을 위한 인증키 설정
 */
//@property (nonatomic,retain) NSString* apiKey;

/**
* 지도 종류.
 *@see OllehMapType
 */
@property (nonatomic) OllehMapType mapType;

/**
 * display 종류. 
 *@see KMapDisplay
 */
@property (nonatomic) KMapDisplay mapDisplay;

/**
 * 측정 타입.
  *@see KMeasureType
 */
@property (nonatomic) KMeasureType measureType;

/**
 * 사용자 위치 표시 타입.
 *@see KUserLocationType
 */
@property (nonatomic) KUserLocationType showUserLocation;

/**
 * 화면에 보여지고 있는 region 반환.
 *@see KRegion
 */
@property (nonatomic) KRegion region;

/**
 * 지도의 중심을 설정 및 중심점 반환.
 *@see Coord
 */
@property (nonatomic) Coord centerCoordinate;

/**
 * traffic Info.
 */
@property (nonatomic) BOOL trafficInfo;

/**
 * ElectionMap Info.
 */
@property (nonatomic) BOOL ElectionInfo;

/**
 * CadastralMap Info.
 */
@property (nonatomic) BOOL CadastralInfo;

/**
 * traffic Info.
 * @param showTrafficInfo : traffic info 활성화 여부.
 * @param clearCache :traffic tile cache를 지울 것인지 여부.
 */
- (void)setTrafficInfo:(BOOL)showTrafficInfo clearCache:(BOOL)clearCache;

/**
 * 지도의 중심을 설정.
 * @param coord :중심점.
 * @param animated :animation 여부.
 */
- (void)setCenterCoordinate:(Coord)coord animated:(BOOL)animated;


/**
 * GPS 수신 위치 반환.
 * @return GPS 수신 위치 좌표(UTMK)
 */
-(Coord) getUserLocation;

-(void) setUserLocationInfo:(UIImage*)LocationImage CompassImage:(UIImage*)compassImage;
//showUserLocation 설정 후 stopUserLocationTracing 실행 후 다시 location manager를 사용하기 위해 설정.
-(void) restartUserLocationTracing;
//showUserLocation 설정 후 view 전환시 호출.
-(void) stopUserLocationTracing;

/**
 * 현재의 ZoomLevel을 설정 및 반환.
 */
@property (nonatomic) int zoomLevel;

/**
 *maxZoomLevel을 반환.
 */
@property (nonatomic,readonly) int maxZoomLevel;

/**
 * 화면에 보여지고 있는 Bounds 반환.
 */
@property (nonatomic,readonly) KBounds viewBounds; 

/**
 * 지도의 회전값 설정 및 반환.
 */
@property (nonatomic) double angle;

/**
 * 지도의 회전값 설정.
 * @param angle :회전각.
 * @param animated :animation 여부.
 */
- (void)setAngle:(double)angle animated:(BOOL)animated;

/**
 * 지도에 보여지는 overlay array 반환.
 * @return overlay array.
 */
- (NSArray*)getOverlays;

/**
 * 지도에 overlay 추가.
 * @param overlay :추가할 overlay.
 * @return overlay 추가 성공 여부.
 */
- (BOOL)addOverlay:(Overlay*)overlay;

/**
 * 지도에 overlay 삭제.
 * @param overlay :삭제할 overlay.
 */
- (void)removeOverlay:(Overlay*)overlay;

/**
 * 지도에 모든 overlay 삭제.
 */
- (void)removeAllOverlays;

/**
 * 지도에 모든 balloon overlay 삭제.
 */
- (void)removeAllBalloonOverlays;

/**
 * 지도 좌표를 화면 좌표로 변환.
 * @param coordinate :지도 좌표.
 * @return 화면 좌표.
 */
- (CGPoint)convertCoordinate:(Coord) coordinate;

/**
 * inType으로 전달된 지도 좌표를 outType으로 변환.
 * @param coordinate :지도 좌표.
 * @param inType :입력 지도좌표체계.
 * @param outType :출력 지도좌표체계.
 * @return 변환된 지도좌표.
 */
- (Coord)convertCoordinate:(Coord) coordinate inCoordType:(KCoordType)inType outCoordType:(KCoordType)outType;

/**
 * 화면 좌표를 지도 좌표로 변환.
 * @param point :화면 좌표.
 * @return 지도 좌표.
 */
- (Coord)convertPoint:(CGPoint) point ;

/**
 * 지도에 layer 추가.
 * @param layer : 추가할 layer.
 */
- (void)addLayer:(MapLayer*)layer;

/**
 * 지도에 layer 삭제.
 * @param layer : 삭제할 layer.
 */
- (void)removeLayer:(MapLayer*)layer;

/**
 * cache file및 메모리 캐시 초기화.
 * @param layerID : 삭제할 cache layer ID. 0: 일반 1: 위성영상 2:하이브리드 
 */
- (void)clearCache:(int)layerID;

/**
 * 모든 cache file및 메모리 캐시 초기화.
 */
- (void)clearAllCache;

/**
 * map init xml 파일을 다시 받아 설정.
 * 내부적으로 clearAllCache를 호출한다.
 */
- (void)reloadConfigXML;

/**
 * xml URL.
 * @param type. 설정할 KMapType
 * @param Url : 설정할 XML Url.
 */
- (void)setMapXMLUrl:(OllehMapType)type URL:(NSString*)Url;

/**
 * 맵 인증을 통해 xml config파일을 읽어 서비스를 시작한다. (외부 개발자용)
 */
- (void)startMapService:(NSString*)appID UserKey:(NSString*)userkey;

/**
 * 맵 인증을 통해 xml config파일을 읽어 서비스를 시작한다. (내부 개발자용 - KT 협력사)
 */
//- (void)startMapService:(NSString*)userkey;

/**
 * 맵 인증을 하지 않고 xml config파일을 읽어 서비스를 시작한다. (GIS BOX 용)
 */
//- (void)startMapService;

/**
 * 맵 설정이 성공했는지 여부를 체크한다. 
 * @return 리턴 플래그(int) 0 - 세팅 준비, 1 - 세팅 실패, 2 - 재시도중, 3 - 정상적으로 세팅 완료 
 */
- (int)checkStartMapService;

/**
 * 주어진 영역을 한 화면에 보여줄 수 있도록 지도 영역 및 레벨을 조정한다.
 */
- (void) zoomToExtent:(KBounds)overlayBounds;

/**
 * Long Press Event를 생성할 최소 시간을 설정한다.
 * @param duration :초단위 시간 - (default : 0.5초)
 */
- (void)setLongPressDuration:(double)duration;

/**
 * 전달된 Overlay 객체를 검색하여 Balloon Overlay를 출력한다.
 * @param overlay :Balloon Overlay로 출력될 Overlay객체
 */
- (void)showBalloonOverlay:(Overlay *)overlay;

//KML Layer start
- (void)showKMLLayer:(NSString *)path;

//KML Layer stop
- (void)removeKMLLayer;

@end

/**
 * OllehMapViewDelegate: OllehView Delegate.
 */
@protocol KMapViewDelegate <NSObject>
@optional
/**
 * 지도 Bounds가 변경되었을 때 호출.
 * @param mapView :대상 지도.
 * @param bounds :변경된 bounds. 
 */
- (void)mapBoundsChanged:(KMapView*)mapView Bounds:(KBounds)bounds;

/**
 * 지도 touch 되었을 때 호출.
 * @param mapView :대상 지도.
 * @param event :event 정보. 
 */
- (void)mapTouched:(KMapView*)mapView Events:(UIEvent*)event;

/**
 * 지도 touch 시작되었을 때 호출.
 * @param mapView :대상 지도.
 * @param event :event 정보. 
 */
- (void)mapTouchBegan:(KMapView*)mapView Events:(UIEvent*)event;
/**
 * 지도 touch가 종료되었을때 호출.
 * @param mapView :대상 지도.
 * @param event :event 정보. 
 */
- (void)mapTouchEnded:(KMapView*)mapView Events:(UIEvent*)event;
/**
 * 지도 touch가 이동되었을때 호출.
 * @param mapView :대상 지도.
 * @param event :event 정보. 
 */
- (void)mapTouchMoved:(KMapView*)mapView Events:(UIEvent*)event;

/**
 * 지도 double touch 되었을 때 호출.
 * @param mapView :대상 지도.
 * @param event :event 정보. 
 */
- (void)mapDoubleTouched:(KMapView*)mapView Events:(UIEvent*)event;

/**
 * 지도 multi touch 되었을 때 호출.
 * @param mapView :대상 지도.
 * @param event :event 정보. 
 */
- (void)mapMultiTouched:(KMapView*)mapView Events:(UIEvent*)event;

/**
 * 지도에 overlay가 추가되었을 때.
 * @param mapView :대상 지도.
 * @param overlay :추가된 overlay. 
 */
- (void)mapOverlayAdded:(KMapView*)mapView Overlay:(Overlay*)overlay;

/**
 * 지도에 config xml파일을 download 시작할때 호출.
 * @param mapView :대상 지도.
 */
- (void)mapConfigStartDownload:(KMapView*)mapView;

/**
 * 지도에 config xml파일을 download완료 하여 준비가 되었을때.
 * @param mapView :대상 지도.
 */
- (void)mapConfigPrepared:(KMapView*)mapView;

/**
 * 지도의 이동상태 확인
 * @param mapLoad :map의 이동상태 (0:이동시작, 1:이동중, 2:이동완료)
 * @param isZoom :map의 이동상태 변경이 Zoom In/Out에 의한 것이라면 True, 아니라면 False
 */
- (void)mapStatusChanged:(NSNumber *)mapLoad isZoom:(NSNumber *)isZoom;

/**
 * Long Touch 이벤트 확인
 * @param coord :Long Touch이벤트가 발생한 좌표
 */
- (void)mapLongTouched:(NSValue *)coord;

// coord : UTMK 좌표 값.
- (void)mapUpdatelocation:(KMapView*)mapView coord:(Coord)coord;

@end
