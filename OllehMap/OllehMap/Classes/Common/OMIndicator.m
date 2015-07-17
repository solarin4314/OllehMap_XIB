//
//  OMIndicator.m
//  OllehMap
//
//  Created by 이 제민 on 12. 5. 8..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#import "OMIndicator.h"
#import "AppDelegate.h"
#import "OllehMapStatus.h"

@interface OMIndicator (PrivateMethod)

- (void) activateIndicator;
- (void) deactivateIndicator;

@end

@implementation OMIndicator



static OMIndicator *_Instance = nil;
+ (OMIndicator *) sharedIndicator
{
    if (_Instance == nil)
    {
        _Instance = [[OMIndicator alloc] init];
    }
    return _Instance;
}


- (id)init
{
	//if ((self = [super init]))
	if ((self = [super initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width,
                                                [[UIScreen mainScreen] bounds].size.height)]))
	{
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
        
		_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		_activityIndicator.frame = CGRectMake(142, 201, 37, 37);
		[self addSubview:_activityIndicator];
        
        _countIndicator = 0;
	}
	
	return self;
}

// 인디케이터 배경 설정 (블랙-불투명)
- (void)drawRect:(CGRect)rect
{
    return [super drawRect:rect];
    
	double red = 1.0/255*128;
	double green = 1.0/255*128;
	double blue = 1.0/255*128;
	
	CGRect rrect =  CGRectMake(110, 180 , 100, 80);
    //CGRect rrect =  CGRectMake(110+25, 180+20 , 100-50, 80-40);
	CGFloat radius = 10.0;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//CGContextSetFillColorWithColor(context, [UIColor colorWithRed:red green:green blue:blue alpha:0.6f].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:red green:green blue:blue alpha:0.0f].CGColor);
	
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	
	CGContextFillPath(context);
}

- (void)dealloc
{
	[_activityIndicator release]; _activityIndicator = nil;
    [super dealloc];
}


// 인디케이터 활성화
- (void) activateIndicator
{
    if (![_activityIndicator isAnimating])
    {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate.window addSubview:self];
        
        self.hidden = NO;
        [_activityIndicator startAnimating];
        
        // 상단 스테이터스바에도 인디케이터 활성화되도록 설정
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
    else
    {
        [((AppDelegate*)[UIApplication sharedApplication].delegate).window bringSubviewToFront:self];
    }
}
// 인디케이터 비활성화
- (void) deactivateIndicator
{
	[self removeFromSuperview];
	self.hidden = YES;
	[_activityIndicator stopAnimating];
    
    // 상단 스테이터스바에도 인디케이터 비활성화되도록 설정
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void) startAnimating
{
    if (_countIndicator < 0) _countIndicator = 0;
    
    _countIndicator++;
    [self activateIndicator];
}
- (void) stopAnimating
{
    if (--_countIndicator <= 0)
        [self deactivateIndicator];
}
- (BOOL)isAnimating
{
    return [_activityIndicator isAnimating];
}

// 인디케이터 강제 비활성화
- (void) forceStopAnimation
{
    _countIndicator =0;
    [self deactivateIndicator];
}


@end
