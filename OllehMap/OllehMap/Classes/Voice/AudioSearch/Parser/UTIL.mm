/*
 *  UTIL.mm
 *  Sem
 *
 *  Created by c2con on 10. 9. 16..
 *  Copyright 2010 01. All rights reserved.
 *
 */

#include "UTIL.h"


#include "_Base64.h"
const char* UTIL::EncodeBase64(const char* szSrc)
{
	CBase64 cvt;
	
	cvt.Encode(szSrc);
	
	return cvt.EncodedMessage();
}

const char* UTIL::DecodeBase64(const char* szSrc)
{
	CBase64 cvt;
	
	cvt.Decode(szSrc);
	
	return cvt.DecodedMessage();
}
