//
//  OMOverlay.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 9. 5..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

// 커스텀 이미지 오버레이를 위한 참조
#import "ImageOverlay.h"
// 커스텀 유저 오버레이를 위한 참조
#import "UserOverlay.h"

#import "PolylineOverlay.h"

@interface OMPolylineOverlay : PolylineOverlay
{
}

@end

// 모든 POI 오버레이를 위한 커스텀 이미지 오버레이 클래스를 정의한다.
@interface OMImageOverlay : ImageOverlay
{
    // 교통옵션 오버레이 여부
    BOOL _isTrafficOption;
    // 길찾기 오버레이 여부
    BOOL _isRouteOption;
    // 중복처리 여부
    BOOL _duplicated;
    // 오버레이 선택 여부
    BOOL _selected;
    // 오버레이 추가정보
    NSMutableDictionary *_additionalInfo;
}
// 멤버변수에 대한 프로퍼티 설정
@property (nonatomic, readonly) BOOL isTrafficOption;
@property  (nonatomic, readonly) BOOL isRouteOption;
@property (nonatomic, assign) BOOL duplicated;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, readonly) NSMutableDictionary *additionalInfo;
@end

// 롱탭 POI 를 처리하기위한 오버레이 클래스를 정의한다.  :: 커스텀 이미지 오버레이 클래스를 상속받는다.
@interface OMImageOverlayLongtap : OMImageOverlay
@end

// 검색결과 단일 POI를 처리하기위한 오버레이 클래스를 정의한다. :: 커스텀 이미지 오버레이 클래스를 상속받는다.
@interface OMImageOverlaySearchSingle : OMImageOverlay
{
    BOOL _usePOIIcon;
}
@property (nonatomic, assign) BOOL usePOIIcon;
@end

// 검색결과 다중 POI를 처리하기위한 오버레이 클래스를 정의한다. :: 커스텀 이미지 오버레이 클래스를 상속받는다.
@interface OMImageOverlaySearchMulti : OMImageOverlay
{
    int indexer;
}
@end

// 최근검색 POI를 처리하기위한 오버레이 클래스를 정의한다. :: 커스텀 이미지 오버레이 클래스를 상속받는다.
@interface OMImageOverlayRecent : OMImageOverlay
{
    NSString *_specialNormalIconImage;
    NSString *_specialSelectedIconImage;
}
@property (nonatomic, retain) NSString *specialNormalIconImage;
@property (nonatomic, retain) NSString *specialSelectedIconImage;
@end

// 즐겨찾기 POI를 처리하기위한 오버레이 클래스를 정의한다. :: 커스텀 이미지 오버레이 클래스를 상속받는다.
@interface OMImageOverlayFavorite : OMImageOverlay
{
    NSString *_specialNormalIconImage;
    NSString *_specialSelectedIconImage;
}
@property (nonatomic, retain) NSString *specialNormalIconImage;
@property (nonatomic, retain) NSString *specialSelectedIconImage;
@end

// 길찾기 POI를 처리하기위한 오버레이 클래스 정의(출바알)
@interface OMImageOverlaySearchRouteStart : OMImageOverlay
@end

// 길찾기 POI를 처리하기위한 오버레이 클래스 정의(경유우)
@interface OMImageOverlaySearchRouteVisit : OMImageOverlay
@end


// 길찾기 POI를 처리하기위한 오버레이 클래스 정의(도차악)
@interface OMImageOverlaySearchRouteDest : OMImageOverlay
@end

// 버스노선도 내 버스정류장 POI를 처리하기위한 오버레이 클래스를 정의한다. :: 커스텀 이미지 오버레이 클래스를 상속받는다.
@interface OMImageOverlayBusStationInBusLIneMap : OMImageOverlay
// MIK.geun :: 20120905 //  2차개발현재 아직까진 사용계획 없음
@end

// 교통옵션 CCTV POI를 처리하기위한 오버레이 클래스를 정의한다. :: 커스텀 이미지 오버레이 클래스를 상속받는다.
@interface OMImageOverlayTrafficCCTV : OMImageOverlay
@end

// 교통옵션 버스정류장 POI를 처리하기위한 오버레이 클래스를 정의한다. :: 커스텀 이미지 오버레이 클래스를 상속받는다.
@interface OMImageOverlayTrafficBusStation : OMImageOverlay
@end

// 교통옵션 지하철역 POI를 처리하기위한 오버레이 클래스를 정의한다. :: 커스텀 이미지 오버레이 클래스를 상속받는다.
@interface OMImageOverlayTrafficSubwayStation : OMImageOverlay
@end

// 테마 POI를 처리하기위한 오버레이 클래스를 정의한다. :: 커스텀 이미지 오버레이 클래스를 상속받는다.
@interface OMImageOverlayTheme : OMImageOverlay
@end



// 커스텀 유저 유저 오버레이 클래스를 정의한다.
@interface OMUserOverlay : UserOverlay
@end

// POI 마커옵션 오버레이 클래스를 정의한다. 커스텀 유저 오버레이를 상속받는다.
@interface OMUserOverlayMarkerOption : OMUserOverlay
@end

// POI 마커옵션 오버레이중 -타이틀- 전용오버레이 클래스를 정의한다.
@interface OMUserOverlayMarkerOptionTitle : OMUserOverlayMarkerOption
{
    NSMutableDictionary *_additionalInfo;
}
@property (nonatomic, readonly) NSMutableDictionary *additionalInfo;
@end




