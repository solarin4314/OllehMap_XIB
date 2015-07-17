//
//  KMapViewInternal.h
//  KMapSDK
//
//  Created by Song Hyun Seob on 10. 07. 19.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "KGeometry.h"

/**
 * ReverseGeocodingInfo: Reverse Geocoding info Class.
 */
@interface ReverseGeocodingInfo : NSObject {
}

/**
 * coord.
 */
@property (nonatomic) Coord coord;

/**
 * distance.
 */
@property (nonatomic) double ldistance;

/**
 * address.
 */
@property (nonatomic, retain) NSString* laddress;

/**
 * main POI.
 */
@property (nonatomic, retain) NSString* lmainPOI;

/**
 * distance.
 */
@property (nonatomic) double hdistance;

/**
 * address.
 */
@property (nonatomic, retain) NSString* haddress;

/**
 * main POI.
 */
@property (nonatomic, retain) NSString* hmainPOI;

@end


