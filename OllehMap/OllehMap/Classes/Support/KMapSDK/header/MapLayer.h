
/*
 *  MapLayer.h
 *  KMapSDK
 *
 *  Created by Song Hyun Seob on 10. 08. 04. *
 */
#import "KGeometry.h"

@protocol MapLayerDelegate;

@interface MapLayer : NSObject
{
@private
	KBounds bounds;
	
	int	   maxLevel;
	int    tileWidth;
	int    tileHeight;
	int    layerID;
	
	double* UPTs;
	
	struct CTileManager* tileManager;    
}

/**
 * MapLayer delegate.
 */
@property (nonatomic, assign) id <MapLayerDelegate> delegate;

/**
 * MapLayer bound.
 */
@property (nonatomic, assign) KBounds bounds;

/**
 * MapLayer layer ID. 0,1,2는 일반 맵이 사용하고 있으므로 이를 피한 값을 사용해야 함.
 */
@property (nonatomic, assign) int	  layerID;


/**
 * MapLayer maxLevel.
 */
@property (nonatomic, assign) int	  maxLevel;

/**
 * MapLayer tileWidth.
 */
@property (nonatomic, assign) int     tileWidth;

/**
 * MapLayer tileHeight.
 */
@property (nonatomic, assign) int     tileHeight;

/**
 * tileLayer의 고유 tag(필요하다면 사용자가 임으로 설정하여 사용하여야 함).
 */
@property (nonatomic) int	tag;

/**
 * tileLayer의 고유 info(필요하다면 사용자가 임으로 설정하여 사용하여야 함).
 */
@property (nonatomic,retain) id		userInfo;

/**
 * tileLayer의 Unit per Pixel 을 설정한다.
 * @param value :upt value.
 * @param level :설정할 level. 
 */
- (void) setUPT:(double)value Level:(int)level;

/**
 * tileLayer의 Unit per Pixel 을 설정한다.
 * @param values :upt values.
 */
- (void) copyUPTs:(double*)values ArraySize:(int)size;

/**
 * 사용하는 메모리 캐시를 지운다.
 */
- (void)clearCache;


/**
 * 내부 함수 사용자가 호출하지 말것.
 */
- (void)setServiceSize:(CGSize)size;
/**
 * 내부 함수 사용자가 호출하지 말것.
 */
- (void)setDownloadAllow:(BOOL)set;
/**
 * 내부 함수 사용자가 호출하지 말것.
 */
- (void)onTile:(id)_internalView Region:(KRegion)region Rect:(CGRect) rect;
@end


/**
 * MapLayerDelegate: MapLayer delegate protocol.
 */
@protocol MapLayerDelegate <NSObject>
@optional

/**
 * tileLayer의 url생성.
 * @param layer :target layer.
 * @param level :level.
 * @param tileX :tile x index.
 * @param tileY :tile y index.
 */
@required
- (NSString*)makeUrl:(MapLayer *)tileLayer Level:(int)level TileX:(int)tileX TileY:(int)tileY;

@end

