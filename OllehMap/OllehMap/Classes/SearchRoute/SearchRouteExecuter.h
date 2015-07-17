//
//  SearchRouteExecuter.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 24..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OllehMapStatus.h"
#import "OMMessageBox.h"
#import "MapContainer.h"
#import "ServerConnector.h"
#import "ServerRequester.h"
#import "OMNavigationController.h"

@interface SearchRouteExecuter : NSObject
{
}


// ================
// [ 싱글턴 메소드 ]
// ================
+ (SearchRouteExecuter *) sharedSearchRouteExecuter;
+ (void) closeSearchRouteExecuter;
// ****************


// ================
// [ 길찾기 메소드 ]
// ================
- (void) searchRoute_Car :(int)searchType;
- (void) searchRoute_Public;
// ****************


// ==================
// [ 보조메소드 시작 ]
// ==================
+ (NSString*) getSearchRouteErrorMessage :(NSString*)msg;
// ******************

@end


