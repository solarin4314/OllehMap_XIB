/*
 *  UTIL.h
 *  Sem
 *
 *  Created by c2con on 10. 9. 16..
 *  Copyright 2010 01. All rights reserved.
 *
 */

class UTIL
{
public:
	static const char* EncodeBase64(const char* szSrc);
	static const char* DecodeBase64(const char* szSrc);

	static const char* GetUUID();
};

