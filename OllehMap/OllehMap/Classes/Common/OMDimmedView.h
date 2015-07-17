//
//  OMDimmedView.h
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 23..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OllehMapStatus.h"


@interface OMDimmedView : UIView
{
    int _dimmedDisableType;
}

+(OMDimmedView *) sharedDimmedView;

@property int dimmedDisableType;

@end


enum DimmedDisableType
{
    DimmedDisableType_NONE = 0,
    DimmedDisableType_Touch = 1, DimmedDisableType_DblTouch = 2,
    DimmedDisableType_LongTouch = 3
};
