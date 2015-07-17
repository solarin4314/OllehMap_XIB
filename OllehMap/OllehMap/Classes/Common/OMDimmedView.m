//
//  OMDimmedView.m
//  OllehMap
//
//  Created by Changgeun Jeon on 12. 4. 23..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "OMDimmedView.h"

@implementation OMDimmedView

@synthesize dimmedDisableType = _dimmedDisableType;

static OMDimmedView *_instanceDimmedView = nil;
+(OMDimmedView *) sharedDimmedView
{
    @synchronized(self)
    {
        if (_instanceDimmedView == nil)
        {
            _instanceDimmedView = [[OMDimmedView alloc]
                                   initWithFrame:CGRectMake(0, 0,
                                                            [[UIScreen mainScreen] bounds].size.width,
                                                            [[UIScreen mainScreen] bounds].size.height)];
            [_instanceDimmedView setBackgroundColor:[UIColor blackColor]];
            [_instanceDimmedView setAlpha:0.8f];
            [_instanceDimmedView setDimmedDisableType: DimmedDisableType_NONE];
        }
    }
    return _instanceDimmedView;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [super touchesEnded:touches withEvent:event];
    
    /*
     
     MainViewController *mvc = [MainViewController sharedMainView];
     
     switch (self.dimmedDisableType)
     {
     case DimmedDisableType_Touch:
     // 딤드활성화 액션타입이 "길찾기" 모드일때 길찾기 다이얼로그 해제 동작하도록
     [mvc hideSearchRouteDialog:nil];
     [self setDimmedDisableType:DimmedDisableType_NONE];
     break;
     
     default:
     break;
     }
     */
    
}

@end
