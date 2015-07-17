//
//  OMSearchRouteDataParser.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 5. 30..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OllehMapStatus.h"


@interface OMSearchRouteDataParser : NSXMLParser <NSXMLParserDelegate>
{
    int _nVehicleType;
    BOOL _isRoute;
    
    int _nCurrentPublicCategory;
    
@private
    NSMutableString *_strErrorMessage;
}

@property (nonatomic, assign) int nVehicleType;

- (void) parseRouteData :(NSData *)data;

@end
