//
//  CAData.h
//  VoiceAssist
//
//  Created by infinity on 11. 4. 8..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "camsg_daf.h"


/**
 * Packet to Object
 *
 * Network packet의 byte나 structure와 같은 C data을
 * Object-C variant 로 저장하거나 추출할 수 있도록 하기 위한 interface
 * 
 * 상위 클래스로 패킷 수신단의 정보 추출 함수만 정의한다.
**/

@interface CAData : NSObject {
    _CA_MSG  msg;
    
    
}
@property (readwrite) _CA_MSG  msg;

/**
 *  camsg_daf.h의 각 structure name이 getXXXXXX 함수명
 *  해당 structure의 변수 name이 field로 사용되는 key value
**/
-(id) getHeader:(NSString *)field;
-(id) getSvcReq:(NSString *)field;
-(id) getSvcRsp:(NSString *)field;
-(id) getSvcRpt:(NSString *)field;
-(id) getInfoRpt:(NSString*)field;
-(id) getEndRpt:(NSString *)field;
-(id) getConRpt:(NSString *)field;

-(id) getMediaReq:(NSString*)field;
-(id) getMediaRsp:(NSString*)field;
-(id) getMediaRpt:(NSString*)field;
@end
