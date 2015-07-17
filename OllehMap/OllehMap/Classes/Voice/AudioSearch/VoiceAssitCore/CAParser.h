//
//  CAParser.h
//  VoiceAssist
//
//  Created by infinity on 11. 4. 8..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAData.h"


enum STATUS_VALUE{
    UNKNOWN_STATUS = noErr,
    CANT_CONNECT_STATUS,
    READY_STATUS,
    TIMEOUT_STATUS,
    START_RECOG_STATUS,
    FAIL_RECOG_STATUS,
    OK_RECOG_STATUS,
    FAILURE_STATUS,
    NONE_DATA_STATUS,
    PLAY_FIN_STATUS
};

/**
 * network protocol command set
**/
enum SEQUENCE_TAG{
    MSG_HEAD,
    MSG_BODY = 0x00100000,
    CA_SVCRTE_REQ = 0x0000B010,
    CA_SVCRTE_RSP = 0x1000B010,
    CA_SVCRTE_RPT = 0x2000B010,
    CA_SVCEND_RPT = 0x2000B011,
    CA_SVCINFO_RPT = 0x2000B012,
    CA_MEDIA_STREAM_REQ = 0x0000B015,
    CA_MEDIA_STREAM_RSP = 0x1000B015,
    CA_MEDIA_STREAM_RPT = 0x2000B015,
    CA_CONTINUE_RPT = 0x2000B014,
    CA_MEDIA_PAUSE_REQ = 0x0000B016,
    CA_MEDIA_PAUSE_RSP = 0x1000B016,
    CA_MEDIA_PAUSE_RPT = 0x2000B016,
    CA_MEDIA_STOP_REQ = 0x0000B017,
    CA_MEDIA_STOP_RSP = 0x1000B017,
    CA_MEDIA_STOP_RPT = 0x2000B017
};

/**
 * 인식 서비스인가 / 합성 서비스인가?
**/
enum RESOURCE_TYPE{
    ASR_RES_TYPE,
    TTS_RES_TYPE,
};

/** 
 *network 망 타입
**/
enum NETWORK_TYPE{
    WIFI_NET_TYPE,
    CDMA3G_NET_TYPE,
    WIBRO_NET_TYPE,
    CDMA4G_NET_TYPE
};

/**
 * 인식기에서 서버에 전송할 contents type
**/
enum CONTENT_TYPE{
    ADDRBOOK_CONT_TYPE,
    VOICE_CONT_TYPE,
    ADDR_VOICE_CONT_TYPE,
    TEXT_CONT_TYPE,
};

enum VOICE_FORMAT_TYPE{
    PCM_FORMAT_TYPE = 1,
    FEATURE_FORMAT_TYPE,
};

enum COMPRESS_TYPE{
    NONE_COMPRESS_TYPE,
    SPEEX_COMPRESS_TYPE,
    DSR_COMPRESS_TYPE,
    FALC_COMPRESS_TYPE
};

enum SAMPLING_TYPE{
    SAMPLING_8K_TYPE = 8,
    SAMPLING_16K_TYPE = 16,
};


/**
 * Packet to Object
 *
 * Network packet으로 송수신하기 위한 자료 처리 클래스로 CAData로부터 상속
 * 
 * 서버로부터 수신된 패킷이나 서버로 송신할 패킷들은 모두 CAParser를 거치도록 한다.
 *
 * CAParser.h , CAParser.m 파일은 송신 패킷 전용 처리 작업 소스
**/
@interface CAParser : CAData {
    NSInteger random;
}

+(id)sharedParser;

/**
 *  unique id 생성용 함수를 포함한다.
 *  MSG_HEAD 의 unSeqID 값을 generation하기 위한 ....
 **/
-(NSInteger)random;
-(void)setRandom:(NSInteger)seed;


-(NSUInteger)getHeaderLength;
-(NSData*)getHeader;
-(void)setHeader:(NSDictionary*)payload;
-(void)putHeader:(NSData*)payload;

-(NSUInteger)getDataLength:(NSUInteger)tag;
-(NSData*)getData:(NSUInteger)tag;
-(NSData*)getDataWithHeader:(NSUInteger)tag;
-(void)setData:(NSDictionary*)payload Tag:(NSUInteger)tag;
-(void)putData:(NSData*)payload Tag:(NSUInteger)tag;


@end
