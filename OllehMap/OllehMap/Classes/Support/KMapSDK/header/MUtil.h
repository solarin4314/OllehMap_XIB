/*
 *  MUtil.h
 *
 *  Created by hyun-sub song on 10. 04. 30.
 *  Copyright 2010 Mosition. All rights reserved.
 *
 */

#ifndef __MUTIL_H__
#define __MUTIL_H__

#include "IUtil.h"
#include "commonDef.h"

#ifdef IPHONE_SDK	
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include "CState.h"
#include "KGeometry.h"

CState GetAffineTransformState(CGAffineTransform transform);
CState GetAffineTransformStateYFlip(CGAffineTransform transform);
CState GetTransform3DState(CATransform3D transform);

//Coord  convertTo900913(double x, double y);
Coord convertToUTMK(double x, double y);
Coord convertToTM(double x, double y);
Coord convetCoord(double x, double y, int inSrs, int toSrs);
CGColorRef CGColorCreateRGB(float r,float g,float b,float a);

#endif
#endif 