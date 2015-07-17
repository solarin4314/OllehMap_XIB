//
//  OMSearchRouteResult.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 30..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoordList.h"


// 두 좌표값 비교
BOOL comparePoints(CGPoint p1, CGPoint p2);


@interface OMSearchRouteResult : NSObject
{
    // 공통 속성
    int _srVehicleType;
    
    // 자동차 관련 데이터
    BOOL _isRouteCar;
    NSString *_routeCarError;
    CoordList *_routeCarLinks;
    NSMutableArray *_routeCarPoints;
    KBounds _routeCarMapArea;
    int _routeCarPointCount;
    double _routeCarTotalDistance;
    float _routeCArTotalTime;
    
    // 대중교통 관련 데이터
    BOOL _isRoutePublic;
    NSString *_routePublicError;
    int _routePublicRecommendCount;
    int _routePublicBothCount;
    int _routePublicBusCount;
    int _routePublicSubwayCount;
    NSMutableArray *_routePublicRecommend;
    NSMutableArray *_routePublicBoth;
    NSMutableArray *_routePublicBus;
    NSMutableArray *_routePublicSubway;
    
}

@property (nonatomic, assign) int srVehicleType;

@property (nonatomic, assign) BOOL isRouteCar;
@property (nonatomic, retain) NSString *routeCarError;
@property (nonatomic, retain) CoordList *routeCarLinks;
@property (nonatomic, retain) NSMutableArray *routeCarPoints;
@property (nonatomic, assign) KBounds routeCarMapArea;
@property (nonatomic, assign) int routeCarPointCount;
@property (nonatomic, assign) double routeCarTotalDistance;
@property (nonatomic, assign) float routeCarTotalTime;

@property (nonatomic, assign) BOOL isRoutePublic;
@property (nonatomic, assign) NSString *routePublicError;
@property (nonatomic, assign) int routePublicRecommendCount;
@property (nonatomic, assign) int routePublicBothCount;
@property (nonatomic, assign) int routePublicBusCount;
@property (nonatomic, assign) int routePublicSubwayCount;
@property (nonatomic, retain) NSMutableArray *routePublicRecommend;
@property (nonatomic, retain) NSMutableArray *routePublicBoth;
@property (nonatomic, retain) NSMutableArray *routePublicBus;
@property (nonatomic, retain) NSMutableArray *routePublicSubway;

- (void) reset;
- (void) resetCar;
- (void) resetPublic;

@end

enum OMSearchRoute_VehicleType
{
    OMSearchRoute_VehicleType_CAR = 0,
    OMSearchRoute_VehicleType_PUBLIC = 1
};


