//
//  OMSearchRouteResult.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 30..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "OMSearchRouteResult.h"


BOOL comparePoints(CGPoint p1, CGPoint p2)
{
    if (p1.x == p2.x && p1.y == p2.y) return YES;
    else return NO;
}

@implementation OMSearchRouteResult

@synthesize srVehicleType = _srVehicleType;

@synthesize isRouteCar = _isRouteCar;
@synthesize routeCarError = _routeCarError;
@synthesize routeCarLinks = _routeCarLinks;
@synthesize routeCarPoints = _routeCarPoints;
@synthesize routeCarMapArea = _routeCarMapArea;
@synthesize routeCarPointCount = _routeCarPointCount;
@synthesize routeCarTotalDistance = _routeCarTotalDistance;
@synthesize routeCarTotalTime = _routeCArTotalTime;

@synthesize isRoutePublic = _isRoutePublic;
@synthesize routePublicError = _routePublicError;
@synthesize routePublicRecommendCount = _routePublicRecommendCount;
@synthesize routePublicBothCount = _routePublicBothCount;
@synthesize routePublicBusCount = _routePublicBusCount;
@synthesize routePublicSubwayCount = _routePublicSubwayCount;
@synthesize routePublicRecommend = _routePublicRecommend;
@synthesize routePublicBoth = _routePublicBoth;
@synthesize routePublicBus = _routePublicBus;
@synthesize routePublicSubway = _routePublicSubway;

- (id) init
{
    self = [super init];
    
    if ( self )
    {
        // 공통속성 초기화
        _srVehicleType = OMSearchRoute_VehicleType_CAR;
        
        // 길찾기 자동차 정보 초기화
        _isRouteCar = NO;
        _routeCarLinks = [[CoordList alloc] init];
        _routeCarPoints = [[NSMutableArray alloc] init];
        
        // 길찾기 대중교통 정보 초기화
        _isRoutePublic = NO;
        _routePublicRecommend = [[NSMutableArray alloc] init];
        _routePublicBoth = [[NSMutableArray alloc] init];
        _routePublicBus = [[NSMutableArray alloc] init];
        _routePublicSubway = [[NSMutableArray alloc] init];
        
        _routeCarPointCount = _routePublicRecommendCount = _routePublicBusCount = _routePublicSubwayCount = _routePublicBothCount = 0;
    }
    
    return self;
}

- (void) dealloc
{
    [_routeCarLinks release];
    [_routeCarPoints release];
    
    [super dealloc];
}


- (void) reset
{
    _srVehicleType = OMSearchRoute_VehicleType_CAR;
    [self resetCar];
    [self resetPublic];
}
- (void) resetCar
{
    _isRouteCar = NO;
    [self setRouteCarError:@""];
    [_routeCarLinks release];
    _routeCarLinks = [[CoordList alloc] init];
    [_routeCarPoints removeAllObjects];
    _routeCarPointCount = 0;
}
- (void) resetPublic
{
    _isRoutePublic = NO;
    [self setRoutePublicError:@""];
    
    [_routePublicRecommend removeAllObjects];
    [_routePublicBoth removeAllObjects];
    [_routePublicBus removeAllObjects];
    [_routePublicSubway removeAllObjects];
    
    _routePublicRecommendCount = _routePublicBusCount = _routePublicSubwayCount = _routePublicBothCount = 0;
}

@end
