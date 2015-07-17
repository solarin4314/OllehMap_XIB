// CBase64.h: interface for the CBase64 class.
//
//////////////////////////////////////////////////////////////////////
#pragma once
#import "VoiceCommon.h"
typedef unsigned long			DWORD;


typedef BYTE 					*PBYTE;
typedef unsigned long			ULONG;


#include <stdio.h>
#include <string.h>
#include <memory.h>


class CBase64  
{
	// Internal bucket class.
	class TempBucket
	{
	public:
		BYTE		nData[4];
		BYTE		nSize;
		void		Clear() { memset(nData, 0, 4); nSize = 0; };
	};

	PBYTE					m_pDBuffer;
	PBYTE					m_pEBuffer;
	DWORD					m_nDBufLen;
	DWORD					m_nEBufLen;
	DWORD					m_nDDataLen;
	DWORD					m_nEDataLen;

public:
	CBase64();
	virtual ~CBase64();

public:
	virtual void		Encode(const PBYTE, DWORD);
	virtual void		Decode(const PBYTE, DWORD);
	virtual void		Encode(const char* sMessage);
	virtual void		Decode(const char* sMessage);

	virtual const char* 	DecodedMessage() const;
	virtual const char*	EncodedMessage() const;

	virtual void		AllocEncode(DWORD);
	virtual void		AllocDecode(DWORD);
	virtual void		SetEncodeBuffer(const PBYTE pBuffer, DWORD nBufLen);
	virtual void		SetDecodeBuffer(const PBYTE pBuffer, DWORD nBufLen);

protected:
	virtual void		_EncodeToBuffer(const TempBucket &Decode, PBYTE pBuffer);
	virtual ULONG		_DecodeToBuffer(const TempBucket &Decode, PBYTE pBuffer);
	virtual void		_EncodeRaw(TempBucket &, const TempBucket &);
	virtual void		_DecodeRaw(TempBucket &, const TempBucket &);
	virtual bool		_IsBadMimeChar(BYTE);

	static  char		m_DecodeTable[256];
	static  bool		m_Init;
	void					_Init();
};

