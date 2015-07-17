#ifndef	__COMMON_OPEN_API__
#define	__COMMON_OPEN_API__

#define FRAME_SIZE_8K   320
#define FRAME_SIZE_16K  640

#define PHONEINFO_LENGTH 20
#define DEVID_LENGTH  44
#define MEDIA_MAX_PACKET 8016
#define RPT_MAX_PACKET 4*1024
#define MEDIA_RPT_MAX_PACKET 8*1024
#define INFO_MAX_PACKET 8000

typedef	struct	TagMsgOpenApiHead
{
    short cFrame;
    unsigned short usLength;
    unsigned int   unMsg;
    unsigned int   unSeqID;
    char cVer[2];
    unsigned char   cUser;
    char cFiller;
}   _MSG_HEAD;

typedef	struct	TagMsgOpenApiBody_SvcRteReq
{
	int		nSvcType;			// 0 ~ 1024
	int		nResouType;			// 0 ASR, 1 TTS, 2 ASR+TTS
	int		nNetworkType;		// 0 WI-FI, 1 3G, 2 WIBRO, 3 4G
	char	szPhoneType[PHONEINFO_LENGTH];	// Phone Model String
	char	szDEVID[DEVID_LENGTH];		// Phone Unique Value(ex:iPhone-> UUID)
	int		nConType;			// _enContentType : 0:Grammar, 1:VOICE, 2:Grammar & VOICE, 3:TTS
	char	szXPos[20];			// GPS Iatitude
	char	szYPos[20];			// GPS longitude
}	_CA_SVCRTE_REQ;

typedef	struct	TagMsgOpenApiBody_ControlAsr
{
	int		nSilenceLength;		// added. ms (Default)
	int		nEnableEPD;			// added. 0 OFF 1 ON
	int		nTheBest;			// added. 0 OFF 1 ON
    int     nVoiceFormat;
    int     nSampleRate;
}	_M_CONTROL_ASR;

typedef	struct	TagMsgOpenApiBody_ControlTts
{
	int		nPayLoadType;				// Must be declared.
}	_M_CONTROL_TTS;

typedef	struct	TagMsgOpenApiBody_ControlVideo
{
	int		nNon;				// Must be declared.
}	_M_CONTROL_VIDEO;

typedef	struct	TagMsgOpenApiBody_SvcRetRsp
{
	int		nResult;			// 0 ~ 99, 0 SUCC, other reason
	int		nPacketSize;		// 1 ~ 99999999
	int		nPacketInterval;	// added. ms
	int		nSessTime;			// Session timer. ms
	int		nRspFlag;			// 0 OFF, 1 ON
	int		nInfoEnable;		// 0 OFF, 1 ON
	int		nReUseFlag;			// 0 OFF, 1 ON
	int		nPaidFeature;		// Billing amount (Default: 0)
    char    szSearchUrl[120];
    int     nStartMethod;
    int     nCompMethod;
    int     nSpeexQuality;      // 1 ~ 9 encoding rate
    int     nTransMethod;
    int     nEndMethod;
	int		nType;				// 0:ASR, 1:TTS
	char	szDestIP[120];		// Access IP
	char	szDestPort[8];		// Acesss Port

	union 
	{
		_M_CONTROL_ASR		stControlAsr;
		_M_CONTROL_TTS		stControlTts;
		_M_CONTROL_VIDEO	stControlVideo;
	};

}	_CA_SVCRTE_RSP;

typedef	struct	TagMsgOpenApiBody_ResultRpt
{
    int     nResult;            // 0 ~ 99
    int     nSvcType;           // 0 ~ 99
    int     nResouType;         // 0 ASR, 1 TTS, 2 ASR+TTS
    int     nNetworkType;       // 0 WI-FI, 1 3G, 2 WIBRO, 3 4G
    char    szPhoneType[PHONEINFO_LENGTH];    // String
    char    szDEVID[DEVID_LENGTH];
	int		nResultLength;
    char    szResult[RPT_MAX_PACKET];
}   _CA_SVCRTE_RPT;

typedef	struct	TagMsgOpenApiBody_InfoRpt
{
	int		nResult;		// 0 ~ 99
    int     nSvcType;           // 0 ~ 99
    int     nResouType;         // 0 ASR, 1 TTS, 2 ASR+TTS
    int     nNetworkType;       // 0 WI-FI, 1 3G, 2 WIBRO, 3 4G
    char    szPhoneType[PHONEINFO_LENGTH];    // String
    char    szDEVID[DEVID_LENGTH];
    int     nCur;
    int     bLast;
	int		nResultLength;
    char    szResult[INFO_MAX_PACKET];    
}	_CA_INFO_RPT;

typedef	struct	TagMsgOpenApiBody_EndRpt
{
	int		nResult;			// 0 ~ 99
	int		nSvcType;			// 0 ~ 99
	int		nResouType;			// 0 ASR, 1 TTS, 2 ASR+TTS
	int		nNetworkType;		// 0 WI-FI, 1 3G, 2 WIBRO, 3 4G
	char	szPhoneType[PHONEINFO_LENGTH];	// String
	char	szDEVID[DEVID_LENGTH];
	int		nConType;
}	_CA_END_RPT;

typedef	struct	TagMsgOpenApiBody_TtsText
{
	int			nSpeakerID;
	int			nVoiceFormat;
	int			nVolume;			// Default : 100
	int			nSpeed;				// Defalut : 100
	int			nPitch;				// Defalut : 100
}	_CA_TTS_TEXT;

typedef	struct	TagMsgOpenApiBodyMediaReq
{
	int			nCur;				// 1 ~ xxxxxx
	int			bLast;				// 1:TRUE, 0:FALSE
	int			nContType;			// 0 USR PROFILE, 1 VOICE, 2 reserved , 3 TEXT
	int			nDataLen;			// Media Stream Length (MAx:8000)
	
	char		cData[MEDIA_MAX_PACKET];

}	_CA_MEDIA_REQ;

typedef	struct	TagMsgOpenApiBodyMediaRsp
{
	int			nResult;		// 0 ~ 99
	int			nCur;				// 1 ~ xxxxxx
	int			bLast;				// 1:TRUE, 0:FALSE
	int			nContType;			// 0 USR PROFILE, 1 VOICE, 2 reserved , 3 TEXT
}	_CA_MEDIA_RSP;

typedef struct TagMsgOpenApiBodyMediaRpt
{
    int     nResult;            // 0 ~ 99
    int     nSvcType;           // 0 ~ 99
    int     nResouType;         // 0 ASR, 1 TTS, 2 ASR+TTS
    int     nNetworkType;       // 0 WI-FI, 1 3G, 2 WIBRO, 3 4G
    char    szPhoneType[PHONEINFO_LENGTH];    // String
    char    szDEVID[DEVID_LENGTH];
	int		nResultLength;
    char    szResult[MEDIA_RPT_MAX_PACKET];    
}   _CA_MEDIA_RPT;

typedef	struct	TagMsgOpenApiBody_Continue
{
	int			nResult;		// 0 ~ 99
}	_CA_CONTINUE_RPT;

typedef struct TagMsgOpenApiBodyMediaStopRpt
{
    
} _CA_MEDIA_STOP_RPT;

typedef	struct	TagMsgOpenApiBodyReq
{
	_CA_SVCRTE_REQ		stSvcRte;
	_CA_MEDIA_REQ		stMedia;
}	_CA_REQ;

typedef	struct	TagMsgOpenApiBodyRsp
{
	_CA_SVCRTE_RSP		stSvcRte;
	_CA_MEDIA_RSP		stMedia;

}	_CA_RSP;

typedef	struct	TagMsgOpenApiBodyRpt
{
	_CA_SVCRTE_RPT		stSvcRte;
	_CA_INFO_RPT		stInfoRpt;
	_CA_END_RPT			stEndRpt;
	_CA_CONTINUE_RPT	stContinue;
    _CA_MEDIA_STOP_RPT  stMediaStopRpt;
    _CA_MEDIA_RPT       stMediaRpt;
}	_CA_RPT;

typedef	struct	TagMsgOpenApiBody
{
	_MSG_HEAD	stHead;

	struct
	{
		_CA_REQ		stReq;
		_CA_RSP		stRsp;
		_CA_RPT		stRpt;
		char            cData[9000];
	}	stD;
}	_CA_MSG;


#endif
